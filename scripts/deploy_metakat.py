from scripts.helpful_scripts import get_account
from brownie import Metakat


def deploy_metakat():
    account = get_account()
    metakat = Metakat.deploy({"from": account})
    print("Metakat deployed")

    return metakat
