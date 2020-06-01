pragma solidity 0.4.24;

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

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

// File: contracts/VestTokenAllocation.sol

/**
 * @title VestTokenAllocation contract
 * @author Gustavo Guimaraes - <<span class="__cf_email__" data-cfemail="bddac8cec9dccbd2dac8d4d0dccfdcd8cefddad0dcd4d193ded2d0">[email protected]</span>&gt;&#13;
 */&#13;
contract VestTokenAllocation is Ownable {&#13;
    using SafeMath for uint256;&#13;
    using SafeERC20 for ERC20;&#13;
&#13;
    uint256 public cliff;&#13;
    uint256 public start;&#13;
    uint256 public duration;&#13;
    uint256 public allocatedTokens;&#13;
    uint256 public canSelfDestruct;&#13;
&#13;
    mapping (address =&gt; uint256) public totalTokensLocked;&#13;
    mapping (address =&gt; uint256) public releasedTokens;&#13;
&#13;
    ERC20 public golix;&#13;
    address public tokenDistribution;&#13;
&#13;
    event Released(address beneficiary, uint256 amount);&#13;
&#13;
    /**&#13;
     * @dev creates the locking contract with vesting mechanism&#13;
     * as well as ability to set tokens for addresses and time contract can self-destruct&#13;
     * @param _token GolixToken address&#13;
     * @param _tokenDistribution GolixTokenDistribution contract address&#13;
     * @param _start timestamp representing the beginning of the token vesting process&#13;
     * @param _cliff duration in seconds of the cliff in which tokens will begin to vest. ie 1 year in secs&#13;
     * @param _duration time in seconds of the period in which the tokens completely vest. ie 4 years in secs&#13;
     * @param _canSelfDestruct timestamp of when contract is able to selfdestruct&#13;
     */&#13;
    function VestTokenAllocation&#13;
        (&#13;
            ERC20 _token,&#13;
            address _tokenDistribution,&#13;
            uint256 _start,&#13;
            uint256 _cliff,&#13;
            uint256 _duration,&#13;
            uint256 _canSelfDestruct&#13;
        )&#13;
        public&#13;
    {&#13;
        require(_token != address(0) &amp;&amp; _cliff != 0);&#13;
        require(_cliff &lt;= _duration);&#13;
        require(_start &gt; now);&#13;
        require(_canSelfDestruct &gt; _duration.add(_start));&#13;
&#13;
        duration = _duration;&#13;
        cliff = _start.add(_cliff);&#13;
        start = _start;&#13;
&#13;
        golix = ERC20(_token);&#13;
        tokenDistribution = _tokenDistribution;&#13;
        canSelfDestruct = _canSelfDestruct;&#13;
    }&#13;
&#13;
    modifier onlyOwnerOrTokenDistributionContract() {&#13;
        require(msg.sender == address(owner) || msg.sender == address(tokenDistribution));&#13;
        _;&#13;
    }&#13;
    /**&#13;
     * @dev Adds vested token allocation&#13;
     * @param beneficiary Ethereum address of a person&#13;
     * @param allocationValue Number of tokens allocated to person&#13;
     */&#13;
    function addVestTokenAllocation(address beneficiary, uint256 allocationValue)&#13;
        external&#13;
        onlyOwnerOrTokenDistributionContract&#13;
    {&#13;
        require(totalTokensLocked[beneficiary] == 0 &amp;&amp; beneficiary != address(0)); // can only add once.&#13;
&#13;
        allocatedTokens = allocatedTokens.add(allocationValue);&#13;
        require(allocatedTokens &lt;= golix.balanceOf(this));&#13;
&#13;
        totalTokensLocked[beneficiary] = allocationValue;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Transfers vested tokens to beneficiary.&#13;
     */&#13;
    function release() public {&#13;
        uint256 unreleased = releasableAmount();&#13;
&#13;
        require(unreleased &gt; 0);&#13;
&#13;
        releasedTokens[msg.sender] = releasedTokens[msg.sender].add(unreleased);&#13;
&#13;
        golix.safeTransfer(msg.sender, unreleased);&#13;
&#13;
        emit Released(msg.sender, unreleased);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Calculates the amount that has already vested but hasn't been released yet.&#13;
     */&#13;
    function releasableAmount() public view returns (uint256) {&#13;
        return vestedAmount().sub(releasedTokens[msg.sender]);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Calculates the amount that has already vested.&#13;
     */&#13;
    function vestedAmount() public view returns (uint256) {&#13;
        uint256 totalBalance = totalTokensLocked[msg.sender];&#13;
&#13;
        if (now &lt; cliff) {&#13;
            return 0;&#13;
        } else if (now &gt;= start.add(duration)) {&#13;
            return totalBalance;&#13;
        } else {&#13;
            return totalBalance.mul(now.sub(start)).div(duration);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev allow for selfdestruct possibility and sending funds to owner&#13;
     */&#13;
    function kill() public onlyOwner {&#13;
        require(now &gt;= canSelfDestruct);&#13;
        uint256 balance = golix.balanceOf(this);&#13;
&#13;
        if (balance &gt; 0) {&#13;
            golix.transfer(msg.sender, balance);&#13;
        }&#13;
&#13;
        selfdestruct(owner);&#13;
    }&#13;
}