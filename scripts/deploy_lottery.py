from re import L

from eth_account import Account

from scripts.helpful_scripts import get_account, get_second_account

from brownie import Lottery, LotteryTicket, Metakat, network


def main():
    metakat = get_metakat()
    if network.show_active() == "bsc-test":
        account = get_second_account()
    elif network.show_active() == "bsc-main":
        account = get_account()
    ticket = deploy_ticket(account, metakat)
    lottery = deploy_lottery(ticket, metakat, account)
    set_up(ticket, lottery, account, metakat)


def deploy_lottery(_ticket, _metakat, _account):

    if network.show_active() == "bsc-test":
        lottery = Lottery.deploy(
            _metakat.address,
            _ticket.address,
            "0xa555fC018435bef5A13C6c6870a9d4C11DEC329C",
            "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06",
            10**17,
            "0xcaf3c3727e033261d383b315559476f48034c13b18f8cafed4d871abe5049186",
            {"from": _account},
        )

    elif network.show_active() == "bsc-main":

        lottery = Lottery.deploy(
            _metakat.address,
            _ticket.address,
            "0x747973a5A2a4Ae1D3a8fDF5479f1514F65Db9C31",
            "0x404460C6A5EdE2D891e8297795264fDe62ADBB75",
            2 * 10**17,
            "0xc251acd21ec4fb7f31bb8868288bfdbaeb4fbfec2df3735ddbd4f7dc8d60103c",
            {"from": _account},
        )
    return lottery


def set_up(_ticket, _lottery, _account, _metakat):
    _ticket.transferOwnership(_lottery.address, {"from": _account})
    _metakat.excludeFromFee(_ticket.address, {"from": _account})
    _metakat.transfer(_lottery.address, 150000000 * 10**9, {"from": _account})


def get_metakat():
    if network.show_active() == "bsc-test":

        metakat = Metakat.at("0x0FD3ceB1724adc176c1bE7BEe38547587C351669")
    elif network.show_active() == "bsc-main":
        metakat = Metakat.at("0xAE8e248f75C1D0e75476A3820B819dFB86Ea16D8")
    return metakat


def deploy_ticket(_account, _metakat):

    ticket = LotteryTicket.deploy(
        "Lottery Ticket", "Lottery Ticket", _metakat.address, {"from": _account}
    )
    return ticket


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
    print(f"Number of entries ---> {lottery.getNumberOfPlayers()}")
    tx = lottery.endLottery({"from": account})
    tx.wait(5)
    print(f"And the winnner is {lottery.recentWinner()}")
    print(f"with Index {lottery.indexOfWinner()}")
