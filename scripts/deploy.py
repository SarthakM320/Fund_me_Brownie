from brownie import FundMe,MockV3Aggregator, network, accounts,config
from scripts.helpful_scripts import get_account, deploy_mocks, LOCAL_BLOCKCHAIN_ENIVIRONMENTS
from web3 import Web3



def deploy_fund_me():
    account = get_account()
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENIVIRONMENTS:
        price_feed = config['networks'][network.show_active()]['eth_usd_price_feed']
    else:
        mock = deploy_mocks()
        price_feed = mock.address
    fund_me = FundMe.deploy(price_feed,{'from':account},publish_source=config['networks'][network.show_active()].get("verify"))
    print(f'Contract deployed to {fund_me.address}')
    return fund_me





def main():
    deploy_fund_me()