pragma solidity ^0.4.21;

// File: contracts/Interfaces/MasterDepositInterface.sol

/**
 * @dev Interface of MasterDeposit that should be used in child contracts 
 * @dev this ensures that no duplication of code and implicit gasprice will be used for the dynamic creation of child contract
 */
contract MasterDepositInterface {
    address public coldWallet1;
    address public coldWallet2;
    uint public percentage;
    function fireDepositToChildEvent(uint _amount) public;
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/ChildDeposit.sol

/**
* @dev Should be dinamically created from master contract 
* @dev multiple payers can contribute here 
*/
contract ChildDeposit {
    
    /**
    * @dev prevents over and under flows
    */
    using SafeMath for uint;
    
    /**
    * @dev import only the interface for low gas cost
    */
    // MasterDepositInterface public master;
    address masterAddress;

    function ChildDeposit() public {
        masterAddress = msg.sender;
        // master = MasterDepositInterface(msg.sender);
    }

    /**
    * @dev any ETH income will fire a master deposit contract event
    * @dev the redirect of ETH will be split in the two wallets provided by the master with respect to the share percentage set for wallet 1 
    */
    function() public payable {

        MasterDepositInterface master = MasterDepositInterface(masterAddress);
        // fire transfer event
        master.fireDepositToChildEvent(msg.value);

        // trasnfer of ETH
        // with respect to the percentage set
        uint coldWallet1Share = msg.value.mul(master.percentage()).div(100);
        
        // actual transfer
        master.coldWallet1().transfer(coldWallet1Share);
        master.coldWallet2().transfer(msg.value.sub(coldWallet1Share));
    }

    /**
    * @dev function that can only be called by the creator of this contract
    * @dev the actual condition of transfer is in the logic of the master contract
    * @param _value ERC20 amount 
    * @param _tokenAddress ERC20 contract address 
    * @param _destination should be onbe of the 2 coldwallets
    */
    function withdraw(address _tokenAddress, uint _value, address _destination) public onlyMaster {
        ERC20(_tokenAddress).transfer(_destination, _value);
    }

    modifier onlyMaster() {
        require(msg.sender == address(masterAddress));
        _;
    }
    
}

// File: zeppelin-solidity/contracts/ReentrancyGuard.sol

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="5321363e303c1361">[email protected]</span>Ï€.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private reentrancy_lock = false;&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * @notice If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one nonReentrant function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and a `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(!reentrancy_lock);&#13;
    reentrancy_lock = true;&#13;
    _;&#13;
    reentrancy_lock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/ownership/Ownable.sol&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
&#13;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  function Ownable() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) public onlyOwner {&#13;
    require(newOwner != address(0));&#13;
    OwnershipTransferred(owner, newOwner);&#13;
    owner = newOwner;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/ownership/Claimable.sol&#13;
&#13;
/**&#13;
 * @title Claimable&#13;
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.&#13;
 * This allows the new owner to accept the transfer.&#13;
 */&#13;
contract Claimable is Ownable {&#13;
  address public pendingOwner;&#13;
&#13;
  /**&#13;
   * @dev Modifier throws if called by any account other than the pendingOwner.&#13;
   */&#13;
  modifier onlyPendingOwner() {&#13;
    require(msg.sender == pendingOwner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to set the pendingOwner address.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) onlyOwner public {&#13;
    pendingOwner = newOwner;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the pendingOwner address to finalize the transfer.&#13;
   */&#13;
  function claimOwnership() onlyPendingOwner public {&#13;
    OwnershipTransferred(owner, pendingOwner);&#13;
    owner = pendingOwner;&#13;
    pendingOwner = address(0);&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/MasterDeposit.sol&#13;
&#13;
/**&#13;
* @dev master contract that creates ChildDeposits. Responsible for controlling and setup of deposit chain.  &#13;
* @dev all functions that should be called from child deposits are specified in the MasterDepositInterface &#13;
*/&#13;
contract MasterDeposit is MasterDepositInterface, Claimable, ReentrancyGuard {&#13;
    &#13;
    /**&#13;
    * @dev prevents over and under flows&#13;
    */&#13;
    using SafeMath for uint;&#13;
&#13;
    /**&#13;
    * @dev mapping of all created child deposits&#13;
    */&#13;
    mapping (address =&gt; bool) public childDeposits;&#13;
&#13;
    /**&#13;
    * @dev responsible for creating deposits (in this way the owner isn't exposed to a api/server security breach)&#13;
    * @dev by loosing the depositCreator key an attacker can only create deposits that will not be a real threat and another depositCreator can be allocated&#13;
    */&#13;
    address public depositCreator;&#13;
&#13;
    /**&#13;
    * @dev Fired at create time&#13;
    * @param _depositAddress blockchain address of the newly created deposit contract&#13;
    */&#13;
    event CreatedDepositEvent (&#13;
    address indexed _depositAddress&#13;
    );&#13;
    &#13;
    /**&#13;
    * @dev Fired at transfer time&#13;
    * @dev Event that signals the transfer of an ETH amount &#13;
    * @param _depositAddress blockchain address of the deposit contract that received ETH&#13;
    * @param _amount of ETH&#13;
    */&#13;
    event DepositToChildEvent(&#13;
    address indexed _depositAddress, &#13;
    uint _amount&#13;
    );&#13;
&#13;
&#13;
    /**&#13;
    * @param _wallet1 redirect of tokens (ERC20) or ETH&#13;
    * @param _wallet2 redirect of tokens (ERC20) or eth&#13;
    * @param _percentage _wallet1 split percentage &#13;
    */&#13;
    function MasterDeposit(address _wallet1, address _wallet2, uint _percentage) onlyValidPercentage(_percentage) public {&#13;
        require(_wallet1 != address(0));&#13;
        require(_wallet2 != address(0));&#13;
        percentage = _percentage;&#13;
        coldWallet1 = _wallet1;&#13;
        coldWallet2 = _wallet2;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev creates a number of instances of ChildDeposit contracts&#13;
    * @param _count creates a specified number of deposit contracts&#13;
    */&#13;
    function createChildDeposits(uint _count) public onlyDepositCreatorOrMaster {&#13;
        for (uint i = 0; i &lt; _count; i++) {&#13;
            ChildDeposit childDeposit = new ChildDeposit();&#13;
            childDeposits[address(childDeposit)] = true;&#13;
            emit CreatedDepositEvent(address(childDeposit));    &#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev setter for the address that is responsible for creating deposits &#13;
    */&#13;
    function setDepositCreator(address _depositCreator) public onlyOwner {&#13;
        require(_depositCreator != address(0));&#13;
        depositCreator = _depositCreator;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Setter for the income percentage in the first coldwallet (not setting this the second wallet will receive all income)&#13;
    */&#13;
    function setColdWallet1SplitPercentage(uint _percentage) public onlyOwner onlyValidPercentage(_percentage) {&#13;
        percentage = _percentage;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev function created to emit the ETH transfer event from the child contract only&#13;
    * @param _amount ETH amount &#13;
    */&#13;
    function fireDepositToChildEvent(uint _amount) public onlyChildContract {&#13;
        emit DepositToChildEvent(msg.sender, _amount);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev changes the coldwallet1 address&#13;
    */&#13;
    function setColdWallet1(address _coldWallet1) public onlyOwner {&#13;
        require(_coldWallet1 != address(0));&#13;
        coldWallet1 = _coldWallet1;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev changes the coldwallet2 address&#13;
    */&#13;
    function setColdWallet2(address _coldWallet2) public onlyOwner {&#13;
        require(_coldWallet2 != address(0));&#13;
        coldWallet2 = _coldWallet2;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev function that can be called only by owner due to security reasons and will withdraw the amount of ERC20 tokens&#13;
    * @dev from the deposit contract list to the cold wallets &#13;
    * @dev transfers only the ERC20 tokens, ETH should be transferred automatically&#13;
    * @param _deposits batch list with all deposit contracts that might hold ERC20 tokens&#13;
    * @param _tokenContractAddress specifies what token to be transfered form each deposit from the batch to the cold wallets&#13;
    */&#13;
    function transferTokens(address[] _deposits, address _tokenContractAddress) public onlyOwner nonReentrant {&#13;
        for (uint i = 0; i &lt; _deposits.length; i++) {&#13;
            address deposit = _deposits[i];&#13;
            uint erc20Balance = ERC20(_tokenContractAddress).balanceOf(deposit);&#13;
&#13;
            // if no balance found just skip&#13;
            if (erc20Balance == 0) {&#13;
                continue;&#13;
            }&#13;
            &#13;
            // trasnfer of erc20 tokens&#13;
            // with respect to the percentage set&#13;
            uint coldWallet1Share = erc20Balance.mul(percentage).div(100);&#13;
            uint coldWallet2Share = erc20Balance.sub(coldWallet1Share); &#13;
            ChildDeposit(deposit).withdraw(_tokenContractAddress,coldWallet1Share, coldWallet1);&#13;
            ChildDeposit(deposit).withdraw(_tokenContractAddress,coldWallet2Share, coldWallet2);&#13;
        }&#13;
    }&#13;
&#13;
    modifier onlyChildContract() {&#13;
        require(childDeposits[msg.sender]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyDepositCreatorOrMaster() {&#13;
        require(msg.sender == owner || msg.sender == depositCreator);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyValidPercentage(uint _percentage) {&#13;
        require(_percentage &gt;=0 &amp;&amp; _percentage &lt;= 100);&#13;
        _;&#13;
    }&#13;
&#13;
}