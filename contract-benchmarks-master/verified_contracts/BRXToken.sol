pragma solidity ^0.4.19;

/**
 * BRX.SPACE (<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6c0f0302180d0f182c0e1e14421f1c0d0f09">[email protected]</a>)&#13;
 * &#13;
 * BRX token is a virtual token, governed by ERC20-compatible&#13;
 * Ethereum Smart Contract and secured by Ethereum Blockchain&#13;
 *&#13;
 * The official website is https://brx.space&#13;
 * &#13;
 * The uints are all in wei and atto tokens (*10^-18)&#13;
&#13;
 * The contract code itself, as usual, is at the end, after all the connected libraries&#13;
 * Developed by 262dfb6c55bf6ac215fac30181bdbfb8a2872cc7e3ea7cffe3a001621bb559e2&#13;
 */&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
  function mul(uint a, uint b) internal pure returns (uint) {&#13;
    uint c = a * b;&#13;
    assert(a == 0 || c / a == b);&#13;
    return c;&#13;
  }&#13;
  function div(uint a, uint b) internal pure returns (uint) {&#13;
    uint c = a / b;&#13;
    return c;&#13;
  }&#13;
  function sub(uint a, uint b) internal pure returns (uint) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
  function add(uint a, uint b) internal pure returns (uint) {&#13;
    uint c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {&#13;
    return a &gt;= b ? a : b;&#13;
  }&#13;
  function min64(uint64 a, uint64 b) internal pure returns (uint64) {&#13;
    return a &lt; b ? a : b;&#13;
  }&#13;
  function max256(uint a, uint b) internal pure returns (uint) {&#13;
    return a &gt;= b ? a : b;&#13;
  }&#13;
  function min256(uint a, uint b) internal pure returns (uint) {&#13;
    return a &lt; b ? a : b;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  uint public totalSupply;&#13;
  function balanceOf(address who) public constant returns (uint);&#13;
  function transfer(address to, uint value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint value);&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) public constant returns (uint);&#13;
  function transferFrom(address from, address to, uint value) public returns (bool);&#13;
  function approve(address spender, uint value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint value);&#13;
}&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint;&#13;
&#13;
  mapping(address =&gt; uint) balances;&#13;
&#13;
  /**&#13;
   * Fix for the ERC20 short address attack  &#13;
   */&#13;
  modifier onlyPayloadSize(uint size) {&#13;
   require(msg.data.length &gt;= size + 4);&#13;
   _;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) returns (bool) {&#13;
    require(_to != address(0) &amp;&amp;&#13;
        _value &lt;= balances[msg.sender]);&#13;
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
  * @return An uint representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) public constant returns (uint balance) {&#13;
    return balances[_owner];&#13;
  }&#13;
  &#13;
}&#13;
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
  mapping (address =&gt; mapping (address =&gt; uint)) internal allowed;&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _to address The address which you want to transfer to&#13;
   * @param _value uint the amount of tokens to be transferred&#13;
   */&#13;
  function transferFrom(address _from, address _to, uint _value) public returns (bool) {&#13;
    require(_to != address(0) &amp;&amp;&#13;
        _value &lt;= balances[_from] &amp;&amp;&#13;
        _value &lt;= allowed[_from][msg.sender]);&#13;
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
  function approve(address _spender, uint _value) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = _value;&#13;
    Approval(msg.sender, _spender, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
   * @param _owner address The address which owns the funds.&#13;
   * @param _spender address The address which will spend the funds.&#13;
   * @return A uint specifying the amount of tokens still available for the spender.&#13;
   */&#13;
  function allowance(address _owner, address _spender) public constant returns (uint remaining) {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {&#13;
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {&#13;
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
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  function Ownable() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
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
&#13;
contract BRXToken is StandardToken, Ownable {&#13;
  using SafeMath for uint;&#13;
&#13;
  //---------------  Info for ERC20 explorers  -----------------//&#13;
  string public constant name = "BRX Coin";&#13;
  string public constant symbol = "BRX";&#13;
  uint8 public constant decimals = 18;&#13;
&#13;
  //----------------------  Constants  -------------------------//&#13;
  uint private constant atto = 1000000000000000000;&#13;
  uint private constant INITIAL_SUPPLY = 15000000 * atto; // 15 mln BRX. Impossible to mint more than this&#13;
  uint public totalSupply = INITIAL_SUPPLY;&#13;
&#13;
  //----------------------  Variables  -------------------------//&#13;
  // Made up ICO address (designating the token pool reserved for ICO, no one has access to it)&#13;
  address public ico_address = 0x1F01f01f01f01F01F01f01F01F01f01F01f01F01;&#13;
  address public teamWallet = 0x58096c1dCd5f338530770B1f6Fe0AcdfB90Cc87B;&#13;
  address public addrBRXPay = 0x2F02F02F02F02f02f02f02f02F02F02f02f02f02;&#13;
&#13;
  uint private current_supply = 0; // Holding the number of all the coins in existence&#13;
  uint private ico_starting_supply = 0; // How many atto tokens *were* available for sale at the beginning of the ICO&#13;
  uint private current_price_atto_tokens_per_wei = 0; // Holding current price (determined by the algorithm in buy())&#13;
&#13;
  //--------------  Flags describing ICO stages  ---------------//&#13;
  bool private preSoldSharesDistributed = false; // Prevents accidental re-distribution of shares&#13;
  bool private isICOOpened = false;&#13;
  bool private isICOClosed = false;&#13;
  // 3 stages:&#13;
  // Contract has just been deployed and initialized. isICOOpened == false, isICOClosed == false&#13;
  // ICO has started, now anybody can buy(). isICOOpened == true, isICOClosed == false&#13;
  // ICO has finished, now the team can receive the ether. isICOOpened == false, isICOClosed == true&#13;
&#13;
  //-------------------  Founder Members  ----------------------//&#13;
  uint public founderMembers = 0;&#13;
  mapping(uint =&gt; address) private founderOwner;&#13;
  mapping(address =&gt; uint) founderMembersInvest;&#13;
  &#13;
  //----------------------  Premiums  --------------------------//&#13;
  uint[] private premiumPacks;&#13;
  mapping(address =&gt; bool) private premiumICOMember;&#13;
  mapping(address =&gt; uint) private premiumPacksPaid;&#13;
  mapping(address =&gt; bool) public frozenAccounts;&#13;
&#13;
  //-----------------------  Events  ---------------------------//&#13;
  event ICOOpened();&#13;
  event ICOClosed();&#13;
&#13;
  event PriceChanged(uint old_price, uint new_price);&#13;
  event SupplyChanged(uint supply, uint old_supply);&#13;
&#13;
  event FrozenFund(address _from, bool _freeze);&#13;
&#13;
  event BRXAcquired(address account, uint amount_in_wei, uint amount_in_brx);&#13;
  event BRXNewFounder(address account, uint amount_in_brx);&#13;
&#13;
  // ***************************************************************************&#13;
  // Constructor&#13;
&#13;
  function BRXToken() public {&#13;
    // Some percentage of the tokens is already reserved by early employees and investors&#13;
    // Here we're initializing their balances&#13;
    distributePreSoldShares();&#13;
&#13;
    // Starting price&#13;
    current_price_atto_tokens_per_wei = calculateCurrentPrice(1);&#13;
&#13;
    // Some other initializations&#13;
    premiumPacks.length = 0;&#13;
  }&#13;
&#13;
  // Sending ether directly to the contract invokes buy() and assigns tokens to the sender&#13;
  function () public payable {&#13;
    buy();&#13;
  }&#13;
&#13;
  // ------------------------------------------------------------------------&#13;
  // Owner can transfer out any accidentally sent ERC20 tokens&#13;
  // ------------------------------------------------------------------------&#13;
  function transferAnyERC20Token(&#13;
    address tokenAddress, uint tokens&#13;
  ) public onlyOwner&#13;
    returns (bool success) {&#13;
    return StandardToken(tokenAddress).transfer(owner, tokens);&#13;
  }&#13;
&#13;
  // ***************************************************************************&#13;
&#13;
  // Buy token by sending ether here&#13;
  //&#13;
  // Price is being determined by the algorithm in recalculatePrice()&#13;
  // You can also send the ether directly to the contract address&#13;
  function buy() public payable {&#13;
    require(msg.value != 0 &amp;&amp; isICOOpened == true &amp;&amp; isICOClosed == false);&#13;
&#13;
    // Deciding how many tokens can be bought with the ether received&#13;
    uint tokens = getAttoTokensAmountPerWeiInternal(msg.value);&#13;
&#13;
    // Don't allow to buy more than 1% per transaction (secures from huge investors swalling the whole thing in 1 second)&#13;
    uint allowedInOneTransaction = current_supply / 100;&#13;
    require(tokens &lt; allowedInOneTransaction &amp;&amp;&#13;
        tokens &lt;= balances[ico_address]);&#13;
&#13;
    // Transfer from the ICO pool&#13;
    balances[ico_address] = balances[ico_address].sub(tokens); // if not enough, will throw&#13;
    balances[msg.sender] = balances[msg.sender].add(tokens);&#13;
    premiumICOMember[msg.sender] = true;&#13;
    &#13;
    // Check if sender has become a founder member&#13;
    if (balances[msg.sender] &gt;= 2000000000000000000000) {&#13;
        if (founderMembersInvest[msg.sender] == 0) {&#13;
            founderOwner[founderMembers] = msg.sender;&#13;
            founderMembers++; BRXNewFounder(msg.sender, balances[msg.sender]);&#13;
        }&#13;
        founderMembersInvest[msg.sender] = balances[msg.sender];&#13;
    }&#13;
&#13;
    // Kick the price changing algo&#13;
    uint old_price = current_price_atto_tokens_per_wei;&#13;
    current_price_atto_tokens_per_wei = calculateCurrentPrice(getAttoTokensBoughtInICO());&#13;
    if (current_price_atto_tokens_per_wei == 0) current_price_atto_tokens_per_wei = 1; // in case it is too small that it gets rounded to zero&#13;
    if (current_price_atto_tokens_per_wei &gt; old_price) current_price_atto_tokens_per_wei = old_price; // in case some weird overflow happens&#13;
&#13;
    // Broadcasting price change event&#13;
    if (old_price != current_price_atto_tokens_per_wei) PriceChanged(old_price, current_price_atto_tokens_per_wei);&#13;
&#13;
    // Broadcasting the buying event&#13;
    BRXAcquired(msg.sender, msg.value, tokens);&#13;
  }&#13;
&#13;
  // Formula for the dynamic price change algorithm&#13;
  function calculateCurrentPrice(&#13;
    uint attoTokensBought&#13;
  ) private pure&#13;
    returns (uint result) {&#13;
    // see http://www.wolframalpha.com/input/?i=f(x)+%3D+395500000+%2F+(x+%2B+150000)+-+136&#13;
    // mixing safe and usual math here because the division will throw on inconsistency&#13;
    return (395500000 / ((attoTokensBought / atto) + 150000)).sub(136);&#13;
  }&#13;
&#13;
  // ***************************************************************************&#13;
  // Functions for the contract owner&#13;
&#13;
  function openICO() public onlyOwner {&#13;
    require(isICOOpened == false &amp;&amp; isICOClosed == false);&#13;
    isICOOpened = true;&#13;
&#13;
    ICOOpened();&#13;
  }&#13;
  function closeICO() public onlyOwner {&#13;
    require(isICOClosed == false &amp;&amp; isICOOpened == true);&#13;
&#13;
    isICOOpened = false;&#13;
    isICOClosed = true;&#13;
&#13;
    // Redistribute ICO Tokens that were not bought as the first premiums&#13;
    premiumPacks.length = 1;&#13;
    premiumPacks[0] = balances[ico_address];&#13;
    balances[ico_address] = 0;&#13;
&#13;
    ICOClosed();&#13;
  }&#13;
  function pullEtherFromContract() public onlyOwner {&#13;
    require(isICOClosed == true); // Only when ICO is closed&#13;
    if (!teamWallet.send(this.balance)) {&#13;
      revert();&#13;
    }&#13;
  }&#13;
  function freezeAccount(&#13;
    address _from, bool _freeze&#13;
  ) public onlyOwner&#13;
    returns (bool) {&#13;
    frozenAccounts[_from] = _freeze;&#13;
    FrozenFund(_from, _freeze);  &#13;
    return true;&#13;
  }&#13;
  function setNewBRXPay(&#13;
    address newBRXPay&#13;
  ) public onlyOwner {&#13;
    require(newBRXPay != address(0));&#13;
    addrBRXPay = newBRXPay;&#13;
  }&#13;
  function transferFromBRXPay(&#13;
    address _from, address _to, uint _value&#13;
  ) public allowedPayments&#13;
    returns (bool) {&#13;
    require(msg.sender == addrBRXPay &amp;&amp; balances[_to].add(_value) &gt; balances[_to] &amp;&amp;&#13;
    _value &lt;= balances[_from] &amp;&amp; !frozenAccounts[_from] &amp;&amp;&#13;
    !frozenAccounts[_to] &amp;&amp; _to != address(0));&#13;
    &#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
  function setCurrentPricePerWei(&#13;
    uint _new_price  &#13;
  ) public onlyOwner&#13;
  returns (bool) {&#13;
    require(isICOClosed == true &amp;&amp; _new_price &gt; 0); // Only when ICO is closed&#13;
    uint old_price = current_price_atto_tokens_per_wei;&#13;
    current_price_atto_tokens_per_wei = _new_price;&#13;
    PriceChanged(old_price, current_price_atto_tokens_per_wei);&#13;
  }&#13;
&#13;
  // ***************************************************************************&#13;
  // Some percentage of the tokens is already reserved by early employees and investors&#13;
  // Here we're initializing their balances&#13;
&#13;
  function distributePreSoldShares() private onlyOwner {&#13;
    // Making it impossible to call this function twice&#13;
    require(preSoldSharesDistributed == false);&#13;
    preSoldSharesDistributed = true;&#13;
&#13;
    // Values are in atto tokens&#13;
    balances[0xAEC5cbcCF89fc25e955A53A5a015f7702a14b629] = 7208811 * atto;&#13;
    balances[0xAECDCB2a8e2cFB91869A9af30050BEa038034949] = 4025712 * atto;&#13;
    balances[0xAECF0B1b6897195295FeeD1146F3732918a5b3E4] = 300275 * atto;&#13;
    balances[0xAEC80F0aC04f389E84F3f4b39827087e393EB229] = 150000 * atto;&#13;
    balances[0xAECc9545385d858D3142023d3c298a1662Aa45da] = 150000 * atto;&#13;
    balances[0xAECE71616d07F609bd2CbD4122FbC9C4a2D11A9D] = 90000 * atto;&#13;
    balances[0xAECee3E9686825e0c8ea65f1bC8b1aB613545B8e] = 75000 * atto;&#13;
    balances[0xAECC8E8908cE17Dd6dCFFFDCCD561696f396148F] = 202 * atto;&#13;
    current_supply = (7208811 + 4025712 + 300275 + 150000 + 150000 + 90000 + 75000 + 202) * atto;&#13;
&#13;
    // Sending the rest to ICO pool&#13;
    balances[ico_address] = INITIAL_SUPPLY.sub(current_supply);&#13;
&#13;
    // Initializing the supply variables&#13;
    ico_starting_supply = balances[ico_address];&#13;
    current_supply = INITIAL_SUPPLY;&#13;
    SupplyChanged(0, current_supply);&#13;
  }&#13;
&#13;
  // ***************************************************************************&#13;
  // Some useful getters (although you can just query the public variables)&#13;
&#13;
  function getIcoStatus() public view&#13;
    returns (string result) {&#13;
    return (isICOClosed) ? 'closed' : (isICOOpened) ? 'opened' : 'not opened' ;&#13;
  }&#13;
  function getCurrentPricePerWei() public view&#13;
    returns (uint result) {&#13;
    return current_price_atto_tokens_per_wei;&#13;
  }&#13;
  function getAttoTokensAmountPerWeiInternal(&#13;
    uint value&#13;
  ) public payable&#13;
    returns (uint result) {&#13;
    return value * current_price_atto_tokens_per_wei;&#13;
  }&#13;
  function getAttoTokensAmountPerWei(&#13;
    uint value&#13;
  ) public view&#13;
  returns (uint result) {&#13;
    return value * current_price_atto_tokens_per_wei;&#13;
  }&#13;
  function getAttoTokensLeftForICO() public view&#13;
    returns (uint result) {&#13;
    return balances[ico_address];&#13;
  }&#13;
  function getAttoTokensBoughtInICO() public view&#13;
    returns (uint result) {&#13;
    return ico_starting_supply - getAttoTokensLeftForICO();&#13;
  }&#13;
  function getPremiumPack(uint index) public view&#13;
    returns (uint premium) {&#13;
    return premiumPacks[index];&#13;
  }&#13;
  function getPremiumsAvailable() public view&#13;
    returns (uint length) {&#13;
    return premiumPacks.length;&#13;
  }&#13;
  function getBalancePremiumsPaid(&#13;
    address account&#13;
  ) public view&#13;
    returns (uint result) {&#13;
    return premiumPacksPaid[account];&#13;
  }&#13;
  function getAttoTokensToBeFounder() public view&#13;
  returns (uint result) {&#13;
    return 2000000000000000000000 / getCurrentPricePerWei();&#13;
  }&#13;
  function getFounderMembersInvest(&#13;
    address account&#13;
  ) public view&#13;
    returns (uint result) {&#13;
    return founderMembersInvest[account];&#13;
  }&#13;
  function getFounderMember(&#13;
    uint index&#13;
  ) public onlyOwner view&#13;
    returns (address account) {&#13;
    require(founderMembers &gt;= index &amp;&amp; founderOwner[index] != address(0));&#13;
    return founderOwner[index];&#13;
  }&#13;
&#13;
  // ***************************************************************************&#13;
  // Premiums&#13;
&#13;
  function sendPremiumPack(&#13;
    uint amount&#13;
  ) public onlyOwner allowedPayments {&#13;
    premiumPacks.length += 1;&#13;
    premiumPacks[premiumPacks.length-1] = amount;&#13;
    balances[msg.sender] = balances[msg.sender].sub(amount); // will throw and revert the whole thing if doesn't have this amount&#13;
  }&#13;
  function getPremiums() public allowedPayments&#13;
    returns (uint amount) {&#13;
    require(premiumICOMember[msg.sender]);&#13;
    if (premiumPacks.length &gt; premiumPacksPaid[msg.sender]) {&#13;
      uint startPackIndex = premiumPacksPaid[msg.sender];&#13;
      uint finishPackIndex = premiumPacks.length - 1;&#13;
      uint owingTotal = 0;&#13;
      for(uint i = startPackIndex; i &lt;= finishPackIndex; i++) {&#13;
        if (current_supply != 0) { // just in case&#13;
          uint owing = balances[msg.sender] * premiumPacks[i] / current_supply;&#13;
          balances[msg.sender] = balances[msg.sender].add(owing);&#13;
          owingTotal = owingTotal + owing;&#13;
        }&#13;
      }&#13;
      premiumPacksPaid[msg.sender] = premiumPacks.length;&#13;
      return owingTotal;&#13;
    } else {&#13;
      revert();&#13;
    }&#13;
  }&#13;
&#13;
  // ***************************************************************************&#13;
  // Overriding payment functions to take control over the logic&#13;
&#13;
  modifier allowedPayments() {&#13;
    // Don't allow to transfer coins until the ICO ends&#13;
    require(isICOOpened == false &amp;&amp; isICOClosed == true &amp;&amp; !frozenAccounts[msg.sender]);&#13;
    _;&#13;
  }&#13;
  &#13;
  function transferFrom(&#13;
    address _from, address _to, uint _value&#13;
  ) public allowedPayments&#13;
    returns (bool) {&#13;
    super.transferFrom(_from, _to, _value);&#13;
  }&#13;
  &#13;
  function transfer(&#13;
    address _to, uint _value&#13;
  ) public onlyPayloadSize(2 * 32) allowedPayments&#13;
    returns (bool) {&#13;
    super.transfer(_to, _value);&#13;
  }&#13;
&#13;
}