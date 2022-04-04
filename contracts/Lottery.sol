// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./LotteryTicket.sol";

contract Lottery is VRFConsumerBase, Ownable {
    IERC20 public metakatToken;
    LotteryTicket public ticket;

    enum LOTTERY_STATE {
        OPEN,
        CLOSED,
        CALCULATING_WINNER
    }
    LOTTERY_STATE public lottery_state;
    address[] public players;
    address public recentWinner;
    uint256 public randomness;
    uint256 public multiplier;
    uint256 public prize;
    uint256 public fee;
    bytes32 public keyhash;

    constructor(
        address _metakatTokenAddress,
        address _ticket,
        address _vrfCoordinator,
        address _link,
        uint256 _fee,
        bytes32 _keyhash
    ) VRFConsumerBase(_vrfCoordinator, _link) {
        lottery_state = LOTTERY_STATE.CLOSED;
        fee = _fee;
        keyhash = _keyhash;
        ticket = LotteryTicket(_ticket);
        metakatToken = IERC20(_metakatTokenAddress);
    }

    function getPrizeValue() public view returns (uint256) {
        require(
            lottery_state == LOTTERY_STATE.OPEN,
            "Lottery is not opened yet"
        );
        return prize;
    }

    function getNumberOfPlayers() public view returns (uint256) {
        require(
            lottery_state == LOTTERY_STATE.OPEN,
            "Lottery is not opened yet"
        );
        return players.length;
    }

    // Now allows for multiple entries without having to call the function several times
    function enterLottery(uint256 _entries) public {
        require(
            ticket.balanceOf(msg.sender) >= _entries,
            "You need a Ticket to enter the lottery"
        );
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery not opened yet!");
        ticket.transferFrom(msg.sender, address(this), _entries);
        for (uint256 i = 0; i < _entries; i++) {
            players.push(msg.sender);
        }
    }

    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Can't start a new lottery yet!"
        );
        lottery_state = LOTTERY_STATE.OPEN;
        prize = metakatToken.balanceOf(address(this));
        multiplier = prize / ticket.ticketCost();
    }

    function endLottery() public onlyOwner returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        return requestRandomness(keyhash, fee);
    }

    function fulfillRandomness(bytes32 _requestId, uint256 _randomness)
        internal
        override
    {
        require(
            lottery_state == LOTTERY_STATE.CALCULATING_WINNER,
            "You aren't there yet!"
        );
        require(_randomness > 0, "random-not-found");

        uint256 indexOfWinner = _randomness % (players.length + multiplier);

        if (indexOfWinner < players.length) {
            recentWinner = players[indexOfWinner];
            metakatToken.transfer(recentWinner, prize);
        }

        // Reset variables and prepare for the next run
        ticket.withdrawFund();
        ticket.resetFreeTicket();
        players = new address[](0);
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
    }

    // This contract is owner of LotteryTicket.sol contract
    function changeTicketCost(uint256 _new_cost) public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Ticket cost can be changed only when lottery is closed"
        );
        ticket.changeTicketCost(_new_cost);
    }

    function changeMinimumHold(uint256 _new_hold) public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Minimum hold can be changed only when lottery is closed"
        );
        ticket.changeMinimumHold(_new_hold);
    }

    function sendFreeTicket(address _receiver, uint256 _amount)
        public
        onlyOwner
    {
        require(
            lottery_state == LOTTERY_STATE.OPEN,
            "Ticket cost must be set first, wait for lottery opening."
        );
        ticket.sendFreeTicket(_receiver, _amount);
    }

    // Add a function to withdraw the funds in case of migrations
    function migrateLottery() public onlyOwner {
        metakatToken.transfer(owner(), metakatToken.balanceOf(address(this)));
    }
}
