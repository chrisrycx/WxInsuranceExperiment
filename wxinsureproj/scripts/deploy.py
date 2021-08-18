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
    insurance.proposeContract('1 ether','0.01 ether',200,200,{'from':accounts[0],'value':'0.02 ether'})
    insurance.proposals(1)

    #Accept the contract
    tx_accept = insurance.acceptContract(1,{'from':accounts[1],'value':'1 ether'})
    tx_accept.events

