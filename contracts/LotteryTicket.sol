// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract LotteryTicket is ERC20, Ownable {
    IERC20 public metakatToken;
    uint256 public ticket_cost;
    mapping(address => bool) public receivedFreeTicket;
    address[] receivers;
    uint256 public minimum_hold;

    constructor(
        string memory name,
        string memory symbol,
        address _metakatTokenAddress
    ) ERC20(name, symbol) {
        metakatToken = IERC20(_metakatTokenAddress);

        minimum_hold = 20000 * 10**9;
    }

    function changeTicketCost(uint256 _new_cost) public onlyOwner {
        ticket_cost = _new_cost;
    }

    function changeMinimumHold(uint256 _new_hold) public onlyOwner {
        minimum_hold = _new_hold;
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

    function withdrawFund() public onlyOwner {
        metakatToken.transfer(owner(), metakatToken.balanceOf(address(this)));
    }

    function buyTicket() public {
        require(
            metakatToken.balanceOf(msg.sender) >= ticket_cost,
            "Insufficient Balance"
        );
        metakatToken.transferFrom(msg.sender, address(this), ticket_cost);
        _mint(msg.sender, 10**18);
    }

    function getFreeTicket() public {
        require(
            !receivedFreeTicket[msg.sender],
            "Free Ticket arleady collected"
        );
        require(
            metakatToken.balanceOf(msg.sender) >= minimum_hold,
            "You need to hold at least 20.000 Metakat"
        );
        _mint(msg.sender, 10**18);
        receivedFreeTicket[msg.sender] = true;
        receivers.push(msg.sender);
    }
}
