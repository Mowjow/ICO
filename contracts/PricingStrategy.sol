pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
/*
*  @title PricingStrategy
*  An abstract class for all Pricing Strategy contracts.
*/
contract PricingStrategy is Ownable {
    uint public endTime;
    address crowdsale;

    /*
    * @dev Number sold tokens for current strategy
    */
    uint256 public totalSoldTokens = 0;

    modifier onlyCrowdsale {
        require(crowdsale == msg.sender);
        _;
    }

    function setCrowdsaleAddress(address _crowdsale) public onlyOwner {
        crowdsale = _crowdsale;
    }

    /*
    * @dev Count number of tokens with bonuses
    * @param _value uint256 Value in ether from investor
    * @return uint256 Return number of tokens for investor
    */
    function countTokens(uint256 _value) public onlyCrowdsale returns (uint256 tokensAndBonus);

    /*
    * @dev Summing sold of tokens
    * @param _tokensAndBonus uint256 Number tokens for current sale in a tranche
    */
    function soldInTranche(uint256 _tokensAndBonus) internal;

    /*
    * @dev Check required of tokens in the tranche
    * @param _requiredTokens uint256 Number required of tokens
    * @return boolean Return true if count of tokens is available
    */
    function getFreeTokensInTranche(uint256 _requiredTokens) internal constant returns (bool);

    function isNoEmptyTranches() public constant returns(bool);

    function setEndDate(uint _endTime) public onlyOwner {
        endTime = _endTime;
    }
}
