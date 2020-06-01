// CryptoTorch Source code
// copyright 2018 CryptoTorch <https://cryptotorch.io>

pragma solidity 0.4.19;


/**
 * @title SafeMath
 * Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * Multiplies two numbers, throws on overflow.
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
    * Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
* @title Ownable
 *
 * Owner rights:
 *   - change the name of the contract
 *   - change the name of the token
 *   - change the Proof of Stake difficulty
 *   - pause/unpause the contract
 *   - transfer ownership
 *
 * Owner CANNOT:
 *   - withdrawal funds
 *   - disable withdrawals
 *   - kill the contract
 *   - change the price of tokens
*/
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


/**
 * @title Pausable
 *
 * Pausing the contract will only disable deposits,
 * it will not prevent player dividend withdraws or token sales
 */
contract Pausable is Ownable {
    event OnPause();
    event OnUnpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        OnPause();
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        OnUnpause();
    }
}


/**
* @title ReentrancyGuard
* Helps contracts guard against reentrancy attacks.
* @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="addfc8c0cec2ed9f">[email protected]</a>π.com&gt;&#13;
*/&#13;
contract ReentrancyGuard {&#13;
    bool private reentrancyLock = false;&#13;
&#13;
    modifier nonReentrant() {&#13;
        require(!reentrancyLock);&#13;
        reentrancyLock = true;&#13;
        _;&#13;
        reentrancyLock = false;&#13;
    }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * DateTime Contract Interface&#13;
 * see https://github.com/pipermerriam/ethereum-datetime&#13;
 * Live Contract Address: 0x1a6184CD4C5Bea62B0116de7962EE7315B7bcBce&#13;
 */&#13;
contract DateTime {&#13;
    function getMonth(uint timestamp) public pure returns (uint8);&#13;
    function getDay(uint timestamp) public pure returns (uint8);&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * OwnTheDay Contract Interface&#13;
 */&#13;
contract OwnTheDayContract {&#13;
    function ownerOf(uint256 _tokenId) public view returns (address);&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title CryptoTorchToken&#13;
 */&#13;
contract CryptoTorchToken {&#13;
    function contractBalance() public view returns (uint256);&#13;
    function totalSupply() public view returns(uint256);&#13;
    function balanceOf(address _playerAddress) public view returns(uint256);&#13;
    function dividendsOf(address _playerAddress) public view returns(uint256);&#13;
    function profitsOf(address _playerAddress) public view returns(uint256);&#13;
    function referralBalanceOf(address _playerAddress) public view returns(uint256);&#13;
    function sellPrice() public view returns(uint256);&#13;
    function buyPrice() public view returns(uint256);&#13;
    function calculateTokensReceived(uint256 _etherToSpend) public view returns(uint256);&#13;
    function calculateEtherReceived(uint256 _tokensToSell) public view returns(uint256);&#13;
&#13;
    function sellFor(address _for, uint256 _amountOfTokens) public;&#13;
    function withdrawFor(address _for) public;&#13;
    function mint(address _to, uint256 _amountForTokens, address _referredBy) public payable returns(uint256);&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Crypto-Torch Contract&#13;
 */&#13;
contract CryptoTorch is Pausable, ReentrancyGuard {&#13;
    using SafeMath for uint256;&#13;
&#13;
    //&#13;
    // Events&#13;
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&#13;
    //&#13;
    event onTorchPassed(&#13;
        address indexed from,&#13;
        address indexed to,&#13;
        uint256 pricePaid&#13;
    );&#13;
&#13;
    //&#13;
    // Types&#13;
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&#13;
    //&#13;
    struct HighPrice {&#13;
        uint256 price;&#13;
        address owner;&#13;
    }&#13;
&#13;
    struct HighMileage {&#13;
        uint256 miles;&#13;
        address owner;&#13;
    }&#13;
&#13;
    struct PlayerData {&#13;
        string name;&#13;
        string note;&#13;
        string coords;&#13;
        uint256 dividends; // earnings waiting to be paid out&#13;
        uint256 profits;   // earnings already paid out&#13;
        bool champion;     // ran the torch while owning the day?&#13;
    }&#13;
&#13;
    //&#13;
    // Payout Structure&#13;
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&#13;
    //&#13;
    //  Dev Fee               - 5%&#13;
    //  Token Pool            - 75%&#13;
    //    - Referral                - 10%&#13;
    //  Remaining             - 20%&#13;
    //    - Day Owner               - 10-25%&#13;
    //    - Remaining               - 75-90%&#13;
    //        - Last Runner             - 60%&#13;
    //        - Second Last Runner      - 30%&#13;
    //        - Third Last Runner       - 10%&#13;
    //&#13;
&#13;
    //&#13;
    // Player Data&#13;
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&#13;
    //&#13;
    uint8 public constant maxLeaders = 3; // Gold, Silver, Bronze&#13;
&#13;
    uint256 private _lowestHighPrice;&#13;
    uint256 private _lowestHighMiles;&#13;
    uint256 public whaleIncreaseLimit = 2 ether;&#13;
    uint256 public whaleMax = 20 ether;&#13;
&#13;
    HighPrice[maxLeaders] private _highestPrices;&#13;
    HighMileage[maxLeaders] private _highestMiles;&#13;
&#13;
    address[maxLeaders] public torchRunners;&#13;
    address internal donationsReceiver_;&#13;
    mapping (address =&gt; PlayerData) private playerData_;&#13;
&#13;
    DateTime internal DateTimeLib_;&#13;
    CryptoTorchToken internal CryptoTorchToken_;&#13;
    OwnTheDayContract internal OwnTheDayContract_;&#13;
    string[3] internal holidayMap_;&#13;
&#13;
    //&#13;
    // Modifiers&#13;
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&#13;
    //&#13;
    // ensures that the first tokens in the contract will be equally distributed&#13;
    // meaning, no divine dump will be possible&#13;
    modifier antiWhalePrice(uint256 _amount) {&#13;
        require(&#13;
            whaleIncreaseLimit == 0 ||&#13;
            (&#13;
                _amount &lt;= (whaleIncreaseLimit.add(_highestPrices[0].price)) &amp;&amp;&#13;
                playerData_[msg.sender].dividends.add(playerData_[msg.sender].profits).add(_amount) &lt;= whaleMax&#13;
            )&#13;
        );&#13;
        _;&#13;
    }&#13;
&#13;
    //&#13;
    // Contract Initialization&#13;
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&#13;
    //&#13;
    /**&#13;
     * Set the Owner to the First Torch Runner&#13;
     */&#13;
    function CryptoTorch() public {&#13;
        torchRunners[0] = msg.sender;&#13;
    }&#13;
&#13;
    /**&#13;
     * Initializes the Contract Dependencies as well as the Holiday Mapping for OwnTheDay.io&#13;
     */&#13;
    function initialize(address _dateTimeAddress, address _tokenAddress, address _otdAddress) public onlyOwner {&#13;
        DateTimeLib_ = DateTime(_dateTimeAddress);&#13;
        CryptoTorchToken_ = CryptoTorchToken(_tokenAddress);&#13;
        OwnTheDayContract_ = OwnTheDayContract(_otdAddress);&#13;
        holidayMap_[0] = "10000110000001100000000000000101100000000011101000000000000011000000000000001001000010000101100010100110000100001000110000";&#13;
        holidayMap_[1] = "10111000100101000111000000100100000100010001001000100000000010010000000001000000110000000000000100000000010001100001100000";&#13;
        holidayMap_[2] = "01000000000100000101011000000110000001100000000100000000000011100001000100000000101000000000100000000000000000010011000001";&#13;
    }&#13;
&#13;
    /**&#13;
     * Sets the external contract address of the DateTime Library&#13;
     */&#13;
    function setDateTimeLib(address _dateTimeAddress) public onlyOwner {&#13;
        DateTimeLib_ = DateTime(_dateTimeAddress);&#13;
    }&#13;
&#13;
    /**&#13;
     * Sets the external contract address of the Token Contract&#13;
     */&#13;
    function setTokenContract(address _tokenAddress) public onlyOwner {&#13;
        CryptoTorchToken_ = CryptoTorchToken(_tokenAddress);&#13;
    }&#13;
&#13;
    /**&#13;
     * Sets the external contract address of OwnTheDay.io&#13;
     */&#13;
    function setOwnTheDayContract(address _otdAddress) public onlyOwner {&#13;
        OwnTheDayContract_ = OwnTheDayContract(_otdAddress);&#13;
    }&#13;
&#13;
    /**&#13;
     * Set the Contract Donations Receiver&#13;
     */&#13;
    function setDonationsReceiver(address _receiver) public onlyOwner {&#13;
        donationsReceiver_ = _receiver;&#13;
    }&#13;
&#13;
    /**&#13;
     * The Max Price-Paid Limit for Whales during the Anti-Whale Phase&#13;
     */&#13;
    function setWhaleMax(uint256 _max) public onlyOwner {&#13;
        whaleMax = _max;&#13;
    }&#13;
&#13;
    /**&#13;
     * The Max Price-Increase Limit for Whales during the Anti-Whale Phase&#13;
     */&#13;
    function setWhaleIncreaseLimit(uint256 _limit) public onlyOwner {&#13;
        whaleIncreaseLimit = _limit;&#13;
    }&#13;
&#13;
    /**&#13;
     * Updates the Holiday Mappings in case of updates/changes at OwnTheDay.io&#13;
     */&#13;
    function updateHolidayState(uint8 _listIndex, string _holidayMap) public onlyOwner {&#13;
        require(_listIndex &gt;= 0 &amp;&amp; _listIndex &lt; 3);&#13;
        holidayMap_[_listIndex] = _holidayMap;&#13;
    }&#13;
&#13;
    //&#13;
    // Public Functions&#13;
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&#13;
    //&#13;
    /**&#13;
     * Checks if a specific day is a holiday at OwnTheDay.io&#13;
     */&#13;
    function isHoliday(uint256 _dayIndex) public view returns (bool) {&#13;
        require(_dayIndex &gt;= 0 &amp;&amp; _dayIndex &lt; 366);&#13;
        return (getHolidayByIndex_(_dayIndex) == 1);&#13;
    }&#13;
&#13;
    /**&#13;
     * Checks if Today is a holiday at OwnTheDay.io&#13;
     */&#13;
    function isHolidayToday() public view returns (bool) {&#13;
        uint256 _dayIndex = getDayIndex_(now);&#13;
        return (getHolidayByIndex_(_dayIndex) == 1);&#13;
    }&#13;
&#13;
    /**&#13;
     * Gets the Day-Index of Today at OwnTheDay.io&#13;
     */&#13;
    function getTodayIndex() public view returns (uint256) {&#13;
        return getDayIndex_(now);&#13;
    }&#13;
&#13;
    /**&#13;
     * Gets the Owner Name of the Day at OwnTheDay.io&#13;
     */&#13;
    function getTodayOwnerName() public view returns (string) {&#13;
        address dayOwner = OwnTheDayContract_.ownerOf(getTodayIndex());&#13;
        return playerData_[dayOwner].name; // Get Name from THIS contract&#13;
    }&#13;
&#13;
    /**&#13;
     * Gets the Owner Address of the Day at OwnTheDay.io&#13;
     */&#13;
    function getTodayOwnerAddress() public view returns (address) {&#13;
        return OwnTheDayContract_.ownerOf(getTodayIndex());&#13;
    }&#13;
&#13;
    /**&#13;
     * Sets the Nickname for an Account Address&#13;
     */&#13;
    function setAccountNickname(string _nickname) public whenNotPaused {&#13;
        require(msg.sender != address(0));&#13;
        require(bytes(_nickname).length &gt; 0);&#13;
        playerData_[msg.sender].name = _nickname;&#13;
    }&#13;
&#13;
    /**&#13;
     * Gets the Nickname for an Account Address&#13;
     */&#13;
    function getAccountNickname(address _playerAddress) public view returns (string) {&#13;
        return playerData_[_playerAddress].name;&#13;
    }&#13;
&#13;
    /**&#13;
     * Sets the Note for an Account Address&#13;
     */&#13;
    function setAccountNote(string _note) public whenNotPaused {&#13;
        require(msg.sender != address(0));&#13;
        playerData_[msg.sender].note = _note;&#13;
    }&#13;
&#13;
    /**&#13;
     * Gets the Note for an Account Address&#13;
     */&#13;
    function getAccountNote(address _playerAddress) public view returns (string) {&#13;
        return playerData_[_playerAddress].note;&#13;
    }&#13;
&#13;
    /**&#13;
     * Sets the Note for an Account Address&#13;
     */&#13;
    function setAccountCoords(string _coords) public whenNotPaused {&#13;
        require(msg.sender != address(0));&#13;
        playerData_[msg.sender].coords = _coords;&#13;
    }&#13;
&#13;
    /**&#13;
     * Gets the Note for an Account Address&#13;
     */&#13;
    function getAccountCoords(address _playerAddress) public view returns (string) {&#13;
        return playerData_[_playerAddress].coords;&#13;
    }&#13;
&#13;
    /**&#13;
     * Gets the Note for an Account Address&#13;
     */&#13;
    function isChampionAccount(address _playerAddress) public view returns (bool) {&#13;
        return playerData_[_playerAddress].champion;&#13;
    }&#13;
&#13;
    /**&#13;
     * Take the Torch!&#13;
     *  The Purchase Price is Paid to the Previous Torch Holder, and is also used&#13;
     *  as the Purchasers Mileage Multiplier&#13;
     */&#13;
    function takeTheTorch(address _referredBy) public nonReentrant whenNotPaused payable {&#13;
        takeTheTorch_(msg.value, msg.sender, _referredBy);&#13;
    }&#13;
&#13;
    /**&#13;
     * Do not make payments directly to this contract (unless it is a donation! :)&#13;
     *  - payments made directly to the contract do not receive tokens.  Tokens&#13;
     *    are only available via "takeTheTorch()" or through the Dapp at https://cryptotorch.io&#13;
     */&#13;
    function() payable public {&#13;
        if (msg.value &gt; 0 &amp;&amp; donationsReceiver_ != 0x0) {&#13;
            donationsReceiver_.transfer(msg.value); // donations?  Thank you!  :)&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Sell some tokens for Ether&#13;
     */&#13;
    function sell(uint256 _amountOfTokens) public {&#13;
        CryptoTorchToken_.sellFor(msg.sender, _amountOfTokens);&#13;
    }&#13;
&#13;
    /**&#13;
     * Withdraw the earned Dividends to Ether&#13;
     *  - Includes Torch + Token Dividends and Token Referral Bonuses&#13;
     */&#13;
    function withdrawDividends() public returns (uint256) {&#13;
        CryptoTorchToken_.withdrawFor(msg.sender);&#13;
        return withdrawFor_(msg.sender);&#13;
    }&#13;
&#13;
    //&#13;
    // Helper Functions&#13;
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&#13;
    //&#13;
    /**&#13;
     * View the total balance of this contract&#13;
     */&#13;
    function torchContractBalance() public view returns (uint256) {&#13;
        return this.balance;&#13;
    }&#13;
&#13;
    /**&#13;
     * View the total balance of the token contract&#13;
     */&#13;
    function tokenContractBalance() public view returns (uint256) {&#13;
        return CryptoTorchToken_.contractBalance();&#13;
    }&#13;
&#13;
    /**&#13;
     * Retrieve the total token supply.&#13;
     */&#13;
    function totalSupply() public view returns(uint256) {&#13;
        return CryptoTorchToken_.totalSupply();&#13;
    }&#13;
&#13;
    /**&#13;
     * Retrieve the token balance of any single address.&#13;
     */&#13;
    function balanceOf(address _playerAddress) public view returns(uint256) {&#13;
        return CryptoTorchToken_.balanceOf(_playerAddress);&#13;
    }&#13;
&#13;
    /**&#13;
     * Retrieve the token dividend balance of any single address.&#13;
     */&#13;
    function tokenDividendsOf(address _playerAddress) public view returns(uint256) {&#13;
        return CryptoTorchToken_.dividendsOf(_playerAddress);&#13;
    }&#13;
&#13;
    /**&#13;
     * Retrieve the referral dividend balance of any single address.&#13;
     */&#13;
    function referralDividendsOf(address _playerAddress) public view returns(uint256) {&#13;
        return CryptoTorchToken_.referralBalanceOf(_playerAddress);&#13;
    }&#13;
&#13;
    /**&#13;
     * Retrieve the dividend balance of any single address.&#13;
     */&#13;
    function torchDividendsOf(address _playerAddress) public view returns(uint256) {&#13;
        return playerData_[_playerAddress].dividends;&#13;
    }&#13;
&#13;
    /**&#13;
     * Retrieve the dividend balance of any single address.&#13;
     */&#13;
    function profitsOf(address _playerAddress) public view returns(uint256) {&#13;
        return playerData_[_playerAddress].profits.add(CryptoTorchToken_.profitsOf(_playerAddress));&#13;
    }&#13;
&#13;
    /**&#13;
     * Return the sell price of 1 individual token.&#13;
     */&#13;
    function sellPrice() public view returns(uint256) {&#13;
        return CryptoTorchToken_.sellPrice();&#13;
    }&#13;
&#13;
    /**&#13;
     * Return the buy price of 1 individual token.&#13;
     */&#13;
    function buyPrice() public view returns(uint256) {&#13;
        return CryptoTorchToken_.buyPrice();&#13;
    }&#13;
&#13;
    /**&#13;
     * Function for the frontend to dynamically retrieve the price scaling of buy orders.&#13;
     */&#13;
    function calculateTokensReceived(uint256 _etherToSpend) public view returns(uint256) {&#13;
        uint256 forTokens = _etherToSpend.sub(_etherToSpend.div(4));&#13;
        return CryptoTorchToken_.calculateTokensReceived(forTokens);&#13;
    }&#13;
&#13;
    /**&#13;
     * Function for the frontend to dynamically retrieve the price scaling of sell orders.&#13;
     */&#13;
    function calculateEtherReceived(uint256 _tokensToSell) public view returns(uint256) {&#13;
        return CryptoTorchToken_.calculateEtherReceived(_tokensToSell);&#13;
    }&#13;
&#13;
    /**&#13;
     * Get the Max Price of the Torch during the Anti-Whale Phase&#13;
     */&#13;
    function getMaxPrice() public view returns (uint256) {&#13;
        if (whaleIncreaseLimit == 0) { return 0; }  // no max price&#13;
        return whaleIncreaseLimit.add(_highestPrices[0].price);&#13;
    }&#13;
&#13;
    /**&#13;
     * Get the Highest Price per each Medal Leader&#13;
     */&#13;
    function getHighestPriceAt(uint _index) public view returns (uint256) {&#13;
        require(_index &gt;= 0 &amp;&amp; _index &lt; maxLeaders);&#13;
        return _highestPrices[_index].price;&#13;
    }&#13;
&#13;
    /**&#13;
     * Get the Highest Price Owner per each Medal Leader&#13;
     */&#13;
    function getHighestPriceOwnerAt(uint _index) public view returns (address) {&#13;
        require(_index &gt;= 0 &amp;&amp; _index &lt; maxLeaders);&#13;
        return _highestPrices[_index].owner;&#13;
    }&#13;
&#13;
    /**&#13;
     * Get the Highest Miles per each Medal Leader&#13;
     */&#13;
    function getHighestMilesAt(uint _index) public view returns (uint256) {&#13;
        require(_index &gt;= 0 &amp;&amp; _index &lt; maxLeaders);&#13;
        return _highestMiles[_index].miles;&#13;
    }&#13;
&#13;
    /**&#13;
     * Get the Highest Miles Owner per each Medal Leader&#13;
     */&#13;
    function getHighestMilesOwnerAt(uint _index) public view returns (address) {&#13;
        require(_index &gt;= 0 &amp;&amp; _index &lt; maxLeaders);&#13;
        return _highestMiles[_index].owner;&#13;
    }&#13;
&#13;
    //&#13;
    // Internal Functions&#13;
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~&#13;
    //&#13;
    /**&#13;
     * Take the Torch!  And receive KMS Tokens!&#13;
     */&#13;
    function takeTheTorch_(uint256 _amountPaid, address _takenBy, address _referredBy) internal antiWhalePrice(_amountPaid) returns (uint256) {&#13;
        require(_takenBy != address(0));&#13;
        require(_amountPaid &gt;= 5 finney);&#13;
        require(_takenBy != torchRunners[0]); // Torch must be passed on&#13;
        if (_referredBy == address(this)) { _referredBy = address(0); }&#13;
&#13;
        // Pass the Torch&#13;
        address previousLast = torchRunners[2];&#13;
        torchRunners[2] = torchRunners[1];&#13;
        torchRunners[1] = torchRunners[0];&#13;
        torchRunners[0] = _takenBy;&#13;
&#13;
        // Get the Current Day Owner at OwnTheDay&#13;
        address dayOwner = OwnTheDayContract_.ownerOf(getDayIndex_(now));&#13;
&#13;
        // Calculate Portions&#13;
        uint256 forDev = _amountPaid.mul(5).div(100);&#13;
        uint256 forTokens = _amountPaid.sub(_amountPaid.div(4));&#13;
        uint256 forPayout = _amountPaid.sub(forDev).sub(forTokens);&#13;
        uint256 forDayOwner = calculateDayOwnerCut_(forPayout);&#13;
        if (dayOwner == _takenBy) {&#13;
            forTokens = forTokens.add(forDayOwner);&#13;
            forPayout = _amountPaid.sub(forDev).sub(forTokens);&#13;
            playerData_[_takenBy].champion = true;&#13;
        } else {&#13;
            forPayout = forPayout.sub(forDayOwner);&#13;
        }&#13;
&#13;
        // Fire Events&#13;
        onTorchPassed(torchRunners[1], _takenBy, _amountPaid);&#13;
&#13;
        // Grant Mileage Tokens to Torch Holder&#13;
        uint256 mintedTokens = CryptoTorchToken_.mint.value(forTokens)(_takenBy, forTokens, _referredBy);&#13;
&#13;
        // Update LeaderBoards&#13;
        updateLeaders_(_takenBy, _amountPaid);&#13;
&#13;
        // Handle Payouts&#13;
        handlePayouts_(forDev, forPayout, forDayOwner, _takenBy, previousLast, dayOwner);&#13;
        return mintedTokens;&#13;
    }&#13;
&#13;
    /**&#13;
     * Payouts to the last 3 Torch Runners, the Day Owner &amp; Dev&#13;
     */&#13;
    function handlePayouts_(uint256 _forDev, uint256 _forPayout, uint256 _forDayOwner, address _takenBy, address _previousLast, address _dayOwner) internal {&#13;
        uint256[] memory runnerPortions = new uint256[](3);&#13;
&#13;
        // Determine Runner Portions&#13;
        //  Note, torch has already been passed, so torchRunners[0]&#13;
        //  is the current torch runner&#13;
        if (_previousLast != address(0)) {&#13;
            runnerPortions[2] = _forPayout.mul(10).div(100);&#13;
        }&#13;
        if (torchRunners[2] != address(0)) {&#13;
            runnerPortions[1] = _forPayout.mul(30).div(100);&#13;
        }&#13;
        runnerPortions[0] = _forPayout.sub(runnerPortions[1]).sub(runnerPortions[2]);&#13;
&#13;
        // Update Player Dividends&#13;
        playerData_[_previousLast].dividends = playerData_[_previousLast].dividends.add(runnerPortions[2]);&#13;
        playerData_[torchRunners[2]].dividends = playerData_[torchRunners[2]].dividends.add(runnerPortions[1]);&#13;
        playerData_[torchRunners[1]].dividends = playerData_[torchRunners[1]].dividends.add(runnerPortions[0]);&#13;
&#13;
        // Track Profits&#13;
        playerData_[owner].profits = playerData_[owner].profits.add(_forDev);&#13;
        if (_dayOwner != _takenBy) {&#13;
            playerData_[_dayOwner].profits = playerData_[_dayOwner].profits.add(_forDayOwner);&#13;
        }&#13;
&#13;
        // Transfer Funds&#13;
        //  - Transfer directly since these accounts are not, or may not be, existing&#13;
        //    Torch-Runners and therefore cannot "exit" this contract&#13;
        owner.transfer(_forDev);&#13;
        if (_dayOwner != _takenBy) {&#13;
            _dayOwner.transfer(_forDayOwner);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Withdraw the earned Torch Dividends to Ether&#13;
     *  - Does not touch Token Dividends or Token Referral Bonuses&#13;
     */&#13;
    function withdrawFor_(address _for) internal returns (uint256) {&#13;
        uint256 torchDividends = playerData_[_for].dividends;&#13;
        if (playerData_[_for].dividends &gt; 0) {&#13;
            playerData_[_for].dividends = 0;&#13;
            playerData_[_for].profits = playerData_[_for].profits.add(torchDividends);&#13;
            _for.transfer(torchDividends);&#13;
        }&#13;
        return torchDividends;&#13;
    }&#13;
&#13;
    /**&#13;
     * Update the Medal Leader Boards&#13;
     */&#13;
    function updateLeaders_(address _takenBy, uint256 _amountPaid) internal {&#13;
        // Owner can't be leader; conflict of interest&#13;
        if (_takenBy == owner || _takenBy == donationsReceiver_) { return; }&#13;
&#13;
        // Update Highest Prices&#13;
        if (_amountPaid &gt; _lowestHighPrice) {&#13;
            updateHighestPrices_(_amountPaid, _takenBy);&#13;
        }&#13;
&#13;
        // Update Highest Mileage&#13;
        uint256 tokenBalance = CryptoTorchToken_.balanceOf(_takenBy);&#13;
        if (tokenBalance &gt; _lowestHighMiles) {&#13;
            updateHighestMiles_(tokenBalance, _takenBy);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Calculate the amount of Payout for the Day Owner (Holidays receive extra)&#13;
     */&#13;
    function calculateDayOwnerCut_(uint256 _price) internal view returns (uint256) {&#13;
        if (getHolidayByIndex_(getDayIndex_(now)) == 1) {&#13;
            return _price.mul(25).div(100);&#13;
        }&#13;
        return _price.mul(10).div(100);&#13;
    }&#13;
&#13;
    /**&#13;
     * Get the Day-Index of the current Day for Mapping with OwnTheDay.io&#13;
     */&#13;
    function getDayIndex_(uint timestamp) internal view returns (uint256) {&#13;
        uint8 day = DateTimeLib_.getDay(timestamp);&#13;
        uint8 month = DateTimeLib_.getMonth(timestamp);&#13;
        // OwnTheDay always includes Feb 29&#13;
        uint16[12] memory offset = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335];&#13;
        return offset[month-1] + day;&#13;
    }&#13;
&#13;
    /**&#13;
     * Determine if Day-Index is a Holiday or not&#13;
     */&#13;
    function getHolidayByIndex_(uint256 _dayIndex) internal view returns (uint result) {&#13;
        if (_dayIndex &lt; 122) {&#13;
            return getFromList_(0, _dayIndex);&#13;
        }&#13;
        if (_dayIndex &lt; 244) {&#13;
            return getFromList_(1, _dayIndex-122);&#13;
        }&#13;
        return getFromList_(2, _dayIndex-244);&#13;
    }&#13;
    function getFromList_(uint8 _idx, uint256 _dayIndex) internal view returns (uint result) {&#13;
        result = parseInt_(uint(bytes(holidayMap_[_idx])[_dayIndex]));&#13;
    }&#13;
    function parseInt_(uint c) internal pure returns (uint result) {&#13;
        if (c &gt;= 48 &amp;&amp; c &lt;= 57) {&#13;
            result = result * 10 + (c - 48);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Update the Medal Leaderboard for the Highest Price&#13;
     */&#13;
    function updateHighestPrices_(uint256 _price, address _owner) internal {&#13;
        uint256 newPos = maxLeaders;&#13;
        uint256 oldPos = maxLeaders;&#13;
        uint256 i;&#13;
        HighPrice memory tmp;&#13;
&#13;
        // Determine positions&#13;
        for (i = maxLeaders-1; i &gt;= 0; i--) {&#13;
            if (_price &gt;= _highestPrices[i].price) {&#13;
                newPos = i;&#13;
            }&#13;
            if (_owner == _highestPrices[i].owner) {&#13;
                oldPos = i;&#13;
            }&#13;
            if (i == 0) { break; } // prevent i going below 0&#13;
        }&#13;
        // Insert or update leader&#13;
        if (newPos &lt; maxLeaders) {&#13;
            if (oldPos &lt; maxLeaders-1) {&#13;
                // update price for existing leader&#13;
                _highestPrices[oldPos].price = _price;&#13;
                if (newPos != oldPos) {&#13;
                    // swap&#13;
                    tmp = _highestPrices[newPos];&#13;
                    _highestPrices[newPos] = _highestPrices[oldPos];&#13;
                    _highestPrices[oldPos] = tmp;&#13;
                }&#13;
            } else {&#13;
                // shift down&#13;
                for (i = maxLeaders-1; i &gt; newPos; i--) {&#13;
                    _highestPrices[i] = _highestPrices[i-1];&#13;
                }&#13;
                // insert&#13;
                _highestPrices[newPos].price = _price;&#13;
                _highestPrices[newPos].owner = _owner;&#13;
            }&#13;
            // track lowest value&#13;
            _lowestHighPrice = _highestPrices[maxLeaders-1].price;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Update the Medal Leaderboard for the Highest Miles&#13;
     */&#13;
    function updateHighestMiles_(uint256 _miles, address _owner) internal {&#13;
        uint256 newPos = maxLeaders;&#13;
        uint256 oldPos = maxLeaders;&#13;
        uint256 i;&#13;
        HighMileage memory tmp;&#13;
&#13;
        // Determine positions&#13;
        for (i = maxLeaders-1; i &gt;= 0; i--) {&#13;
            if (_miles &gt;= _highestMiles[i].miles) {&#13;
                newPos = i;&#13;
            }&#13;
            if (_owner == _highestMiles[i].owner) {&#13;
                oldPos = i;&#13;
            }&#13;
            if (i == 0) { break; } // prevent i going below 0&#13;
        }&#13;
        // Insert or update leader&#13;
        if (newPos &lt; maxLeaders) {&#13;
            if (oldPos &lt; maxLeaders-1) {&#13;
                // update miles for existing leader&#13;
                _highestMiles[oldPos].miles = _miles;&#13;
                if (newPos != oldPos) {&#13;
                    // swap&#13;
                    tmp = _highestMiles[newPos];&#13;
                    _highestMiles[newPos] = _highestMiles[oldPos];&#13;
                    _highestMiles[oldPos] = tmp;&#13;
                }&#13;
            } else {&#13;
                // shift down&#13;
                for (i = maxLeaders-1; i &gt; newPos; i--) {&#13;
                    _highestMiles[i] = _highestMiles[i-1];&#13;
                }&#13;
                // insert&#13;
                _highestMiles[newPos].miles = _miles;&#13;
                _highestMiles[newPos].owner = _owner;&#13;
            }&#13;
            // track lowest value&#13;
            _lowestHighMiles = _highestMiles[maxLeaders-1].miles;&#13;
        }&#13;
    }&#13;
}