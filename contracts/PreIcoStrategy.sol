pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./PricingStrategy.sol";

contract PreIcoStrategy is PricingStrategy {
    using SafeMath for uint256;

    uint256 public rate;
    uint256 public bonus;
    uint256 public maxCap;

    /*
    * @dev event after counting tokens of a investor
    */
    event TokenForPreIcoInvestor(uint256 _token, uint256 _tokenAndBonus, uint256 bonusRate);

    /*
    * @dev Constructor
    */
    function PreIcoStrategy(uint256 _bonus, uint256 _maxCap, uint256 _rate) public {
        bonus = _bonus;
        maxCap = _maxCap;
        rate = _rate;
    }


    /*
    * @dev Count number of tokens with bonuses
    * @return uint256 Return number of tokens for an investor
    */
    function countTokens(uint256 _value) public onlyCrowdsale returns (uint256 tokensAndBonus) {
        uint256 etherInWei = 1e18;
        uint256 val = _value.mul(etherInWei);
        uint256 oneTokenInWei = etherInWei.div(rate);
        uint256 tokens = val.div(oneTokenInWei);
        uint256 bonusToken = tokens.mul(bonus).div(100);
        uint256 freeTokens = getUnSoldTokens();
        tokensAndBonus = tokens.add(bonusToken);

        if(freeTokens >= tokensAndBonus) {
            soldInTranche(tokensAndBonus);
            TokenForPreIcoInvestor(tokens, tokensAndBonus, rate);
        } else {
            require(false);
        }

        return tokensAndBonus;
    }

    /*
    * @dev Check required of tokens in the tranche
    * @param _requiredTokens uint256 Number of tokens
    * @return boolean Return true if count of tokens is available
    */
    function getFreeTokensInTranche(uint256 requiredTokens) internal constant returns (bool) {
        return (maxCap - totalSoldTokens) >= requiredTokens;
    }

    /*
    * @dev Calculate unsold tokens
    */
    function getUnSoldTokens() public constant returns (uint256) {
        return maxCap - totalSoldTokens;
    }

    /*
    * @dev Check available tokens for sale
    */
    function isNoEmptyTranches() public constant returns(bool) {
        uint256 availableTokens = maxCap - totalSoldTokens;
        return availableTokens > 0 && now <= endTime;
    }

    /*
    * @dev Summing sold tokens
    */
    function soldInTranche(uint256 tokens) internal {
        totalSoldTokens = totalSoldTokens.add(tokens);
    }
}
