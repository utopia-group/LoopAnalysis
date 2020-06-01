pragma solidity ^0.4.11;
/**
    ERC20 Interface
    @author DongOk Peter Ryu - <<span class="__cf_email__" data-cfemail="4a252e23240a332d2d2e382b3922642325">[email protected]</span>&gt;&#13;
*/&#13;
contract ERC20 {&#13;
    function totalSupply() public constant returns (uint supply);&#13;
    function balanceOf( address who ) public constant returns (uint value);&#13;
    function allowance( address owner, address spender ) public constant returns (uint _allowance);&#13;
&#13;
    function transfer( address to, uint value) public returns (bool ok);&#13;
    function transferFrom( address from, address to, uint value) public returns (bool ok);&#13;
    function approve( address spender, uint value ) public returns (bool ok);&#13;
&#13;
    event Transfer( address indexed from, address indexed to, uint value);&#13;
    event Approval( address indexed owner, address indexed spender, uint value);&#13;
}&#13;
&#13;
library SafeMath {&#13;
  function mul(uint a, uint b) internal returns (uint) {&#13;
    uint c = a * b;&#13;
    assert(a == 0 || c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  function div(uint a, uint b) internal returns (uint) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  function sub(uint a, uint b) internal returns (uint) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  function add(uint a, uint b) internal returns (uint) {&#13;
    uint c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
&#13;
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {&#13;
    return a &gt;= b ? a : b;&#13;
  }&#13;
&#13;
  function min64(uint64 a, uint64 b) internal constant returns (uint64) {&#13;
    return a &lt; b ? a : b;&#13;
  }&#13;
&#13;
  function max256(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    return a &gt;= b ? a : b;&#13;
  }&#13;
&#13;
  function min256(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    return a &lt; b ? a : b;&#13;
  }&#13;
&#13;
}&#13;
/**&#13;
    YGGDRASH SmartContract&#13;
    @author Peter Ryu - &lt;<span class="__cf_email__" data-cfemail="9af5fef3f4dae3fdfdfee8fbe9f2b4f3f5">[email protected]</span>&gt;&#13;
*/&#13;
contract YggdrashCrowd {&#13;
    using SafeMath for uint;&#13;
    ERC20 public yeedToken;&#13;
    Stages stage;&#13;
    address public wallet;&#13;
    address public owner;&#13;
    address public tokenOwner;&#13;
    uint public totalAmount;    // Contruibute Token amount&#13;
    uint public priceFactor; // ratio&#13;
    uint public startBlock;&#13;
    uint public totalReceived;&#13;
    uint public endTime;&#13;
&#13;
    uint public maxValue; // max ETH&#13;
    uint public minValue;&#13;
&#13;
    uint public maxGasPrice; // Max gasPrice&#13;
&#13;
    // collect log&#13;
    event FundTransfer (address sender, uint amount);&#13;
&#13;
    struct ContributeAddress {&#13;
        bool exists; // set to true&#13;
        address account; // sending account&#13;
        uint amount; // sending amount&#13;
        uint balance; // token value&#13;
        bytes data; // sending data&#13;
    }&#13;
&#13;
    mapping(address =&gt; ContributeAddress) public _contributeInfo;&#13;
    mapping(bytes =&gt; ContributeAddress) _contruibuteData;&#13;
&#13;
    /*&#13;
        Check is owner address&#13;
    */&#13;
    modifier isOwner() {&#13;
        // Only owner is allowed to proceed&#13;
        require (msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
        Check Valid Payload&#13;
    */&#13;
    modifier isValidPayload() {&#13;
        // check Max&#13;
        if(maxValue != 0){&#13;
            require(msg.value &lt; maxValue + 1);&#13;
        }&#13;
        // Check Min&#13;
        if(minValue != 0){&#13;
            require(msg.value &gt; minValue - 1);&#13;
        }&#13;
        require(wallet != msg.sender);&#13;
        // check data value&#13;
        require(msg.data.length != 0);&#13;
        _;&#13;
&#13;
    }&#13;
&#13;
    /*&#13;
        Check exists Contribute list&#13;
    */&#13;
    modifier isExists() {&#13;
        require(_contruibuteData[msg.data].exists == false);&#13;
        require(_contributeInfo[msg.sender].amount == 0);&#13;
        _;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Modifiers Stage&#13;
     */&#13;
    modifier atStage(Stages _stage) {&#13;
        require(stage == _stage);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    /*&#13;
     *  Enums Stage Status&#13;
     */&#13;
    enum Stages {&#13;
    Deployed,&#13;
    SetUp,&#13;
    Started,&#13;
    Ended&#13;
    }&#13;
&#13;
&#13;
    /// init&#13;
    /// @param _token token address&#13;
    /// @param _tokenOwner token owner wallet address&#13;
    /// @param _wallet Send ETH wallet&#13;
    /// @param _amount token total value&#13;
    /// @param _priceFactor token and ETH ratio&#13;
    /// @param _maxValue maximum ETH balance&#13;
    /// @param _minValue minimum ETH balance&#13;
&#13;
    function YggdrashCrowd(address _token, address _tokenOwner, address _wallet, uint _amount, uint _priceFactor, uint _maxValue, uint _minValue)&#13;
    public&#13;
    {&#13;
        require (_tokenOwner != 0 &amp;&amp; _wallet != 0 &amp;&amp; _amount != 0 &amp;&amp; _priceFactor != 0);&#13;
        tokenOwner = _tokenOwner;&#13;
        owner = msg.sender;&#13;
        wallet = _wallet;&#13;
        totalAmount = _amount;&#13;
        priceFactor = _priceFactor;&#13;
        maxValue = _maxValue;&#13;
        minValue = _minValue;&#13;
        stage = Stages.Deployed;&#13;
&#13;
        if(_token != 0){ // setup token&#13;
            yeedToken = ERC20(_token);&#13;
            stage = Stages.SetUp;&#13;
        }&#13;
        // Max Gas Price is unlimited&#13;
        maxGasPrice = 0;&#13;
    }&#13;
&#13;
    // setupToken&#13;
    function setupToken(address _token)&#13;
    public&#13;
    isOwner&#13;
    {&#13;
        require(_token != 0);&#13;
        yeedToken = ERC20(_token);&#13;
        stage = Stages.SetUp;&#13;
    }&#13;
&#13;
    /// @dev Start Contruibute&#13;
    function startContruibute()&#13;
    public&#13;
    isOwner&#13;
    atStage(Stages.SetUp)&#13;
    {&#13;
        stage = Stages.Started;&#13;
        startBlock = block.number;&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
        Contributer send to ETH&#13;
        Payload Check&#13;
        Exist Check&#13;
        GasPrice Check&#13;
        Stage Check&#13;
    */&#13;
    function()&#13;
    public&#13;
    isValidPayload&#13;
    isExists&#13;
    atStage(Stages.Started)&#13;
    payable&#13;
    {&#13;
        uint amount = msg.value;&#13;
        uint maxAmount = totalAmount.div(priceFactor);&#13;
        // refund&#13;
        if (amount &gt; maxAmount){&#13;
            uint refund = amount.sub(maxAmount);&#13;
            assert(msg.sender.send(refund));&#13;
            amount = maxAmount;&#13;
        }&#13;
        //  NO MORE GAS WAR!!!&#13;
        if(maxGasPrice != 0){&#13;
            assert(tx.gasprice &lt; maxGasPrice + 1);&#13;
        }&#13;
        totalReceived = totalReceived.add(amount);&#13;
        // calculate token&#13;
        uint token = amount.mul(priceFactor);&#13;
        totalAmount = totalAmount.sub(token);&#13;
&#13;
        // give token to sender&#13;
        yeedToken.transferFrom(tokenOwner, msg.sender, token);&#13;
        FundTransfer(msg.sender, token);&#13;
&#13;
        // Set Contribute Account&#13;
        ContributeAddress crowdData = _contributeInfo[msg.sender];&#13;
        crowdData.exists = true;&#13;
        crowdData.account = msg.sender;&#13;
        crowdData.data = msg.data;&#13;
        crowdData.amount = amount;&#13;
        crowdData.balance = token;&#13;
        // add contruibuteData&#13;
        _contruibuteData[msg.data] = crowdData;&#13;
        _contributeInfo[msg.sender] = crowdData;&#13;
        // send to wallet&#13;
        wallet.transfer(amount);&#13;
&#13;
        // token sold out&#13;
        if (amount == maxAmount)&#13;
            finalizeContruibute();&#13;
    }&#13;
&#13;
    /// @dev Changes auction totalAmount and start price factor before auction is started.&#13;
    /// @param _totalAmount Updated auction totalAmount.&#13;
    /// @param _priceFactor Updated start price factor.&#13;
    /// @param _maxValue Maximum balance of ETH&#13;
    /// @param _minValue Minimum balance of ETH&#13;
    function changeSettings(uint _totalAmount, uint _priceFactor, uint _maxValue, uint _minValue, uint _maxGasPrice)&#13;
    public&#13;
    isOwner&#13;
    {&#13;
        require(_totalAmount != 0 &amp;&amp; _priceFactor != 0);&#13;
        totalAmount = _totalAmount;&#13;
        priceFactor = _priceFactor;&#13;
        maxValue = _maxValue;&#13;
        minValue = _minValue;&#13;
        maxGasPrice = _maxGasPrice;&#13;
    }&#13;
    /**&#13;
        Set Max Gas Price by Admin&#13;
    */&#13;
    function setMaxGasPrice(uint _maxGasPrice)&#13;
    public&#13;
    isOwner&#13;
    {&#13;
        maxGasPrice = _maxGasPrice;&#13;
    }&#13;
&#13;
&#13;
    // token balance&#13;
    // @param src sender wallet address&#13;
    function balanceOf(address src) public constant returns (uint256)&#13;
    {&#13;
        return _contributeInfo[src].balance;&#13;
    }&#13;
&#13;
    // amount ETH value&#13;
    // @param src sender wallet address&#13;
    function amountOf(address src) public constant returns(uint256)&#13;
    {&#13;
        return _contributeInfo[src].amount;&#13;
    }&#13;
&#13;
    // contruibute data&#13;
    // @param src Yggdrash uuid&#13;
    function contruibuteData(bytes src) public constant returns(address)&#13;
    {&#13;
        return _contruibuteData[src].account;&#13;
    }&#13;
&#13;
    // Check contruibute is open&#13;
    function isContruibuteOpen() public constant returns (bool)&#13;
    {&#13;
        return stage == Stages.Started;&#13;
    }&#13;
&#13;
    // Smartcontract halt&#13;
    function halt()&#13;
    public&#13;
    isOwner&#13;
    {&#13;
        finalizeContruibute();&#13;
    }&#13;
&#13;
    // END of this Contruibute&#13;
    function finalizeContruibute()&#13;
    private&#13;
    {&#13;
        stage = Stages.Ended;&#13;
        // remain token send to owner&#13;
        totalAmount = 0;&#13;
        endTime = now;&#13;
    }&#13;
}