pragma solidity ^0.4.13;


/// @title Abstract ERC20 token interface
contract AbstractToken {

    function totalSupply() constant returns (uint256) {}
    function balanceOf(address owner) constant returns (uint256 balance);
    function transfer(address to, uint256 value) returns (bool success);
    function transferFrom(address from, address to, uint256 value) returns (bool success);
    function approve(address spender, uint256 value) returns (bool success);
    function allowance(address owner, address spender) constant returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Issuance(address indexed to, uint256 value);
}


contract Owned {

    address public owner = msg.sender;
    address public potentialOwner;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPotentialOwner {
        require(msg.sender == potentialOwner);
        _;
    }

    event NewOwner(address old, address current);
    event NewPotentialOwner(address old, address potential);

    function setOwner(address _new)
        public
        onlyOwner
    {
        NewPotentialOwner(owner, _new);
        potentialOwner = _new;
    }

    function confirmOwnership()
        public
        onlyPotentialOwner
    {
        NewOwner(owner, potentialOwner);
        owner = potentialOwner;
        potentialOwner = 0;
    }
}


/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
contract StandardToken is AbstractToken, Owned {

    /*
     *  Data structures
     */
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

    /*
     *  Read and write storage functions
     */
    /// @dev Transfers sender's tokens to a given address. Returns success.
    /// @param _to Address of token receiver.
    /// @param _value Number of tokens to transfer.
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    /// @dev Returns number of tokens owned by given address.
    /// @param _owner Address of token owner.
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /*
     * Read storage functions
     */
    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}


/// @title SafeMath contract - Math operations with safety checks.
/// @author OpenZeppelin: https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
contract SafeMath {
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

    function pow(uint a, uint b) internal returns (uint) {
        uint c = a ** b;
        assert(c >= a);
        return c;
    }
}


/// @title Token contract - Implements Standard ERC20 with additional features.
/// @author Zerion - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="365f5854594e764c53445f5958185f59">[email protected]</a>&gt;&#13;
contract Token is StandardToken, SafeMath {&#13;
&#13;
    // Time of the contract creation&#13;
    uint public creationTime;&#13;
&#13;
    function Token() {&#13;
        creationTime = now;&#13;
    }&#13;
&#13;
&#13;
    /// @dev Owner can transfer out any accidentally sent ERC20 tokens&#13;
    function transferERC20Token(address tokenAddress)&#13;
        public&#13;
        onlyOwner&#13;
        returns (bool)&#13;
    {&#13;
        uint balance = AbstractToken(tokenAddress).balanceOf(this);&#13;
        return AbstractToken(tokenAddress).transfer(owner, balance);&#13;
    }&#13;
&#13;
    /// @dev Multiplies the given number by 10^(decimals)&#13;
    function withDecimals(uint number, uint decimals)&#13;
        internal&#13;
        returns (uint)&#13;
    {&#13;
        return mul(number, pow(10, decimals));&#13;
    }&#13;
}&#13;
&#13;
&#13;
/// @title Token contract - Implements Standard ERC20 Token for Tokenbox project.&#13;
/// @author Zerion - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a4cdcac6cbdce4dec1d6cdcbca8acdcb">[email protected]</a>&gt;&#13;
contract TokenboxToken is Token {&#13;
&#13;
    /*&#13;
     * Token meta data&#13;
     */&#13;
    string constant public name = "Tokenbox";&#13;
    //TODO: Fix before production&#13;
    string constant public symbol = "TBX";&#13;
    uint8 constant public decimals = 18;&#13;
&#13;
    // Address where Foundation tokens are allocated&#13;
    address constant public foundationReserve = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
    // Address where all tokens for the ICO stage are initially allocated&#13;
    address constant public icoAllocation = 0x1111111111111111111111111111111111111111;&#13;
&#13;
    // Address where all tokens for the PreICO are initially allocated&#13;
    address constant public preIcoAllocation = 0x2222222222222222222222222222222222222222;&#13;
&#13;
    // TGE start date. 11/14/2017 @ 12:00pm (UTC)&#13;
    uint256 constant public startDate = 1510660800;&#13;
    // TGE duration is 14 days&#13;
    uint256 constant public duration = 14 days;&#13;
&#13;
    // Vesting date to withdraw 15% of total sold tokens, 11/28/2018 @ 12:00pm (UTC)&#13;
    uint256 constant public vestingDateEnd = 1543406400;&#13;
&#13;
    // Total USD collected (10^-12)&#13;
    uint256 public totalPicoUSD = 0;&#13;
    uint8 constant public usdDecimals = 12;&#13;
&#13;
    // Public key of the signer&#13;
    address public signer;&#13;
&#13;
    // Foundation multisignature wallet, all Ether is collected there&#13;
    address public multisig;&#13;
&#13;
    bool public finalised = false;&#13;
&#13;
    // Events&#13;
    event InvestmentInETH(address investor, uint256 tokenPriceInWei, uint256 investedInWei, uint256 investedInPicoUsd, uint256 tokensNumber, bytes32 hash);&#13;
    event InvestmentInBTC(address investor, uint256 tokenPriceInSatoshi, uint256 investedInSatoshi, uint256 investedInPicoUsd, uint256 tokensNumber, string btcAddress);&#13;
    event InvestmentInUSD(address investor, uint256 tokenPriceInPicoUsd, uint256 investedInPicoUsd, uint256 tokensNumber);&#13;
    event PresaleInvestment(address investor, uint256 investedInPicoUsd, uint256 tokensNumber);&#13;
&#13;
    /// @dev Contract constructor, sets totalSupply&#13;
    function TokenboxToken(address _signer, address _multisig, uint256 _preIcoTokens )&#13;
    {&#13;
        // Overall, 31,000,000 TBX tokens are distributed&#13;
        totalSupply = withDecimals(31000000, decimals);&#13;
&#13;
        uint preIcoTokens = withDecimals(_preIcoTokens, decimals);&#13;
&#13;
        // PreICO tokens are allocated to the special address and will be distributed manually&#13;
        balances[preIcoAllocation] = preIcoTokens;&#13;
&#13;
        // foundationReserve balance will be allocated after the end of the crowdsale&#13;
        balances[foundationReserve] = 0;&#13;
&#13;
        // The rest of the tokens is available for sale (75% of totalSupply)&#13;
        balances[icoAllocation] = div(mul(totalSupply, 75), 100)  - preIcoTokens;&#13;
&#13;
        signer = _signer;&#13;
        multisig = _multisig;&#13;
    }&#13;
&#13;
    modifier icoIsActive {&#13;
        require(now &gt;= startDate &amp;&amp; now &lt; startDate + duration);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier icoIsCompleted {&#13;
        require(now &gt;= startDate + duration);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyOwnerOrSigner {&#13;
        require((msg.sender == owner) || (msg.sender == signer));&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Settle an investment made in ETH and distribute tokens&#13;
    function invest(address investor, uint256 tokenPriceInPicoUsd, uint256 investedInWei, bytes32 hash, uint8 v, bytes32 r, bytes32 s, uint256 WeiToUSD)&#13;
        public&#13;
        icoIsActive&#13;
        payable&#13;
    {&#13;
        // Check the hash&#13;
        require(sha256(uint(investor) &lt;&lt; 96 | tokenPriceInWei) == hash);&#13;
&#13;
        // Check the signature&#13;
        require(ecrecover(hash, v, r, s) == signer);&#13;
&#13;
        // Difference between the value argument and actual value should not be&#13;
        // more than 0.005 ETH (gas commission)&#13;
        require(sub(investedInWei, msg.value) &lt;= withDecimals(5, 15));&#13;
&#13;
        uint tokenPriceInWei = div(mul(tokenPriceInPicoUsd, WeiToUSD), pow(10, usdDecimals));&#13;
&#13;
        // Number of tokens to distribute&#13;
        uint256 tokensNumber = div(withDecimals(investedInWei, decimals), tokenPriceInWei);&#13;
&#13;
        // Check if there is enough tokens left&#13;
        require(balances[icoAllocation] &gt;= tokensNumber);&#13;
&#13;
        // Send Ether to the multisig&#13;
        require(multisig.send(msg.value));&#13;
&#13;
        uint256 investedInPicoUsd = div(withDecimals(investedInWei, usdDecimals), WeiToUSD);&#13;
&#13;
        investInUSD(investor, investedInPicoUsd, tokensNumber);&#13;
&#13;
        InvestmentInETH(investor, tokenPriceInWei, investedInWei, investedInPicoUsd, tokensNumber, hash);&#13;
    }&#13;
&#13;
    /// @dev Settle an investment in BTC and distribute tokens.&#13;
    function investInBTC(address investor, uint256 tokenPriceInPicoUsd, uint256 investedInSatoshi, string btcAddress, uint256 satoshiToUSD)&#13;
        public&#13;
        icoIsActive&#13;
        onlyOwnerOrSigner&#13;
    {&#13;
        uint tokenPriceInSatoshi = div(mul(tokenPriceInPicoUsd, satoshiToUSD), pow(10, usdDecimals));&#13;
&#13;
        // Number of tokens to distribute&#13;
        uint256 tokensNumber = div(withDecimals(investedInSatoshi, decimals), tokenPriceInSatoshi);&#13;
&#13;
        // Check if there is enough tokens left&#13;
        require(balances[icoAllocation] &gt;= tokensNumber);&#13;
&#13;
        uint256 investedInPicoUsd = div(withDecimals(investedInSatoshi, usdDecimals), satoshiToUSD);&#13;
&#13;
        investInUSD(investor, investedInPicoUsd, tokensNumber);&#13;
&#13;
        InvestmentInBTC(investor, tokenPriceInSatoshi, investedInSatoshi, investedInPicoUsd, tokensNumber, btcAddress);&#13;
    }&#13;
&#13;
    // @dev Invest in USD&#13;
    function investInUSD(address investor, uint256 investedInPicoUsd, uint256 tokensNumber)&#13;
        private&#13;
    {&#13;
      totalPicoUSD = add(totalPicoUSD, investedInPicoUsd);&#13;
&#13;
      // Allocate tokens to an investor&#13;
      balances[icoAllocation] -= tokensNumber;&#13;
      balances[investor] += tokensNumber;&#13;
      Transfer(icoAllocation, investor, tokensNumber);&#13;
    }&#13;
&#13;
    // @dev Wire investment&#13;
    function wireInvestInUSD(address investor, uint256 tokenPriceInUsdCents, uint256 investedInUsdCents)&#13;
        public&#13;
        icoIsActive&#13;
        onlyOwnerOrSigner&#13;
     {&#13;
&#13;
       uint256 tokensNumber = div(withDecimals(investedInUsdCents, decimals), tokenPriceInUsdCents);&#13;
&#13;
       // Check if there is enough tokens left&#13;
       require(balances[icoAllocation] &gt;= tokensNumber);&#13;
&#13;
       // We subtract 2 because the value is in cents.&#13;
       uint256 investedInPicoUsd = withDecimals(investedInUsdCents, usdDecimals - 2);&#13;
       uint256 tokenPriceInPicoUsd = withDecimals(tokenPriceInUsdCents, usdDecimals - 2);&#13;
&#13;
       investInUSD(investor, investedInPicoUsd, tokensNumber);&#13;
&#13;
       InvestmentInUSD(investor, tokenPriceInPicoUsd, investedInPicoUsd, tokensNumber);&#13;
    }&#13;
&#13;
    // @dev Presale tokens distribution&#13;
    function preIcoDistribution(address investor, uint256 investedInUsdCents, uint256 tokensNumber)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
      uint256 tokensNumberWithDecimals = withDecimals(tokensNumber, decimals);&#13;
&#13;
      // Check if there is enough tokens left&#13;
      require(balances[preIcoAllocation] &gt;= tokensNumberWithDecimals);&#13;
&#13;
      // Allocate tokens to an investor&#13;
      balances[preIcoAllocation] -= tokensNumberWithDecimals;&#13;
      balances[investor] += tokensNumberWithDecimals;&#13;
      Transfer(preIcoAllocation, investor, tokensNumberWithDecimals);&#13;
&#13;
      uint256 investedInPicoUsd = withDecimals(investedInUsdCents, usdDecimals - 2);&#13;
      // Add investment to totalPicoUSD collected&#13;
      totalPicoUSD = add(totalPicoUSD, investedInPicoUsd);&#13;
&#13;
      PresaleInvestment(investor, investedInPicoUsd, tokensNumberWithDecimals);&#13;
    }&#13;
&#13;
&#13;
    /// @dev Allow token withdrawals from Foundation reserve&#13;
    function allowToWithdrawFromReserve()&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        require(now &gt;= vestingDateEnd);&#13;
&#13;
        // Allow the owner to withdraw tokens from the Foundation reserve&#13;
        allowed[foundationReserve][msg.sender] = balanceOf(foundationReserve);&#13;
    }&#13;
&#13;
&#13;
    // @dev Withdraws tokens from Foundation reserve&#13;
    function withdrawFromReserve(uint amount)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        require(now &gt;= vestingDateEnd);&#13;
        // Withdraw tokens from Foundation reserve to multisig address&#13;
        require(transferFrom(foundationReserve, multisig, amount));&#13;
    }&#13;
&#13;
    /// @dev Changes multisig address&#13;
    function changeMultisig(address _multisig)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        multisig = _multisig;&#13;
    }&#13;
&#13;
    /// @dev Changes signer address&#13;
    function changeSigner(address _signer)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        signer = _signer;&#13;
    }&#13;
&#13;
    /// @dev Burns the rest of the tokens after the crowdsale end and&#13;
    /// send 10% tokens of totalSupply to team address&#13;
    function finaliseICO()&#13;
        public&#13;
        onlyOwner&#13;
        icoIsCompleted&#13;
    {&#13;
        require(!finalised);&#13;
&#13;
        //total sold during ICO&#13;
        totalSupply = sub(totalSupply, balanceOf(icoAllocation));&#13;
        totalSupply = sub(totalSupply, withDecimals(7750000, decimals));&#13;
&#13;
        //send 5% bounty + 7.5% of total sold tokens to team address&#13;
        balances[multisig] = div(mul(totalSupply, 125), 1000);&#13;
&#13;
        //lock 12.5% of sold tokens to team address for one year&#13;
        balances[foundationReserve] = div(mul(totalSupply, 125), 1000);&#13;
&#13;
        totalSupply = add(totalSupply, mul(balanceOf(foundationReserve), 2));&#13;
&#13;
        //burn the rest of tokens&#13;
        balances[icoAllocation] = 0;&#13;
&#13;
        finalised = true;&#13;
    }&#13;
&#13;
    function totalUSD()&#13;
      public&#13;
      constant&#13;
      returns (uint)&#13;
    {&#13;
       return div(totalPicoUSD, pow(10, usdDecimals));&#13;
    }&#13;
}