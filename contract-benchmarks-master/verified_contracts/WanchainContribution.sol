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
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
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
}


pragma solidity ^0.4.11;


/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed
contract Owned {

    /// @dev `owner` is the only address that can call a function with this
    /// modifier
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() {
        owner = msg.sender;
    }

    address public newOwner;

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }


    function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
pragma solidity ^0.4.11;

contract ERC20Protocol {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint supply);
    is replaced with:
    uint public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint remaining);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


pragma solidity ^0.4.11;

//import "./ERC20Protocol.sol";
//import "./SafeMath.sol";

contract StandardToken is ERC20Protocol {
    using SafeMath for uint;

    /**
    * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    function transfer(address _to, uint _value) onlyPayloadSize(2 * 32) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) onlyPayloadSize(2 * 32) returns (bool success) {
        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        assert((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
}




pragma solidity ^0.4.11;


/*

  Copyright 2017 Wanchain Foundation.

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

//                            _           _           _
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/
//
//  Code style according to: https://github.com/wanchain/wanchain-token/blob/master/style-guide.rst



//import "./StandardToken.sol";
//import "./SafeMath.sol";


/// @title Wanchain Token Contract
/// For more information about this token sale, please visit https://wanchain.org
/// @author Cathy - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="482b293c2031083f29262b2029212666273a2f">[email protected]</a>&gt;&#13;
contract WanToken is StandardToken {&#13;
    using SafeMath for uint;&#13;
&#13;
    /// Constant token specific fields&#13;
    string public constant name = "WanCoin";&#13;
    string public constant symbol = "WAN";&#13;
    uint public constant decimals = 18;&#13;
&#13;
    /// Wanchain total tokens supply&#13;
    uint public constant MAX_TOTAL_TOKEN_AMOUNT = 210000000 ether;&#13;
&#13;
    /// Fields that are only changed in constructor&#13;
    /// Wanchain contribution contract&#13;
    address public minter;&#13;
    /// ICO start time&#13;
    uint public startTime;&#13;
    /// ICO end time&#13;
    uint public endTime;&#13;
&#13;
    /// Fields that can be changed by functions&#13;
    mapping (address =&gt; uint) public lockedBalances;&#13;
    /*&#13;
     * MODIFIERS&#13;
     */&#13;
&#13;
    modifier onlyMinter {&#13;
    	  assert(msg.sender == minter);&#13;
    	  _;&#13;
    }&#13;
&#13;
    modifier isLaterThan (uint x){&#13;
    	  assert(now &gt; x);&#13;
    	  _;&#13;
    }&#13;
&#13;
    modifier maxWanTokenAmountNotReached (uint amount){&#13;
    	  assert(totalSupply.add(amount) &lt;= MAX_TOTAL_TOKEN_AMOUNT);&#13;
    	  _;&#13;
    }&#13;
&#13;
    /**&#13;
     * CONSTRUCTOR&#13;
     *&#13;
     * @dev Initialize the Wanchain Token&#13;
     * @param _minter The Wanchain Contribution Contract&#13;
     * @param _startTime ICO start time&#13;
     * @param _endTime ICO End Time&#13;
     */&#13;
    function WanToken(address _minter, uint _startTime, uint _endTime){&#13;
    	  minter = _minter;&#13;
    	  startTime = _startTime;&#13;
    	  endTime = _endTime;&#13;
    }&#13;
&#13;
    /**&#13;
     * EXTERNAL FUNCTION&#13;
     *&#13;
     * @dev Contribution contract instance mint token&#13;
     * @param receipent The destination account owned mint tokens&#13;
     * @param amount The amount of mint token&#13;
     * be sent to this address.&#13;
     */&#13;
    function mintToken(address receipent, uint amount)&#13;
        external&#13;
        onlyMinter&#13;
        maxWanTokenAmountNotReached(amount)&#13;
        returns (bool)&#13;
    {&#13;
      	lockedBalances[receipent] = lockedBalances[receipent].add(amount);&#13;
      	totalSupply = totalSupply.add(amount);&#13;
      	return true;&#13;
    }&#13;
&#13;
    /*&#13;
     * PUBLIC FUNCTIONS&#13;
     */&#13;
&#13;
    /// @dev Locking period has passed - Locked tokens have turned into tradeable&#13;
    ///      All tokens owned by receipent will be tradeable&#13;
    function claimTokens(address receipent)&#13;
        public&#13;
        onlyMinter&#13;
    {&#13;
      	balances[receipent] = balances[receipent].add(lockedBalances[receipent]);&#13;
      	lockedBalances[receipent] = 0;&#13;
    }&#13;
&#13;
    /*&#13;
     * CONSTANT METHODS&#13;
     */&#13;
    function lockedBalanceOf(address _owner) constant returns (uint balance) {&#13;
        return lockedBalances[_owner];&#13;
    }&#13;
}&#13;
&#13;
&#13;
pragma solidity ^0.4.11;&#13;
&#13;
/*&#13;
&#13;
  Copyright 2017 Wanchain Foundation.&#13;
&#13;
  Licensed under the Apache License, Version 2.0 (the "License");&#13;
  you may not use this file except in compliance with the License.&#13;
  You may obtain a copy of the License at&#13;
&#13;
  http://www.apache.org/licenses/LICENSE-2.0&#13;
&#13;
  Unless required by applicable law or agreed to in writing, software&#13;
  distributed under the License is distributed on an "AS IS" BASIS,&#13;
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.&#13;
  See the License for the specific language governing permissions and&#13;
  limitations under the License.&#13;
&#13;
*/&#13;
&#13;
//                            _           _           _&#13;
//  __      ____ _ _ __   ___| |__   __ _(_)_ __   __| | _____   __&#13;
//  \ \ /\ / / _` | '_ \ / __| '_ \ / _` | | '_ \@/ _` |/ _ \ \ / /&#13;
//   \ V  V / (_| | | | | (__| | | | (_| | | | | | (_| |  __/\ V /&#13;
//    \_/\_/ \__,_|_| |_|\___|_| |_|\__,_|_|_| |_|\__,_|\___| \_/&#13;
//&#13;
//  Code style according to: https://github.com/wanchain/wanchain-token/blob/master/style-guide.rst&#13;
&#13;
/// @title Wanchain Contribution Contract&#13;
/// ICO Rules according: https://www.wanchain.org/crowdsale&#13;
/// For more information about this token sale, please visit https://wanchain.org&#13;
/// @author Zane Liang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="215b404f444d48404f466156404f424940484f0f4e5346">[email protected]</a>&gt;&#13;
contract WanchainContribution is Owned {&#13;
    using SafeMath for uint;&#13;
&#13;
    /// Constant fields&#13;
    /// Wanchain total tokens supply&#13;
    uint public constant WAN_TOTAL_SUPPLY = 210000000 ether;&#13;
    uint public constant MAX_CONTRIBUTION_DURATION = 3 days;&#13;
&#13;
    /// Exchange rates for first phase&#13;
    uint public constant PRICE_RATE_FIRST = 880;&#13;
    /// Exchange rates for second phase&#13;
    uint public constant PRICE_RATE_SECOND = 790;&#13;
    /// Exchange rates for last phase&#13;
    uint public constant PRICE_RATE_LAST = 750;&#13;
&#13;
    /// ----------------------------------------------------------------------------------------------------&#13;
    /// |                                                  |                    |                 |        |&#13;
    /// |        PUBLIC SALE (PRESALE + OPEN SALE)         |      DEV TEAM      |    FOUNDATION   |  MINER |&#13;
    /// |                       51%                        |         20%        |       19%       |   10%  |&#13;
    /// ----------------------------------------------------------------------------------------------------&#13;
      /// OPEN_SALE_STAKE + PRESALE_STAKE = 51; 51% sale for public&#13;
      uint public constant OPEN_SALE_STAKE = 459;  // 45.9% for open sale&#13;
      uint public constant PRESALE_STAKE = 51;     // 5.1%  for presale&#13;
&#13;
      // Reserved stakes&#13;
      uint public constant DEV_TEAM_STAKE = 200;   // 20%&#13;
      uint public constant FOUNDATION_STAKE = 190; // 19%&#13;
      uint public constant MINERS_STAKE = 100;     // 10%&#13;
&#13;
      uint public constant DIVISOR_STAKE = 1000;&#13;
&#13;
      /// Holder address for presale and reserved tokens&#13;
      /// TODO: change addressed before deployed to main net&#13;
      address public constant PRESALE_HOLDER = 0xca8f76fd9597e5c0ea5ef0f83381c0635271cd5d;&#13;
&#13;
      // Addresses of Patrons&#13;
      address public constant DEV_TEAM_HOLDER = 0x1631447d041f929595a9c7b0c9c0047de2e76186;&#13;
      address public constant FOUNDATION_HOLDER = 0xe442408a5f2e224c92b34e251de48f5266fc38de;&#13;
      address public constant MINERS_HOLDER = 0x38b195d2a18a4e60292868fa74fae619d566111e;&#13;
&#13;
      uint public MAX_OPEN_SOLD = WAN_TOTAL_SUPPLY * OPEN_SALE_STAKE / DIVISOR_STAKE;&#13;
&#13;
    /// Fields that are only changed in constructor&#13;
    /// All deposited ETH will be instantly forwarded to this address.&#13;
    address public wanport;&#13;
    /// Contribution start time&#13;
    uint public startTime;&#13;
    /// Contribution end time&#13;
    uint public endTime;&#13;
&#13;
    /// Fields that can be changed by functions&#13;
    /// Accumulator for open sold tokens&#13;
    uint openSoldTokens;&#13;
    /// Normal sold tokens&#13;
    uint normalSoldTokens;&#13;
    /// The sum of reserved tokens for ICO stage 1&#13;
    uint public partnerReservedSum;&#13;
    /// Due to an emergency, set this to true to halt the contribution&#13;
    bool public halted;&#13;
    /// ERC20 compilant wanchain token contact instance&#13;
    WanToken public wanToken;&#13;
&#13;
    /// Quota for partners&#13;
    mapping (address =&gt; uint256) public partnersLimit;&#13;
    /// Accumulator for partner sold&#13;
    mapping (address =&gt; uint256) public partnersBought;&#13;
&#13;
    uint256 public normalBuyLimit = 65 ether;&#13;
&#13;
    /*&#13;
     * EVENTS&#13;
     */&#13;
&#13;
    event NewSale(address indexed destAddress, uint ethCost, uint gotTokens);&#13;
    event PartnerAddressQuota(address indexed partnerAddress, uint quota);&#13;
&#13;
    /*&#13;
     * MODIFIERS&#13;
     */&#13;
&#13;
    modifier onlyWallet {&#13;
        require(msg.sender == wanport);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notHalted() {&#13;
        require(!halted);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier initialized() {&#13;
        require(address(wanport) != 0x0);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notEarlierThan(uint x) {&#13;
        require(now &gt;= x);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier earlierThan(uint x) {&#13;
        require(now &lt; x);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ceilingNotReached() {&#13;
        require(openSoldTokens &lt; MAX_OPEN_SOLD);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isSaleEnded() {&#13;
        require(now &gt; endTime || openSoldTokens &gt;= MAX_OPEN_SOLD);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
     * CONSTRUCTOR&#13;
     *&#13;
     * @dev Initialize the Wanchain contribution contract&#13;
     * @param _wanport The escrow account address, all ethers will be sent to this address.&#13;
     * @param _startTime ICO start time&#13;
     */&#13;
    function WanchainContribution(address _wanport, uint _startTime){&#13;
    	require(_wanport != 0x0);&#13;
&#13;
        halted = false;&#13;
    	wanport = _wanport;&#13;
    	startTime = _startTime;&#13;
    	endTime = startTime + MAX_CONTRIBUTION_DURATION;&#13;
        openSoldTokens = 0;&#13;
        partnerReservedSum = 0;&#13;
        normalSoldTokens = 0;&#13;
        /// Create wanchain token contract instance&#13;
    	wanToken = new WanToken(this,startTime, endTime);&#13;
&#13;
        /// Reserve tokens according wanchain ICO rules&#13;
    	uint stakeMultiplier = WAN_TOTAL_SUPPLY / DIVISOR_STAKE;&#13;
&#13;
    	wanToken.mintToken(PRESALE_HOLDER, PRESALE_STAKE * stakeMultiplier);&#13;
        wanToken.mintToken(DEV_TEAM_HOLDER, DEV_TEAM_STAKE * stakeMultiplier);&#13;
        wanToken.mintToken(FOUNDATION_HOLDER, FOUNDATION_STAKE * stakeMultiplier);&#13;
        wanToken.mintToken(MINERS_HOLDER, MINERS_STAKE * stakeMultiplier);&#13;
    }&#13;
&#13;
    /**&#13;
     * Fallback function&#13;
     *&#13;
     * @dev If anybody sends Ether directly to this  contract, consider he is getting wan token&#13;
     */&#13;
    function () public payable notHalted ceilingNotReached{&#13;
    	buyWanCoin(msg.sender);&#13;
    }&#13;
&#13;
    /*&#13;
     * PUBLIC FUNCTIONS&#13;
     */&#13;
&#13;
   function setNormalBuyLimit(uint256 limit)&#13;
        public&#13;
        initialized&#13;
        onlyOwner&#13;
        earlierThan(endTime)&#13;
    {&#13;
        normalBuyLimit = limit;&#13;
    }&#13;
&#13;
    /// @dev Sets the limit for a partner address. All the partner addresses&#13;
    /// will be able to get wan token during the contribution period with his own&#13;
    /// specific limit.&#13;
    /// This method should be called by the owner after the initialization&#13;
    /// and before the contribution end.&#13;
    /// @param setPartnerAddress Partner address&#13;
    /// @param limit Limit for the partner address,the limit is WANTOKEN, not ETHER&#13;
    function setPartnerQuota(address setPartnerAddress, uint256 limit)&#13;
        public&#13;
        initialized&#13;
        onlyOwner&#13;
        earlierThan(endTime)&#13;
    {&#13;
        require(limit &gt; 0 &amp;&amp; limit &lt;= MAX_OPEN_SOLD);&#13;
        partnersLimit[setPartnerAddress] = limit;&#13;
        partnerReservedSum += limit;&#13;
        PartnerAddressQuota(setPartnerAddress, limit);&#13;
    }&#13;
&#13;
    /// @dev Exchange msg.value ether to WAN for account recepient&#13;
    /// @param receipient WAN tokens receiver&#13;
    function buyWanCoin(address receipient)&#13;
        public&#13;
        payable&#13;
        notHalted&#13;
        initialized&#13;
        ceilingNotReached&#13;
        notEarlierThan(startTime)&#13;
        earlierThan(endTime)&#13;
        returns (bool)&#13;
    {&#13;
    	require(receipient != 0x0);&#13;
    	require(msg.value &gt;= 0.1 ether);&#13;
&#13;
    	if (partnersLimit[receipient] &gt; 0)&#13;
    		buyFromPartner(receipient);&#13;
    	else {&#13;
    		require(msg.value &lt;= normalBuyLimit);&#13;
    		buyNormal(receipient);&#13;
    	}&#13;
&#13;
    	return true;&#13;
    }&#13;
&#13;
    /// @dev Emergency situation that requires contribution period to stop.&#13;
    /// Contributing not possible anymore.&#13;
    function halt() public onlyWallet{&#13;
        halted = true;&#13;
    }&#13;
&#13;
    /// @dev Emergency situation resolved.&#13;
    /// Contributing becomes possible again withing the outlined restrictions.&#13;
    function unHalt() public onlyWallet{&#13;
        halted = false;&#13;
    }&#13;
&#13;
    /// @dev Emergency situation&#13;
    function changeWalletAddress(address newAddress) onlyWallet {&#13;
        wanport = newAddress;&#13;
    }&#13;
&#13;
    /// @return true if sale has started, false otherwise.&#13;
    function saleStarted() constant returns (bool) {&#13;
        return now &gt;= startTime;&#13;
    }&#13;
&#13;
    /// @return true if sale has ended, false otherwise.&#13;
    function saleEnded() constant returns (bool) {&#13;
        return now &gt; endTime || openSoldTokens &gt;= MAX_OPEN_SOLD;&#13;
    }&#13;
&#13;
    /// CONSTANT METHODS&#13;
    /// @dev Get current exchange rate&#13;
    function priceRate() public constant returns (uint) {&#13;
        // Three price tiers&#13;
        if (startTime &lt;= now &amp;&amp; now &lt; startTime + 1 days)&#13;
            return PRICE_RATE_FIRST;&#13;
        if (startTime + 1 days &lt;= now &amp;&amp; now &lt; startTime + 2 days)&#13;
            return PRICE_RATE_SECOND;&#13;
        if (startTime + 2 days &lt;= now &amp;&amp; now &lt; endTime)&#13;
            return PRICE_RATE_LAST;&#13;
        // Should not be called before or after contribution period&#13;
        assert(false);&#13;
    }&#13;
&#13;
&#13;
    function claimTokens(address receipent)&#13;
      public&#13;
      isSaleEnded&#13;
    {&#13;
&#13;
      wanToken.claimTokens(receipent);&#13;
&#13;
    }&#13;
&#13;
    /*&#13;
     * INTERNAL FUNCTIONS&#13;
     */&#13;
&#13;
    /// @dev Buy wanchain tokens by partners&#13;
    function buyFromPartner(address receipient) internal {&#13;
    	uint partnerAvailable = partnersLimit[receipient].sub(partnersBought[receipient]);&#13;
	    uint allAvailable = MAX_OPEN_SOLD.sub(openSoldTokens);&#13;
      partnerAvailable = partnerAvailable.min256(allAvailable);&#13;
&#13;
    	require(partnerAvailable &gt; 0);&#13;
&#13;
    	uint toFund;&#13;
    	uint toCollect;&#13;
    	(toFund,  toCollect)= costAndBuyTokens(partnerAvailable);&#13;
&#13;
    	partnersBought[receipient] = partnersBought[receipient].add(toCollect);&#13;
&#13;
    	buyCommon(receipient, toFund, toCollect);&#13;
&#13;
    }&#13;
&#13;
    /// @dev Buy wanchain token normally&#13;
    function buyNormal(address receipient) internal {&#13;
        // Do not allow contracts to game the system&#13;
        require(!isContract(msg.sender));&#13;
&#13;
        // protect partner quota in stage one&#13;
        uint tokenAvailable;&#13;
        if(startTime &lt;= now &amp;&amp; now &lt; startTime + 1 days) {&#13;
            uint totalNormalAvailable = MAX_OPEN_SOLD.sub(partnerReservedSum);&#13;
            tokenAvailable = totalNormalAvailable.sub(normalSoldTokens);&#13;
        } else {&#13;
            tokenAvailable = MAX_OPEN_SOLD.sub(openSoldTokens);&#13;
        }&#13;
&#13;
        require(tokenAvailable &gt; 0);&#13;
&#13;
    	uint toFund;&#13;
    	uint toCollect;&#13;
    	(toFund, toCollect) = costAndBuyTokens(tokenAvailable);&#13;
        buyCommon(receipient, toFund, toCollect);&#13;
        normalSoldTokens += toCollect;&#13;
    }&#13;
&#13;
    /// @dev Utility function for bug wanchain token&#13;
    function buyCommon(address receipient, uint toFund, uint wanTokenCollect) internal {&#13;
        require(msg.value &gt;= toFund); // double check&#13;
&#13;
        if(toFund &gt; 0) {&#13;
            require(wanToken.mintToken(receipient, wanTokenCollect));&#13;
            wanport.transfer(toFund);&#13;
            openSoldTokens = openSoldTokens.add(wanTokenCollect);&#13;
            NewSale(receipient, toFund, wanTokenCollect);&#13;
        }&#13;
&#13;
        uint toReturn = msg.value.sub(toFund);&#13;
        if(toReturn &gt; 0) {&#13;
            msg.sender.transfer(toReturn);&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Utility function for calculate available tokens and cost ethers&#13;
    function costAndBuyTokens(uint availableToken) constant internal returns (uint costValue, uint getTokens){&#13;
    	// all conditions has checked in the caller functions&#13;
    	uint exchangeRate = priceRate();&#13;
    	getTokens = exchangeRate * msg.value;&#13;
&#13;
    	if(availableToken &gt;= getTokens){&#13;
    		costValue = msg.value;&#13;
    	} else {&#13;
    		costValue = availableToken / exchangeRate;&#13;
    		getTokens = availableToken;&#13;
    	}&#13;
&#13;
    }&#13;
&#13;
    /// @dev Internal function to determine if an address is a contract&#13;
    /// @param _addr The address being queried&#13;
    /// @return True if `_addr` is a contract&#13;
    function isContract(address _addr) constant internal returns(bool) {&#13;
        uint size;&#13;
        if (_addr == 0) return false;&#13;
        assembly {&#13;
            size := extcodesize(_addr)&#13;
        }&#13;
        return size &gt; 0;&#13;
    }&#13;
}