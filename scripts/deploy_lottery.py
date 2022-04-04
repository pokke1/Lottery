from tracemalloc import start
from turtle import st
from webbrowser import get
from scripts.helpful_scripts import get_account, get_second_account
from scripts.deploy_metakat import deploy_metakat
from brownie import Lottery, Metakat, LotteryTicket


def main():
    pass
    # metakat = deploy_metakat()
    # deploy_lottery(metakat)
    # start_lottery()
    # enter_lottery2(100)
    # enter_lottery(10
    # end_lottery()
    # get_state()


# Remember to change constructor for VRFcordinator when deploying on bsc main-net
def deploy_lottery(_metakat):
    account = get_account()
    metakat = Metakat[-1]
    ticket = LotteryTicket.deploy(
        "Lottery Ticket", "Ticket", metakat.address, {"from": account}
    )

    print("Lottery Ticket deployed")
    tx = metakat.excludeFromFee(ticket.address)
    tx.wait(1)
    print("Ticket  excluded from metakat fee")
    lottery = Lottery.deploy(
        metakat.address,
        ticket.address,
        "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C",
        "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06",
        10**17,
        "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186",
        {"from": account},
    )

    print("Deployed lottery!")
    transfer_ownership = ticket.transferOwnership(lottery.address, {"from": account})
    transfer_ownership.wait(1)
    print("Ownership has been trasnfered succesfully!")

    metakat.transfer(lottery.address, 1000000 * 10**9, {"from": account})

    return lottery, ticket


def start_lottery():
    lottery = Lottery[-1]
    account = get_account()
    tx = lottery.startLottery({"from": account})
    tx.wait(1)
    print({lottery.lottery_state()})
    return tx


def enter_lottery(_entries):
    account = get_account()
    metakat = Metakat[-1]
    lottery = Lottery[-1]
    ticket = LotteryTicket[-1]
    metakat.approve(ticket.address, _entries * ticket.ticketCost(), {"from": account})
    ticket.buyTicket(_entries, {"from": account})
    ticket.approve(lottery.address, _entries, {"from": account})
    lottery.enterLottery(_entries, {"from": account})


def enter_lottery2(_entries):
    account = get_account()
    account2 = get_second_account()
    lottery = Lottery[-1]
    ticket = LotteryTicket[-1]
    lottery.sendFreeTicket(account2.address, _entries, {"from": account})
    ticket.approve(lottery.address, _entries, {"from": account2})
    lottery.enterLottery(_entries, {"from": account2})


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
