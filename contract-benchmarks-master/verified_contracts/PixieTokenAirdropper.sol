pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="84f6e1e9e7ebc4b6">[email protected]</span>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be sent to this contract by:&#13;
 * calling functions labeled `payable`&#13;
 * `selfdestruct(contract_address)`&#13;
 * mining directly to the contract address&#13;
 */&#13;
contract HasNoEther is Ownable {&#13;
&#13;
  /**&#13;
  * @dev Constructor that rejects incoming Ether&#13;
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we&#13;
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable&#13;
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively&#13;
  * we could use assembly to access msg.value.&#13;
  */&#13;
  constructor() public payable {&#13;
    require(msg.value == 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Disallows direct send by settings a default function without the `payable` flag.&#13;
   */&#13;
  function() external {&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer all Ether held by the contract to the owner.&#13;
   */&#13;
  function reclaimEther() external onlyOwner {&#13;
    owner.transfer(address(this).balance);&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  function totalSupply() public view returns (uint256);&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
// File: contracts/pixie/PixieTokenAirdropper.sol&#13;
&#13;
contract PixieTokenAirdropper is Ownable, HasNoEther {&#13;
&#13;
  // The token which is already deployed to the network&#13;
  ERC20Basic public token;&#13;
&#13;
  event AirDroppedTokens(uint256 addressCount);&#13;
  event AirDrop(address indexed receiver, uint256 total);&#13;
&#13;
  // After this contract is deployed, we will grant access to this contract&#13;
  // by calling methods on the token since we are using the same owner&#13;
  // and granting the distribution of tokens to this contract&#13;
  constructor(address _token) public payable {&#13;
    require(_token != address(0), "Must be a non-zero address");&#13;
&#13;
    token = ERC20Basic(_token);&#13;
  }&#13;
&#13;
  function transfer(address[] _address, uint256[] _values) onlyOwner public {&#13;
    require(_address.length == _values.length, "Address array and values array must be same length");&#13;
&#13;
    for (uint i = 0; i &lt; _address.length; i += 1) {&#13;
      _transfer(_address[i], _values[i]);&#13;
    }&#13;
&#13;
    emit AirDroppedTokens(_address.length);&#13;
  }&#13;
&#13;
  function transferSingle(address _address, uint256 _value) onlyOwner public {&#13;
    _transfer(_address, _value);&#13;
&#13;
    emit AirDroppedTokens(1);&#13;
  }&#13;
&#13;
  function _transfer(address _address, uint256 _value) internal {&#13;
    require(_address != address(0), "Address invalid");&#13;
    require(_value &gt; 0, "Value invalid");&#13;
&#13;
    token.transfer(_address, _value);&#13;
&#13;
    emit AirDrop(_address, _value);&#13;
  }&#13;
&#13;
  function remainingBalance() public view returns (uint256) {&#13;
    return token.balanceOf(address(this));&#13;
  }&#13;
&#13;
  // after we distribute the bonus tokens, we will send them back to the coin itself&#13;
  function ownerRecoverTokens(address _beneficiary) external onlyOwner {&#13;
    require(_beneficiary != address(0));&#13;
    require(_beneficiary != address(token));&#13;
&#13;
    uint256 _tokensRemaining = token.balanceOf(address(this));&#13;
    if (_tokensRemaining &gt; 0) {&#13;
      token.transfer(_beneficiary, _tokensRemaining);&#13;
    }&#13;
  }&#13;
&#13;
}