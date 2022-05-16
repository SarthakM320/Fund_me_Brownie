// SPDX-License-Identifier: MIT

pragma solidity >=0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    address public owner;
    mapping(address=>uint256) public addressToAmountFunded;
    address[] public funders;
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed ){
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

   function fund() public payable {
    	// 18 digit number to be compared with donated amount 
        uint256 minimumUSD = 50 * 10 ** 18;
        //is the donated amount less than 50USD?
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
        //if not, add to mapping and funders array
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }   
    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethprice = getPrice();
        uint256 ethAmountInUSD = (ethprice*ethAmount)/1000000000000000000;
        return ethAmountInUSD;
    }
    function getVersion() public view returns (uint256){
        return priceFeed.version();
    }
    function getPrice() public view returns(uint256){
        (,int256 answer,,,)= priceFeed.latestRoundData();
        return uint256(answer * 10000000000) ;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    function getEntranceFee() public view returns(uint256){
        //minimum USD 
        uint256 minimum = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1* 10**18;
        return (minimum*precision)/price;
    }
    function withdraw() payable onlyOwner public {
    
    	// If you are using version eight (v0.8) of chainlink aggregator interface,
        // you will need to change the code below to
        payable(msg.sender).transfer(address(this).balance);
        // msg.sender.transfer(address(this).balance);

        
        //iterate through all the mappings and make them 0
        //since all the deposited amount has been withdrawn
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        //funders array will be initialized to 0
        funders = new address[](0);
    }


}
