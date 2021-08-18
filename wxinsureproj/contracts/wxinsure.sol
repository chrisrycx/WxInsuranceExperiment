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
    address insured;
    address insurer;
    uint premium;
    uint coverage;

    constructor(address _insured,address _insurer,uint _premium,uint _coverage) {
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
    struct contractSetting{
        address insured;
        uint coverage; //In ETH
        uint premium; //In ETH
        uint16 day; //Julian Day
        uint16 year;
        uint16 temperature; //Kelvin
    }
    mapping(uint => contractSetting) public proposals;
    event newContract();

    function proposeContract(uint coverage, uint premium, uint16 day, uint16 temperature) public payable returns (uint) {
        require(msg.value >= premium + CONTRACT_FEE);
        num_proposals++;
        proposals[num_proposals].insured = msg.sender;
        proposals[num_proposals].coverage = coverage;
        proposals[num_proposals].premium = premium;
        proposals[num_proposals].day = day;
        proposals[num_proposals].temperature = temperature;
        return num_proposals;
    }

    function acceptContract(uint proposalid) public payable {
        //Insurer pays accepts contract by paying coverage
        require(msg.value >= proposals[proposalid].coverage);
        WxContract _wxcontract = new WxContract(
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