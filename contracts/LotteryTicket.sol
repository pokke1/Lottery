// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LotteryTicket is ERC20, Ownable {
    IERC20 public metakatToken;
    uint256 public ticketCost;
    mapping(address => bool) public receivedFreeTicket;
    address[] receivers;
    uint256 public minimumHold;

    constructor(
        string memory name,
        string memory symbol,
        address _metakatTokenAddress
    ) ERC20(name, symbol) {
        metakatToken = IERC20(_metakatTokenAddress);

        minimumHold = 20000000 * 10**9; // 20 Milions token
        ticketCost = 100000 * 10**9; // 100k Metakat cost of tikcket
    }

    function changeTicketCost(uint256 _new_cost) public onlyOwner {
        ticketCost = _new_cost;
    }

    function changeMinimumHold(uint256 _new_hold) public onlyOwner {
        minimumHold = _new_hold;
    }

    function resetFreeTicket() public onlyOwner {
        for (uint256 i = 0; i < receivers.length; i++) {
            receivedFreeTicket[receivers[i]] = false;
        }
    }

    function sendFreeTicket(address _receiver, uint256 _amount)
        public
        onlyOwner
    {
        _mint(_receiver, _amount);
    }

    function withdrawFund(address _receiver) public onlyOwner {
        metakatToken.transfer(_receiver, metakatToken.balanceOf(address(this)));
    }

    function buyTicket() public {
        require(
            metakatToken.balanceOf(msg.sender) >= ticketCost,
            "Insufficient Balance"
        );
        metakatToken.transferFrom(msg.sender, address(this), ticketCost);
        _mint(msg.sender, 10**18);
    }

    function getFreeTicket() public {
        require(
            !receivedFreeTicket[msg.sender],
            "Free Ticket arleady collected"
        );
        require(
            metakatToken.balanceOf(msg.sender) >= minimumHold,
            "You need to hold at least 20.000.000 Metakat"
        );
        _mint(msg.sender, 10**18);
        receivedFreeTicket[msg.sender] = true;
        receivers.push(msg.sender);
    }
}
