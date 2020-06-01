/*
  Copyright 2017 Sharder Foundation.

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
pragma solidity ^0.4.18;

/**
 * Math operations with safety checks
 */
library SafeMath {
    function mul(uint a, uint b) internal pure returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

/**
* @title Sharder Protocol Token.
* For more information about this token sale, please visit https://sharder.org
* @author Ben - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6d15142d1e050c1f09081f43021f0a">[email protected]</a>&gt;.&#13;
* @dev https://github.com/ethereum/EIPs/issues/20&#13;
* @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
*/&#13;
contract SharderToken {&#13;
    using SafeMath for uint;&#13;
    string public constant NAME = "Sharder Storage";&#13;
    string public constant SYMBOL = "SS";&#13;
    uint public constant DECIMALS = 18;&#13;
    uint public totalSupply;&#13;
&#13;
    mapping (address =&gt; mapping (address =&gt; uint256))  public allowed;&#13;
    mapping (address =&gt; uint) public balances;&#13;
&#13;
    /// This is where we hold ether during this crowdsale. We will not transfer any ether&#13;
    /// out of this address before we invocate the `closeCrowdsale` function to finalize the crowdsale.&#13;
    /// This promise is not guanranteed by smart contract by can be verified with public&#13;
    /// Ethereum transactions data available on several blockchain browsers.&#13;
    /// This is the only address from which `startCrowdsale` and `closeCrowdsale` can be invocated.&#13;
    address public owner;&#13;
&#13;
    /// Admin account used to manage after crowdsale&#13;
    address public admin;&#13;
&#13;
    mapping (address =&gt; bool) public accountLockup;&#13;
    mapping (address =&gt; uint) public accountLockupTime;&#13;
    mapping (address =&gt; bool) public frozenAccounts;&#13;
&#13;
    ///   +-----------------------------------------------------------------------------------+&#13;
    ///   |                        SS Token Issue Plan - First Round                          |&#13;
    ///   +-----------------------------------------------------------------------------------+&#13;
    ///   |  Total Sale  |   Airdrop    |  Community Reserve  |  Team Reserve | System Reward |&#13;
    ///   +-----------------------------------------------------------------------------------+&#13;
    ///   |     50%      |     10%      |         10%         |  Don't Issued | Don't Issued  |&#13;
    ///   +-----------------------------------------------------------------------------------+&#13;
    ///   | 250,000,000  |  50,000,000  |     50,000,000      |      None     |      None     |&#13;
    ///   +-----------------------------------------------------------------------------------+&#13;
    uint256 internal constant FIRST_ROUND_ISSUED_SS = 350000000000000000000000000;&#13;
&#13;
    /// Maximum amount of fund to be raised, the sale ends on reaching this amount.&#13;
    uint256 public constant HARD_CAP = 1500 ether;&#13;
&#13;
    /// It will be refuned if crowdsale can't acheive the soft cap, all ethers will be refuned.&#13;
    uint256 public constant SOFT_CAP = 1000 ether;&#13;
&#13;
    /// 1 ether exchange rate&#13;
    /// base the 7-day average close price (Feb.15 through Feb.21, 2018) on CoinMarketCap.com at Feb.21.&#13;
    uint256 public constant BASE_RATE = 20719;&#13;
&#13;
    /// 1 ether == 1000 finney&#13;
    /// Min contribution: 0.1 ether&#13;
    uint256 public constant CONTRIBUTION_MIN = 100 finney;&#13;
&#13;
    /// Max contribution: 5 ether&#13;
    uint256 public constant CONTRIBUTION_MAX = 5000 finney;&#13;
&#13;
    /// Sold SS tokens in crowdsale&#13;
    uint256 public soldSS = 0;&#13;
&#13;
    uint8[2] internal bonusPercentages = [&#13;
    0,&#13;
    0&#13;
    ];&#13;
&#13;
    uint256 internal constant MAX_PROMOTION_SS = 0;&#13;
    uint internal constant NUM_OF_PHASE = 2;&#13;
    /// Each phase contains exactly 78776 Ethereum blocks, which is roughly 15 days,&#13;
    /// See https://www.ethereum.org/crowdsale#scheduling-a-call&#13;
    uint internal constant BLOCKS_PER_PHASE = 78776;&#13;
&#13;
    /// Crowdsale start block number.&#13;
    uint public saleStartAtBlock = 0;&#13;
&#13;
    /// Crowdsale ended block number.&#13;
    uint public saleEndAtBlock = 0;&#13;
&#13;
    /// Unsold ss token whether isssued.&#13;
    bool internal unsoldTokenIssued = false;&#13;
&#13;
    /// Goal whether achieved&#13;
    bool internal isGoalAchieved = false;&#13;
&#13;
    /// Received ether&#13;
    uint256 internal totalEthReceived = 0;&#13;
&#13;
    /// Issue event index starting from 0.&#13;
    uint256 internal issueIndex = 0;&#13;
&#13;
    /*&#13;
     * EVENTS&#13;
     */&#13;
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
    /// address with a minor deduction of transaction fee（gas)&#13;
    event SaleFailed();&#13;
&#13;
    // This notifies clients about the amount to transfer&#13;
    event Transfer(address indexed from, address indexed to, uint256 value);&#13;
&#13;
    // This notifies clients about the amount to approve&#13;
    event Approval(address indexed owner, address indexed spender, uint value);&#13;
&#13;
    // This notifies clients about the amount burnt&#13;
    event Burn(address indexed from, uint256 value);&#13;
&#13;
    /**&#13;
     * Internal transfer, only can be called by this contract&#13;
     */&#13;
    function _transfer(address _from, address _to, uint _value) internal isNotFrozen {&#13;
        // Prevent transfer to 0x0 address. Use burn() instead&#13;
        require(_to != 0x0);&#13;
        // Check if the sender has enough&#13;
        require(balances[_from] &gt;= _value);&#13;
        // Check for overflows&#13;
        require(balances[_to] + _value &gt; balances[_to]);&#13;
        // Save this for an assertion in the future&#13;
        uint previousBalances = balances[_from] + balances[_to];&#13;
        // Subtract from the sender&#13;
        balances[_from] -= _value;&#13;
        // Add the same to the recipient&#13;
        balances[_to] += _value;&#13;
        Transfer(_from, _to, _value);&#13;
        // Asserts are used to use static analysis to find bugs in your code. They should never fail&#13;
        assert(balances[_from] + balances[_to] == previousBalances);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev transfer token for a specified address&#13;
    * @param _to The address to transfer to.&#13;
    * @param _transferTokensWithDecimal The amount to be transferred.&#13;
    */&#13;
    function transfer(address _to, uint _transferTokensWithDecimal) public {&#13;
        _transfer(msg.sender, _to, _transferTokensWithDecimal);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfer tokens from one address to another&#13;
    * @param _from address The address which you want to send tokens from&#13;
    * @param _to address The address which you want to transfer to&#13;
    * @param _transferTokensWithDecimal uint the amout of tokens to be transfered&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint _transferTokensWithDecimal) public returns (bool success) {&#13;
        require(_transferTokensWithDecimal &lt;= allowed[_from][msg.sender]);     // Check allowance&#13;
        allowed[_from][msg.sender] -= _transferTokensWithDecimal;&#13;
        _transfer(_from, _to, _transferTokensWithDecimal);&#13;
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
    /**&#13;
     * Set allowance for other address&#13;
     * Allows `_spender` to spend no more than `_approveTokensWithDecimal` tokens in your behalf&#13;
     *&#13;
     * @param _spender The address authorized to spend&#13;
     * @param _approveTokensWithDecimal the max amount they can spend&#13;
     */&#13;
    function approve(address _spender, uint256 _approveTokensWithDecimal) public isNotFrozen returns (bool success) {&#13;
        allowed[msg.sender][_spender] = _approveTokensWithDecimal;&#13;
        Approval(msg.sender, _spender, _approveTokensWithDecimal);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Function to check the amount of tokens than an owner allowed to a spender.&#13;
     * @param _owner address The address which owns the funds.&#13;
     * @param _spender address The address which will spend the funds.&#13;
     * @return A uint specifing the amount of tokens still avaible for the spender.&#13;
     */&#13;
    function allowance(address _owner, address _spender) internal constant returns (uint remaining) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    /**&#13;
       * Destroy tokens&#13;
       * Remove `_value` tokens from the system irreversibly&#13;
       *&#13;
       * @param _burnedTokensWithDecimal the amount of reserve tokens. !!IMPORTANT is 18 DECIMALS&#13;
       */&#13;
    function burn(uint256 _burnedTokensWithDecimal) public returns (bool success) {&#13;
        require(balances[msg.sender] &gt;= _burnedTokensWithDecimal);   /// Check if the sender has enough&#13;
        balances[msg.sender] -= _burnedTokensWithDecimal;            /// Subtract from the sender&#13;
        totalSupply -= _burnedTokensWithDecimal;                      /// Updates totalSupply&#13;
        Burn(msg.sender, _burnedTokensWithDecimal);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Destroy tokens from other account&#13;
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.&#13;
     *&#13;
     * @param _from the address of the sender&#13;
     * @param _burnedTokensWithDecimal the amount of reserve tokens. !!IMPORTANT is 18 DECIMALS&#13;
     */&#13;
    function burnFrom(address _from, uint256 _burnedTokensWithDecimal) public returns (bool success) {&#13;
        require(balances[_from] &gt;= _burnedTokensWithDecimal);                /// Check if the targeted balance is enough&#13;
        require(_burnedTokensWithDecimal &lt;= allowed[_from][msg.sender]);    /// Check allowance&#13;
        balances[_from] -= _burnedTokensWithDecimal;                        /// Subtract from the targeted balance&#13;
        allowed[_from][msg.sender] -= _burnedTokensWithDecimal;             /// Subtract from the sender's allowance&#13;
        totalSupply -= _burnedTokensWithDecimal;                            /// Update totalSupply&#13;
        Burn(_from, _burnedTokensWithDecimal);&#13;
        return true;&#13;
    }&#13;
&#13;
    /*&#13;
     * MODIFIERS&#13;
     */&#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyAdmin {&#13;
        require(msg.sender == owner || msg.sender == admin);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier beforeStart {&#13;
        require(!saleStarted());&#13;
        _;&#13;
    }&#13;
&#13;
    modifier inProgress {&#13;
        require(saleStarted() &amp;&amp; !saleEnded());&#13;
        _;&#13;
    }&#13;
&#13;
    modifier afterEnd {&#13;
        require(saleEnded());&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isNotFrozen {&#13;
        require( frozenAccounts[msg.sender] != true &amp;&amp; now &gt; accountLockupTime[msg.sender] );&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * CONSTRUCTOR&#13;
     *&#13;
     * @dev Initialize the Sharder Token&#13;
     */&#13;
    function SharderToken() public {&#13;
        owner = msg.sender;&#13;
        admin = msg.sender;&#13;
        totalSupply = FIRST_ROUND_ISSUED_SS;&#13;
    }&#13;
&#13;
    /*&#13;
     * PUBLIC FUNCTIONS&#13;
     */&#13;
&#13;
    ///@dev Set admin account.&#13;
    function setAdmin(address _address) public onlyOwner {&#13;
       admin=_address;&#13;
    }&#13;
&#13;
    ///@dev Set frozen status of account.&#13;
    function setAccountFrozenStatus(address _address, bool _frozenStatus) public onlyAdmin {&#13;
        require(unsoldTokenIssued);&#13;
        frozenAccounts[_address] = _frozenStatus;&#13;
    }&#13;
&#13;
    /// @dev Lockup account till the date. Can't lockup again when this account locked already.&#13;
    /// 1 year = 31536000 seconds&#13;
    /// 0.5 year = 15768000 seconds&#13;
    function lockupAccount(address _address, uint _lockupSeconds) public onlyAdmin {&#13;
        require((accountLockup[_address] &amp;&amp; now &gt; accountLockupTime[_address]) || !accountLockup[_address]);&#13;
&#13;
        // frozen time = now + _lockupSeconds&#13;
        accountLockupTime[_address] = now + _lockupSeconds;&#13;
        accountLockup[_address] = true;&#13;
    }&#13;
&#13;
    /// @dev Start the crowdsale.&#13;
    function startCrowdsale(uint _saleStartAtBlock) public onlyOwner beforeStart {&#13;
        require(_saleStartAtBlock &gt; block.number);&#13;
        saleStartAtBlock = _saleStartAtBlock;&#13;
        SaleStarted();&#13;
    }&#13;
&#13;
    /// @dev Close the crowdsale and issue unsold tokens to `owner` address.&#13;
    function closeCrowdsale() public onlyOwner afterEnd {&#13;
        require(!unsoldTokenIssued);&#13;
&#13;
        if (totalEthReceived &gt;= SOFT_CAP) {&#13;
            saleEndAtBlock = block.number;&#13;
            issueUnsoldToken();&#13;
            SaleSucceeded();&#13;
        } else {&#13;
            SaleFailed();&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev goal achieved ahead of time&#13;
    function goalAchieved() public onlyOwner {&#13;
        require(!isGoalAchieved &amp;&amp; softCapReached());&#13;
        isGoalAchieved = true;&#13;
        closeCrowdsale();&#13;
    }&#13;
&#13;
    /// @dev Returns the current price.&#13;
    function price() public constant returns (uint tokens) {&#13;
        return computeTokenAmount(1 ether);&#13;
    }&#13;
&#13;
    /// @dev This default function allows token to be purchased by directly&#13;
    /// sending ether to this smart contract.&#13;
    function () public payable {&#13;
        issueToken(msg.sender);&#13;
    }&#13;
&#13;
    /// @dev Issue token based on ether received.&#13;
    /// @param recipient Address that newly issued token will be sent to.&#13;
    function issueToken(address recipient) public payable inProgress {&#13;
        // Personal cap check&#13;
        require(balances[recipient].div(BASE_RATE).add(msg.value) &lt;= CONTRIBUTION_MAX);&#13;
        // Contribution cap check&#13;
        require(CONTRIBUTION_MIN &lt;= msg.value &amp;&amp; msg.value &lt;= CONTRIBUTION_MAX);&#13;
&#13;
        uint tokens = computeTokenAmount(msg.value);&#13;
&#13;
        totalEthReceived = totalEthReceived.add(msg.value);&#13;
        soldSS = soldSS.add(tokens);&#13;
&#13;
        balances[recipient] = balances[recipient].add(tokens);&#13;
        Issue(issueIndex++,recipient,msg.value,tokens);&#13;
&#13;
        require(owner.send(msg.value));&#13;
    }&#13;
&#13;
    /// @dev Issue token for reserve.&#13;
    /// @param recipient Address that newly issued reserve token will be sent to.&#13;
    /// @param _issueTokensWithDecimal the amount of reserve tokens. !!IMPORTANT is 18 DECIMALS&#13;
    function issueReserveToken(address recipient, uint256 _issueTokensWithDecimal) onlyOwner public {&#13;
        balances[recipient] = balances[recipient].add(_issueTokensWithDecimal);&#13;
        totalSupply = totalSupply.add(_issueTokensWithDecimal);&#13;
        Issue(issueIndex++,recipient,0,_issueTokensWithDecimal);&#13;
    }&#13;
&#13;
    /*&#13;
     * INTERNAL FUNCTIONS&#13;
     */&#13;
    /// @dev Compute the amount of SS token that can be purchased.&#13;
    /// @param ethAmount Amount of Ether to purchase SS.&#13;
    /// @return Amount of SS token to purchase&#13;
    function computeTokenAmount(uint ethAmount) internal constant returns (uint tokens) {&#13;
        uint phase = (block.number - saleStartAtBlock).div(BLOCKS_PER_PHASE);&#13;
&#13;
        // A safe check&#13;
        if (phase &gt;= bonusPercentages.length) {&#13;
            phase = bonusPercentages.length - 1;&#13;
        }&#13;
&#13;
        uint tokenBase = ethAmount.mul(BASE_RATE);&#13;
&#13;
        //Check promotion supply and phase bonus&#13;
        uint tokenBonus = 0;&#13;
        if(totalEthReceived * BASE_RATE &lt; MAX_PROMOTION_SS) {&#13;
            tokenBonus = tokenBase.mul(bonusPercentages[phase]).div(100);&#13;
        }&#13;
&#13;
        tokens = tokenBase.add(tokenBonus);&#13;
    }&#13;
&#13;
    /// @dev Issue unsold token to `owner` address.&#13;
    function issueUnsoldToken() internal {&#13;
        if (unsoldTokenIssued) {&#13;
            InvalidState("Unsold token has been issued already");&#13;
        } else {&#13;
            // Add another safe guard&#13;
            require(soldSS &gt; 0);&#13;
&#13;
            uint256 unsoldSS = totalSupply.sub(soldSS);&#13;
            // Issue 'unsoldToken' to the admin account.&#13;
            balances[owner] = balances[owner].add(unsoldSS);&#13;
            Issue(issueIndex++,owner,0,unsoldSS);&#13;
&#13;
            unsoldTokenIssued = true;&#13;
        }&#13;
    }&#13;
&#13;
    /// @return true if sale has started, false otherwise.&#13;
    function saleStarted() public constant returns (bool) {&#13;
        return (saleStartAtBlock &gt; 0 &amp;&amp; block.number &gt;= saleStartAtBlock);&#13;
    }&#13;
&#13;
    /// @return true if sale has ended, false otherwise.&#13;
    /// Sale ended in: a) end time of crowdsale reached, b) hard cap reached, c) goal achieved ahead of time&#13;
    function saleEnded() public constant returns (bool) {&#13;
        return saleStartAtBlock &gt; 0 &amp;&amp; (saleDue() || hardCapReached() || isGoalAchieved);&#13;
    }&#13;
&#13;
    /// @return true if sale is due when the last phase is finished.&#13;
    function saleDue() internal constant returns (bool) {&#13;
        return block.number &gt;= saleStartAtBlock + BLOCKS_PER_PHASE * NUM_OF_PHASE;&#13;
    }&#13;
&#13;
    /// @return true if the hard cap is reached.&#13;
    function hardCapReached() internal constant returns (bool) {&#13;
        return totalEthReceived &gt;= HARD_CAP;&#13;
    }&#13;
&#13;
    /// @return true if the soft cap is reached.&#13;
    function softCapReached() internal constant returns (bool) {&#13;
        return totalEthReceived &gt;= SOFT_CAP;&#13;
    }&#13;
}