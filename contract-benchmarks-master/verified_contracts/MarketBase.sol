pragma solidity ^0.4.18;

// @author - <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f5839c83909e9f9c9782b59298949c99db969a98">[email protected]</a>&#13;
// Website: http://CryptoStockMarket.co&#13;
// Only CEO can change CEO and CFO address&#13;
&#13;
contract CompanyAccessControl {&#13;
    &#13;
    address public ceoAddress;&#13;
    address public cfoAddress;&#13;
&#13;
    bool public paused = false;&#13;
&#13;
    modifier onlyCEO() {&#13;
        require(msg.sender == ceoAddress);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyCFO() {&#13;
        require(msg.sender == cfoAddress);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyCLevel() {&#13;
        require(&#13;
            msg.sender == ceoAddress ||&#13;
            msg.sender == cfoAddress&#13;
        );&#13;
        _;&#13;
    }&#13;
&#13;
    function setCEO(address _newCEO) &#13;
    onlyCEO &#13;
    external {&#13;
        require(_newCEO != address(0));&#13;
        ceoAddress = _newCEO;&#13;
    }&#13;
&#13;
    function setCFO(address _newCFO) &#13;
    onlyCEO &#13;
    external {&#13;
        require(_newCFO != address(0));&#13;
        cfoAddress = _newCFO;&#13;
    }&#13;
&#13;
    modifier whenNotPaused() {&#13;
        require(!paused);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier whenPaused {&#13;
        require(paused);&#13;
        _;&#13;
    }&#13;
&#13;
    function pause() &#13;
    onlyCLevel&#13;
    external &#13;
    whenNotPaused {&#13;
        paused = true;&#13;
    }&#13;
&#13;
    function unpause() &#13;
    onlyCLevel &#13;
    whenPaused &#13;
    external {&#13;
        paused = false;&#13;
    }&#13;
}&#13;
&#13;
// Keeps a mapping of onwerAddress to the number of shares owned&#13;
contract BookKeeping {&#13;
    &#13;
    struct ShareHolders {&#13;
        mapping(address =&gt; uint) ownerAddressToShares;&#13;
        uint numberOfShareHolders;&#13;
    }&#13;
    &#13;
    // _amount should be greator than 0&#13;
    function _sharesBought(ShareHolders storage _shareHolders, address _owner, uint _amount) &#13;
    internal {&#13;
        // If user didn't have shares earlier, he is now a share holder!&#13;
        if (_shareHolders.ownerAddressToShares[_owner] == 0) {&#13;
            _shareHolders.numberOfShareHolders += 1;&#13;
        }&#13;
        _shareHolders.ownerAddressToShares[_owner] += _amount;&#13;
        &#13;
    }&#13;
&#13;
    // _amount should be greator or equal to what user already have, otherwise will result in underflow&#13;
    function _sharesSold(ShareHolders storage _shareHolders, address _owner, uint _amount) &#13;
    internal {&#13;
        _shareHolders.ownerAddressToShares[_owner] -= _amount;&#13;
        &#13;
        // if user sold all his tokens, then there is one less share holder&#13;
        if (_shareHolders.ownerAddressToShares[_owner] == 0) {&#13;
            _shareHolders.numberOfShareHolders -= 1;&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
&#13;
contract CompanyConstants {&#13;
    // Days after which trading volume competiton result will be annouced&#13;
    uint constant TRADING_COMPETITION_PERIOD = 5 days;&#13;
    &#13;
    // Max Percentage of shares that can be released per cycle&#13;
    uint constant MAX_PERCENTAGE_SHARE_RELEASE = 5;&#13;
    &#13;
    uint constant MAX_CLAIM_SHARES_PERCENTAGE = 5;&#13;
    &#13;
    // Release cycle! Every company needs to wait for "at least" 10 days&#13;
    // before releasing next set of shares!&#13;
    uint constant MIN_COOLDOWN_TIME = 10; // in days&#13;
    uint constant MAX_COOLDOWN_TIME = 255;&#13;
    &#13;
    // A company can start with min 100 tokens or max 10K tokens&#13;
    // and min(10%, 500) new tokens will be released every x days where&#13;
    // x &gt;= 10;&#13;
    uint constant INIT_MAX_SHARES_IN_CIRCULATION = 10000;&#13;
    uint constant INIT_MIN_SHARES_IN_CIRCULATION = 100;&#13;
    uint constant MAX_SHARES_RELEASE_IN_ONE_CYCLE = 500;&#13;
    &#13;
    // Company will take a cut of 10% from the share sales!&#13;
    uint constant SALES_CUT = 10;&#13;
    &#13;
    // Company will take a cut of 2% when an order is claimed.&#13;
    uint constant ORDER_CUT = 2;&#13;
    &#13;
    // Type of orders&#13;
    enum OrderType {Buy, Sell}&#13;
    &#13;
    // A new company is listed!&#13;
    event Listed(uint companyId, string companyName, uint sharesInCirculation, uint pricePerShare,&#13;
    uint percentageSharesToRelease, uint nextSharesReleaseTime, address owner);&#13;
    &#13;
    // Tokens are claimed!&#13;
    event Claimed(uint companyId, uint numberOfShares, address owner);&#13;
    &#13;
    // Tokens are transfered&#13;
    event Transfer(uint companyId, address from, address to, uint numberOfShares);&#13;
    &#13;
    // There is a new CEO of the company&#13;
    event CEOChanged(uint companyId, address previousCEO, address newCEO);&#13;
    &#13;
    // Shares are relased for the company&#13;
    event SharesReleased(uint companyId, address ceo, uint numberOfShares, uint nextSharesReleaseTime);&#13;
    &#13;
    // A new order is placed&#13;
    event OrderPlaced(uint companyId, uint orderIndex, uint amount, uint pricePerShare, OrderType orderType, address owner);&#13;
    &#13;
    // An order is claimed!&#13;
    event OrderFilled(uint companyId, uint orderIndex, uint amount, address buyer);&#13;
    &#13;
    // A placed order is cancelled!&#13;
    event OrderCancelled(uint companyId, uint orderIndex);&#13;
    &#13;
    event TradingWinnerAnnounced(uint companyId, address winner, uint sharesAwarded);&#13;
}&#13;
&#13;
contract CompanyBase is BookKeeping, CompanyConstants {&#13;
&#13;
    struct Company {&#13;
        // Company names are stored as hashes to save gas cost during execution&#13;
        bytes32 companyNameHash;&#13;
&#13;
        // Percentage of shares to release&#13;
        // will be less than maxPercentageSharesRelease&#13;
        uint32 percentageSharesToRelease;&#13;
&#13;
        // The time of the release cycle in days. If it is set to 10&#13;
        // then it means shares can only be released every 10 days &#13;
        // Min values is 10&#13;
        uint32 coolDownTime;&#13;
        &#13;
        // Total number of shares that are in circulation right now!&#13;
        uint32 sharesInCirculation; &#13;
&#13;
        // Total number of shares that are still with the company and can be claimed by paying the price&#13;
        uint32 unclaimedShares; &#13;
        &#13;
        // Address of the person who owns more tha 50% shares of the company.&#13;
        address ceoOfCompany; &#13;
&#13;
        // Address of person who registered this company and will receive money from the share sales.&#13;
        address ownedBy; &#13;
        &#13;
        // The exact time in future before which shares can't be released!&#13;
        // if shares are just released then nextSharesReleaseTime will be (now + coolDownTime);&#13;
        uint nextSharesReleaseTime; &#13;
&#13;
        // Price of one share as set by the company&#13;
        uint pricePerShare; &#13;
&#13;
        // Share holders of the company&#13;
        ShareHolders shareHolders;&#13;
    }&#13;
&#13;
    Company[] companies;&#13;
    &#13;
    function getCompanyDetails(uint _companyId) &#13;
    view&#13;
    external &#13;
    returns (&#13;
        bytes32 companyNameHash,&#13;
        uint percentageSharesToRelease,&#13;
        uint coolDownTime,&#13;
        uint nextSharesReleaseTime,&#13;
        uint sharesInCirculation,&#13;
        uint unclaimedShares,&#13;
        uint pricePerShare,&#13;
        uint sharesRequiredToBeCEO,&#13;
        address ceoOfCompany,     &#13;
        address owner,&#13;
        uint numberOfShareHolders) {&#13;
&#13;
        Company storage company = companies[_companyId];&#13;
&#13;
        companyNameHash = company.companyNameHash;&#13;
        percentageSharesToRelease = company.percentageSharesToRelease;&#13;
        coolDownTime = company.coolDownTime;&#13;
        nextSharesReleaseTime = company.nextSharesReleaseTime;&#13;
        sharesInCirculation = company.sharesInCirculation;&#13;
        unclaimedShares = company.unclaimedShares;&#13;
        pricePerShare = company.pricePerShare; &#13;
        sharesRequiredToBeCEO = (sharesInCirculation/2) + 1;&#13;
        ceoOfCompany = company.ceoOfCompany;&#13;
        owner = company.ownedBy;&#13;
        numberOfShareHolders = company.shareHolders.numberOfShareHolders;&#13;
    }&#13;
&#13;
    function getNumberOfShareHolders(uint _companyId) &#13;
    view&#13;
    external&#13;
    returns (uint) {&#13;
        return companies[_companyId].shareHolders.numberOfShareHolders;&#13;
    }&#13;
&#13;
    function getNumberOfSharesForAddress(uint _companyId, address _user) &#13;
    view&#13;
    external &#13;
    returns(uint) {&#13;
        return companies[_companyId].shareHolders.ownerAddressToShares[_user];&#13;
    }&#13;
    &#13;
    function getTotalNumberOfRegisteredCompanies()&#13;
    view&#13;
    external&#13;
    returns (uint) {&#13;
        return companies.length;&#13;
    }&#13;
}&#13;
&#13;
contract TradingVolume is CompanyConstants {&#13;
    &#13;
    struct Traders {&#13;
        uint relaseTime;&#13;
        address winningTrader;&#13;
        mapping (address =&gt; uint) sharesTraded;&#13;
    }&#13;
    &#13;
    mapping (uint =&gt; Traders) companyIdToTraders;&#13;
    &#13;
    // unique _companyId&#13;
    function _addNewCompanyTraders(uint _companyId) &#13;
    internal {&#13;
        Traders memory traders = Traders({&#13;
            winningTrader : 0x0,&#13;
            relaseTime : now + TRADING_COMPETITION_PERIOD &#13;
        });&#13;
        &#13;
        companyIdToTraders[_companyId] = traders;&#13;
    }&#13;
    &#13;
    // _from!=_to , _amount &gt; 0&#13;
    function _updateTradingVolume(Traders storage _traders, address _from, address _to, uint _amount) &#13;
    internal {&#13;
        _traders.sharesTraded[_from] += _amount;&#13;
        _traders.sharesTraded[_to] += _amount;&#13;
        &#13;
        if (_traders.sharesTraded[_from] &gt; _traders.sharesTraded[_traders.winningTrader]) {&#13;
            _traders.winningTrader = _from;&#13;
        } &#13;
        &#13;
        if (_traders.sharesTraded[_to] &gt; _traders.sharesTraded[_traders.winningTrader]) {&#13;
            _traders.winningTrader = _to;&#13;
        } &#13;
    }&#13;
    &#13;
    // Get reference of winningTrader before clearing&#13;
    function _clearWinner(Traders storage _traders) &#13;
    internal {&#13;
        delete _traders.sharesTraded[_traders.winningTrader];&#13;
        delete _traders.winningTrader;&#13;
        _traders.relaseTime = now + TRADING_COMPETITION_PERIOD;&#13;
    }&#13;
}&#13;
&#13;
contract ApprovalContract is CompanyAccessControl {&#13;
    // Approver who are approved to launch a company a particular name&#13;
    // the bytes32 hash is the hash of the company name!&#13;
    mapping(bytes32 =&gt; address) public approvedToLaunch;&#13;
    &#13;
    // Make sure that we don't add two companies with same name&#13;
    mapping(bytes32 =&gt; bool) public registredCompanyNames;&#13;
    &#13;
    // Approve addresses to launch a company with the given name&#13;
    // Only ceo or cfo can approve a company;&#13;
    // the owner who launched the company would receive 90% from the sales of&#13;
    // shares and 10% will be kept by the contract!&#13;
    function addApprover(address _owner, string _companyName) &#13;
    onlyCLevel&#13;
    whenNotPaused&#13;
    external {&#13;
        approvedToLaunch[keccak256(_companyName)] = _owner;&#13;
    }&#13;
}&#13;
&#13;
contract CompanyMain is CompanyBase, ApprovalContract, TradingVolume {&#13;
    uint public withdrawableBalance;&#13;
    &#13;
    // The cut contract takes from the share sales of an approved company.&#13;
    // price is in wei&#13;
    function _computeSalesCut(uint _price) &#13;
    pure&#13;
    internal &#13;
    returns (uint) {&#13;
        return (_price * SALES_CUT)/100;&#13;
    }&#13;
    &#13;
    // Whenever there is transfer of tokens from _from to _to, CEO of company might get changed!&#13;
    function _updateCEOIfRequired(Company storage _company, uint _companyId, address _to) &#13;
    internal {&#13;
        uint sharesRequiredToBecomeCEO = (_company.sharesInCirculation/2 ) + 1;&#13;
        address currentCEO = _company.ceoOfCompany;&#13;
        &#13;
        if (_company.shareHolders.ownerAddressToShares[currentCEO] &gt;= sharesRequiredToBecomeCEO) {&#13;
            return;&#13;
        } &#13;
        &#13;
        if (_to != address(this) &amp;&amp; _company.shareHolders.ownerAddressToShares[_to] &gt;= sharesRequiredToBecomeCEO) {&#13;
            _company.ceoOfCompany = _to;&#13;
            emit CEOChanged(_companyId, currentCEO, _to);&#13;
            return;&#13;
        }&#13;
        &#13;
        if (currentCEO == 0x0) {&#13;
            return;&#13;
        }&#13;
        _company.ceoOfCompany = 0x0;&#13;
        emit CEOChanged(_companyId, currentCEO, 0x0);&#13;
    }&#13;
    &#13;
&#13;
    /// Transfer tokens from _from to _to and verify if CEO of company has changed!&#13;
    // _from should have enough tokens before calling this functions!&#13;
    // _numberOfTokens should be greator than 0&#13;
    function _transfer(uint _companyId, address _from, address _to, uint _numberOfTokens) &#13;
    internal {&#13;
        Company storage company = companies[_companyId];&#13;
        &#13;
        _sharesSold(company.shareHolders, _from, _numberOfTokens);&#13;
        _sharesBought(company.shareHolders, _to, _numberOfTokens);&#13;
&#13;
        _updateCEOIfRequired(company, _companyId, _to);&#13;
        &#13;
        emit Transfer(_companyId, _from, _to, _numberOfTokens);&#13;
    }&#13;
    &#13;
    function transferPromotionalShares(uint _companyId, address _to, uint _amount)&#13;
    onlyCLevel&#13;
    whenNotPaused&#13;
    external&#13;
    {&#13;
        Company storage company = companies[_companyId];&#13;
        // implies a promotional company&#13;
        require(company.pricePerShare == 0);&#13;
        require(companies[_companyId].shareHolders.ownerAddressToShares[msg.sender] &gt;= _amount);&#13;
        _transfer(_companyId, msg.sender, _to, _amount);&#13;
    }&#13;
    &#13;
    function addPromotionalCompany(string _companyName, uint _precentageSharesToRelease, uint _coolDownTime, uint _sharesInCirculation)&#13;
    onlyCLevel&#13;
    whenNotPaused &#13;
    external&#13;
    {&#13;
        bytes32 companyNameHash = keccak256(_companyName);&#13;
        &#13;
        // There shouldn't be a company that is already registered with same name!&#13;
        require(registredCompanyNames[companyNameHash] == false);&#13;
        &#13;
        // Max 10% shares can be released in one release cycle, to control liquidation&#13;
        // and uncontrolled issuing of new tokens. Furthermore the max shares that can&#13;
        // be released in one cycle can only be upto 500.&#13;
        require(_precentageSharesToRelease &lt;= MAX_PERCENTAGE_SHARE_RELEASE);&#13;
        &#13;
        // The min release cycle should be at least 10 days&#13;
        require(_coolDownTime &gt;= MIN_COOLDOWN_TIME &amp;&amp; _coolDownTime &lt;= MAX_COOLDOWN_TIME);&#13;
&#13;
        uint _companyId = companies.length;&#13;
        uint _nextSharesReleaseTime = now + _coolDownTime * 1 days;&#13;
        &#13;
        Company memory company = Company({&#13;
            companyNameHash: companyNameHash,&#13;
            &#13;
            percentageSharesToRelease : uint32(_precentageSharesToRelease),&#13;
            coolDownTime : uint32(_coolDownTime),&#13;
            &#13;
            sharesInCirculation : uint32(_sharesInCirculation),&#13;
            nextSharesReleaseTime : _nextSharesReleaseTime,&#13;
            unclaimedShares : 0,&#13;
            &#13;
            pricePerShare : 0,&#13;
            &#13;
            ceoOfCompany : 0x0,&#13;
            ownedBy : msg.sender,&#13;
            shareHolders : ShareHolders({numberOfShareHolders : 0})&#13;
            });&#13;
&#13;
        companies.push(company);&#13;
        _addNewCompanyTraders(_companyId);&#13;
        // Register company name&#13;
        registredCompanyNames[companyNameHash] = true;&#13;
        _sharesBought(companies[_companyId].shareHolders, msg.sender, _sharesInCirculation);&#13;
        emit Listed(_companyId, _companyName, _sharesInCirculation, 0, _precentageSharesToRelease, _nextSharesReleaseTime, msg.sender);&#13;
    }&#13;
&#13;
    // Add a new company with the given name  &#13;
    function addNewCompany(string _companyName, uint _precentageSharesToRelease, uint _coolDownTime, uint _sharesInCirculation, uint _pricePerShare) &#13;
    external &#13;
    whenNotPaused &#13;
    {&#13;
        bytes32 companyNameHash = keccak256(_companyName);&#13;
        &#13;
        // There shouldn't be a company that is already registered with same name!&#13;
        require(registredCompanyNames[companyNameHash] == false);&#13;
        &#13;
        // Owner have the permissions to launch the company&#13;
        require(approvedToLaunch[companyNameHash] == msg.sender);&#13;
        &#13;
        // Max 10% shares can be released in one release cycle, to control liquidation&#13;
        // and uncontrolled issuing of new tokens. Furthermore the max shares that can&#13;
        // be released in one cycle can only be upto 500.&#13;
        require(_precentageSharesToRelease &lt;= MAX_PERCENTAGE_SHARE_RELEASE);&#13;
        &#13;
        // The min release cycle should be at least 10 days&#13;
        require(_coolDownTime &gt;= MIN_COOLDOWN_TIME &amp;&amp; _coolDownTime &lt;= MAX_COOLDOWN_TIME);&#13;
        &#13;
        require(_sharesInCirculation &gt;= INIT_MIN_SHARES_IN_CIRCULATION &amp;&amp;&#13;
        _sharesInCirculation &lt;= INIT_MAX_SHARES_IN_CIRCULATION);&#13;
&#13;
        uint _companyId = companies.length;&#13;
        uint _nextSharesReleaseTime = now + _coolDownTime * 1 days;&#13;
&#13;
        Company memory company = Company({&#13;
            companyNameHash: companyNameHash,&#13;
            &#13;
            percentageSharesToRelease : uint32(_precentageSharesToRelease),&#13;
            nextSharesReleaseTime : _nextSharesReleaseTime,&#13;
            coolDownTime : uint32(_coolDownTime),&#13;
            &#13;
            sharesInCirculation : uint32(_sharesInCirculation),&#13;
            unclaimedShares : uint32(_sharesInCirculation),&#13;
            &#13;
            pricePerShare : _pricePerShare,&#13;
            &#13;
            ceoOfCompany : 0x0,&#13;
            ownedBy : msg.sender,&#13;
            shareHolders : ShareHolders({numberOfShareHolders : 0})&#13;
            });&#13;
&#13;
        companies.push(company);&#13;
        _addNewCompanyTraders(_companyId);&#13;
        // Register company name&#13;
        registredCompanyNames[companyNameHash] = true;&#13;
        emit Listed(_companyId, _companyName, _sharesInCirculation, _pricePerShare, _precentageSharesToRelease, _nextSharesReleaseTime, msg.sender);&#13;
    }&#13;
    &#13;
    // People can claim shares from the company! &#13;
    // The share price is fixed. However, once bought the users can place buy/sell&#13;
    // orders of any amount!&#13;
    function claimShares(uint _companyId, uint _numberOfShares) &#13;
    whenNotPaused&#13;
    external &#13;
    payable {&#13;
        Company storage company = companies[_companyId];&#13;
        &#13;
        require (_numberOfShares &gt; 0 &amp;&amp;&#13;
            _numberOfShares &lt;= (company.sharesInCirculation * MAX_CLAIM_SHARES_PERCENTAGE)/100);&#13;
&#13;
        require(company.unclaimedShares &gt;= _numberOfShares);&#13;
        &#13;
        uint totalPrice = company.pricePerShare * _numberOfShares;&#13;
        require(msg.value &gt;= totalPrice);&#13;
&#13;
        company.unclaimedShares -= uint32(_numberOfShares);&#13;
&#13;
        _sharesBought(company.shareHolders, msg.sender, _numberOfShares);&#13;
        _updateCEOIfRequired(company, _companyId, msg.sender);&#13;
&#13;
        if (totalPrice &gt; 0) {&#13;
            uint salesCut = _computeSalesCut(totalPrice);&#13;
            withdrawableBalance += salesCut;&#13;
            uint sellerProceeds = totalPrice - salesCut;&#13;
&#13;
            company.ownedBy.transfer(sellerProceeds);&#13;
        } &#13;
&#13;
        emit Claimed(_companyId, _numberOfShares, msg.sender);&#13;
    }&#13;
    &#13;
    // Company's next shares can be released only by the CEO of the company! &#13;
    // So there should exist a CEO first&#13;
    function releaseNextShares(uint _companyId) &#13;
    external &#13;
    whenNotPaused {&#13;
&#13;
        Company storage company = companies[_companyId];&#13;
        &#13;
        require(company.ceoOfCompany == msg.sender);&#13;
        &#13;
        // If there are unclaimedShares with the company, then new shares can't be relased!&#13;
        require(company.unclaimedShares == 0 );&#13;
        &#13;
        require(now &gt;= company.nextSharesReleaseTime);&#13;
&#13;
        company.nextSharesReleaseTime = now + company.coolDownTime * 1 days;&#13;
        &#13;
        // In worst case, we will be relasing max 500 tokens every 10 days! &#13;
        // If we will start with max(10K) tokens, then on average we will be adding&#13;
        // 18000 tokens every year! In 100 years, it will be 1.8 millions. Multiplying it&#13;
        // by 10 makes it 18 millions. There is no way we can overflow the multiplication here!&#13;
        uint sharesToRelease = (company.sharesInCirculation * company.percentageSharesToRelease)/100;&#13;
        &#13;
        // Max 500 tokens can be relased&#13;
        if (sharesToRelease &gt; MAX_SHARES_RELEASE_IN_ONE_CYCLE) {&#13;
            sharesToRelease = MAX_SHARES_RELEASE_IN_ONE_CYCLE;&#13;
        }&#13;
        &#13;
        if (sharesToRelease &gt; 0) {&#13;
            company.sharesInCirculation += uint32(sharesToRelease);&#13;
            _sharesBought(company.shareHolders, company.ceoOfCompany, sharesToRelease);&#13;
            emit SharesReleased(_companyId, company.ceoOfCompany, sharesToRelease, company.nextSharesReleaseTime);&#13;
        }&#13;
    }&#13;
    &#13;
    function _updateTradingVolume(uint _companyId, address _from, address _to, uint _amount) &#13;
    internal {&#13;
        Traders storage traders = companyIdToTraders[_companyId];&#13;
        _updateTradingVolume(traders, _from, _to, _amount);&#13;
        &#13;
        if (now &lt; traders.relaseTime) {&#13;
            return;&#13;
        }&#13;
        &#13;
        Company storage company = companies[_companyId];&#13;
        uint _newShares = company.sharesInCirculation/100;&#13;
        if (_newShares &gt; MAX_SHARES_RELEASE_IN_ONE_CYCLE) {&#13;
            _newShares = 100;&#13;
        }&#13;
        company.sharesInCirculation += uint32(_newShares);&#13;
         _sharesBought(company.shareHolders, traders.winningTrader, _newShares);&#13;
        _updateCEOIfRequired(company, _companyId, traders.winningTrader);&#13;
        emit TradingWinnerAnnounced(_companyId, traders.winningTrader, _newShares);&#13;
        _clearWinner(traders);&#13;
    }&#13;
}&#13;
&#13;
contract MarketBase is CompanyMain {&#13;
    &#13;
    function MarketBase() public {&#13;
        ceoAddress = msg.sender;&#13;
        cfoAddress = msg.sender;&#13;
    }&#13;
    &#13;
    struct Order {&#13;
        // Owner who placed the order&#13;
        address owner;&#13;
                &#13;
        // Total number of tokens in order&#13;
        uint32 amount;&#13;
        &#13;
        // Amount of tokens that are already bought/sold by other people&#13;
        uint32 amountFilled;&#13;
        &#13;
        // Type of the order&#13;
        OrderType orderType;&#13;
        &#13;
        // Price of one share&#13;
        uint pricePerShare;&#13;
    }&#13;
    &#13;
    // A mapping of companyId to orders&#13;
    mapping (uint =&gt; Order[]) companyIdToOrders;&#13;
    &#13;
    // _amount &gt; 0&#13;
    function _createOrder(uint _companyId, uint _amount, uint _pricePerShare, OrderType _orderType) &#13;
    internal {&#13;
        Order memory order = Order({&#13;
            owner : msg.sender,&#13;
            pricePerShare : _pricePerShare,&#13;
            amount : uint32(_amount),&#13;
            amountFilled : 0,&#13;
            orderType : _orderType&#13;
        });&#13;
        &#13;
        uint index = companyIdToOrders[_companyId].push(order) - 1;&#13;
        emit OrderPlaced(_companyId, index, order.amount, order.pricePerShare, order.orderType, msg.sender);&#13;
    }&#13;
    &#13;
    // Place a sell request if seller have enough tokens!&#13;
    function placeSellRequest(uint _companyId, uint _amount, uint _pricePerShare) &#13;
    whenNotPaused&#13;
    external {&#13;
        require (_amount &gt; 0);&#13;
        require (_pricePerShare &gt; 0);&#13;
&#13;
        // Seller should have enough tokens to place a sell order!&#13;
        _verifyOwnershipOfTokens(_companyId, msg.sender, _amount);&#13;
&#13;
        _transfer(_companyId, msg.sender, this, _amount);&#13;
        _createOrder(_companyId, _amount, _pricePerShare, OrderType.Sell);&#13;
    }&#13;
    &#13;
    // Place a request to buy shares of a particular company!&#13;
    function placeBuyRequest(uint _companyId, uint _amount, uint _pricePerShare) &#13;
    external &#13;
    payable &#13;
    whenNotPaused {&#13;
        require(_amount &gt; 0);&#13;
        require(_pricePerShare &gt; 0);&#13;
        require(_amount == uint(uint32(_amount)));&#13;
        &#13;
        // Should have enough eth!&#13;
        require(msg.value &gt;= _amount * _pricePerShare);&#13;
&#13;
        _createOrder(_companyId, _amount, _pricePerShare, OrderType.Buy);&#13;
    }&#13;
    &#13;
    // Cancel a placed order!&#13;
    function cancelRequest(uint _companyId, uint _orderIndex) &#13;
    external {        &#13;
        Order storage order = companyIdToOrders[_companyId][_orderIndex];&#13;
        &#13;
        require(order.owner == msg.sender);&#13;
        &#13;
        uint sharesRemaining = _getRemainingSharesInOrder(order);&#13;
        &#13;
        require(sharesRemaining &gt; 0);&#13;
&#13;
        order.amountFilled += uint32(sharesRemaining);&#13;
        &#13;
        if (order.orderType == OrderType.Buy) {&#13;
&#13;
             // If its a buy order, transfer the ether back to owner;&#13;
            uint price = _getTotalPrice(order, sharesRemaining);&#13;
            &#13;
            // Sends money back to owner!&#13;
            msg.sender.transfer(price);&#13;
        } else {&#13;
            &#13;
            // Send the tokens back to the owner&#13;
            _transfer(_companyId, this, msg.sender, sharesRemaining);&#13;
        }&#13;
&#13;
        emit OrderCancelled(_companyId, _orderIndex);&#13;
    }&#13;
    &#13;
    // Fill the sell order!&#13;
    function fillSellOrder(uint _companyId, uint _orderIndex, uint _amount) &#13;
    whenNotPaused&#13;
    external &#13;
    payable {&#13;
        require(_amount &gt; 0);&#13;
        &#13;
        Order storage order = companyIdToOrders[_companyId][_orderIndex];&#13;
        require(order.orderType == OrderType.Sell);&#13;
        &#13;
        require(msg.sender != order.owner);&#13;
       &#13;
        _verifyRemainingSharesInOrder(order, _amount);&#13;
&#13;
        uint price = _getTotalPrice(order, _amount);&#13;
        require(msg.value &gt;= price);&#13;
&#13;
        order.amountFilled += uint32(_amount);&#13;
        &#13;
        // transfer tokens to the buyer&#13;
        _transfer(_companyId, this, msg.sender, _amount);&#13;
        &#13;
        // send money to seller after taking a small share&#13;
        _transferOrderMoney(price, order.owner);  &#13;
        &#13;
        _updateTradingVolume(_companyId, msg.sender, order.owner, _amount);&#13;
        &#13;
        emit OrderFilled(_companyId, _orderIndex, _amount, msg.sender);&#13;
    }&#13;
    &#13;
    // Fill the sell order!&#13;
    function fillSellOrderPartially(uint _companyId, uint _orderIndex, uint _maxAmount) &#13;
    whenNotPaused&#13;
    external &#13;
    payable {&#13;
        require(_maxAmount &gt; 0);&#13;
        &#13;
        Order storage order = companyIdToOrders[_companyId][_orderIndex];&#13;
        require(order.orderType == OrderType.Sell);&#13;
        &#13;
        require(msg.sender != order.owner);&#13;
       &#13;
        uint buyableShares = _getRemainingSharesInOrder(order);&#13;
        require(buyableShares &gt; 0);&#13;
        &#13;
        if (buyableShares &gt; _maxAmount) {&#13;
            buyableShares = _maxAmount;&#13;
        }&#13;
&#13;
        uint price = _getTotalPrice(order, buyableShares);&#13;
        require(msg.value &gt;= price);&#13;
&#13;
        order.amountFilled += uint32(buyableShares);&#13;
        &#13;
        // transfer tokens to the buyer&#13;
        _transfer(_companyId, this, msg.sender, buyableShares);&#13;
        &#13;
        // send money to seller after taking a small share&#13;
        _transferOrderMoney(price, order.owner); &#13;
        &#13;
        _updateTradingVolume(_companyId, msg.sender, order.owner, buyableShares);&#13;
        &#13;
        uint buyerProceeds = msg.value - price;&#13;
        msg.sender.transfer(buyerProceeds);&#13;
        &#13;
        emit OrderFilled(_companyId, _orderIndex, buyableShares, msg.sender);&#13;
    }&#13;
&#13;
    // Fill the buy order!&#13;
    function fillBuyOrder(uint _companyId, uint _orderIndex, uint _amount) &#13;
    whenNotPaused&#13;
    external {&#13;
        require(_amount &gt; 0);&#13;
        &#13;
        Order storage order = companyIdToOrders[_companyId][_orderIndex];&#13;
        require(order.orderType == OrderType.Buy);&#13;
        &#13;
        require(msg.sender != order.owner);&#13;
        &#13;
        // There should exist enought shares to fulfill the request!&#13;
        _verifyRemainingSharesInOrder(order, _amount);&#13;
        &#13;
        // The seller have enought tokens to fulfill the request!&#13;
        _verifyOwnershipOfTokens(_companyId, msg.sender, _amount);&#13;
        &#13;
        order.amountFilled += uint32(_amount);&#13;
        &#13;
        // transfer the tokens from the seller to the buyer!&#13;
        _transfer(_companyId, msg.sender, order.owner, _amount);&#13;
        &#13;
        uint price = _getTotalPrice(order, _amount);&#13;
        &#13;
        // transfer the money from this contract to the seller&#13;
        _transferOrderMoney(price , msg.sender);&#13;
        &#13;
        _updateTradingVolume(_companyId, msg.sender, order.owner, _amount);&#13;
&#13;
        emit OrderFilled(_companyId, _orderIndex, _amount, msg.sender);&#13;
    }&#13;
    &#13;
    // Fill buy order partially if possible!&#13;
    function fillBuyOrderPartially(uint _companyId, uint _orderIndex, uint _maxAmount) &#13;
    whenNotPaused&#13;
    external {&#13;
        require(_maxAmount &gt; 0);&#13;
        &#13;
        Order storage order = companyIdToOrders[_companyId][_orderIndex];&#13;
        require(order.orderType == OrderType.Buy);&#13;
        &#13;
        require(msg.sender != order.owner);&#13;
        &#13;
        // There should exist enought shares to fulfill the request!&#13;
        uint buyableShares = _getRemainingSharesInOrder(order);&#13;
        require(buyableShares &gt; 0);&#13;
        &#13;
        if ( buyableShares &gt; _maxAmount) {&#13;
            buyableShares = _maxAmount;&#13;
        }&#13;
        &#13;
        // The seller have enought tokens to fulfill the request!&#13;
        _verifyOwnershipOfTokens(_companyId, msg.sender, buyableShares);&#13;
        &#13;
        order.amountFilled += uint32(buyableShares);&#13;
        &#13;
        // transfer the tokens from the seller to the buyer!&#13;
        _transfer(_companyId, msg.sender, order.owner, buyableShares);&#13;
        &#13;
        uint price = _getTotalPrice(order, buyableShares);&#13;
        &#13;
        // transfer the money from this contract to the seller&#13;
        _transferOrderMoney(price , msg.sender);&#13;
        &#13;
        _updateTradingVolume(_companyId, msg.sender, order.owner, buyableShares);&#13;
&#13;
        emit OrderFilled(_companyId, _orderIndex, buyableShares, msg.sender);&#13;
    }&#13;
&#13;
    // transfer money to the owner!&#13;
    function _transferOrderMoney(uint _price, address _owner) &#13;
    internal {&#13;
        uint priceCut = (_price * ORDER_CUT)/100;&#13;
        _owner.transfer(_price - priceCut);&#13;
        withdrawableBalance += priceCut;&#13;
    }&#13;
&#13;
    // Returns the price for _amount tokens for the given order&#13;
    // _amount &gt; 0&#13;
    // order should be verified&#13;
    function _getTotalPrice(Order storage _order, uint _amount) &#13;
    view&#13;
    internal &#13;
    returns (uint) {&#13;
        return _amount * _order.pricePerShare;&#13;
    }&#13;
    &#13;
    // Gets the number of remaining shares that can be bought or sold under this order&#13;
    function _getRemainingSharesInOrder(Order storage _order) &#13;
    view&#13;
    internal &#13;
    returns (uint) {&#13;
        return _order.amount - _order.amountFilled;&#13;
    }&#13;
&#13;
    // Verifies if the order have _amount shares to buy/sell&#13;
    // _amount &gt; 0&#13;
    function _verifyRemainingSharesInOrder(Order storage _order, uint _amount) &#13;
    view&#13;
    internal {&#13;
        require(_getRemainingSharesInOrder(_order) &gt;= _amount);&#13;
    }&#13;
&#13;
    // Checks if the owner have at least '_amount' shares of the company&#13;
    // _amount &gt; 0&#13;
    function _verifyOwnershipOfTokens(uint _companyId, address _owner, uint _amount) &#13;
    view&#13;
    internal {&#13;
        require(companies[_companyId].shareHolders.ownerAddressToShares[_owner] &gt;= _amount);&#13;
    }&#13;
    &#13;
    // Returns the length of array! All orders might not be active&#13;
    function getNumberOfOrders(uint _companyId) &#13;
    view&#13;
    external &#13;
    returns (uint numberOfOrders) {&#13;
        numberOfOrders = companyIdToOrders[_companyId].length;&#13;
    }&#13;
&#13;
    function getOrderDetails(uint _comanyId, uint _orderIndex) &#13;
    view&#13;
    external &#13;
    returns (address _owner,&#13;
        uint _pricePerShare,&#13;
        uint _amount,&#13;
        uint _amountFilled,&#13;
        OrderType _orderType) {&#13;
            Order storage order =  companyIdToOrders[_comanyId][_orderIndex];&#13;
            &#13;
            _owner = order.owner;&#13;
            _pricePerShare = order.pricePerShare;&#13;
            _amount = order.amount;&#13;
            _amountFilled = order.amountFilled;&#13;
            _orderType = order.orderType;&#13;
    }&#13;
    &#13;
    function withdrawBalance(address _address) &#13;
    onlyCLevel&#13;
    external {&#13;
        require(_address != 0x0);&#13;
        uint balance = withdrawableBalance;&#13;
        withdrawableBalance = 0;&#13;
        _address.transfer(balance);&#13;
    }&#13;
    &#13;
    // Only when the contract is paused and there is a subtle bug!&#13;
    function kill(address _address) &#13;
    onlyCLevel&#13;
    whenPaused&#13;
    external {&#13;
        require(_address != 0x0);&#13;
        selfdestruct(_address);&#13;
    }&#13;
}