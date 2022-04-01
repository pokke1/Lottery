from scripts.helpful_scripts import get_account
from brownie import Metakat, LotteryTicket


def main():
    deploy_lottery_ticket()


def deploy_lottery_ticket():
    account = get_account()
    metakat = Metakat[-1]
    ticket = LotteryTicket.deploy("Ticket", "TKT", metakat.address, {"from": account})
    ticket.wait(1)
    tx = ticket.sendFreeTicket(account.address, 1)
