// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

//Experimental Weather Insurance contract

contract WxContract {
    address oracle;  //This is the address that will provide the measured temperature
    address payable public insured;
    address payable public insurer;
    uint coverage;
    uint temperature;
    uint public measured_temperature = 0;

    constructor(address payable _insured,address payable _insurer,uint _coverage,uint _temperature,address _oracle) payable {
        insured = _insured;
        insurer = _insurer;
        coverage = _coverage;
        temperature = _temperature;
        oracle = _oracle;
    }

    function claim() public {
        require((msg.sender==insured)||(msg.sender==insurer),"Not party to insurance contract");
        require(measured_temperature != 0,"Temperature not yet measured");

        if(measured_temperature <= temperature){
            //Insurer gets premium + coverage
            insurer.transfer(coverage);
            selfdestruct(insurer);
        }else{
            //Insured gets funds
            insured.transfer(coverage);
            selfdestruct(insurer);
        }
    }

    function setTemp(uint16 _temperature) public {
        require(msg.sender==oracle,"Only oracle can set temperature");
        measured_ temperature = _temperature;
    }

}

contract InsuranceProvider {
    //Creates simple weather insurance by pairing insurers and insurees
    uint public constant CONTRACT_FEE = 0.01 ether;  //Fee for creating the contract in ETH
    uint public num_proposals = 0;
    uint public total_fees = 0; //Total fees paid into provider
    struct contractSetting{
        address payable insured;
        uint coverage; //In ETH
        uint premium; //In ETH
        uint16 temperature; //Kelvin
    }
    mapping(uint => contractSetting) public proposals;
    address oracle; //Set this to address deploying provider
    address payable owner; //Set to address deploying Provider
    event newProposal(uint proposalID, uint16 _temperature, uint _coverage);
    event newContract();

    constructor(){
        oracle = msg.sender;
        owner = msg.sender;
    }

    function proposeContract(uint coverage, uint premium, uint16 temperature) public payable {
        require(msg.value >= premium + CONTRACT_FEE);
        num_proposals++;
        proposals[num_proposals].insured = msg.sender;
        proposals[num_proposals].coverage = coverage;
        proposals[num_proposals].premium = premium;
        proposals[num_proposals].temperature = temperature;
        emit newProposal(num_proposals, temperature, coverage);
        total_fees = total_fees + 0.01 ether;
    }

    function acceptContract(uint proposalid) public payable {
        //Insurer accepts contract by paying coverage
        require(msg.value >= proposals[proposalid].coverage);
        WxContract _wxcontract = new WxContract {value:proposals[proposalid].coverage}(
            proposals[proposalid].insured,
            msg.sender,
            proposals[proposalid].coverage,
            proposals[proposalid].temperature,
            oracle
            );
        emit newContract();

        //Transfer premium to insurer
        msg.sender.transfer(proposals[proposalid].premium);
    }

    function withdrawFees() public {
        //Withdraw all Provider fees
        require(msg.sender == owner,"Only the owner can withdraw fees");
        owner.transfer(total_fees);
        total_fees = 0;
    }
    
}