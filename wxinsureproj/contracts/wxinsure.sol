// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

//Experimental Weather Insurance contract

/*
import "chainlink/contracts/ChainlinkClient.sol";
import "chainlink/contracts/vendor/Ownable.sol";
import "chainlink/contracts/interfaces/LinkTokenInterface.sol";
import "chainlink/contracts/interfaces/AggregatorInterface.sol";
import "chainlink/contracts/vendor/SafeMathChainlink.sol";
import "chainlink/contracts/interfaces/AggregatorV3Interface.sol";
*/
//import "wxcontract.sol";

contract WxContract {
    uint total_fund = 0;  //GWEI
    address payable public insured;
    address payable public insurer;
    uint premium;
    uint coverage;

    constructor(address payable _insured,address payable _insurer,uint _premium,uint _coverage) payable {
        insured = _insured;
        insurer = _insurer;
        premium = _premium;
        coverage = _coverage;
    }

    function claim() public {
        require((msg.sender==insured)||(msg.sender==insurer),"Not party to insurance contract");

        if(msg.sender==insured){
            msg.sender.transfer(coverage);
        }else{
            msg.sender.transfer(coverage + premium);
        }
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
    event newProposal(uint proposalID, uint16 _temperature, uint _coverage);
    event newContract();

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
        uint funds = proposals[proposalid].coverage + proposals[proposalid].premium;
        WxContract _wxcontract = new WxContract {value:funds}(
            proposals[proposalid].insured,
            msg.sender,
            proposals[proposalid].premium,
            proposals[proposalid].coverage
            );
        emit newContract();
    }

    //function cancelContract(contractid)

    //function withdraw()
    
    
}