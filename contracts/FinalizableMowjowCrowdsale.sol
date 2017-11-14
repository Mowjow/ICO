pragma solidity ^0.4.11;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol"; 
import "zeppelin-solidity/contracts/crowdsale/FinalizableCrowdsale.sol";


/**
 * @title FinalizableMowjowCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
*/
contract FinalizableMowjowCrowdsale is Ownable { 
    using SafeMath for uint256;

    bool public isFinalized = false;

    event Finalized();

    /**
    * @dev Must be called after crowdsale ends, to do some extra finalization
    * work. Calls the contract's finalization function.
    */
    function finalize() onlyOwner public {  
    }

    /**
    * @dev Can be overridden to add finalization logic. The overriding function
    * should call super.finalization() to ensure the chain of finalization is
    * executed entirely.
    */
    function finalization() internal {
    }
}