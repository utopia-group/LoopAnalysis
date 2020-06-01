pragma solidity ^0.4.18;

/*
    Copyright 2017-2018 Phillip A. Elsasser

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/


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
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


contract UpgradeableTarget {
    function upgradeFrom(address from, uint256 value) external; // note: implementation should require(from == oldToken)
}


contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    require(_value <= balances[msg.sender]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    address burner = msg.sender;
    balances[burner] = balances[burner].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    Burn(burner, _value);
    Transfer(burner, address(0), _value);
  }
}

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

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}



/// @title Upgradeable Token
/// @notice allows for us to update some of the needed functionality in our tokens post deployment. Inspiration taken
/// from Golems migrate functionality.
/// @author Phil Elsasser <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f7879f9e9bb79a96859c9283878598839894989bd99e98">[email protected]</a>&gt;&#13;
contract UpgradeableToken is Ownable, BurnableToken, StandardToken {&#13;
&#13;
    address public upgradeableTarget;       // contract address handling upgrade&#13;
    uint256 public totalUpgraded;           // total token amount already upgraded&#13;
&#13;
    event Upgraded(address indexed from, address indexed to, uint256 value);&#13;
&#13;
    /*&#13;
    // EXTERNAL METHODS - TOKEN UPGRADE SUPPORT&#13;
    */&#13;
&#13;
    /// @notice Update token to the new upgraded token&#13;
    /// @param value The amount of token to be migrated to upgraded token&#13;
    function upgrade(uint256 value) external {&#13;
        require(upgradeableTarget != address(0));&#13;
&#13;
        burn(value);                    // burn tokens as we migrate them.&#13;
        totalUpgraded = totalUpgraded.add(value);&#13;
&#13;
        UpgradeableTarget(upgradeableTarget).upgradeFrom(msg.sender, value);&#13;
        Upgraded(msg.sender, upgradeableTarget, value);&#13;
    }&#13;
&#13;
    /// @notice Set address of upgrade target process.&#13;
    /// @param upgradeAddress The address of the UpgradeableTarget contract.&#13;
    function setUpgradeableTarget(address upgradeAddress) external onlyOwner {&#13;
        upgradeableTarget = upgradeAddress;&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
/// @title Market Token&#13;
/// @notice Our membership token.  Users must lock tokens to enable trading for a given Market Contract&#13;
/// as well as have a minimum balance of tokens to create new Market Contracts.&#13;
/// @author Phil Elsasser &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="dbabb3b2b79bb6baa9b0beafaba9b4afb4b8b4b7f5b2b4">[email protected]</a>&gt;&#13;
contract MarketToken is UpgradeableToken {&#13;
&#13;
    string public constant name = "MARKET Protocol Token";&#13;
    string public constant symbol = "MKT";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    uint public constant INITIAL_SUPPLY = 600000000 * 10**uint(decimals); // 600 million tokens with 18 decimals (6e+26)&#13;
&#13;
    uint public lockQtyToAllowTrading;&#13;
    uint public minBalanceToAllowContractCreation;&#13;
&#13;
    mapping(address =&gt; mapping(address =&gt; uint)) contractAddressToUserAddressToQtyLocked;&#13;
&#13;
    event UpdatedUserLockedBalance(address indexed contractAddress, address indexed userAddress, uint balance);&#13;
&#13;
    function MarketToken(uint qtyToLockForTrading, uint minBalanceForCreation) public {&#13;
        lockQtyToAllowTrading = qtyToLockForTrading;&#13;
        minBalanceToAllowContractCreation = minBalanceForCreation;&#13;
        totalSupply_ = INITIAL_SUPPLY;  //note totalSupply_ and INITIAL_SUPPLY may vary as token's are burnt.&#13;
&#13;
        balances[msg.sender] = INITIAL_SUPPLY; // for now allocate all tokens to creator&#13;
    }&#13;
&#13;
    /*&#13;
    // EXTERNAL METHODS&#13;
    */&#13;
&#13;
    /// @notice checks if a user address has locked the needed qty to allow trading to a given contract address&#13;
    /// @param marketContractAddress address of the MarketContract&#13;
    /// @param userAddress address of the user&#13;
    /// @return true if user has locked tokens to trade the supplied marketContractAddress&#13;
    function isUserEnabledForContract(address marketContractAddress, address userAddress) external view returns (bool) {&#13;
        return contractAddressToUserAddressToQtyLocked[marketContractAddress][userAddress] &gt;= lockQtyToAllowTrading;&#13;
    }&#13;
&#13;
    /// @notice checks if a user address has enough token balance to be eligible to create a contract&#13;
    /// @param userAddress address of the user&#13;
    /// @return true if user has sufficient balance of tokens&#13;
    function isBalanceSufficientForContractCreation(address userAddress) external view returns (bool) {&#13;
        return balances[userAddress] &gt;= minBalanceToAllowContractCreation;&#13;
    }&#13;
&#13;
    /// @notice allows user to lock tokens to enable trading for a given market contract&#13;
    /// @param marketContractAddress address of the MarketContract&#13;
    /// @param qtyToLock desired qty of tokens to lock&#13;
    function lockTokensForTradingMarketContract(address marketContractAddress, uint qtyToLock) external {&#13;
        uint256 lockedBalance = contractAddressToUserAddressToQtyLocked[marketContractAddress][msg.sender].add(&#13;
            qtyToLock&#13;
        );&#13;
        transfer(this, qtyToLock);&#13;
        contractAddressToUserAddressToQtyLocked[marketContractAddress][msg.sender] = lockedBalance;&#13;
        UpdatedUserLockedBalance(marketContractAddress, msg.sender, lockedBalance);&#13;
    }&#13;
&#13;
    /// @notice allows user to unlock tokens previously allocated to trading a MarketContract&#13;
    /// @param marketContractAddress address of the MarketContract&#13;
    /// @param qtyToUnlock desired qty of tokens to unlock&#13;
    function unlockTokens(address marketContractAddress, uint qtyToUnlock) external {&#13;
        uint256 balanceAfterUnLock = contractAddressToUserAddressToQtyLocked[marketContractAddress][msg.sender].sub(&#13;
            qtyToUnlock&#13;
        );  // no need to check balance, sub() will ensure sufficient balance to unlock!&#13;
        contractAddressToUserAddressToQtyLocked[marketContractAddress][msg.sender] = balanceAfterUnLock;        // update balance before external call!&#13;
        transferLockedTokensBackToUser(qtyToUnlock);&#13;
        UpdatedUserLockedBalance(marketContractAddress, msg.sender, balanceAfterUnLock);&#13;
    }&#13;
&#13;
    /// @notice get the currently locked balance for a user given the specific contract address&#13;
    /// @param marketContractAddress address of the MarketContract&#13;
    /// @param userAddress address of the user&#13;
    /// @return the locked balance&#13;
    function getLockedBalanceForUser(address marketContractAddress, address userAddress) external view returns (uint) {&#13;
        return contractAddressToUserAddressToQtyLocked[marketContractAddress][userAddress];&#13;
    }&#13;
&#13;
    /*&#13;
    // EXTERNAL - ONLY CREATOR  METHODS&#13;
    */&#13;
&#13;
    /// @notice allows the creator to set the qty each user address needs to lock in&#13;
    /// order to trade a given MarketContract&#13;
    /// @param qtyToLock qty needed to enable trading&#13;
    function setLockQtyToAllowTrading(uint qtyToLock) external onlyOwner {&#13;
        lockQtyToAllowTrading = qtyToLock;&#13;
    }&#13;
&#13;
    /// @notice allows the creator to set minimum balance a user must have in order to create MarketContracts&#13;
    /// @param minBalance balance to enable contract creation&#13;
    function setMinBalanceForContractCreation(uint minBalance) external onlyOwner {&#13;
        minBalanceToAllowContractCreation = minBalance;&#13;
    }&#13;
&#13;
    /*&#13;
    // PRIVATE METHODS&#13;
    */&#13;
&#13;
    /// @dev returns locked balance from this contract to the user's balance&#13;
    /// @param qtyToUnlock qty to return to user's balance&#13;
    function transferLockedTokensBackToUser(uint qtyToUnlock) private {&#13;
        balances[this] = balances[this].sub(qtyToUnlock);&#13;
        balances[msg.sender] = balances[msg.sender].add(qtyToUnlock);&#13;
        Transfer(this, msg.sender, qtyToUnlock);&#13;
    }&#13;
}