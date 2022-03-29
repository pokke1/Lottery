from scripts.helpful_scripts import get_account
from brownie import Metakat, LotteryTicket


def main():
    deploy_lottery_ticket()


def deploy_lottery_ticket():
    account = get_account()
    metakat = Metakat[-1]
    tx = LotteryTicket.deploy("Ticket", "TKT", metakat.address, {"from": account})
