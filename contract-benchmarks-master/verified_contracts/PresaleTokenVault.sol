//File: node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol
pragma solidity ^0.4.18;


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

//File: node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol
pragma solidity ^0.4.18;




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

//File: node_modules/zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol
pragma solidity ^0.4.18;





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

//File: node_modules/zeppelin-solidity/contracts/math/SafeMath.sol
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

//File: node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol
pragma solidity ^0.4.18;


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

//File: node_modules/zeppelin-solidity/contracts/token/ERC20/TokenVesting.sol
pragma solidity ^0.4.18;







/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   */
  function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param token ERC20 token which is being vested
   */
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   * @param token ERC20 token which is being vested
   */
  function revoke(ERC20Basic token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    Revoked();
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param token ERC20 token which is being vested
   */
  function releasableAmount(ERC20Basic token) public view returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token ERC20 token which is being vested
   */
  function vestedAmount(ERC20Basic token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (now < cliff) {
      return 0;
    } else if (now >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(now.sub(start)).div(duration);
    }
  }
}

//File: node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol
pragma solidity ^0.4.18;





/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

//File: node_modules/zeppelin-solidity/contracts/ownership/CanReclaimToken.sol
pragma solidity ^0.4.18;






/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}

//File: src/contracts/ico/KYCBase.sol
pragma solidity ^0.4.19;




// Abstract base contract
contract KYCBase {
    using SafeMath for uint256;

    mapping (address => bool) public isKycSigner;
    mapping (uint64 => uint256) public alreadyPayed;

    event KycVerified(address indexed signer, address buyerAddress, uint64 buyerId, uint maxAmount);

    function KYCBase(address [] kycSigners) internal {
        for (uint i = 0; i < kycSigners.length; i++) {
            isKycSigner[kycSigners[i]] = true;
        }
    }

    // Must be implemented in descending contract to assign tokens to the buyers. Called after the KYC verification is passed
    function releaseTokensTo(address buyer) internal returns(bool);

    // This method can be overridden to enable some sender to buy token for a different address
    function senderAllowedFor(address buyer)
        internal view returns(bool)
    {
        return buyer == msg.sender;
    }

    function buyTokensFor(address buyerAddress, uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s)
        public payable returns (bool)
    {
        require(senderAllowedFor(buyerAddress));
        return buyImplementation(buyerAddress, buyerId, maxAmount, v, r, s);
    }

    function buyTokens(uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s)
        public payable returns (bool)
    {
        return buyImplementation(msg.sender, buyerId, maxAmount, v, r, s);
    }

    function buyImplementation(address buyerAddress, uint64 buyerId, uint maxAmount, uint8 v, bytes32 r, bytes32 s)
        private returns (bool)
    {
        // check the signature
        bytes32 hash = sha256("Eidoo icoengine authorization", this, buyerAddress, buyerId, maxAmount);
        address signer = ecrecover(hash, v, r, s);
        if (!isKycSigner[signer]) {
            revert();
        } else {
            uint256 totalPayed = alreadyPayed[buyerId].add(msg.value);
            require(totalPayed <= maxAmount);
            alreadyPayed[buyerId] = totalPayed;
            KycVerified(signer, buyerAddress, buyerId, maxAmount);
            return releaseTokensTo(buyerAddress);
        }
        return true;
    }

    // No payable fallback function, the tokens must be buyed using the functions buyTokens and buyTokensFor
    function () public {
        revert();
    }
}
//File: src/contracts/ico/ICOEngineInterface.sol
pragma solidity ^0.4.19;


contract ICOEngineInterface {

    // false if the ico is not started, true if the ico is started and running, true if the ico is completed
    function started() public view returns(bool);

    // false if the ico is not started, false if the ico is started and running, true if the ico is completed
    function ended() public view returns(bool);

    // time stamp of the starting time of the ico, must return 0 if it depends on the block number
    function startTime() public view returns(uint);

    // time stamp of the ending time of the ico, must retrun 0 if it depends on the block number
    function endTime() public view returns(uint);

    // Optional function, can be implemented in place of startTime
    // Returns the starting block number of the ico, must return 0 if it depends on the time stamp
    // function startBlock() public view returns(uint);

    // Optional function, can be implemented in place of endTime
    // Returns theending block number of the ico, must retrun 0 if it depends on the time stamp
    // function endBlock() public view returns(uint);

    // returns the total number of the tokens available for the sale, must not change when the ico is started
    function totalTokens() public view returns(uint);

    // returns the number of the tokens available for the ico. At the moment that the ico starts it must be equal to totalTokens(),
    // then it will decrease. It is used to calculate the percentage of sold tokens as remainingTokens() / totalTokens()
    function remainingTokens() public view returns(uint);

    // return the price as number of tokens released for each ether
    function price() public view returns(uint);
}
//File: src/contracts/ico/CrowdsaleBase.sol
/**
 * @title CrowdsaleBase
 * @dev Base crowdsale contract to be inherited by the UacCrowdsale and Reservation contracts.
 *
 * @version 1.0
 * @author Validity Labs AG <<span class="__cf_email__" data-cfemail="f891969e97b88e9994919c918c8194999a8bd6978a9f">[email protected]</span>&gt;&#13;
 */&#13;
pragma solidity ^0.4.19;&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract CrowdsaleBase is Pausable, CanReclaimToken, ICOEngineInterface, KYCBase {&#13;
&#13;
    /*** CONSTANTS ***/&#13;
    uint256 public constant USD_PER_TOKEN = 2;                        //&#13;
    uint256 public constant USD_PER_ETHER = 795;                      //&#13;
&#13;
    uint256 public start;                                             // ICOEngineInterface&#13;
    uint256 public end;                                               // ICOEngineInterface&#13;
    uint256 public cap;                                               // ICOEngineInterface&#13;
    address public wallet;&#13;
    uint256 public tokenPerEth;&#13;
    uint256 public availableTokens;                                   // ICOEngineInterface&#13;
    address[] public kycSigners;                                      // KYCBase&#13;
    bool public capReached;&#13;
    uint256 public weiRaised;&#13;
    uint256 public tokensSold;&#13;
&#13;
    /**&#13;
     * @dev Constructor.&#13;
     * @param _start The start time of the sale.&#13;
     * @param _end The end time of the sale.&#13;
     * @param _cap The maximum amount of tokens to be sold during the sale.&#13;
     * @param _wallet The address where funds should be transferred.&#13;
     * @param _kycSigners Array of the signers addresses required by the KYCBase constructor, provided by Eidoo.&#13;
     * See https://github.com/eidoo/icoengine&#13;
     */&#13;
    function CrowdsaleBase(&#13;
        uint256 _start,&#13;
        uint256 _end,&#13;
        uint256 _cap,&#13;
        address _wallet,&#13;
        address[] _kycSigners&#13;
    )&#13;
        public&#13;
        KYCBase(_kycSigners)&#13;
    {&#13;
        require(_end &gt;= _start);&#13;
        require(_cap &gt; 0);&#13;
&#13;
        start = _start;&#13;
        end = _end;&#13;
        cap = _cap;&#13;
        wallet = _wallet;&#13;
        tokenPerEth = USD_PER_ETHER.div(USD_PER_TOKEN);&#13;
        availableTokens = _cap;&#13;
        kycSigners = _kycSigners;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Implements the ICOEngineInterface.&#13;
     * @return False if the ico is not started, true if the ico is started and running, true if the ico is completed.&#13;
     */&#13;
    function started() public view returns(bool) {&#13;
        if (block.timestamp &gt;= start) {&#13;
            return true;&#13;
        } else {&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Implements the ICOEngineInterface.&#13;
     * @return False if the ico is not started, false if the ico is started and running, true if the ico is completed.&#13;
     */&#13;
    function ended() public view returns(bool) {&#13;
        if (block.timestamp &gt;= end) {&#13;
            return true;&#13;
        } else {&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Implements the ICOEngineInterface.&#13;
     * @return Timestamp of the ico start time.&#13;
     */&#13;
    function startTime() public view returns(uint) {&#13;
        return start;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Implements the ICOEngineInterface.&#13;
     * @return Timestamp of the ico end time.&#13;
     */&#13;
    function endTime() public view returns(uint) {&#13;
        return end;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Implements the ICOEngineInterface.&#13;
     * @return The total number of the tokens available for the sale, must not change when the ico is started.&#13;
     */&#13;
    function totalTokens() public view returns(uint) {&#13;
        return cap;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Implements the ICOEngineInterface.&#13;
     * @return The number of the tokens available for the ico. At the moment the ico starts it must be equal to totalTokens(),&#13;
     * then it will decrease.&#13;
     */&#13;
    function remainingTokens() public view returns(uint) {&#13;
        return availableTokens;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Implements the KYCBase senderAllowedFor function to enable a sender to buy tokens for a different address.&#13;
     * @return true.&#13;
     */&#13;
    function senderAllowedFor(address buyer) internal view returns(bool) {&#13;
        require(buyer != address(0));&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Implements the KYCBase releaseTokensTo function to mint tokens for an investor. Called after the KYC process has passed.&#13;
     * @return A bollean that indicates if the operation was successful.&#13;
     */&#13;
    function releaseTokensTo(address buyer) internal returns(bool) {&#13;
        require(validPurchase());&#13;
&#13;
        uint256 overflowTokens;&#13;
        uint256 refundWeiAmount;&#13;
&#13;
        uint256 weiAmount = msg.value;&#13;
        uint256 tokenAmount = weiAmount.mul(price());&#13;
&#13;
        if (tokenAmount &gt;= availableTokens) {&#13;
            capReached = true;&#13;
            overflowTokens = tokenAmount.sub(availableTokens);&#13;
            tokenAmount = tokenAmount.sub(overflowTokens);&#13;
            refundWeiAmount = overflowTokens.div(price());&#13;
            weiAmount = weiAmount.sub(refundWeiAmount);&#13;
            buyer.transfer(refundWeiAmount);&#13;
        }&#13;
&#13;
        weiRaised = weiRaised.add(weiAmount);&#13;
        tokensSold = tokensSold.add(tokenAmount);&#13;
        availableTokens = availableTokens.sub(tokenAmount);&#13;
        mintTokens(buyer, tokenAmount);&#13;
        forwardFunds(weiAmount);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Fired by the releaseTokensTo function after minting tokens, to forward the raised wei to the address that collects funds.&#13;
     * @param _weiAmount Amount of wei send by the investor.&#13;
     */&#13;
    function forwardFunds(uint256 _weiAmount) internal {&#13;
        wallet.transfer(_weiAmount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Validates an incoming purchase. Required statements revert state when conditions are not met.&#13;
     * @return true If the transaction can buy tokens.&#13;
     */&#13;
    function validPurchase() internal view returns (bool) {&#13;
        require(!paused &amp;&amp; !capReached);&#13;
        require(block.timestamp &gt;= start &amp;&amp; block.timestamp &lt;= end);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Abstract function to mint tokens, to be implemented in the Crowdsale and Reservation contracts.&#13;
    * @param to The address that will receive the minted tokens.&#13;
    * @param amount The amount of tokens to mint.&#13;
    */&#13;
    function mintTokens(address to, uint256 amount) private;&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
//File: src/contracts/ico/Reservation.sol&#13;
/**&#13;
 * @title Reservation&#13;
 *&#13;
 * @version 1.0&#13;
 * @author Validity Labs AG &lt;<span class="__cf_email__" data-cfemail="8ee7e0e8e1cef8efe2e7eae7faf7e2efecfda0e1fce9">[email protected]</span>&gt;&#13;
 */&#13;
pragma solidity ^0.4.19;&#13;
&#13;
&#13;
&#13;
&#13;
contract Reservation is CrowdsaleBase {&#13;
&#13;
    /*** CONSTANTS ***/&#13;
    uint256 public constant START_TIME = 1525683600;                     // 7 May 2018 09:00:00 GMT&#13;
    uint256 public constant END_TIME = 1525856400;                       // 9 May 2018 09:00:00 GMT&#13;
    uint256 public constant RESERVATION_CAP = 7.5e6 * 1e18;&#13;
    uint256 public constant BONUS = 110;                                 // 10% bonus&#13;
&#13;
    UacCrowdsale public crowdsale;&#13;
&#13;
    /**&#13;
     * @dev Constructor.&#13;
     * @notice Unsold tokens should add up to the crowdsale hard cap.&#13;
     * @param _wallet The address where funds should be transferred.&#13;
     * @param _kycSigners Array of the signers addresses required by the KYCBase constructor, provided by Eidoo.&#13;
     * See https://github.com/eidoo/icoengine&#13;
     */&#13;
    function Reservation(&#13;
        address _wallet,&#13;
        address[] _kycSigners&#13;
    )&#13;
        public&#13;
        CrowdsaleBase(START_TIME, END_TIME, RESERVATION_CAP, _wallet, _kycSigners)&#13;
    {&#13;
    }&#13;
&#13;
    function setCrowdsale(address _crowdsale) public {&#13;
        require(crowdsale == address(0));&#13;
        crowdsale = UacCrowdsale(_crowdsale);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Implements the price function from EidooEngineInterface.&#13;
     * @notice Calculates the price as tokens/ether based on the corresponding bonus.&#13;
     * @return Price as tokens/ether.&#13;
     */&#13;
    function price() public view returns (uint256) {&#13;
        return tokenPerEth.mul(BONUS).div(1e2);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Fires the mintReservationTokens function on the crowdsale contract to mint the tokens being sold during the reservation phase.&#13;
     * This function is called by the releaseTokensTo function, as part of the KYCBase implementation.&#13;
     * @param to The address that will receive the minted tokens.&#13;
     * @param amount The amount of tokens to mint.&#13;
     */&#13;
    function mintTokens(address to, uint256 amount) private {&#13;
        crowdsale.mintReservationTokens(to, amount);&#13;
    }&#13;
}&#13;
//File: node_modules/zeppelin-solidity/contracts/token/ERC20/BasicToken.sol&#13;
pragma solidity ^0.4.18;&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
&#13;
  uint256 totalSupply_;&#13;
&#13;
  /**&#13;
  * @dev total number of tokens in existence&#13;
  */&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return totalSupply_;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[msg.sender]);&#13;
&#13;
    // SafeMath.sub will throw if there is not enough balance.&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param _owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
    return balances[_owner];&#13;
  }&#13;
&#13;
}&#13;
&#13;
//File: node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol&#13;
pragma solidity ^0.4.18;&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 *&#13;
 * @dev Implementation of the basic standard token.&#13;
 * @dev https://github.com/ethereum/EIPs/issues/20&#13;
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
contract StandardToken is ERC20, BasicToken {&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _to address The address which you want to transfer to&#13;
   * @param _value uint256 the amount of tokens to be transferred&#13;
   */&#13;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
   *&#13;
   * Beware that changing an allowance with this method brings the risk that someone may use both the old&#13;
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this&#13;
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:&#13;
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _value The amount of tokens to be spent.&#13;
   */&#13;
  function approve(address _spender, uint256 _value) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = _value;&#13;
    Approval(msg.sender, _spender, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
   * @param _owner address The address which owns the funds.&#13;
   * @param _spender address The address which will spend the funds.&#13;
   * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
   */&#13;
  function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _addedValue The amount of tokens to increase the allowance by.&#13;
   */&#13;
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * approve should be called when allowed[_spender] == 0. To decrement&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _subtractedValue The amount of tokens to decrease the allowance by.&#13;
   */&#13;
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {&#13;
    uint oldValue = allowed[msg.sender][_spender];&#13;
    if (_subtractedValue &gt; oldValue) {&#13;
      allowed[msg.sender][_spender] = 0;&#13;
    } else {&#13;
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
    }&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
}&#13;
&#13;
//File: node_modules/zeppelin-solidity/contracts/token/ERC20/MintableToken.sol&#13;
pragma solidity ^0.4.18;&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Mintable token&#13;
 * @dev Simple ERC20 Token example, with mintable token creation&#13;
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120&#13;
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol&#13;
 */&#13;
contract MintableToken is StandardToken, Ownable {&#13;
  event Mint(address indexed to, uint256 amount);&#13;
  event MintFinished();&#13;
&#13;
  bool public mintingFinished = false;&#13;
&#13;
&#13;
  modifier canMint() {&#13;
    require(!mintingFinished);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to mint tokens&#13;
   * @param _to The address that will receive the minted tokens.&#13;
   * @param _amount The amount of tokens to mint.&#13;
   * @return A boolean that indicates if the operation was successful.&#13;
   */&#13;
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {&#13;
    totalSupply_ = totalSupply_.add(_amount);&#13;
    balances[_to] = balances[_to].add(_amount);&#13;
    Mint(_to, _amount);&#13;
    Transfer(address(0), _to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to stop minting new tokens.&#13;
   * @return True if the operation was successful.&#13;
   */&#13;
  function finishMinting() onlyOwner canMint public returns (bool) {&#13;
    mintingFinished = true;&#13;
    MintFinished();&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
//File: node_modules/zeppelin-solidity/contracts/token/ERC20/PausableToken.sol&#13;
pragma solidity ^0.4.18;&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * @title Pausable token&#13;
 * @dev StandardToken modified with pausable transfers.&#13;
 **/&#13;
contract PausableToken is StandardToken, Pausable {&#13;
&#13;
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.approve(_spender, _value);&#13;
  }&#13;
&#13;
  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {&#13;
    return super.increaseApproval(_spender, _addedValue);&#13;
  }&#13;
&#13;
  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {&#13;
    return super.decreaseApproval(_spender, _subtractedValue);&#13;
  }&#13;
}&#13;
&#13;
//File: src/contracts/ico/UacToken.sol&#13;
/**&#13;
 * @title Ubiatar Coin token&#13;
 *&#13;
 * @version 1.0&#13;
 * @author Validity Labs AG &lt;<span class="__cf_email__" data-cfemail="8be2e5ede4cbfdeae7e2efe2fff2e7eae9f8a5e4f9ec">[email protected]</span>&gt;&#13;
 */&#13;
pragma solidity ^0.4.19;&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract UacToken is CanReclaimToken, MintableToken, PausableToken {&#13;
    string public constant name = "Ubiatar Coin";&#13;
    string public constant symbol = "UAC";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    /**&#13;
     * @dev Constructor of UacToken that instantiates a new Mintable Pausable Token&#13;
     */&#13;
    function UacToken() public {&#13;
        // token should not be transferrable until after all tokens have been issued&#13;
        paused = true;&#13;
    }&#13;
}&#13;
&#13;
//File: src/contracts/ico/UbiatarPlayVault.sol&#13;
/**&#13;
 * @title UbiatarPlayVault&#13;
 * @dev A token holder contract that allows the release of tokens to the UbiatarPlay Wallet.&#13;
 *&#13;
 * @version 1.0&#13;
 * @author Validity Labs AG &lt;<span class="__cf_email__" data-cfemail="4e272028210e382f22272a273a37222f2c3d60213c29">[email protected]</span>&gt;&#13;
 */&#13;
&#13;
pragma solidity ^0.4.19;&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract UbiatarPlayVault {&#13;
    using SafeMath for uint256;&#13;
    using SafeERC20 for UacToken;&#13;
&#13;
    uint256[6] public vesting_offsets = [&#13;
        90 days,&#13;
        180 days,&#13;
        270 days,&#13;
        360 days,&#13;
        540 days,&#13;
        720 days&#13;
    ];&#13;
&#13;
    uint256[6] public vesting_amounts = [&#13;
        2e6 * 1e18,&#13;
        4e6 * 1e18,&#13;
        6e6 * 1e18,&#13;
        8e6 * 1e18,&#13;
        10e6 * 1e18,&#13;
        20.5e6 * 1e18&#13;
    ];&#13;
&#13;
    address public ubiatarPlayWallet;&#13;
    UacToken public token;&#13;
    uint256 public start;&#13;
    uint256 public released;&#13;
&#13;
    /**&#13;
     * @dev Constructor.&#13;
     * @param _ubiatarPlayWallet The address that will receive the vested tokens.&#13;
     * @param _token The UAC Token, which is being vested.&#13;
     * @param _start The start time from which each release time will be calculated.&#13;
     */&#13;
    function UbiatarPlayVault(&#13;
        address _ubiatarPlayWallet,&#13;
        address _token,&#13;
        uint256 _start&#13;
    )&#13;
        public&#13;
    {&#13;
        ubiatarPlayWallet = _ubiatarPlayWallet;&#13;
        token = UacToken(_token);&#13;
        start = _start;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Transfers vested tokens to ubiatarPlayWallet.&#13;
     */&#13;
    function release() public {&#13;
        uint256 unreleased = releasableAmount();&#13;
        require(unreleased &gt; 0);&#13;
&#13;
        released = released.add(unreleased);&#13;
&#13;
        token.safeTransfer(ubiatarPlayWallet, unreleased);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Calculates the amount that has already vested but hasn't been released yet.&#13;
     */&#13;
    function releasableAmount() public view returns (uint256) {&#13;
        return vestedAmount().sub(released);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Calculates the amount that has already vested.&#13;
     */&#13;
    function vestedAmount() public view returns (uint256) {&#13;
        uint256 vested = 0;&#13;
&#13;
        for (uint256 i = 0; i &lt; vesting_offsets.length; i = i.add(1)) {&#13;
            if (block.timestamp &gt; start.add(vesting_offsets[i])) {&#13;
                vested = vested.add(vesting_amounts[i]);&#13;
            }&#13;
        }&#13;
&#13;
        return vested;&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
//File: src/contracts/ico/UacCrowdsale.sol&#13;
/**&#13;
 * @title UacCrowdsale&#13;
 *&#13;
 * @version 1.0&#13;
 * @author Validity Labs AG &lt;<span class="__cf_email__" data-cfemail="375e5951587741565b5e535e434e5b56554419584550">[email protected]</span>&gt;&#13;
 */&#13;
pragma solidity ^0.4.19;&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract UacCrowdsale is CrowdsaleBase {&#13;
&#13;
    /*** CONSTANTS ***/&#13;
    uint256 public constant START_TIME = 1525856400;                     // 9 May 2018 09:00:00 GMT&#13;
    uint256 public constant END_TIME = 1528448400;                       // 8 June 2018 09:00:00 GMT&#13;
    uint256 public constant PRESALE_VAULT_START = END_TIME + 7 days;&#13;
    uint256 public constant PRESALE_CAP = 17584778551358900100698693;&#13;
    uint256 public constant TOTAL_MAX_CAP = 15e6 * 1e18;                // Reservation plus main sale tokens&#13;
    uint256 public constant CROWDSALE_CAP = 7.5e6 * 1e18;&#13;
    uint256 public constant FOUNDERS_CAP = 12e6 * 1e18;&#13;
    uint256 public constant UBIATARPLAY_CAP = 50.5e6 * 1e18;&#13;
    uint256 public constant ADVISORS_CAP = 4915221448641099899301307;&#13;
&#13;
    // Eidoo interface requires price as tokens/ether, therefore the discounts are presented as bonus tokens.&#13;
    uint256 public constant BONUS_TIER1 = 108;                           // 8% during first 3 hours&#13;
    uint256 public constant BONUS_TIER2 = 106;                           // 6% during next 9 hours&#13;
    uint256 public constant BONUS_TIER3 = 104;                           // 4% during next 30 hours&#13;
    uint256 public constant BONUS_DURATION_1 = 3 hours;&#13;
    uint256 public constant BONUS_DURATION_2 = 12 hours;&#13;
    uint256 public constant BONUS_DURATION_3 = 42 hours;&#13;
&#13;
    uint256 public constant FOUNDERS_VESTING_CLIFF = 1 years;&#13;
    uint256 public constant FOUNDERS_VESTING_DURATION = 2 years;&#13;
&#13;
    Reservation public reservation;&#13;
&#13;
    // Vesting contracts.&#13;
    PresaleTokenVault public presaleTokenVault;&#13;
    TokenVesting public foundersVault;&#13;
    UbiatarPlayVault public ubiatarPlayVault;&#13;
&#13;
    // Vesting wallets.&#13;
    address public foundersWallet;&#13;
    address public advisorsWallet;&#13;
    address public ubiatarPlayWallet;&#13;
&#13;
    address public wallet;&#13;
&#13;
    UacToken public token;&#13;
&#13;
    // Lets owner manually end crowdsale.&#13;
    bool public didOwnerEndCrowdsale;&#13;
&#13;
    /**&#13;
     * @dev Constructor.&#13;
     * @param _foundersWallet address Wallet holding founders tokens.&#13;
     * @param _advisorsWallet address Wallet holding advisors tokens.&#13;
     * @param _ubiatarPlayWallet address Wallet holding ubiatarPlay tokens.&#13;
     * @param _wallet The address where funds should be transferred.&#13;
     * @param _kycSigners Array of the signers addresses required by the KYCBase constructor, provided by Eidoo.&#13;
     * See https://github.com/eidoo/icoengine&#13;
     */&#13;
    function UacCrowdsale(&#13;
        address _token,&#13;
        address _reservation,&#13;
        address _presaleTokenVault,&#13;
        address _foundersWallet,&#13;
        address _advisorsWallet,&#13;
        address _ubiatarPlayWallet,&#13;
        address _wallet,&#13;
        address[] _kycSigners&#13;
    )&#13;
        public&#13;
        CrowdsaleBase(START_TIME, END_TIME, TOTAL_MAX_CAP, _wallet, _kycSigners)&#13;
    {&#13;
        token = UacToken(_token);&#13;
        reservation = Reservation(_reservation);&#13;
        presaleTokenVault = PresaleTokenVault(_presaleTokenVault);&#13;
        foundersWallet = _foundersWallet;&#13;
        advisorsWallet = _advisorsWallet;&#13;
        ubiatarPlayWallet = _ubiatarPlayWallet;&#13;
        wallet = _wallet;&#13;
        // Create founders vault contract&#13;
        foundersVault = new TokenVesting(foundersWallet, END_TIME, FOUNDERS_VESTING_CLIFF, FOUNDERS_VESTING_DURATION, false);&#13;
&#13;
        // Create Ubiatar Play vault contract&#13;
        ubiatarPlayVault = new UbiatarPlayVault(ubiatarPlayWallet, address(token), END_TIME);&#13;
    }&#13;
&#13;
    function mintPreAllocatedTokens() public onlyOwner {&#13;
        mintTokens(address(foundersVault), FOUNDERS_CAP);&#13;
        mintTokens(advisorsWallet, ADVISORS_CAP);&#13;
        mintTokens(address(ubiatarPlayVault), UBIATARPLAY_CAP);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Creates the presale vault contract.&#13;
     * @param beneficiaries Array of the presale investors addresses to whom vested tokens are transferred.&#13;
     * @param balances Array of token amount per beneficiary.&#13;
     */&#13;
    function initPresaleTokenVault(address[] beneficiaries, uint256[] balances) public onlyOwner {&#13;
        require(beneficiaries.length == balances.length);&#13;
&#13;
        presaleTokenVault.init(beneficiaries, balances, PRESALE_VAULT_START, token);&#13;
&#13;
        uint256 totalPresaleBalance = 0;&#13;
        uint256 balancesLength = balances.length;&#13;
        for(uint256 i = 0; i &lt; balancesLength; i++) {&#13;
            totalPresaleBalance = totalPresaleBalance.add(balances[i]);&#13;
        }&#13;
&#13;
        mintTokens(presaleTokenVault, totalPresaleBalance);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Implements the price function from EidooEngineInterface.&#13;
     * @notice Calculates the price as tokens/ether based on the corresponding bonus bracket.&#13;
     * @return Price as tokens/ether.&#13;
     */&#13;
    function price() public view returns (uint256 _price) {&#13;
        if (block.timestamp &lt;= start.add(BONUS_DURATION_1)) {&#13;
            return tokenPerEth.mul(BONUS_TIER1).div(1e2);&#13;
        } else if (block.timestamp &lt;= start.add(BONUS_DURATION_2)) {&#13;
            return tokenPerEth.mul(BONUS_TIER2).div(1e2);&#13;
        } else if (block.timestamp &lt;= start.add(BONUS_DURATION_3)) {&#13;
            return tokenPerEth.mul(BONUS_TIER3).div(1e2);&#13;
        }&#13;
        return tokenPerEth;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Mints tokens being sold during the reservation phase, as part of the implementation of the releaseTokensTo function&#13;
     * from the KYCBase contract.&#13;
     * Also, updates tokensSold and availableTokens in the crowdsale contract.&#13;
     * @param to The address that will receive the minted tokens.&#13;
     * @param amount The amount of tokens to mint.&#13;
     */&#13;
    function mintReservationTokens(address to, uint256 amount) public {&#13;
        require(msg.sender == address(reservation));&#13;
        tokensSold = tokensSold.add(amount);&#13;
        availableTokens = availableTokens.sub(amount);&#13;
        mintTokens(to, amount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Mints tokens being sold during the crowdsale phase as part of the implementation of releaseTokensTo function&#13;
     * from the KYCBase contract.&#13;
     * @param to The address that will receive the minted tokens.&#13;
     * @param amount The amount of tokens to mint.&#13;
     */&#13;
    function mintTokens(address to, uint256 amount) private {&#13;
        token.mint(to, amount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Allows the owner to close the crowdsale manually before the end time.&#13;
     */&#13;
    function closeCrowdsale() public onlyOwner {&#13;
        require(block.timestamp &gt;= START_TIME &amp;&amp; block.timestamp &lt; END_TIME);&#13;
        didOwnerEndCrowdsale = true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Allows the owner to unpause tokens, stop minting and transfer ownership of the token contract.&#13;
     */&#13;
    function finalise() public onlyOwner {&#13;
        require(didOwnerEndCrowdsale || block.timestamp &gt; end || capReached);&#13;
        token.finishMinting();&#13;
        token.unpause();&#13;
&#13;
        // Token contract extends CanReclaimToken so the owner can recover any ERC20 token received in this contract by mistake.&#13;
        // So far, the owner of the token contract is the crowdsale contract.&#13;
        // We transfer the ownership so the owner of the crowdsale is also the owner of the token.&#13;
        token.transferOwnership(owner);&#13;
    }&#13;
}&#13;
&#13;
&#13;
//File: src/contracts/ico/PresaleTokenVault.sol&#13;
/**&#13;
 * @title PresaleTokenVault&#13;
 * @dev A token holder contract that allows multiple beneficiaries to extract their tokens after a given release time.&#13;
 *&#13;
 * @version 1.0&#13;
 * @author Validity Labs AG &lt;<span class="__cf_email__" data-cfemail="462f2820290630272a2f222f323f2a27243568293421">[email protected]</span>&gt;&#13;
 */&#13;
pragma solidity ^0.4.17;&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract PresaleTokenVault {&#13;
    using SafeMath for uint256;&#13;
    using SafeERC20 for ERC20Basic;&#13;
&#13;
    /*** CONSTANTS ***/&#13;
    uint256 public constant VESTING_OFFSET = 90 days;                   // starting of vesting&#13;
    uint256 public constant VESTING_DURATION = 180 days;                // duration of vesting&#13;
&#13;
    uint256 public start;&#13;
    uint256 public cliff;&#13;
    uint256 public end;&#13;
&#13;
    ERC20Basic public token;&#13;
&#13;
    struct Investment {&#13;
        address beneficiary;&#13;
        uint256 totalBalance;&#13;
        uint256 released;&#13;
    }&#13;
&#13;
    Investment[] public investments;&#13;
&#13;
    // key: investor address; value: index in investments array.&#13;
    mapping(address =&gt; uint256) public investorLUT;&#13;
&#13;
    function init(address[] beneficiaries, uint256[] balances, uint256 startTime, address _token) public {&#13;
        // makes sure this function is only called once&#13;
        require(token == address(0));&#13;
        require(beneficiaries.length == balances.length);&#13;
&#13;
        start = startTime;&#13;
        cliff = start.add(VESTING_OFFSET);&#13;
        end = cliff.add(VESTING_DURATION);&#13;
&#13;
        token = ERC20Basic(_token);&#13;
&#13;
        for (uint256 i = 0; i &lt; beneficiaries.length; i = i.add(1)) {&#13;
            investorLUT[beneficiaries[i]] = investments.length;&#13;
            investments.push(Investment(beneficiaries[i], balances[i], 0));&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Allows a sender to transfer vested tokens to the beneficiary's address.&#13;
     * @param beneficiary The address that will receive the vested tokens.&#13;
     */&#13;
    function release(address beneficiary) public {&#13;
        uint256 unreleased = releasableAmount(beneficiary);&#13;
        require(unreleased &gt; 0);&#13;
&#13;
        uint256 investmentIndex = investorLUT[beneficiary];&#13;
        investments[investmentIndex].released = investments[investmentIndex].released.add(unreleased);&#13;
        token.safeTransfer(beneficiary, unreleased);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Transfers vested tokens to the sender's address.&#13;
     */&#13;
    function release() public {&#13;
        release(msg.sender);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Calculates the amount that has already vested but hasn't been released yet.&#13;
     * @param beneficiary The address that will receive the vested tokens.&#13;
     */&#13;
    function releasableAmount(address beneficiary) public view returns (uint256) {&#13;
        uint256 investmentIndex = investorLUT[beneficiary];&#13;
&#13;
        return vestedAmount(beneficiary).sub(investments[investmentIndex].released);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Calculates the amount that has already vested.&#13;
     * @param beneficiary The address that will receive the vested tokens.&#13;
     */&#13;
    function vestedAmount(address beneficiary) public view returns (uint256) {&#13;
&#13;
        uint256 investmentIndex = investorLUT[beneficiary];&#13;
&#13;
        uint256 vested = 0;&#13;
&#13;
        if (block.timestamp &gt;= start) {&#13;
            // after start -&gt; 1/3 released (fixed)&#13;
            vested = investments[investmentIndex].totalBalance.div(3);&#13;
        }&#13;
        if (block.timestamp &gt;= cliff &amp;&amp; block.timestamp &lt; end) {&#13;
            // after cliff -&gt; linear vesting over time&#13;
            uint256 p1 = investments[investmentIndex].totalBalance.div(3);&#13;
            uint256 p2 = investments[investmentIndex].totalBalance;&#13;
&#13;
            /*&#13;
              released amount:  r&#13;
              1/3:              p1&#13;
              all:              p2&#13;
              current time:     t&#13;
              cliff:            c&#13;
              end:              e&#13;
&#13;
              r = p1 +  / d_time * time&#13;
                = p1 + (p2-p1) / (e-c) * (t-c)&#13;
            */&#13;
            uint256 d_token = p2.sub(p1);&#13;
            uint256 time = block.timestamp.sub(cliff);&#13;
            uint256 d_time = end.sub(cliff);&#13;
&#13;
            vested = vested.add(d_token.mul(time).div(d_time));&#13;
        }&#13;
        if (block.timestamp &gt;= end) {&#13;
            // after end -&gt; all vested&#13;
            vested = investments[investmentIndex].totalBalance;&#13;
        }&#13;
        return vested;&#13;
    }&#13;
}