pragma solidity ^0.4.23;
// Made By PinkCherry - <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5b3235283a35322f2228303a351b3c363a323775383436">[email protected]</a> - https://blog.naver.com/soolmini&#13;
&#13;
library SafeMath&#13;
{&#13;
    function mul(uint256 a, uint256 b) internal pure returns (uint256)&#13;
    {&#13;
        uint256 c = a * b;&#13;
        assert(a == 0 || c / a == b);&#13;
&#13;
        return c;&#13;
    }&#13;
&#13;
    function div(uint256 a, uint256 b) internal pure returns (uint256)&#13;
    {&#13;
        uint256 c = a / b;&#13;
&#13;
        return c;&#13;
    }&#13;
&#13;
    function sub(uint256 a, uint256 b) internal pure returns (uint256)&#13;
    {&#13;
        assert(b &lt;= a);&#13;
&#13;
        return a - b;&#13;
    }&#13;
&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256)&#13;
    {&#13;
        uint256 c = a + b;&#13;
        assert(c &gt;= a);&#13;
&#13;
        return c;&#13;
    }&#13;
}&#13;
&#13;
&#13;
contract OwnerHelper&#13;
{&#13;
    address public owner;&#13;
&#13;
    event OwnerTransferPropose(address indexed _from, address indexed _to);&#13;
&#13;
    modifier onlyOwner&#13;
    {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    constructor() public&#13;
    {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    function transferOwnership(address _to) onlyOwner public&#13;
    {&#13;
        require(_to != owner);&#13;
        require(_to != address(0x0));&#13;
        owner = _to;&#13;
        emit OwnerTransferPropose(owner, _to);&#13;
    }&#13;
&#13;
}&#13;
&#13;
contract ERC20Interface&#13;
{&#13;
    event Transfer( address indexed _from, address indexed _to, uint _value);&#13;
    event Approval( address indexed _owner, address indexed _spender, uint _value);&#13;
    &#13;
    function totalSupply() constant public returns (uint _supply);&#13;
    function balanceOf( address _who ) public view returns (uint _value);&#13;
    function transfer( address _to, uint _value) public returns (bool _success);&#13;
    function approve( address _spender, uint _value ) public returns (bool _success);&#13;
    function allowance( address _owner, address _spender ) public view returns (uint _allowance);&#13;
    function transferFrom( address _from, address _to, uint _value) public returns (bool _success);&#13;
}&#13;
&#13;
contract GemmyCoin is ERC20Interface, OwnerHelper&#13;
{&#13;
    using SafeMath for uint;&#13;
    &#13;
    string public name;&#13;
    uint public decimals;&#13;
    string public symbol;&#13;
    address public wallet;&#13;
&#13;
    uint public totalSupply;&#13;
    &#13;
    uint constant public saleSupply = 4000000000 * E18;&#13;
    uint constant public rewardPoolSupply = 2500000000 * E18;&#13;
    uint constant public foundationSupply = 500000000 * E18;&#13;
    uint constant public gemmyMusicSupply = 1500000000 * E18;&#13;
    uint constant public advisorSupply = 700000000 * E18;&#13;
    uint constant public mktSupply = 800000000 * E18;&#13;
    uint constant public maxSupply = 10000000000 * E18;&#13;
    &#13;
    uint public coinIssuedSale = 0;&#13;
    uint public coinIssuedRewardPool = 0;&#13;
    uint public coinIssuedFoundation = 0;&#13;
    uint public coinIssuedGemmyMusic = 0;&#13;
    uint public coinIssuedAdvisor = 0;&#13;
    uint public coinIssuedMkt = 0;&#13;
    uint public coinIssuedTotal = 0;&#13;
    uint public coinIssuedBurn = 0;&#13;
    &#13;
    uint public saleEtherReceived = 0;&#13;
&#13;
    uint constant private E18 = 1000000000000000000;&#13;
    uint constant private ethPerCoin = 35000;&#13;
    &#13;
    uint private UTC9 = 9 * 60 * 60;&#13;
    uint public privateSaleDate = 1526223600 + UTC9;        // 2018-05-14 00:00:00 (UTC + 9)&#13;
    uint public privateSaleEndDate = 1527951600 + UTC9;     // 2018-06-03 00:00:00 (UTC + 9)&#13;
    &#13;
    uint public firstPreSaleDate = 1528038000 + UTC9;       // 2018-06-04 00:00:00 (UTC + 9)&#13;
    uint public firstPreSaleEndDate = 1528988400 + UTC9;    // 2018-06-15 00:00:00 (UTC + 9)&#13;
    &#13;
    uint public secondPreSaleDate = 1529852400 + UTC9;      // 2018-06-25 00:00:00 (UTC + 9)&#13;
    uint public secondPreSaleEndDate = 1530802800 + UTC9;   // 2018-07-06 00:00:00 (UTC + 9)&#13;
    &#13;
    uint public firstCrowdSaleDate = 1531062000 + UTC9;     // 2018-07-09 00:00:00 (UTC + 9)&#13;
    uint public firstCrowdSaleEndDate = 1532012400 + UTC9;  // 2018-07-20 00:00:00 (UTC + 9)&#13;
&#13;
    uint public secondCrowdSaleDate = 1532271600 + UTC9;    // 2018-07-23 00:00:00 (UTC + 9)&#13;
    uint public secondCrowdSaleEndDate = 1532962800 + UTC9; // 2018-07-31 00:00:00 (UTC + 9)&#13;
    &#13;
    bool public totalCoinLock;&#13;
    uint public gemmyMusicLockTime;&#13;
    &#13;
    uint public advisorFirstLockTime;&#13;
    uint public advisorSecondLockTime;&#13;
    &#13;
    mapping (address =&gt; uint) internal balances;&#13;
    mapping (address =&gt; mapping ( address =&gt; uint )) internal approvals;&#13;
&#13;
    mapping (address =&gt; bool) internal personalLocks;&#13;
    mapping (address =&gt; bool) internal gemmyMusicLocks;&#13;
    &#13;
    mapping (address =&gt; uint) internal advisorFirstLockBalances;&#13;
    mapping (address =&gt; uint) internal advisorSecondLockBalances;&#13;
    &#13;
    mapping (address =&gt; uint) internal  icoEtherContributeds;&#13;
    &#13;
    event CoinIssuedSale(address indexed _who, uint _coins, uint _balances, uint _ether);&#13;
    event RemoveTotalCoinLock();&#13;
    event SetAdvisorLockTime(uint _first, uint _second);&#13;
    event RemovePersonalLock(address _who);&#13;
    event RemoveGemmyMusicLock(address _who);&#13;
    event RemoveAdvisorFirstLock(address _who);&#13;
    event RemoveAdvisorSecondLock(address _who);&#13;
    event WithdrawRewardPool(address _who, uint _value);&#13;
    event WithdrawFoundation(address _who, uint _value);&#13;
    event WithdrawGemmyMusic(address _who, uint _value);&#13;
    event WithdrawAdvisor(address _who, uint _value);&#13;
    event WithdrawMkt(address _who, uint _value);&#13;
    event ChangeWallet(address _who);&#13;
    event BurnCoin(uint _value);&#13;
&#13;
    constructor() public&#13;
    {&#13;
        name = "GemmyMusicCoin";&#13;
        decimals = 18;&#13;
        symbol = "GMM";&#13;
        totalSupply = 0;&#13;
        &#13;
        owner = msg.sender;&#13;
        wallet = msg.sender;&#13;
        &#13;
        require(maxSupply == saleSupply + rewardPoolSupply + foundationSupply + gemmyMusicSupply + advisorSupply + mktSupply);&#13;
        &#13;
        totalCoinLock = true;&#13;
        gemmyMusicLockTime = privateSaleDate + (365 * 24 * 60 * 60);&#13;
        advisorFirstLockTime = gemmyMusicLockTime;   // if tokenUnLock == timeChange&#13;
        advisorSecondLockTime = gemmyMusicLockTime;  // if tokenUnLock == timeChange&#13;
    }&#13;
&#13;
    function atNow() public view returns (uint)&#13;
    {&#13;
        return now;&#13;
    }&#13;
    &#13;
    function () payable public&#13;
    {&#13;
        require(saleSupply &gt; coinIssuedSale);&#13;
        buyCoin();&#13;
    }&#13;
    &#13;
    function buyCoin() private&#13;
    {&#13;
        uint saleTime = 0; // 1 : privateSale, 2 : firstPreSale, 3 : secondPreSale, 4 : firstCrowdSale, 5 : secondCrowdSale&#13;
        uint coinBonus = 0;&#13;
        &#13;
        uint minEth = 0.1 ether;&#13;
        uint maxEth = 100000 ether;&#13;
        &#13;
        uint nowTime = atNow();&#13;
        &#13;
        if( nowTime &gt;= privateSaleDate &amp;&amp; nowTime &lt; privateSaleEndDate )&#13;
        {&#13;
            saleTime = 1;&#13;
            coinBonus = 40;&#13;
        }&#13;
        else if( nowTime &gt;= firstPreSaleDate &amp;&amp; nowTime &lt; firstPreSaleEndDate )&#13;
        {&#13;
            saleTime = 2;&#13;
            coinBonus = 20;&#13;
        }&#13;
        else if( nowTime &gt;= secondPreSaleDate &amp;&amp; nowTime &lt; secondPreSaleEndDate )&#13;
        {&#13;
            saleTime = 3;&#13;
            coinBonus = 15;&#13;
        }&#13;
        else if( nowTime &gt;= firstCrowdSaleDate &amp;&amp; nowTime &lt; firstCrowdSaleEndDate )&#13;
        {&#13;
            saleTime = 4;&#13;
            coinBonus = 5;&#13;
        }&#13;
        else if( nowTime &gt;= secondCrowdSaleDate &amp;&amp; nowTime &lt; secondCrowdSaleEndDate )&#13;
        {&#13;
            saleTime = 5;&#13;
            coinBonus = 0;&#13;
        }&#13;
        &#13;
        require(saleTime &gt;= 1 &amp;&amp; saleTime &lt;= 5);&#13;
        require(msg.value &gt;= minEth &amp;&amp; icoEtherContributeds[msg.sender].add(msg.value) &lt;= maxEth);&#13;
&#13;
        uint coins = ethPerCoin.mul(msg.value);&#13;
        coins = coins.mul(100 + coinBonus) / 100;&#13;
        &#13;
        require(saleSupply &gt;= coinIssuedSale.add(coins));&#13;
&#13;
        totalSupply = totalSupply.add(coins);&#13;
        coinIssuedSale = coinIssuedSale.add(coins);&#13;
        saleEtherReceived = saleEtherReceived.add(msg.value);&#13;
&#13;
        balances[msg.sender] = balances[msg.sender].add(coins);&#13;
        icoEtherContributeds[msg.sender] = icoEtherContributeds[msg.sender].add(msg.value);&#13;
        personalLocks[msg.sender] = true;&#13;
&#13;
        emit Transfer(0x0, msg.sender, coins);&#13;
        emit CoinIssuedSale(msg.sender, coins, balances[msg.sender], msg.value);&#13;
&#13;
        wallet.transfer(address(this).balance);&#13;
    }&#13;
    &#13;
    function isTransferLock(address _from, address _to) constant private returns (bool _success)&#13;
    {&#13;
        _success = false;&#13;
&#13;
        if(totalCoinLock == true)&#13;
        {&#13;
            _success = true;&#13;
        }&#13;
        &#13;
        if(personalLocks[_from] == true || personalLocks[_to] == true)&#13;
        {&#13;
            _success = true;&#13;
        }&#13;
        &#13;
        if(gemmyMusicLocks[_from] == true || gemmyMusicLocks[_to] == true)&#13;
        {&#13;
            _success = true;&#13;
        }&#13;
        &#13;
        return _success;&#13;
    }&#13;
    &#13;
    function isPersonalLock(address _who) constant public returns (bool)&#13;
    {&#13;
        return personalLocks[_who];&#13;
    }&#13;
    &#13;
    function removeTotalCoinLock() onlyOwner public&#13;
    {&#13;
        require(totalCoinLock == true);&#13;
        &#13;
        uint nowTime = atNow();&#13;
        advisorFirstLockTime = nowTime + (2 * 30 * 24 * 60 * 60);&#13;
        advisorSecondLockTime = nowTime + (4 * 30 * 24 * 60 * 60);&#13;
    &#13;
        totalCoinLock = false;&#13;
        &#13;
        emit RemoveTotalCoinLock();&#13;
        emit SetAdvisorLockTime(advisorFirstLockTime, advisorSecondLockTime);&#13;
    }&#13;
    &#13;
    function removePersonalLock(address _who) onlyOwner public&#13;
    {&#13;
        require(personalLocks[_who] == true);&#13;
        &#13;
        personalLocks[_who] = false;&#13;
        &#13;
        emit RemovePersonalLock(_who);&#13;
    }&#13;
    &#13;
    function removePersonalLockMultiple(address[] _addresses) onlyOwner public&#13;
    {&#13;
        for(uint i = 0; i &lt; _addresses.length; i++)&#13;
        {&#13;
        &#13;
            require(personalLocks[_addresses[i]] == true);&#13;
        &#13;
            personalLocks[_addresses[i]] = false;&#13;
        &#13;
            emit RemovePersonalLock(_addresses[i]);&#13;
        }&#13;
    }&#13;
    &#13;
    function removeGemmyMusicLock(address _who) onlyOwner public&#13;
    {&#13;
        require(atNow() &gt; gemmyMusicLockTime);&#13;
        require(gemmyMusicLocks[_who] == true);&#13;
        &#13;
        gemmyMusicLocks[_who] = false;&#13;
        &#13;
        emit RemoveGemmyMusicLock(_who);&#13;
    }&#13;
    &#13;
    function removeFirstAdvisorLock(address _who) onlyOwner public&#13;
    {&#13;
        require(atNow() &gt; advisorFirstLockTime);&#13;
        require(advisorFirstLockBalances[_who] &gt; 0);&#13;
        require(personalLocks[_who] == true);&#13;
        &#13;
        balances[_who] = balances[_who].add(advisorFirstLockBalances[_who]);&#13;
        advisorFirstLockBalances[_who] = 0;&#13;
        &#13;
        emit RemoveAdvisorFirstLock(_who);&#13;
    }&#13;
    &#13;
    function removeSecondAdvisorLock(address _who) onlyOwner public&#13;
    {&#13;
        require(atNow() &gt; advisorSecondLockTime);&#13;
        require(advisorFirstLockBalances[_who] &gt; 0);&#13;
        require(personalLocks[_who] == true);&#13;
        &#13;
        balances[_who] = balances[_who].add(advisorFirstLockBalances[_who]);&#13;
        advisorFirstLockBalances[_who] = 0;&#13;
        &#13;
        emit RemoveAdvisorFirstLock(_who);&#13;
    }&#13;
    &#13;
    function totalSupply() constant public returns (uint) &#13;
    {&#13;
        return totalSupply;&#13;
    }&#13;
    &#13;
    function balanceOf(address _who) public view returns (uint) &#13;
    {&#13;
        return balances[_who].add(advisorFirstLockBalances[_who].add(advisorSecondLockBalances[_who]));&#13;
    }&#13;
    &#13;
    function transfer(address _to, uint _value) public returns (bool) &#13;
    {&#13;
        require(balances[msg.sender] &gt;= _value);&#13;
        require(isTransferLock(msg.sender, _to) == false);&#13;
        &#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        &#13;
        emit Transfer(msg.sender, _to, _value);&#13;
        &#13;
        return true;&#13;
    }&#13;
    &#13;
    function transferMultiple(address[] _addresses, uint[] _values) onlyOwner public returns (bool) &#13;
    {&#13;
        require(_addresses.length == _values.length);&#13;
        &#13;
        for(uint i = 0; i &lt; _addresses.length; i++)&#13;
        {&#13;
            require(balances[msg.sender] &gt;= _values[i]);&#13;
            require(isTransferLock(msg.sender, _addresses[i]) == false);&#13;
            &#13;
            balances[msg.sender] = balances[msg.sender].sub(_values[i]);&#13;
            balances[_addresses[i]] = balances[_addresses[i]].add(_values[i]);&#13;
            &#13;
            emit Transfer(msg.sender, _addresses[i], _values[i]);&#13;
        }&#13;
        return true;&#13;
    }&#13;
    &#13;
    function approve(address _spender, uint _value) public returns (bool)&#13;
    {&#13;
        require(balances[msg.sender] &gt;= _value);&#13;
        require(isTransferLock(msg.sender, _spender) == false);&#13;
        &#13;
        approvals[msg.sender][_spender] = _value;&#13;
        &#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        &#13;
        return true;&#13;
    }&#13;
    &#13;
    function allowance(address _owner, address _spender) constant public returns (uint) &#13;
    {&#13;
        return approvals[_owner][_spender];&#13;
    }&#13;
    &#13;
    function transferFrom(address _from, address _to, uint _value) public returns (bool) &#13;
    {&#13;
        require(balances[_from] &gt;= _value);&#13;
        require(approvals[_from][msg.sender] &gt;= _value);&#13;
        require(isTransferLock(msg.sender, _to) == false);&#13;
        &#13;
        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        balances[_to]  = balances[_to].add(_value);&#13;
        &#13;
        emit Transfer(_from, _to, _value);&#13;
        &#13;
        return true;&#13;
    }&#13;
    &#13;
    function withdrawRewardPool(address _who, uint _value) onlyOwner public&#13;
    {&#13;
        uint coins = _value * E18;&#13;
        &#13;
        require(rewardPoolSupply &gt;= coinIssuedRewardPool.add(coins));&#13;
&#13;
        totalSupply = totalSupply.add(coins);&#13;
        coinIssuedRewardPool = coinIssuedRewardPool.add(coins);&#13;
        coinIssuedTotal = coinIssuedTotal.add(coins);&#13;
&#13;
        balances[_who] = balances[_who].add(coins);&#13;
        personalLocks[_who] = true;&#13;
&#13;
        emit Transfer(0x0, msg.sender, coins);&#13;
        emit WithdrawRewardPool(_who, coins);&#13;
    }&#13;
    &#13;
    function withdrawFoundation(address _who, uint _value) onlyOwner public&#13;
    {&#13;
        uint coins = _value * E18;&#13;
        &#13;
        require(foundationSupply &gt;= coinIssuedFoundation.add(coins));&#13;
&#13;
        totalSupply = totalSupply.add(coins);&#13;
        coinIssuedFoundation = coinIssuedFoundation.add(coins);&#13;
        coinIssuedTotal = coinIssuedTotal.add(coins);&#13;
&#13;
        balances[_who] = balances[_who].add(coins);&#13;
        personalLocks[_who] = true;&#13;
&#13;
        emit Transfer(0x0, msg.sender, coins);&#13;
        emit WithdrawFoundation(_who, coins);&#13;
    }&#13;
    &#13;
    function withdrawGemmyMusic(address _who, uint _value) onlyOwner public&#13;
    {&#13;
        uint coins = _value * E18;&#13;
        &#13;
        require(gemmyMusicSupply &gt;= coinIssuedGemmyMusic.add(coins));&#13;
&#13;
        totalSupply = totalSupply.add(coins);&#13;
        coinIssuedGemmyMusic = coinIssuedGemmyMusic.add(coins);&#13;
        coinIssuedTotal = coinIssuedTotal.add(coins);&#13;
&#13;
        balances[_who] = balances[_who].add(coins);&#13;
        gemmyMusicLocks[_who] = true;&#13;
&#13;
        emit Transfer(0x0, msg.sender, coins);&#13;
        emit WithdrawGemmyMusic(_who, coins);&#13;
    }&#13;
    &#13;
    function withdrawAdvisor(address _who, uint _value) onlyOwner public&#13;
    {&#13;
        uint coins = _value * E18;&#13;
        &#13;
        require(advisorSupply &gt;= coinIssuedAdvisor.add(coins));&#13;
&#13;
        totalSupply = totalSupply.add(coins);&#13;
        coinIssuedAdvisor = coinIssuedAdvisor.add(coins);&#13;
        coinIssuedTotal = coinIssuedTotal.add(coins);&#13;
&#13;
        balances[_who] = balances[_who].add(coins * 20 / 100);&#13;
        advisorFirstLockBalances[_who] = advisorFirstLockBalances[_who].add(coins * 40 / 100);&#13;
        advisorSecondLockBalances[_who] = advisorSecondLockBalances[_who].add(coins * 40 / 100);&#13;
        personalLocks[_who] = true;&#13;
&#13;
        emit Transfer(0x0, msg.sender, coins);&#13;
        emit WithdrawAdvisor(_who, coins);&#13;
    }&#13;
    &#13;
    function withdrawMkt(address _who, uint _value) onlyOwner public&#13;
    {&#13;
        uint coins = _value * E18;&#13;
        &#13;
        require(mktSupply &gt;= coinIssuedMkt.add(coins));&#13;
&#13;
        totalSupply = totalSupply.add(coins);&#13;
        coinIssuedMkt = coinIssuedMkt.add(coins);&#13;
        coinIssuedTotal = coinIssuedTotal.add(coins);&#13;
&#13;
        balances[_who] = balances[_who].add(coins);&#13;
        personalLocks[_who] = true;&#13;
&#13;
        emit Transfer(0x0, msg.sender, coins);&#13;
        emit WithdrawMkt(_who, coins);&#13;
    }&#13;
    &#13;
    function burnCoin() onlyOwner public&#13;
    {&#13;
        require(atNow() &gt; secondCrowdSaleEndDate);&#13;
        require(saleSupply - coinIssuedSale &gt; 0);&#13;
&#13;
        uint coins = saleSupply - coinIssuedSale;&#13;
        &#13;
        balances[0x0] = balances[0x0].add(coins);&#13;
        coinIssuedSale = coinIssuedSale.add(coins);&#13;
        coinIssuedBurn = coinIssuedBurn.add(coins);&#13;
&#13;
        emit BurnCoin(coins);&#13;
    }&#13;
    &#13;
    function changeWallet(address _who) onlyOwner public&#13;
    {&#13;
        require(_who != address(0x0));&#13;
        require(_who != wallet);&#13;
        &#13;
        wallet = _who;&#13;
        &#13;
        emit ChangeWallet(_who);&#13;
    }&#13;
}