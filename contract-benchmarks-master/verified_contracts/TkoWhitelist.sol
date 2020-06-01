pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/// @title Whitelist for TKO token sale.
/// @author Takeoff Technology OU - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c3aaada5ac83b7a2a8a6aca5a5edb4b0">[email protected]</a>&gt;&#13;
/// @dev Based on code by OpenZeppelin's WhitelistedCrowdsale.sol&#13;
contract TkoWhitelist is Ownable{&#13;
&#13;
    using SafeMath for uint256;&#13;
&#13;
    // Manage whitelist account address.&#13;
    address public admin;&#13;
&#13;
    mapping(address =&gt; uint256) internal totalIndividualWeiAmount;&#13;
    mapping(address =&gt; bool) internal whitelist;&#13;
&#13;
    event AdminChanged(address indexed previousAdmin, address indexed newAdmin);&#13;
&#13;
&#13;
    /**&#13;
     * TkoWhitelist&#13;
     * @dev TkoWhitelist is the storage for whitelist and total amount by contributor's address.&#13;
     * @param _admin Address of managing whitelist.&#13;
     */&#13;
    function TkoWhitelist (address _admin) public {&#13;
        require(_admin != address(0));&#13;
        admin = _admin;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Throws if called by any account other than the owner or the admin.&#13;
     */&#13;
    modifier onlyOwnerOrAdmin() {&#13;
        require(msg.sender == owner || msg.sender == admin);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Allows the current owner to change administrator account of the contract to a newAdmin.&#13;
     * @param newAdmin The address to transfer ownership to.&#13;
     */&#13;
    function changeAdmin(address newAdmin) public onlyOwner {&#13;
        require(newAdmin != address(0));&#13;
        emit AdminChanged(admin, newAdmin);&#13;
        admin = newAdmin;&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
      * @dev Returen whether the beneficiary is whitelisted.&#13;
      */&#13;
    function isWhitelisted(address _beneficiary) external view onlyOwnerOrAdmin returns (bool) {&#13;
        return whitelist[_beneficiary];&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Adds single address to whitelist.&#13;
     * @param _beneficiary Address to be added to the whitelist&#13;
     */&#13;
    function addToWhitelist(address _beneficiary) external onlyOwnerOrAdmin {&#13;
        whitelist[_beneficiary] = true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Adds list of addresses to whitelist.&#13;
     * @param _beneficiaries Addresses to be added to the whitelist&#13;
     */&#13;
    function addManyToWhitelist(address[] _beneficiaries) external onlyOwnerOrAdmin {&#13;
        for (uint256 i = 0; i &lt; _beneficiaries.length; i++) {&#13;
            whitelist[_beneficiaries[i]] = true;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Removes single address from whitelist.&#13;
     * @param _beneficiary Address to be removed to the whitelist&#13;
     */&#13;
    function removeFromWhitelist(address _beneficiary) external onlyOwnerOrAdmin {&#13;
        whitelist[_beneficiary] = false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Return total individual wei amount.&#13;
     * @param _beneficiary Addresses to get total wei amount .&#13;
     * @return Total wei amount for the address.&#13;
     */&#13;
    function getTotalIndividualWeiAmount(address _beneficiary) external view onlyOwnerOrAdmin returns (uint256) {&#13;
        return totalIndividualWeiAmount[_beneficiary];&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Set total individual wei amount.&#13;
     * @param _beneficiary Addresses to set total wei amount.&#13;
     * @param _totalWeiAmount Total wei amount for the address.&#13;
     */&#13;
    function setTotalIndividualWeiAmount(address _beneficiary,uint256 _totalWeiAmount) external onlyOwner {&#13;
        totalIndividualWeiAmount[_beneficiary] = _totalWeiAmount;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Add total individual wei amount.&#13;
     * @param _beneficiary Addresses to add total wei amount.&#13;
     * @param _weiAmount Total wei amount to be added for the address.&#13;
     */&#13;
    function addTotalIndividualWeiAmount(address _beneficiary,uint256 _weiAmount) external onlyOwner {&#13;
        totalIndividualWeiAmount[_beneficiary] = totalIndividualWeiAmount[_beneficiary].add(_weiAmount);&#13;
    }&#13;
&#13;
}