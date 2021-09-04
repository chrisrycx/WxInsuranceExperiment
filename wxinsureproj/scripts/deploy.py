'''
Initial script for test deployment of wxinsure
'''

from brownie import *

def main():
    '''
    Main function for use when calling from brownie console
    '''
    #Deploy the provider and propose a contract
    insurance = InsuranceProvider.deploy({'from':accounts[0]})
    tx_propose = insurance.proposeContract('3 ether','1.5 ether',200,{'from':accounts[1],'value':'1.51 ether'})
    print(tx_propose.events)

    #Accept the contract
    tx_accept = insurance.acceptContract(1,{'from':accounts[2],'value':'3 ether'})
    print(tx_accept.events)

    #Load the new contract into an object
    WxContract.at(tx_accept.new_contracts[0])

    print('Current contract balance: {}'.format(web3.fromWei(insurance.balance(),'ether')))
    print('Current total fees: {}'.format(web3.fromWei(insurance.total_fees(),'ether')))

    #Set the measured temperature
    WxContract[0].setTemp(215,{'from':accounts[0]})

