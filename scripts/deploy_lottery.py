from tracemalloc import start
from turtle import st
from webbrowser import get
from scripts.helpful_scripts import get_account, get_second_account

from brownie import Lottery, LotteryTicket


def main():
    pass


def deploy_lottery(_metakat_address):
    account = get_account()
    ticket = LotteryTicket.deploy(
        "Lottery Ticket", "Ticket", _metakat_address, {"from": account}
    )

    print("Lottery Ticket deployed")

    lottery = Lottery.deploy(
        _metakat_address,
        ticket.address,
        "0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31",
        "0x404460C6A5EdE2D891e8297795264fDe62ADBB75",
        2 * 10**17,
        "0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c",
        {"from": account},
    )
    print("Deployed lottery!")
    transfer_ownership = ticket.transferOwnership(lottery.address, {"from": account})
    transfer_ownership.wait(1)
    print("Ownership has been trasnfered succesfully!")

    return lottery, ticket

    # tx = metakat.excludeFromFee(ticket.address)
    # metakat.transfer(lottery.address, 1000000 * 10**9, {"from": account})


def start_lottery():
    lottery = Lottery[-1]
    account = get_account()
    tx = lottery.startLottery({"from": account})
    tx.wait(1)
    print({lottery.lottery_state()})
    return tx


def end_lottery():
    account = get_account()
    lottery = Lottery[-1]
    print(f"Current prize for winner : {lottery.getPrizeValue()}")
    print(f"Current multiplier : {lottery.multiplier()}")
    print(f"Number of players ---> {lottery.getNumberOfPlayers()}")
    tx = lottery.endLottery({"from": account})
    tx.wait(5)
    print(f"And the winnner is {lottery.recentWinner()}")
    print(f"with Index {lottery.indexOfWinner()}")
