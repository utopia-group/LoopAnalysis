pragma solidity ^0.4.25;

/* solium-disable error-reason */

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8efcebe3ede1cebc">[email protected]</a>π.com&gt;, Eenae &lt;alexe<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="235a634e4a5b415a5746500d4a4c">[email protected]</a>&gt;&#13;
 * @dev If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
    /// @dev counter to allow mutex lock with only one SSTORE operation&#13;
    uint256 private _guardCounter;&#13;
&#13;
    constructor () internal {&#13;
        // The counter starts at one to prevent changing it from zero to a non-zero&#13;
        // value, which is a more expensive operation.&#13;
        _guardCounter = 1;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
     * Calling a `nonReentrant` function from another `nonReentrant`&#13;
     * function is not supported. It is possible to prevent this from happening&#13;
     * by making the `nonReentrant` function external, and make it call a&#13;
     * `private` function that does the actual work.&#13;
     */&#13;
    modifier nonReentrant() {&#13;
        _guardCounter += 1;&#13;
        uint256 localCounter = _guardCounter;&#13;
        _;&#13;
        require(localCounter == _guardCounter);&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title Crowdsale&#13;
 * @dev Crowdsale is a base contract for managing a token crowdsale,&#13;
 * allowing investors to purchase tokens with ether. This contract implements&#13;
 * such functionality in its most fundamental form and can be extended to provide additional&#13;
 * functionality and/or custom behavior.&#13;
 * The external interface represents the basic interface for purchasing tokens, and conform&#13;
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.&#13;
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override&#13;
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate&#13;
 * behavior.&#13;
 */&#13;
contract Crowdsale is ReentrancyGuard {&#13;
    using SafeMath for uint256;&#13;
    using SafeERC20 for IERC20;&#13;
&#13;
    // The token being sold&#13;
    IERC20 private _token;&#13;
&#13;
    // Address where funds are collected&#13;
    address private _wallet;&#13;
&#13;
    // How many token units a buyer gets per wei.&#13;
    // The rate is the conversion between wei and the smallest and indivisible token unit.&#13;
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK&#13;
    // 1 wei will give you 1 unit, or 0.001 TOK.&#13;
    uint256 private _rate;&#13;
&#13;
    // Amount of wei raised&#13;
    uint256 private _weiRaised;&#13;
&#13;
    /**&#13;
     * Event for token purchase logging&#13;
     * @param purchaser who paid for the tokens&#13;
     * @param beneficiary who got the tokens&#13;
     * @param value weis paid for purchase&#13;
     * @param amount amount of tokens purchased&#13;
     */&#13;
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);&#13;
&#13;
    /**&#13;
     * @param rate Number of token units a buyer gets per wei&#13;
     * @dev The rate is the conversion between wei and the smallest and indivisible&#13;
     * token unit. So, if you are using a rate of 1 with a ERC20Detailed token&#13;
     * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.&#13;
     * @param wallet Address where collected funds will be forwarded to&#13;
     * @param token Address of the token being sold&#13;
     */&#13;
    constructor (uint256 rate, address wallet, IERC20 token) internal {&#13;
        require(rate &gt; 0);&#13;
        require(wallet != address(0));&#13;
        require(token != address(0));&#13;
&#13;
        _rate = rate;&#13;
        _wallet = wallet;&#13;
        _token = token;&#13;
    }&#13;
&#13;
    // -----------------------------------------&#13;
    // Crowdsale external interface&#13;
    // -----------------------------------------&#13;
&#13;
    /**&#13;
     * @dev fallback function ***DO NOT OVERRIDE***&#13;
     * Note that other contracts will transfer fund with a base gas stipend&#13;
     * of 2300, which is not enough to call buyTokens. Consider calling&#13;
     * buyTokens directly when purchasing tokens from a contract.&#13;
     */&#13;
    function () external payable {&#13;
        buyTokens(msg.sender);&#13;
    }&#13;
&#13;
    /**&#13;
     * @return the token being sold.&#13;
     */&#13;
    function token() public view returns (IERC20) {&#13;
        return _token;&#13;
    }&#13;
&#13;
    /**&#13;
     * @return the address where funds are collected.&#13;
     */&#13;
    function wallet() public view returns (address) {&#13;
        return _wallet;&#13;
    }&#13;
&#13;
    /**&#13;
     * @return the number of token units a buyer gets per wei.&#13;
     */&#13;
    function rate() public view returns (uint256) {&#13;
        return _rate;&#13;
    }&#13;
&#13;
    /**&#13;
     * @return the amount of wei raised.&#13;
     */&#13;
    function weiRaised() public view returns (uint256) {&#13;
        return _weiRaised;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev low level token purchase ***DO NOT OVERRIDE***&#13;
     * This function has a non-reentrancy guard, so it shouldn't be called by&#13;
     * another `nonReentrant` function.&#13;
     * @param beneficiary Recipient of the token purchase&#13;
     */&#13;
    function buyTokens(address beneficiary) public nonReentrant payable {&#13;
        uint256 weiAmount = msg.value;&#13;
        _preValidatePurchase(beneficiary, weiAmount);&#13;
&#13;
        // calculate token amount to be created&#13;
        uint256 tokens = _getTokenAmount(weiAmount);&#13;
&#13;
        // update state&#13;
        _weiRaised = _weiRaised.add(weiAmount);&#13;
&#13;
        _processPurchase(beneficiary, tokens);&#13;
        emit TokensPurchased(msg.sender, beneficiary, weiAmount, tokens);&#13;
&#13;
        _updatePurchasingState(beneficiary, weiAmount);&#13;
&#13;
        _forwardFunds();&#13;
        _postValidatePurchase(beneficiary, weiAmount);&#13;
    }&#13;
&#13;
    // -----------------------------------------&#13;
    // Internal interface (extensible)&#13;
    // -----------------------------------------&#13;
&#13;
    /**&#13;
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.&#13;
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:&#13;
     *     super._preValidatePurchase(beneficiary, weiAmount);&#13;
     *     require(weiRaised().add(weiAmount) &lt;= cap);&#13;
     * @param beneficiary Address performing the token purchase&#13;
     * @param weiAmount Value in wei involved in the purchase&#13;
     */&#13;
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {&#13;
        require(beneficiary != address(0));&#13;
        require(weiAmount != 0);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.&#13;
     * @param beneficiary Address performing the token purchase&#13;
     * @param weiAmount Value in wei involved in the purchase&#13;
     */&#13;
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {&#13;
        // optional override&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.&#13;
     * @param beneficiary Address performing the token purchase&#13;
     * @param tokenAmount Number of tokens to be emitted&#13;
     */&#13;
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {&#13;
        _token.safeTransfer(beneficiary, tokenAmount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send tokens.&#13;
     * @param beneficiary Address receiving the tokens&#13;
     * @param tokenAmount Number of tokens to be purchased&#13;
     */&#13;
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {&#13;
        _deliverTokens(beneficiary, tokenAmount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)&#13;
     * @param beneficiary Address receiving the tokens&#13;
     * @param weiAmount Value in wei involved in the purchase&#13;
     */&#13;
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {&#13;
        // optional override&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Override to extend the way in which ether is converted to tokens.&#13;
     * @param weiAmount Value in wei to be converted into tokens&#13;
     * @return Number of tokens that can be purchased with the specified _weiAmount&#13;
     */&#13;
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {&#13;
        return weiAmount.mul(_rate);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Determines how ETH is stored/forwarded on purchases.&#13;
     */&#13;
    function _forwardFunds() internal {&#13;
        _wallet.transfer(msg.value);&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title CappedCrowdsale&#13;
 * @dev Crowdsale with a limit for total contributions.&#13;
 */&#13;
contract CappedCrowdsale is Crowdsale {&#13;
    using SafeMath for uint256;&#13;
&#13;
    uint256 private _cap;&#13;
&#13;
    /**&#13;
     * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.&#13;
     * @param cap Max amount of wei to be contributed&#13;
     */&#13;
    constructor (uint256 cap) internal {&#13;
        require(cap &gt; 0);&#13;
        _cap = cap;&#13;
    }&#13;
&#13;
    /**&#13;
     * @return the cap of the crowdsale.&#13;
     */&#13;
    function cap() public view returns (uint256) {&#13;
        return _cap;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Checks whether the cap has been reached.&#13;
     * @return Whether the cap was reached&#13;
     */&#13;
    function capReached() public view returns (bool) {&#13;
        return weiRaised() &gt;= _cap;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Extend parent behavior requiring purchase to respect the funding cap.&#13;
     * @param beneficiary Token purchaser&#13;
     * @param weiAmount Amount of wei contributed&#13;
     */&#13;
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {&#13;
        super._preValidatePurchase(beneficiary, weiAmount);&#13;
        require(weiRaised().add(weiAmount) &lt;= _cap);&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title TimedCrowdsale&#13;
 * @dev Crowdsale accepting contributions only within a time frame.&#13;
 */&#13;
contract TimedCrowdsale is Crowdsale {&#13;
    using SafeMath for uint256;&#13;
&#13;
    uint256 private _openingTime;&#13;
    uint256 private _closingTime;&#13;
&#13;
    /**&#13;
     * @dev Reverts if not in crowdsale time range.&#13;
     */&#13;
    modifier onlyWhileOpen {&#13;
        require(isOpen());&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Constructor, takes crowdsale opening and closing times.&#13;
     * @param openingTime Crowdsale opening time&#13;
     * @param closingTime Crowdsale closing time&#13;
     */&#13;
    constructor (uint256 openingTime, uint256 closingTime) internal {&#13;
        // solium-disable-next-line security/no-block-members&#13;
        require(openingTime &gt;= block.timestamp);&#13;
        require(closingTime &gt; openingTime);&#13;
&#13;
        _openingTime = openingTime;&#13;
        _closingTime = closingTime;&#13;
    }&#13;
&#13;
    /**&#13;
     * @return the crowdsale opening time.&#13;
     */&#13;
    function openingTime() public view returns (uint256) {&#13;
        return _openingTime;&#13;
    }&#13;
&#13;
    /**&#13;
     * @return the crowdsale closing time.&#13;
     */&#13;
    function closingTime() public view returns (uint256) {&#13;
        return _closingTime;&#13;
    }&#13;
&#13;
    /**&#13;
     * @return true if the crowdsale is open, false otherwise.&#13;
     */&#13;
    function isOpen() public view returns (bool) {&#13;
        // solium-disable-next-line security/no-block-members&#13;
        return block.timestamp &gt;= _openingTime &amp;&amp; block.timestamp &lt;= _closingTime;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.&#13;
     * @return Whether crowdsale period has elapsed&#13;
     */&#13;
    function hasClosed() public view returns (bool) {&#13;
        // solium-disable-next-line security/no-block-members&#13;
        return block.timestamp &gt; _closingTime;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Extend parent behavior requiring to be within contributing period&#13;
     * @param beneficiary Token purchaser&#13;
     * @param weiAmount Amount of wei contributed&#13;
     */&#13;
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {&#13;
        super._preValidatePurchase(beneficiary, weiAmount);&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title FthCrowdsale&#13;
 */&#13;
contract FthCrowdsale is CappedCrowdsale, TimedCrowdsale {&#13;
    using SafeMath for uint256;&#13;
&#13;
    uint256 public unlockPeriod;&#13;
&#13;
    struct Contribution {&#13;
        uint256 contributeTime;&#13;
        uint256 buyTokenAmount;&#13;
        uint256 rewardTokenAmount;&#13;
        uint256 lastUnlockTime;&#13;
        uint256 unlockPercent;&#13;
    }&#13;
&#13;
    mapping(address =&gt; Contribution[]) private _contributions;&#13;
&#13;
    constructor (&#13;
        uint256 period,&#13;
        uint256 cap,&#13;
        uint256 openingTime,&#13;
        uint256 closingTime,&#13;
        uint256 rate,&#13;
        address wallet,&#13;
        IERC20 token&#13;
    )&#13;
        public&#13;
        CappedCrowdsale(cap)&#13;
        TimedCrowdsale(openingTime, closingTime)&#13;
        Crowdsale(rate, wallet, token)&#13;
    {&#13;
        unlockPeriod = period;&#13;
    }&#13;
&#13;
    function contributionsOf(address beneficiary)&#13;
        public&#13;
        view&#13;
        returns (&#13;
            uint256[] memory contributeTimes,&#13;
            uint256[] memory buyTokenAmounts,&#13;
            uint256[] memory rewardTokenAmounts,&#13;
            uint256[] memory lastUnlockTimes,&#13;
            uint256[] memory unlockPercents&#13;
        )&#13;
    {&#13;
        Contribution[] memory contributions = _contributions[beneficiary];&#13;
&#13;
        uint256 length = contributions.length;&#13;
&#13;
        contributeTimes = new uint256[](length);&#13;
        buyTokenAmounts = new uint256[](length);&#13;
        rewardTokenAmounts = new uint256[](length);&#13;
        lastUnlockTimes = new uint256[](length);&#13;
        unlockPercents = new uint256[](length);&#13;
&#13;
        for (uint256 i = 0; i &lt; length; i++) {&#13;
            contributeTimes[i] = contributions[i].contributeTime;&#13;
            buyTokenAmounts[i] = contributions[i].buyTokenAmount;&#13;
            rewardTokenAmounts[i] = contributions[i].rewardTokenAmount;&#13;
            lastUnlockTimes[i] = contributions[i].lastUnlockTime;&#13;
            unlockPercents[i] = contributions[i].unlockPercent;&#13;
        }&#13;
    }&#13;
&#13;
    function withdrawTokens(address beneficiary) public {&#13;
        require(isOver());&#13;
&#13;
        if (msg.sender == beneficiary &amp;&amp; msg.sender == wallet()) {&#13;
            _withdrawTokensToWallet();&#13;
        } else {&#13;
            _withdrawTokensTo(beneficiary);&#13;
        }&#13;
    }&#13;
&#13;
    function unlockBalanceOf(address beneficiary) public view returns (uint256) {&#13;
        uint256 unlockBalance = 0;&#13;
&#13;
        Contribution[] memory contributions = _contributions[beneficiary];&#13;
&#13;
        for (uint256 i = 0; i &lt; contributions.length; i++) {&#13;
            uint256 unlockPercent = _unlockPercent(contributions[i]);&#13;
&#13;
            if (unlockPercent == 0) {&#13;
                continue;&#13;
            }&#13;
&#13;
            unlockBalance = unlockBalance.add(&#13;
                contributions[i].buyTokenAmount.mul(unlockPercent).div(100)&#13;
            ).add(&#13;
                contributions[i].rewardTokenAmount.mul(unlockPercent).div(100)&#13;
            );&#13;
        }&#13;
&#13;
        return unlockBalance;&#13;
    }&#13;
&#13;
    function rewardTokenAmount(uint256 buyTokenAmount) public view returns (uint256) {&#13;
        uint256 rewardTokenPercent = 0;&#13;
&#13;
        // solium-disable-next-line security/no-block-members&#13;
        uint256 timePeriod = block.timestamp.sub(openingTime()).div(1 weeks);&#13;
&#13;
        if (timePeriod &lt; 1) {&#13;
            rewardTokenPercent = 15;&#13;
        } else if (timePeriod &lt; 2) {&#13;
            rewardTokenPercent = 10;&#13;
        } else if (timePeriod &lt; 3) {&#13;
            rewardTokenPercent = 5;&#13;
        } else if (timePeriod &lt; 4) {&#13;
            rewardTokenPercent = 4;&#13;
        }&#13;
&#13;
        return buyTokenAmount.mul(rewardTokenPercent).div(100);&#13;
    }&#13;
&#13;
    function isOver() public view returns (bool) {&#13;
        return capReached() || hasClosed();&#13;
    }&#13;
&#13;
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {&#13;
        uint256 minWeiAmount = 0.1 ether;&#13;
        require(weiAmount &gt;= minWeiAmount);&#13;
&#13;
        super._preValidatePurchase(beneficiary, weiAmount);&#13;
    }&#13;
&#13;
    function _processPurchase(address beneficiary, uint256 buyTokenAmount) internal {&#13;
        Contribution[] storage contributions = _contributions[beneficiary];&#13;
        require(contributions.length &lt; 100);&#13;
&#13;
        contributions.push(Contribution({&#13;
            // solium-disable-next-line security/no-block-members&#13;
            contributeTime: block.timestamp,&#13;
            buyTokenAmount: buyTokenAmount,&#13;
            rewardTokenAmount: rewardTokenAmount(buyTokenAmount),&#13;
            lastUnlockTime: 0,&#13;
            unlockPercent: 0&#13;
        }));&#13;
    }&#13;
&#13;
    function _withdrawTokensToWallet() private {&#13;
        uint256 balanceTokenAmount = token().balanceOf(address(this));&#13;
        require(balanceTokenAmount &gt; 0);&#13;
&#13;
        _deliverTokens(wallet(), balanceTokenAmount);&#13;
    }&#13;
&#13;
    function _withdrawTokensTo(address beneficiary) private {&#13;
        uint256 unlockBalance = unlockBalanceOf(beneficiary);&#13;
        require(unlockBalance &gt; 0);&#13;
&#13;
        Contribution[] storage contributions = _contributions[beneficiary];&#13;
&#13;
        for (uint256 i = 0; i &lt; contributions.length; i++) {&#13;
            uint256 unlockPercent = _unlockPercent(contributions[i]);&#13;
&#13;
            if (unlockPercent == 0) {&#13;
                continue;&#13;
            }&#13;
&#13;
            // solium-disable-next-line security/no-block-members&#13;
            contributions[i].lastUnlockTime = block.timestamp;&#13;
            contributions[i].unlockPercent = contributions[i].unlockPercent.add(unlockPercent);&#13;
        }&#13;
&#13;
        _deliverTokens(beneficiary, unlockBalance);&#13;
    }&#13;
&#13;
    function _unlockPercent(Contribution memory contribution) private view returns (uint256) {&#13;
        if (contribution.unlockPercent &gt;= 100) {&#13;
            return 0;&#13;
        }&#13;
&#13;
        uint256 baseTimestamp = contribution.contributeTime;&#13;
&#13;
        if (contribution.lastUnlockTime &gt; baseTimestamp) {&#13;
            baseTimestamp = contribution.lastUnlockTime;&#13;
        }&#13;
&#13;
        // solium-disable-next-line security/no-block-members&#13;
        uint256 period = block.timestamp.sub(baseTimestamp);&#13;
&#13;
        if (period &lt; unlockPeriod) {&#13;
            return 0;&#13;
        }&#13;
&#13;
        uint256 unlockPercent;&#13;
&#13;
        if (contribution.unlockPercent == 0) {&#13;
            unlockPercent = period.div(unlockPeriod).sub(1).mul(10).add(50);&#13;
        } else {&#13;
            unlockPercent = period.div(unlockPeriod).mul(10);&#13;
        }&#13;
&#13;
        uint256 max = 100 - contribution.unlockPercent;&#13;
&#13;
        if (unlockPercent &gt; max) {&#13;
            unlockPercent = max;&#13;
        }&#13;
&#13;
        return unlockPercent;&#13;
    }&#13;
}