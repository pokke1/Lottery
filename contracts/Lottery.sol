// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Lottery is VRFConsumerBase, Ownable {
    IERC20 public metakatToken;
    IERC20 public Ticket;

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
        Ticket = IERC20(_ticket);
        metakatToken = IERC20(_metakatTokenAddress);
    }

    function getPrizeValue() public view returns (uint256) {
        return metakatToken.balanceOf(address(this));
    }

    function getNumberOfPlayers() public view returns (uint256) {
        return players.length;
    }

    function enterLottery() public {
        require(Ticket.balanceOf(msg.sender) >= 10**18, "Insufficient Balance");
        require(lottery_state == LOTTERY_STATE.OPEN, "Lottery not opened yet!");
        Ticket.transferFrom(msg.sender, address(this), 10**18);
        players.push(msg.sender);
    }

    function startLottery() public onlyOwner {
        require(
            lottery_state == LOTTERY_STATE.CLOSED,
            "Can't start a new lottery yet!"
        );
        lottery_state = LOTTERY_STATE.OPEN;
    }

    function endLottery() public onlyOwner returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        lottery_state = LOTTERY_STATE.CALCULATING_WINNER;
        multiplier =
            metakatToken.balanceOf(address(this)) /
            Ticket.ticket_cost();
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
        if (indexOfWinner < players.length){
            recentWinner = players[indexOfWinner];
            metakatToken.transfer(
                recentWinner,
                metakatToken.balanceOf(address(this))
            )};

        // Reset
        players = new address[](0);
        multiplier = 0;
        lottery_state = LOTTERY_STATE.CLOSED;
        randomness = _randomness;
    }
}
