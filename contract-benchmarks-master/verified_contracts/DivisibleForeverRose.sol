pragma solidity ^0.4.18;


/*============================================================================= */
/*=============================ERC721 interface==================================== */
/*============================================================================= */

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Yumin.yang
contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    //function ownerOf(uint256 _tokenId) external view returns (address owner);
    //function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    //function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    //event Approval(address owner, address approved, uint256 tokenId);

}


/*============================================================================= */
/*=============================Forever Rose==================================== */
/*============================================================================= */

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Yumin.yang
contract DivisibleForeverRose is ERC721 {
  
    //This contract's owner
    address private contractOwner;

    
    //Gift token storage.
    mapping(uint => GiftToken) giftStorage;

    // Total supply of this token. 
	uint public totalSupply = 10; 

    bool public tradable = false;

    uint foreverRoseId = 1;

    // Divisibility of ownership over a token  
	mapping(address => mapping(uint => uint)) ownerToTokenShare;

	// How much owners have of a token
	mapping(uint => mapping(address => uint)) tokenToOwnersHoldings;

    // If Forever Rose has been created
	mapping(uint => bool) foreverRoseCreated;

    string public name;  
    string public symbol;           
    uint8 public decimals = 1;                                 
    string public version = "1.0";    

    //Special gift token
    struct GiftToken {
        uint256 giftId;
    } 

    //@dev Constructor 
    function DivisibleForeverRose() public {
        contractOwner = msg.sender;
        name = "ForeverRose";
        symbol = "ROSE";  

        // Create Forever rose
        GiftToken memory newGift = GiftToken({
            giftId: foreverRoseId
        });
        giftStorage[foreverRoseId] = newGift;

        
        foreverRoseCreated[foreverRoseId] = true;
        _addNewOwnerHoldingsToToken(contractOwner, foreverRoseId, totalSupply);
        _addShareToNewOwner(contractOwner, foreverRoseId, totalSupply);

    }
    
    // Fallback funciton
    function() public {
        revert();
    }

    function totalSupply() public view returns (uint256 total) {
        return totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return ownerToTokenShare[_owner][foreverRoseId];
    }

    // We use parameter '_tokenId' as the divisibility
    function transfer(address _to, uint256 _tokenId) external {

        // Requiring this contract be tradable
        require(tradable == true);

        require(_to != address(0));
        require(msg.sender != _to);

        // Take _tokenId as divisibility
        uint256 _divisibility = _tokenId;

        // Requiring msg.sender has Holdings of Forever rose
        require(tokenToOwnersHoldings[foreverRoseId][msg.sender] >= _divisibility);

    
        // Remove divisibilitys from old owner
        _removeShareFromLastOwner(msg.sender, foreverRoseId, _divisibility);
        _removeLastOwnerHoldingsFromToken(msg.sender, foreverRoseId, _divisibility);

        // Add divisibilitys to new owner
        _addNewOwnerHoldingsToToken(_to, foreverRoseId, _divisibility);
        _addShareToNewOwner(_to, foreverRoseId, _divisibility);

        // Trigger Ethereum Event
        Transfer(msg.sender, _to, foreverRoseId);

    }

    // Transfer gift to a new owner.
    function assignSharedOwnership(address _to, uint256 _divisibility)
                               onlyOwner external returns (bool success) 
                               {

        require(_to != address(0));
        require(msg.sender != _to);
        require(_to != address(this));
        
        // Requiring msg.sender has Holdings of Forever rose
        require(tokenToOwnersHoldings[foreverRoseId][msg.sender] >= _divisibility);

        //Remove ownership from oldOwner(msg.sender)
        _removeLastOwnerHoldingsFromToken(msg.sender, foreverRoseId, _divisibility);
        _removeShareFromLastOwner(msg.sender, foreverRoseId, _divisibility);

         //Add ownership to NewOwner(address _to)
        _addShareToNewOwner(_to, foreverRoseId, _divisibility); 
        _addNewOwnerHoldingsToToken(_to, foreverRoseId, _divisibility);

        // Trigger Ethereum Event
        Transfer(msg.sender, _to, foreverRoseId);

        return true;
    }

    function getForeverRose() public view returns(uint256 _foreverRoseId) {
        return giftStorage[foreverRoseId].giftId;
    }

    // Turn on this contract to be tradable, so owners can transfer their token
    function turnOnTradable() public onlyOwner {
        tradable = true;
    }
    
    // ------------------------------ Helper functions (internal functions) ------------------------------

	// Add divisibility to new owner
	function _addShareToNewOwner(address _owner, uint _tokenId, uint _units) internal {
		ownerToTokenShare[_owner][_tokenId] += _units;
	}

	
	// Add the divisibility to new owner
	function _addNewOwnerHoldingsToToken(address _owner, uint _tokenId, uint _units) internal {
		tokenToOwnersHoldings[_tokenId][_owner] += _units;
	}
    
    // Remove divisibility from last owner
	function _removeShareFromLastOwner(address _owner, uint _tokenId, uint _units) internal {
		ownerToTokenShare[_owner][_tokenId] -= _units;
	}
    
    // Remove divisibility from last owner 
	function _removeLastOwnerHoldingsFromToken(address _owner, uint _tokenId, uint _units) internal {
		tokenToOwnersHoldings[_tokenId][_owner] -= _units;
	}

    // Withdraw Ether from this contract to Multi sigin wallet
    function withdrawEther() onlyOwner public returns(bool) {
        return contractOwner.send(this.balance);
    }

    // ------------------------------ Modifier -----------------------------------


     modifier onlyExistentToken(uint _tokenId) {
	    require(foreverRoseCreated[_tokenId] == true);
	    _;
	}

    modifier onlyOwner(){
         require(msg.sender == contractOwner);
         _;
     }

}


/*============================================================================= */
/*=============================MultiSig Wallet================================= */
/*============================================================================= */

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5c2f28393a3d32723b39332e3b391c3f33322f39322f252f72323928">[email protected]</a>&gt;&#13;
contract MultiSigWallet {&#13;
&#13;
   //Load Gifto and IAMICOIN Contracts to this contract.&#13;
    //ERC20 private Gifto = ERC20(0x92e87a5622cf9955d1062822454701198a028a72);&#13;
    //ERC20 private IAMIToken = ERC20(0xee10a06b2a0cf7e04115edfbee46242136eb6ae1);&#13;
&#13;
    uint constant public MAX_OWNER_COUNT = 50;&#13;
&#13;
    event Confirmation(address indexed sender, uint indexed transactionId);&#13;
    event Revocation(address indexed sender, uint indexed transactionId);&#13;
    event Submission(uint indexed transactionId);&#13;
    event Execution(uint indexed transactionId);&#13;
    event ExecutionFailure(uint indexed transactionId);&#13;
    event Deposit(address indexed sender, uint value);&#13;
    event OwnerAddition(address indexed owner);&#13;
    event OwnerRemoval(address indexed owner);&#13;
    event RequirementChange(uint required);&#13;
    event CoinCreation(address coin);&#13;
&#13;
    mapping (uint =&gt; Transaction) public transactions;&#13;
    mapping (uint =&gt; mapping (address =&gt; bool)) public confirmations;&#13;
    mapping (address =&gt; bool) public isOwner;&#13;
    address[] public owners;&#13;
    uint public required;&#13;
    uint public transactionCount;&#13;
    bool flag = true;&#13;
&#13;
    struct Transaction {&#13;
        address destination;&#13;
        uint value;&#13;
        bytes data;&#13;
        bool executed;&#13;
    }&#13;
&#13;
    modifier onlyWallet() {&#13;
        if (msg.sender != address(this))&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerDoesNotExist(address owner) {&#13;
        if (isOwner[owner])&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerExists(address owner) {&#13;
        if (!isOwner[owner])&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    modifier transactionExists(uint transactionId) {&#13;
        if (transactions[transactionId].destination == 0)&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    modifier confirmed(uint transactionId, address owner) {&#13;
        if (!confirmations[transactionId][owner])&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notConfirmed(uint transactionId, address owner) {&#13;
        if (confirmations[transactionId][owner])&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notExecuted(uint transactionId) {&#13;
        if (transactions[transactionId].executed)&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notNull(address _address) {&#13;
        if (_address == 0)&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    modifier validRequirement(uint ownerCount, uint _required) {&#13;
        if (   ownerCount &gt; MAX_OWNER_COUNT&#13;
            || _required &gt; ownerCount&#13;
            || _required == 0&#13;
            || ownerCount == 0)&#13;
            revert();&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Fallback function allows to deposit ether.&#13;
    function()&#13;
        payable&#13;
    {&#13;
        if (msg.value &gt; 0)&#13;
            Deposit(msg.sender, msg.value);&#13;
    }&#13;
&#13;
    /*&#13;
     * Public functions&#13;
     */&#13;
    /// @dev Contract constructor sets initial owners and required number of confirmations.&#13;
    /// @param _owners List of initial owners.&#13;
    /// @param _required Number of required confirmations.&#13;
    function MultiSigWallet(address[] _owners, uint _required)&#13;
        public&#13;
        validRequirement(_owners.length, _required)&#13;
    {&#13;
        for (uint i=0; i&lt;_owners.length; i++) {&#13;
            if (isOwner[_owners[i]] || _owners[i] == 0)&#13;
                revert();&#13;
            isOwner[_owners[i]] = true;&#13;
        }&#13;
        owners = _owners;&#13;
        required = _required;&#13;
    }&#13;
&#13;
    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.&#13;
    /// @param owner Address of new owner.&#13;
    function addOwner(address owner)&#13;
        public&#13;
        onlyWallet&#13;
        ownerDoesNotExist(owner)&#13;
        notNull(owner)&#13;
        validRequirement(owners.length + 1, required)&#13;
    {&#13;
        isOwner[owner] = true;&#13;
        owners.push(owner);&#13;
        OwnerAddition(owner);&#13;
    }&#13;
&#13;
    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.&#13;
    /// @param owner Address of owner.&#13;
    function removeOwner(address owner)&#13;
        public&#13;
        onlyWallet&#13;
        ownerExists(owner)&#13;
    {&#13;
        isOwner[owner] = false;&#13;
        for (uint i=0; i&lt;owners.length - 1; i++)&#13;
            if (owners[i] == owner) {&#13;
                owners[i] = owners[owners.length - 1];&#13;
                break;&#13;
            }&#13;
        owners.length -= 1;&#13;
        if (required &gt; owners.length)&#13;
            changeRequirement(owners.length);&#13;
        OwnerRemoval(owner);&#13;
    }&#13;
&#13;
    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.&#13;
    /// @param owner Address of owner to be replaced.&#13;
    /// @param owner Address of new owner.&#13;
    function replaceOwner(address owner, address newOwner)&#13;
        public&#13;
        onlyWallet&#13;
        ownerExists(owner)&#13;
        ownerDoesNotExist(newOwner)&#13;
    {&#13;
        for (uint i=0; i&lt;owners.length; i++)&#13;
            if (owners[i] == owner) {&#13;
                owners[i] = newOwner;&#13;
                break;&#13;
            }&#13;
        isOwner[owner] = false;&#13;
        isOwner[newOwner] = true;&#13;
        OwnerRemoval(owner);&#13;
        OwnerAddition(newOwner);&#13;
    }&#13;
&#13;
    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.&#13;
    /// @param _required Number of required confirmations.&#13;
    function changeRequirement(uint _required)&#13;
        public&#13;
        onlyWallet&#13;
        validRequirement(owners.length, _required)&#13;
    {&#13;
        required = _required;&#13;
        RequirementChange(_required);&#13;
    }&#13;
&#13;
    /// @dev Allows an owner to submit and confirm a transaction.&#13;
    /// @param destination Transaction target address.&#13;
    /// @param value Transaction ether value.&#13;
    /// @param data Transaction data payload.&#13;
    /// @return Returns transaction ID.&#13;
    function submitTransaction(address destination, uint value, bytes data)&#13;
        public&#13;
        returns (uint transactionId)&#13;
    {&#13;
        transactionId = addTransaction(destination, value, data);&#13;
        confirmTransaction(transactionId);&#13;
    }&#13;
&#13;
    /// @dev Allows an owner to confirm a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function confirmTransaction(uint transactionId)&#13;
        public&#13;
        ownerExists(msg.sender)&#13;
        transactionExists(transactionId)&#13;
        notConfirmed(transactionId, msg.sender)&#13;
    {&#13;
        confirmations[transactionId][msg.sender] = true;&#13;
        Confirmation(msg.sender, transactionId);&#13;
        executeTransaction(transactionId);&#13;
    }&#13;
&#13;
    /// @dev Allows an owner to revoke a confirmation for a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function revokeConfirmation(uint transactionId)&#13;
        public&#13;
        ownerExists(msg.sender)&#13;
        confirmed(transactionId, msg.sender)&#13;
        notExecuted(transactionId)&#13;
    {&#13;
        confirmations[transactionId][msg.sender] = false;&#13;
        Revocation(msg.sender, transactionId);&#13;
    }&#13;
&#13;
    /// @dev Allows anyone to execute a confirmed transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    function executeTransaction(uint transactionId)&#13;
        public&#13;
        notExecuted(transactionId)&#13;
    {&#13;
        if (isConfirmed(transactionId)) {&#13;
            Transaction tx = transactions[transactionId];&#13;
            tx.executed = true;&#13;
            if (tx.destination.call.value(tx.value)(tx.data))&#13;
                Execution(transactionId);&#13;
            else {&#13;
                ExecutionFailure(transactionId);&#13;
                tx.executed = false;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Returns the confirmation status of a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    /// @return Confirmation status.&#13;
    function isConfirmed(uint transactionId)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        uint count = 0;&#13;
        for (uint i=0; i&lt;owners.length; i++) {&#13;
            if (confirmations[transactionId][owners[i]])&#13;
                count += 1;&#13;
            if (count == required)&#13;
                return true;&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * Internal functions&#13;
     */&#13;
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.&#13;
    /// @param destination Transaction target address.&#13;
    /// @param value Transaction ether value.&#13;
    /// @param data Transaction data payload.&#13;
    /// @return Returns transaction ID.&#13;
    function addTransaction(address destination, uint value, bytes data)&#13;
        internal&#13;
        notNull(destination)&#13;
        returns (uint transactionId)&#13;
    {&#13;
        transactionId = transactionCount;&#13;
        transactions[transactionId] = Transaction({&#13;
            destination: destination,&#13;
            value: value,&#13;
            data: data,&#13;
            executed: false&#13;
        });&#13;
        transactionCount += 1;&#13;
        Submission(transactionId);&#13;
    }&#13;
&#13;
    /*&#13;
     * Web3 call functions&#13;
     */&#13;
    /// @dev Returns number of confirmations of a transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    /// @return Number of confirmations.&#13;
    function getConfirmationCount(uint transactionId)&#13;
        public&#13;
        constant&#13;
        returns (uint count)&#13;
    {&#13;
        for (uint i=0; i&lt;owners.length; i++)&#13;
            if (confirmations[transactionId][owners[i]])&#13;
                count += 1;&#13;
    }&#13;
&#13;
    /// @dev Returns total number of transactions after filers are applied.&#13;
    /// @param pending Include pending transactions.&#13;
    /// @param executed Include executed transactions.&#13;
    /// @return Total number of transactions after filters are applied.&#13;
    function getTransactionCount(bool pending, bool executed)&#13;
        public&#13;
        constant&#13;
        returns (uint count)&#13;
    {&#13;
        for (uint i=0; i&lt;transactionCount; i++)&#13;
            if (   pending &amp;&amp; !transactions[i].executed&#13;
                || executed &amp;&amp; transactions[i].executed)&#13;
                count += 1;&#13;
    }&#13;
&#13;
    /// @dev Returns list of owners.&#13;
    /// @return List of owner addresses.&#13;
    function getOwners()&#13;
        public&#13;
        constant&#13;
        returns (address[])&#13;
    {&#13;
        return owners;&#13;
    }&#13;
&#13;
    /// @dev Returns array with owner addresses, which confirmed transaction.&#13;
    /// @param transactionId Transaction ID.&#13;
    /// @return Returns array of owner addresses.&#13;
    function getConfirmations(uint transactionId)&#13;
        public&#13;
        constant&#13;
        returns (address[] _confirmations)&#13;
    {&#13;
        address[] memory confirmationsTemp = new address[](owners.length);&#13;
        uint count = 0;&#13;
        uint i;&#13;
        for (i=0; i&lt;owners.length; i++)&#13;
            if (confirmations[transactionId][owners[i]]) {&#13;
                confirmationsTemp[count] = owners[i];&#13;
                count += 1;&#13;
            }&#13;
        _confirmations = new address[](count);&#13;
        for (i=0; i&lt;count; i++)&#13;
            _confirmations[i] = confirmationsTemp[i];&#13;
    }&#13;
&#13;
    /// @dev Returns list of transaction IDs in defined range.&#13;
    /// @param from Index start position of transaction array.&#13;
    /// @param to Index end position of transaction array.&#13;
    /// @param pending Include pending transactions.&#13;
    /// @param executed Include executed transactions.&#13;
    /// @return Returns array of transaction IDs.&#13;
    function getTransactionIds(uint from, uint to, bool pending, bool executed)&#13;
        public&#13;
        constant&#13;
        returns (uint[] _transactionIds)&#13;
    {&#13;
        uint[] memory transactionIdsTemp = new uint[](transactionCount);&#13;
        uint count = 0;&#13;
        uint i;&#13;
        for (i=0; i&lt;transactionCount; i++)&#13;
            if (   pending &amp;&amp; !transactions[i].executed&#13;
                || executed &amp;&amp; transactions[i].executed)&#13;
            {&#13;
                transactionIdsTemp[count] = i;&#13;
                count += 1;&#13;
            }&#13;
        _transactionIds = new uint[](to - from);&#13;
        for (i=from; i&lt;to; i++)&#13;
            _transactionIds[i - from] = transactionIdsTemp[i];&#13;
    }&#13;
&#13;
    // Transfer GTO to an outside account&#13;
    /*function _withdrawGTO(address _to, uint256 _balance) onlyOwner internal { &#13;
        require(Gifto.balanceOf(address(this)) &gt;= _balance);&#13;
        Gifto.transfer(_to, _balance); &#13;
    }&#13;
&#13;
    // Transfer IAMI to an outside account&#13;
    function _withdrawIAMI(address _to, uint256 _balance) onlyOwner internal { &#13;
        require(IAMIToken.balanceOf(address(this)) &gt;= _balance);&#13;
        IAMIToken.transfer(_to, _balance); &#13;
    }&#13;
&#13;
    // Change Gifto contract's address or another type of token, like Ether.&#13;
    function setIAMITokenAddress(address newAddress) public onlyOwner {&#13;
        IAMIToken = ERC20(newAddress);&#13;
    }&#13;
&#13;
    function setGiftoAddress(address newAddress) public onlyOwner {&#13;
        Gifto = ERC20(newAddress);&#13;
    }*/&#13;
&#13;
    modifier onlyOwner() {&#13;
        require(isOwner[msg.sender] == true);&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Create new forever rose.&#13;
    function createForeverRose()&#13;
        external&#13;
        onlyWallet&#13;
    {&#13;
        require(flag == true);&#13;
        CoinCreation(new DivisibleForeverRose());&#13;
        flag = false;&#13;
    }&#13;
    &#13;
&#13;
}