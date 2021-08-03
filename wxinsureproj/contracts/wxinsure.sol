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

contract InsuranceProvider {
    //Creates simple weather insurance by pairing insurers and insurees

    uint public constant CONTRACT_FEE = 0.01 ether;  //Fee for creating the contract in ETH
    uint public num_proposals = 0;
    struct contractSetting{
        uint coverage; //In ETH
        uint premium; //In ETH
        uint16 day; //Julian Day
        uint16 year;
        uint16 temperature; //Kelvin
    }
    mapping(uint => contractSetting) public proposals;

    function proposeContract(uint coverage, uint premium, uint16 day, uint16 temperature) public payable returns (uint proposalid) {
        require(msg.value > premium + CONTRACT_FEE);
        proposalid = num_proposals++;
        proposals[proposalid] = contractSetting(coverage,premium,day,2021,temperature);
        return proposalid;
    }

    //function acceptContract(contractid)

    //function cancelContract(contractid)

    //function withdraw()
    
    
}