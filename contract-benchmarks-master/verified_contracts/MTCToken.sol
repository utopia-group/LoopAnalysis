pragma solidity ^0.4.11;


/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Basic {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint value);
  event Transfer(address indexed from, address indexed to, uint value);
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint;

  mapping(address => uint) balances;

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
     if(msg.data.length < size + 4) {
       throw;
     }
     _;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

}





/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint);
  function transferFrom(address from, address to, uint value);
  function approve(address spender, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}





/**
 * @title Standard ERC20 token
 *
 * @dev Implemantation of the basic standart token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is BasicToken, ERC20 {

  mapping (address => mapping (address => uint)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on beahlf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint _value) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  /**
   * @dev Function to check the amount of tokens than an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}






/// @title MTC Protocol Token.
/// For more information about this token sale, please visit https://mtc.red
/// @author 曹小彬(email: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1370727c717a7d537e67703d617677">[email protected]</a>, 微信：14435949，ETH捐款地址：0x86204b1889ac37cc43094b4a52c312f89eeb60ed).&#13;
contract MTCToken is StandardToken {&#13;
    string public constant NAME = "MTCoin";&#13;
    string public constant SYMBOL = "MTC";&#13;
    uint public constant DECIMALS = 18;&#13;
&#13;
    /// During token sale, we use one consistent price: 1000 MTC/ETH.&#13;
    /// We split the entire token sale period into 3 phases, each&#13;
    /// phase has a different bonus setting as specified in `bonusPercentages`.&#13;
    /// The real price for phase i is `(1 + bonusPercentages[i]/100.0) * BASE_RATE`.&#13;
    /// The first phase or early-bird phase has a much higher bonus.&#13;
    uint8[10] public bonusPercentages = [&#13;
        20,&#13;
        10,&#13;
        0&#13;
    ];&#13;
&#13;
    uint public constant NUM_OF_PHASE = 3;&#13;
  &#13;
    /// Each phase contains exactly 29000 Ethereum blocks, which is roughly 7 days,&#13;
    /// which makes this 3-phase sale period roughly 21 days.&#13;
    /// See https://www.ethereum.org/crowdsale#scheduling-a-call&#13;
    uint16 public constant BLOCKS_PER_PHASE = 29000;&#13;
&#13;
    /// This is where we hold ETH during this token sale. We will not transfer any Ether&#13;
    /// out of this address before we invocate the `close` function to finalize the sale. &#13;
    /// This promise is not guanranteed by smart contract by can be verified with public&#13;
    /// Ethereum transactions data available on several blockchain browsers.&#13;
    /// This is the only address from which `start` and `close` can be invocated.&#13;
    ///&#13;
    /// Note: this will be initialized during the contract deployment.&#13;
    address public target;&#13;
&#13;
    /// `firstblock` specifies from which block our token sale starts.&#13;
    /// This can only be modified once by the owner of `target` address.&#13;
    uint public firstblock = 0;&#13;
&#13;
    /// Indicates whether unsold token have been issued. This part of MTC token&#13;
    /// is managed by the project team and is issued directly to `target`.&#13;
    bool public unsoldTokenIssued = false;&#13;
&#13;
    /// Minimum amount of funds to be raised for the sale to succeed. &#13;
    uint256 public constant GOAL = 3000 ether;&#13;
&#13;
    /// Maximum amount of fund to be raised, the sale ends on reaching this amount.&#13;
    uint256 public constant HARD_CAP = 4500 ether;&#13;
&#13;
    /// Base exchange rate is set to 1 ETH = 1050 MTC.&#13;
    uint256 public constant BASE_RATE = 1050;&#13;
&#13;
    /// A simple stat for emitting events.&#13;
    uint public totalEthReceived = 0;&#13;
&#13;
    /// Issue event index starting from 0.&#13;
    uint public issueIndex = 0;&#13;
&#13;
    /* &#13;
     * EVENTS&#13;
     */&#13;
&#13;
    /// Emitted only once after token sale starts.&#13;
    event SaleStarted();&#13;
&#13;
    /// Emitted only once after token sale ended (all token issued).&#13;
    event SaleEnded();&#13;
&#13;
    /// Emitted when a function is invocated by unauthorized addresses.&#13;
    event InvalidCaller(address caller);&#13;
&#13;
    /// Emitted when a function is invocated without the specified preconditions.&#13;
    /// This event will not come alone with an exception.&#13;
    event InvalidState(bytes msg);&#13;
&#13;
    /// Emitted for each sucuessful token purchase.&#13;
    event Issue(uint issueIndex, address addr, uint ethAmount, uint tokenAmount);&#13;
&#13;
    /// Emitted if the token sale succeeded.&#13;
    event SaleSucceeded();&#13;
&#13;
    /// Emitted if the token sale failed.&#13;
    /// When token sale failed, all Ether will be return to the original purchasing&#13;
    /// address with a minor deduction of transaction fee(gas)&#13;
    event SaleFailed();&#13;
&#13;
    /*&#13;
     * MODIFIERS&#13;
     */&#13;
&#13;
    modifier onlyOwner {&#13;
        if (target == msg.sender) {&#13;
            _;&#13;
        } else {&#13;
            InvalidCaller(msg.sender);&#13;
            throw;&#13;
        }&#13;
    }&#13;
&#13;
    modifier beforeStart {&#13;
        if (!saleStarted()) {&#13;
            _;&#13;
        } else {&#13;
            InvalidState("Sale has not started yet");&#13;
            throw;&#13;
        }&#13;
    }&#13;
&#13;
    modifier inProgress {&#13;
        if (saleStarted() &amp;&amp; !saleEnded()) {&#13;
            _;&#13;
        } else {&#13;
            InvalidState("Sale is not in progress");&#13;
            throw;&#13;
        }&#13;
    }&#13;
&#13;
    modifier afterEnd {&#13;
        if (saleEnded()) {&#13;
            _;&#13;
        } else {&#13;
            InvalidState("Sale is not ended yet");&#13;
            throw;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * CONSTRUCTOR &#13;
     * &#13;
     * @dev Initialize the MTC Token&#13;
     * @param _target The escrow account address, all ethers will&#13;
     * be sent to this address.&#13;
     * This address will be : 0x40d4e1c93314b17f4af1b019848d56fc01876f4c&#13;
     */&#13;
    function MTCToken(address _target) {&#13;
        target = _target;&#13;
        totalSupply = 10 ** 26;&#13;
        balances[target] = totalSupply;&#13;
    }&#13;
&#13;
    /*&#13;
     * PUBLIC FUNCTIONS&#13;
     */&#13;
&#13;
    /// @dev Start the token sale.&#13;
    /// @param _firstblock The block from which the sale will start.&#13;
    function start(uint _firstblock) public onlyOwner beforeStart {&#13;
        if (_firstblock &lt;= block.number) {&#13;
            // Must specify a block in the future.&#13;
            throw;&#13;
        }&#13;
&#13;
        firstblock = _firstblock;&#13;
        SaleStarted();&#13;
    }&#13;
&#13;
    /// @dev Triggers unsold tokens to be issued to `target` address.&#13;
    function close() public onlyOwner afterEnd {&#13;
        if (totalEthReceived &lt; GOAL) {&#13;
            SaleFailed();&#13;
        } else {&#13;
            SaleSucceeded();&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Returns the current price.&#13;
    function price() public constant returns (uint tokens) {&#13;
        return computeTokenAmount(1 ether);&#13;
    }&#13;
&#13;
    /// @dev This default function allows token to be purchased by directly&#13;
    /// sending ether to this smart contract.&#13;
    function () payable {&#13;
        issueToken(msg.sender);&#13;
    }&#13;
&#13;
    /// @dev Issue token based on Ether received.&#13;
    /// @param recipient Address that newly issued token will be sent to.&#13;
    function issueToken(address recipient) payable inProgress {&#13;
        // We only accept minimum purchase of 0.01 ETH.&#13;
        assert(msg.value &gt;= 0.01 ether);&#13;
&#13;
        // We only accept maximum purchase of 35 ETH.&#13;
        assert(msg.value &lt;= 35 ether);&#13;
&#13;
        // We only accept totalEthReceived &lt; HARD_CAP&#13;
        uint ethReceived = totalEthReceived + msg.value;&#13;
        assert(ethReceived &lt;= HARD_CAP);&#13;
&#13;
        uint tokens = computeTokenAmount(msg.value);&#13;
        totalEthReceived = totalEthReceived.add(msg.value);&#13;
        &#13;
        balances[msg.sender] = balances[msg.sender].add(tokens);&#13;
        balances[target] = balances[target].sub(tokens);&#13;
&#13;
        Issue(&#13;
            issueIndex++,&#13;
            recipient,&#13;
            msg.value,&#13;
            tokens&#13;
        );&#13;
&#13;
        if (!target.send(msg.value)) {&#13;
            throw;&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * INTERNAL FUNCTIONS&#13;
     */&#13;
  &#13;
    /// @dev Compute the amount of MTC token that can be purchased.&#13;
    /// @param ethAmount Amount of Ether to purchase MTC.&#13;
    /// @return Amount of MTC token to purchase&#13;
    function computeTokenAmount(uint ethAmount) internal constant returns (uint tokens) {&#13;
        uint phase = (block.number - firstblock).div(BLOCKS_PER_PHASE);&#13;
&#13;
        // A safe check&#13;
        if (phase &gt;= bonusPercentages.length) {&#13;
            phase = bonusPercentages.length - 1;&#13;
        }&#13;
&#13;
        uint tokenBase = ethAmount.mul(BASE_RATE);&#13;
        uint tokenBonus = tokenBase.mul(bonusPercentages[phase]).div(100);&#13;
&#13;
        tokens = tokenBase.add(tokenBonus);&#13;
    }&#13;
&#13;
    /// @return true if sale has started, false otherwise.&#13;
    function saleStarted() constant returns (bool) {&#13;
        return (firstblock &gt; 0 &amp;&amp; block.number &gt;= firstblock);&#13;
    }&#13;
&#13;
    /// @return true if sale has ended, false otherwise.&#13;
    function saleEnded() constant returns (bool) {&#13;
        return firstblock &gt; 0 &amp;&amp; (saleDue() || hardCapReached());&#13;
    }&#13;
&#13;
    /// @return true if sale is due when the last phase is finished.&#13;
    function saleDue() constant returns (bool) {&#13;
        return block.number &gt;= firstblock + BLOCKS_PER_PHASE * NUM_OF_PHASE;&#13;
    }&#13;
&#13;
    /// @return true if the hard cap is reached.&#13;
    function hardCapReached() constant returns (bool) {&#13;
        return totalEthReceived &gt;= HARD_CAP;&#13;
    }&#13;
}