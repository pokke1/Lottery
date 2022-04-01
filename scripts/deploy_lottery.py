from scripts.helpful_scripts import get_account
from scripts.deploy_metakat import deploy_metakat
from brownie import Lottery, Metakat, LotteryTicket


def main():
    metakat = deploy_metakat()
    deploy_lottery(metakat)


# Remember to change constructor for VRFcordinator when deploying on bsc main-net
def deploy_lottery(_metakat):
    account = get_account()
    metakat = Metakat[_metakat]
    ticket = LotteryTicket.deploy(
        "Lottery Ticket", "Ticket", metakat.address, {"from": account}
    )
    ticket.wait(1)
    print("Lottery Ticket deployed")
    metakat.excludeFromFee(ticket.address)
    lottery = Lottery.deploy(
        metakat.address,
        ticket.address,
        "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C",
        "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06",
        10**17,
        "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186",
        {"from": account},
    )
    lottery.wait(1)
    print("Deployed lottery!")
    transfer_ownership = ticket.transferOwnership(lottery.address, {"from": account})
    transfer_ownership.wait(1)

    return lottery, ticket, transfer_ownership


def start_lottery():
    lottery = Lottery[-1]
    account = get_account()
    tx = lottery.startLottery({"from": account})
    tx.wait(1)
    print({lottery.lottery_state()})
    return tx


def enter_lottery():
    account = get_account()
    metakat = Metakat[-1]
    lottery = Lottery[-1]
    tx1 = metakat.approve(lottery.address, lottery.entry_cost(), {"from": account})
    tx1.wait(1)
    tx2 = lottery.enterLottery({"from": account})


def end_lottery():
    account = get_account()
    lottery = Lottery[-1]
    print(f"Current prize for winner : {lottery.getPrizeValue()}")
    print(f"Number of players ---> {lottery.getNumberOfPlayers()}")
    tx = lottery.endLottery({"from": account})
    print(f"And the winnner is {lottery.recentWinner()}")
    tx.wait(2)
    print(f"And the winnner is {lottery.recentWinner()}")
