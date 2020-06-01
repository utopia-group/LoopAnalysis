pragma solidity ^0.4.18;




/// note: during any ownership changes all pending operations (waiting for more signatures) are cancelled
// TODO acceptOwnership
contract multiowned {

    // TYPES

    // struct for the status of a pending operation.
    struct MultiOwnedOperationPendingState {
    // count of confirmations needed
    uint yetNeeded;

    // bitmap of confirmations where owner #ownerIndex's decision corresponds to 2**ownerIndex bit
    uint ownersDone;

    // position of this operation key in m_multiOwnedPendingIndex
    uint index;
    }

    // EVENTS

    event Confirmation(address owner, bytes32 operation);
    event Revoke(address owner, bytes32 operation);
    event FinalConfirmation(address owner, bytes32 operation);

    // some others are in the case of an owner changing.
    event OwnerChanged(address oldOwner, address newOwner);
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);

    // the last one is emitted if the required signatures change
    event RequirementChanged(uint newRequirement);

    // MODIFIERS

    // simple single-sig function modifier.
    modifier onlyowner {
        require(isOwner(msg.sender));
        _;
    }
    // multi-sig function modifier: the operation must have an intrinsic hash in order
    // that later attempts can be realised as the same underlying operation and
    // thus count as confirmations.
    modifier onlymanyowners(bytes32 _operation) {
        if (confirmAndCheck(_operation)) {
            _;
        }
        // Even if required number of confirmations has't been collected yet,
        // we can't throw here - because changes to the state have to be preserved.
        // But, confirmAndCheck itself will throw in case sender is not an owner.
    }

    modifier validNumOwners(uint _numOwners) {
        require(_numOwners > 0 && _numOwners <= c_maxOwners);
        _;
    }

    modifier multiOwnedValidRequirement(uint _required, uint _numOwners) {
        require(_required > 0 && _required <= _numOwners);
        _;
    }

    modifier ownerExists(address _address) {
        require(isOwner(_address));
        _;
    }

    modifier ownerDoesNotExist(address _address) {
        require(!isOwner(_address));
        _;
    }

    modifier multiOwnedOperationIsActive(bytes32 _operation) {
        require(isOperationActive(_operation));
        _;
    }

    // METHODS

    // constructor is given number of sigs required to do protected "onlymanyowners" transactions
    // as well as the selection of addresses capable of confirming them (msg.sender is not added to the owners!).
    function multiowned(address[] _owners, uint _required)
    validNumOwners(_owners.length)
    multiOwnedValidRequirement(_required, _owners.length)
    {
        assert(c_maxOwners <= 255);

        m_numOwners = _owners.length;
        m_multiOwnedRequired = _required;

        for (uint i = 0; i < _owners.length; ++i)
        {
            address owner = _owners[i];
            // invalid and duplicate addresses are not allowed
            require(0 != owner && !isOwner(owner) /* not isOwner yet! */);

            uint currentOwnerIndex = checkOwnerIndex(i + 1 /* first slot is unused */);
            m_owners[currentOwnerIndex] = owner;
            m_ownerIndex[owner] = currentOwnerIndex;
        }

        assertOwnersAreConsistent();
    }

    /// @notice replaces an owner `_from` with another `_to`.
    /// @param _from address of owner to replace
    /// @param _to address of new owner
    // All pending operations will be canceled!
    function changeOwner(address _from, address _to)
    external
    ownerExists(_from)
    ownerDoesNotExist(_to)
    onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_from]);
        m_owners[ownerIndex] = _to;
        m_ownerIndex[_from] = 0;
        m_ownerIndex[_to] = ownerIndex;

        assertOwnersAreConsistent();
        OwnerChanged(_from, _to);
    }

    /// @notice adds an owner
    /// @param _owner address of new owner
    // All pending operations will be canceled!
    function addOwner(address _owner)
    external
    ownerDoesNotExist(_owner)
    validNumOwners(m_numOwners + 1)
    onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        m_numOwners++;
        m_owners[m_numOwners] = _owner;
        m_ownerIndex[_owner] = checkOwnerIndex(m_numOwners);

        assertOwnersAreConsistent();
        OwnerAdded(_owner);
    }

    /// @notice removes an owner
    /// @param _owner address of owner to remove
    // All pending operations will be canceled!
    function removeOwner(address _owner)
    external
    ownerExists(_owner)
    validNumOwners(m_numOwners - 1)
    multiOwnedValidRequirement(m_multiOwnedRequired, m_numOwners - 1)
    onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_owner]);
        m_owners[ownerIndex] = 0;
        m_ownerIndex[_owner] = 0;
        //make sure m_numOwners is equal to the number of owners and always points to the last owner
        reorganizeOwners();

        assertOwnersAreConsistent();
        OwnerRemoved(_owner);
    }

    /// @notice changes the required number of owner signatures
    /// @param _newRequired new number of signatures required
    // All pending operations will be canceled!
    function changeRequirement(uint _newRequired)
    external
    multiOwnedValidRequirement(_newRequired, m_numOwners)
    onlymanyowners(sha3(msg.data))
    {
        m_multiOwnedRequired = _newRequired;
        clearPending();
        RequirementChanged(_newRequired);
    }

    /// @notice Gets an owner by 0-indexed position
    /// @param ownerIndex 0-indexed owner position
    function getOwner(uint ownerIndex) public constant returns (address) {
        return m_owners[ownerIndex + 1];
    }

    /// @notice Gets owners
    /// @return memory array of owners
    function getOwners() public constant returns (address[]) {
        address[] memory result = new address[](m_numOwners);
        for (uint i = 0; i < m_numOwners; i++)
        result[i] = getOwner(i);

        return result;
    }

    /// @notice checks if provided address is an owner address
    /// @param _addr address to check
    /// @return true if it's an owner
    function isOwner(address _addr) public constant returns (bool) {
        return m_ownerIndex[_addr] > 0;
    }

    /// @notice Tests ownership of the current caller.
    /// @return true if it's an owner
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to
    // addOwner/changeOwner and to isOwner.
    function amIOwner() external constant onlyowner returns (bool) {
        return true;
    }

    /// @notice Revokes a prior confirmation of the given operation
    /// @param _operation operation value, typically sha3(msg.data)
    function revoke(bytes32 _operation)
    external
    multiOwnedOperationIsActive(_operation)
    onlyowner
    {
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);
        var pending = m_multiOwnedPending[_operation];
        require(pending.ownersDone & ownerIndexBit > 0);

        assertOperationIsConsistent(_operation);

        pending.yetNeeded++;
        pending.ownersDone -= ownerIndexBit;

        assertOperationIsConsistent(_operation);
        Revoke(msg.sender, _operation);
    }

    /// @notice Checks if owner confirmed given operation
    /// @param _operation operation value, typically sha3(msg.data)
    /// @param _owner an owner address
    function hasConfirmed(bytes32 _operation, address _owner)
    external
    constant
    multiOwnedOperationIsActive(_operation)
    ownerExists(_owner)
    returns (bool)
    {
        return !(m_multiOwnedPending[_operation].ownersDone & makeOwnerBitmapBit(_owner) == 0);
    }

    // INTERNAL METHODS

    function confirmAndCheck(bytes32 _operation)
    private
    onlyowner
    returns (bool)
    {
        if (512 == m_multiOwnedPendingIndex.length)
        // In case m_multiOwnedPendingIndex grows too much we have to shrink it: otherwise at some point
        // we won't be able to do it because of block gas limit.
        // Yes, pending confirmations will be lost. Dont see any security or stability implications.
        // TODO use more graceful approach like compact or removal of clearPending completely
        clearPending();

        var pending = m_multiOwnedPending[_operation];

        // if we're not yet working on this operation, switch over and reset the confirmation status.
        if (! isOperationActive(_operation)) {
            // reset count of confirmations needed.
            pending.yetNeeded = m_multiOwnedRequired;
            // reset which owners have confirmed (none) - set our bitmap to 0.
            pending.ownersDone = 0;
            pending.index = m_multiOwnedPendingIndex.length++;
            m_multiOwnedPendingIndex[pending.index] = _operation;
            assertOperationIsConsistent(_operation);
        }

        // determine the bit to set for this owner.
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);
        // make sure we (the message sender) haven't confirmed this operation previously.
        if (pending.ownersDone & ownerIndexBit == 0) {
            // ok - check if count is enough to go ahead.
            assert(pending.yetNeeded > 0);
            if (pending.yetNeeded == 1) {
                // enough confirmations: reset and run interior.
                delete m_multiOwnedPendingIndex[m_multiOwnedPending[_operation].index];
                delete m_multiOwnedPending[_operation];
                FinalConfirmation(msg.sender, _operation);
                return true;
            }
            else
            {
                // not enough: record that this owner in particular confirmed.
                pending.yetNeeded--;
                pending.ownersDone |= ownerIndexBit;
                assertOperationIsConsistent(_operation);
                Confirmation(msg.sender, _operation);
            }
        }
    }

    // Reclaims free slots between valid owners in m_owners.
    // TODO given that its called after each removal, it could be simplified.
    function reorganizeOwners() private {
        uint free = 1;
        while (free < m_numOwners)
        {
            // iterating to the first free slot from the beginning
            while (free < m_numOwners && m_owners[free] != 0) free++;

            // iterating to the first occupied slot from the end
            while (m_numOwners > 1 && m_owners[m_numOwners] == 0) m_numOwners--;

            // swap, if possible, so free slot is located at the end after the swap
            if (free < m_numOwners && m_owners[m_numOwners] != 0 && m_owners[free] == 0)
            {
                // owners between swapped slots should't be renumbered - that saves a lot of gas
                m_owners[free] = m_owners[m_numOwners];
                m_ownerIndex[m_owners[free]] = free;
                m_owners[m_numOwners] = 0;
            }
        }
    }

    function clearPending() private onlyowner {
        uint length = m_multiOwnedPendingIndex.length;
        // TODO block gas limit
        for (uint i = 0; i < length; ++i) {
            if (m_multiOwnedPendingIndex[i] != 0)
            delete m_multiOwnedPending[m_multiOwnedPendingIndex[i]];
        }
        delete m_multiOwnedPendingIndex;
    }

    function checkOwnerIndex(uint ownerIndex) private constant returns (uint) {
        assert(0 != ownerIndex && ownerIndex <= c_maxOwners);
        return ownerIndex;
    }

    function makeOwnerBitmapBit(address owner) private constant returns (uint) {
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[owner]);
        return 2 ** ownerIndex;
    }

    function isOperationActive(bytes32 _operation) private constant returns (bool) {
        return 0 != m_multiOwnedPending[_operation].yetNeeded;
    }


    function assertOwnersAreConsistent() private constant {
        assert(m_numOwners > 0);
        assert(m_numOwners <= c_maxOwners);
        assert(m_owners[0] == 0);
        assert(0 != m_multiOwnedRequired && m_multiOwnedRequired <= m_numOwners);
    }

    function assertOperationIsConsistent(bytes32 _operation) private constant {
        var pending = m_multiOwnedPending[_operation];
        assert(0 != pending.yetNeeded);
        assert(m_multiOwnedPendingIndex[pending.index] == _operation);
        assert(pending.yetNeeded <= m_multiOwnedRequired);
    }


    // FIELDS

    uint constant c_maxOwners = 250;

    // the number of owners that must confirm the same operation before it is run.
    uint public m_multiOwnedRequired;


    // pointer used to find a free slot in m_owners
    uint public m_numOwners;

    // list of owners (addresses),
    // slot 0 is unused so there are no owner which index is 0.
    // TODO could we save space at the end of the array for the common case of <10 owners? and should we?
    address[256] internal m_owners;

    // index on the list of owners to allow reverse lookup: owner address => index in m_owners
    mapping(address => uint) internal m_ownerIndex;


    // the ongoing operations.
    mapping(bytes32 => MultiOwnedOperationPendingState) internal m_multiOwnedPending;
    bytes32[] internal m_multiOwnedPendingIndex;
}

/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d6a4b3bbb5b996e4">[email protected]</a>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
    /**&#13;
     * @dev We use a single lock for the whole contract.&#13;
     */&#13;
    bool private rentrancy_lock = false;&#13;
&#13;
    /**&#13;
     * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
     * @notice If you mark a function `nonReentrant`, you should also&#13;
     * mark it `external`. Calling one nonReentrant function from&#13;
     * another is not supported. Instead, you can implement a&#13;
     * `private` function doing the actual work, and a `external`&#13;
     * wrapper marked as `nonReentrant`.&#13;
     */&#13;
    modifier nonReentrant() {&#13;
        require(!rentrancy_lock);&#13;
        rentrancy_lock = true;&#13;
        _;&#13;
        rentrancy_lock = false;&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Contract which is owned by owners and operated by controller.&#13;
 *&#13;
 * @notice Provides a way to set up an entity (typically other contract) entitled to control actions of this contract.&#13;
 * Controller is set up by owners or during construction.&#13;
 *&#13;
 * @dev controller check is performed by onlyController modifier.&#13;
 */&#13;
contract MultiownedControlled is multiowned {&#13;
&#13;
    event ControllerSet(address controller);&#13;
    event ControllerRetired(address was);&#13;
&#13;
&#13;
    modifier onlyController {&#13;
        require(msg.sender == m_controller);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    // PUBLIC interface&#13;
&#13;
    function MultiownedControlled(address[] _owners, uint _signaturesRequired, address _controller)&#13;
    multiowned(_owners, _signaturesRequired)&#13;
    {&#13;
        m_controller = _controller;&#13;
        ControllerSet(m_controller);&#13;
    }&#13;
&#13;
    /// @dev sets the controller&#13;
    function setController(address _controller) external onlymanyowners(sha3(msg.data)) {&#13;
        m_controller = _controller;&#13;
        ControllerSet(m_controller);&#13;
    }&#13;
&#13;
    /// @dev ability for controller to step down&#13;
    function detachController() external onlyController {&#13;
        address was = m_controller;&#13;
        m_controller = address(0);&#13;
        ControllerRetired(was);&#13;
    }&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @notice address of entity entitled to mint new tokens&#13;
    address public m_controller;&#13;
}&#13;
&#13;
&#13;
/// @title utility methods and modifiers of arguments validation&#13;
contract ArgumentsChecker {&#13;
&#13;
    /// @dev check which prevents short address attack&#13;
    modifier payloadSizeIs(uint size) {&#13;
        require(msg.data.length == size + 4 /* function selector */);&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev check that address is valid&#13;
    modifier validAddress(address addr) {&#13;
        require(addr != address(0));&#13;
        _;&#13;
    }&#13;
}&#13;
&#13;
&#13;
/// @title registry of funds sent by investors&#13;
contract FundsRegistry is ArgumentsChecker, MultiownedControlled, ReentrancyGuard {&#13;
    using SafeMath for uint256;&#13;
&#13;
    enum State {&#13;
    // gathering funds&#13;
    GATHERING,&#13;
    // returning funds to investors&#13;
    REFUNDING,&#13;
    // funds can be pulled by owners&#13;
    SUCCEEDED&#13;
    }&#13;
&#13;
    event StateChanged(State _state);&#13;
    event Invested(address indexed investor, uint256 amount);&#13;
    event EtherSent(address indexed to, uint value);&#13;
    event RefundSent(address indexed to, uint value);&#13;
&#13;
&#13;
    modifier requiresState(State _state) {&#13;
        require(m_state == _state);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    // PUBLIC interface&#13;
&#13;
    function FundsRegistry(address[] _owners, uint _signaturesRequired, address _controller)&#13;
    MultiownedControlled(_owners, _signaturesRequired, _controller)&#13;
    {&#13;
    }&#13;
&#13;
    /// @dev performs only allowed state transitions&#13;
    function changeState(State _newState)&#13;
    external&#13;
    onlyController&#13;
    {&#13;
        assert(m_state != _newState);&#13;
&#13;
        if (State.GATHERING == m_state) {   assert(State.REFUNDING == _newState || State.SUCCEEDED == _newState); }&#13;
        else assert(false);&#13;
&#13;
        m_state = _newState;&#13;
        StateChanged(m_state);&#13;
    }&#13;
&#13;
    /// @dev records an investment&#13;
    function invested(address _investor)&#13;
    external&#13;
    payable&#13;
    onlyController&#13;
    requiresState(State.GATHERING)&#13;
    {&#13;
        uint256 amount = msg.value;&#13;
        require(0 != amount);&#13;
        assert(_investor != m_controller);&#13;
&#13;
        // register investor&#13;
        if (0 == m_weiBalances[_investor])&#13;
        m_investors.push(_investor);&#13;
&#13;
        // register payment&#13;
        totalInvested = totalInvested.add(amount);&#13;
        m_weiBalances[_investor] = m_weiBalances[_investor].add(amount);&#13;
&#13;
        Invested(_investor, amount);&#13;
    }&#13;
&#13;
    /// @notice owners: send `value` of ether to address `to`, can be called if crowdsale succeeded&#13;
    /// @param to where to send ether&#13;
    /// @param value amount of wei to send&#13;
    function sendEther(address to, uint value)&#13;
    external&#13;
    validAddress(to)&#13;
    onlymanyowners(sha3(msg.data))&#13;
    requiresState(State.SUCCEEDED)&#13;
    {&#13;
        require(value &gt; 0 &amp;&amp; this.balance &gt;= value);&#13;
        to.transfer(value);&#13;
        EtherSent(to, value);&#13;
    }&#13;
&#13;
    /// @notice withdraw accumulated balance, called by payee in case crowdsale failed&#13;
    function withdrawPayments(address payee)&#13;
    external&#13;
    nonReentrant&#13;
    onlyController&#13;
    requiresState(State.REFUNDING)&#13;
    {&#13;
        uint256 payment = m_weiBalances[payee];&#13;
&#13;
        require(payment != 0);&#13;
        require(this.balance &gt;= payment);&#13;
&#13;
        totalInvested = totalInvested.sub(payment);&#13;
        m_weiBalances[payee] = 0;&#13;
&#13;
        payee.transfer(payment);&#13;
        RefundSent(payee, payment);&#13;
    }&#13;
&#13;
    function getInvestorsCount() external constant returns (uint) { return m_investors.length; }&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @notice total amount of investments in wei&#13;
    uint256 public totalInvested;&#13;
&#13;
    /// @notice state of the registry&#13;
    State public m_state = State.GATHERING;&#13;
&#13;
    /// @dev balances of investors in wei&#13;
    mapping(address =&gt; uint256) public m_weiBalances;&#13;
&#13;
    /// @dev list of unique investors&#13;
    address[] public m_investors;&#13;
}&#13;
&#13;
&#13;
///123&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        if (a == 0) {&#13;
            return 0;&#13;
        }&#13;
        uint256 c = a * b;&#13;
        assert(c / a == b);&#13;
        return c;&#13;
    }&#13;
&#13;
    function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
        uint256 c = a / b;&#13;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
        return c;&#13;
    }&#13;
&#13;
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        uint256 c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
    uint256 public totalSupply;&#13;
    function balanceOf(address who) public view returns (uint256);&#13;
    function transfer(address to, uint256 value) public returns (bool);&#13;
    event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
    using SafeMath for uint256;&#13;
&#13;
    mapping(address =&gt; uint256) balances;&#13;
&#13;
    /**&#13;
    * @dev transfer token for a specified address&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= balances[msg.sender]);&#13;
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
    * @return An uint256 representing the amount owned by the passed address.&#13;
    */&#13;
    function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
    function allowance(address owner, address spender) public view returns (uint256);&#13;
    function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
    function approve(address spender, uint256 value) public returns (bool);&#13;
    event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
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
    mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
&#13;
&#13;
    /**&#13;
     * @dev Transfer tokens from one address to another&#13;
     * @param _from address The address which you want to send tokens from&#13;
     * @param _to address The address which you want to transfer to&#13;
     * @param _value uint256 the amount of tokens to be transferred&#13;
     */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= balances[_from]);&#13;
        require(_value &lt;= allowed[_from][msg.sender]);&#13;
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
    function approve(address _spender, uint256 _value) public returns (bool) {&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
     * @param _owner address The address which owns the funds.&#13;
     * @param _spender address The address which will spend the funds.&#13;
     * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
     */&#13;
    function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    /**&#13;
     * approve should be called when allowed[_spender] == 0. To increment&#13;
     * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
     * the first transaction is mined)&#13;
     * From MonolithDAO Token.sol&#13;
     */&#13;
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
        return true;&#13;
    }&#13;
&#13;
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {&#13;
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
&#13;
&#13;
/// @title StandardToken which can be minted by another contract.&#13;
contract MintableToken {&#13;
    event Mint(address indexed to, uint256 amount);&#13;
&#13;
    /// @dev mints new tokens&#13;
    function mint(address _to, uint256 _amount) public;&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * MetropolMintableToken&#13;
 */&#13;
contract MetropolMintableToken is StandardToken, MintableToken {&#13;
&#13;
    event Mint(address indexed to, uint256 amount);&#13;
&#13;
    function mint(address _to, uint256 _amount) public;//todo propose return value&#13;
&#13;
    /**&#13;
     * Function to mint tokens&#13;
     * Internal for not forgetting to add access modifier&#13;
     *&#13;
     * @param _to The address that will receive the minted tokens.&#13;
     * @param _amount The amount of tokens to mint.&#13;
     *&#13;
     * @return A boolean that indicates if the operation was successful.&#13;
     */&#13;
    function mintInternal(address _to, uint256 _amount) internal returns (bool) {&#13;
        require(_amount&gt;0);&#13;
        require(_to!=address(0));&#13;
&#13;
        totalSupply = totalSupply.add(_amount);&#13;
        balances[_to] = balances[_to].add(_amount);&#13;
        Mint(_to, _amount);&#13;
        Transfer(address(0), _to, _amount);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * Contract which is operated by controller.&#13;
 *&#13;
 * Provides a way to set up an entity (typically other contract) entitled to control actions of this contract.&#13;
 *&#13;
 * Controller check is performed by onlyController modifier.&#13;
 */&#13;
contract Controlled {&#13;
&#13;
    address public m_controller;&#13;
&#13;
    event ControllerSet(address controller);&#13;
    event ControllerRetired(address was);&#13;
&#13;
&#13;
    modifier onlyController {&#13;
        require(msg.sender == m_controller);&#13;
        _;&#13;
    }&#13;
&#13;
    function setController(address _controller) external;&#13;
&#13;
    /**&#13;
     * Sets the controller. Internal for not forgetting to add access modifier&#13;
     */&#13;
    function setControllerInternal(address _controller) internal {&#13;
        m_controller = _controller;&#13;
        ControllerSet(m_controller);&#13;
    }&#13;
&#13;
    /**&#13;
     * Ability for controller to step down&#13;
     */&#13;
    function detachController() external onlyController {&#13;
        address was = m_controller;&#13;
        m_controller = address(0);&#13;
        ControllerRetired(was);&#13;
    }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * MintableControlledToken&#13;
 */&#13;
contract MintableControlledToken is MetropolMintableToken, Controlled {&#13;
&#13;
    /**&#13;
     * Function to mint tokens&#13;
     *&#13;
     * @param _to The address that will receive the minted tokens.&#13;
     * @param _amount The amount of tokens to mint.&#13;
     *&#13;
     * @return A boolean that indicates if the operation was successful.&#13;
     */&#13;
    function mint(address _to, uint256 _amount) public onlyController {&#13;
        super.mintInternal(_to, _amount);&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * BurnableToken&#13;
 */&#13;
contract BurnableToken is StandardToken {&#13;
&#13;
    event Burn(address indexed from, uint256 amount);&#13;
&#13;
    function burn(address _from, uint256 _amount) public returns (bool);&#13;
&#13;
    /**&#13;
     * Function to burn tokens&#13;
     * Internal for not forgetting to add access modifier&#13;
     *&#13;
     * @param _from The address to burn tokens from.&#13;
     * @param _amount The amount of tokens to burn.&#13;
     *&#13;
     * @return A boolean that indicates if the operation was successful.&#13;
     */&#13;
    function burnInternal(address _from, uint256 _amount) internal returns (bool) {&#13;
        require(_amount&gt;0);&#13;
        require(_amount&lt;=balances[_from]);&#13;
&#13;
        totalSupply = totalSupply.sub(_amount);&#13;
        balances[_from] = balances[_from].sub(_amount);&#13;
        Burn(_from, _amount);&#13;
        Transfer(_from, address(0), _amount);&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * BurnableControlledToken&#13;
 */&#13;
contract BurnableControlledToken is BurnableToken, Controlled {&#13;
&#13;
    /**&#13;
     * Function to burn tokens&#13;
     *&#13;
     * @param _from The address to burn tokens from.&#13;
     * @param _amount The amount of tokens to burn.&#13;
     *&#13;
     * @return A boolean that indicates if the operation was successful.&#13;
     */&#13;
    function burn(address _from, uint256 _amount) public onlyController returns (bool) {&#13;
        return super.burnInternal(_from, _amount);&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * Contract which is owned by owners and operated by controller.&#13;
 *&#13;
 * Provides a way to set up an entity (typically other contract) entitled to control actions of this contract.&#13;
 * Controller is set up by owners or during construction.&#13;
 *&#13;
 */&#13;
contract MetropolMultiownedControlled is Controlled, multiowned {&#13;
&#13;
&#13;
    function MetropolMultiownedControlled(address[] _owners, uint256 _signaturesRequired)&#13;
    multiowned(_owners, _signaturesRequired)&#13;
    public&#13;
    {&#13;
        // nothing here&#13;
    }&#13;
&#13;
    /**&#13;
     * Sets the controller&#13;
     */&#13;
    function setController(address _controller) external onlymanyowners(sha3(msg.data)) {&#13;
        super.setControllerInternal(_controller);&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title StandardToken which circulation can be delayed and started by another contract.&#13;
/// @dev To be used as a mixin contract.&#13;
/// The contract is created in disabled state: circulation is disabled.&#13;
contract CirculatingToken is StandardToken {&#13;
&#13;
    event CirculationEnabled();&#13;
&#13;
    modifier requiresCirculation {&#13;
        require(m_isCirculating);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    // PUBLIC interface&#13;
&#13;
    function transfer(address _to, uint256 _value) requiresCirculation returns (bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) requiresCirculation returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    function approve(address _spender, uint256 _value) requiresCirculation returns (bool) {&#13;
        return super.approve(_spender, _value);&#13;
    }&#13;
&#13;
&#13;
    // INTERNAL functions&#13;
&#13;
    function enableCirculation() internal returns (bool) {&#13;
        if (m_isCirculating)&#13;
        return false;&#13;
&#13;
        m_isCirculating = true;&#13;
        CirculationEnabled();&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @notice are the circulation started?&#13;
    bool public m_isCirculating;&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
/**&#13;
 * CirculatingControlledToken&#13;
 */&#13;
contract CirculatingControlledToken is CirculatingToken, Controlled {&#13;
&#13;
    /**&#13;
     * Allows token transfers&#13;
     */&#13;
    function startCirculation() external onlyController {&#13;
        assert(enableCirculation());    // must be called once&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * MetropolToken&#13;
 */&#13;
contract MetropolToken is&#13;
    StandardToken,&#13;
    Controlled,&#13;
    MintableControlledToken,&#13;
    BurnableControlledToken,&#13;
    CirculatingControlledToken,&#13;
    MetropolMultiownedControlled&#13;
{&#13;
    string internal m_name = '';&#13;
    string internal m_symbol = '';&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    /**&#13;
     * MetropolToken constructor&#13;
     */&#13;
    function MetropolToken(address[] _owners)&#13;
        MetropolMultiownedControlled(_owners, 2)&#13;
        public&#13;
    {&#13;
        require(3 == _owners.length);&#13;
    }&#13;
&#13;
    function name() public constant returns (string) {&#13;
        return m_name;&#13;
    }&#13;
    function symbol() public constant returns (string) {&#13;
        return m_symbol;&#13;
    }&#13;
&#13;
    function setNameSymbol(string _name, string _symbol) external onlymanyowners(sha3(msg.data)) {&#13;
        require(bytes(m_name).length==0);&#13;
        require(bytes(_name).length!=0 &amp;&amp; bytes(_symbol).length!=0);&#13;
&#13;
        m_name = _name;&#13;
        m_symbol = _symbol;&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
/////////123&#13;
/**&#13;
 * @title Basic crowdsale stat&#13;
 * @author Eenae&#13;
 */&#13;
contract ICrowdsaleStat {&#13;
&#13;
    /// @notice amount of funds collected in wei&#13;
    function getWeiCollected() public constant returns (uint);&#13;
&#13;
    /// @notice amount of tokens minted (NOT equal to totalSupply() in case token is reused!)&#13;
    function getTokenMinted() public constant returns (uint);&#13;
}&#13;
&#13;
/**&#13;
 * @title Interface for code which processes and stores investments.&#13;
 * @author Eenae&#13;
 */&#13;
contract IInvestmentsWalletConnector {&#13;
    /// @dev process and forward investment&#13;
    function storeInvestment(address investor, uint payment) internal;&#13;
&#13;
    /// @dev total investments amount stored using storeInvestment()&#13;
    function getTotalInvestmentsStored() internal constant returns (uint);&#13;
&#13;
    /// @dev called in case crowdsale succeeded&#13;
    function wcOnCrowdsaleSuccess() internal;&#13;
&#13;
    /// @dev called in case crowdsale failed&#13;
    function wcOnCrowdsaleFailure() internal;&#13;
}&#13;
&#13;
&#13;
/// @title Base contract for simple crowdsales&#13;
contract SimpleCrowdsaleBase is ArgumentsChecker, ReentrancyGuard, IInvestmentsWalletConnector, ICrowdsaleStat {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event FundTransfer(address backer, uint amount, bool isContribution);&#13;
&#13;
    function SimpleCrowdsaleBase(address token)&#13;
    validAddress(token)&#13;
    {&#13;
        m_token = MintableToken(token);&#13;
    }&#13;
&#13;
&#13;
    // PUBLIC interface: payments&#13;
&#13;
    // fallback function as a shortcut&#13;
    function() payable {&#13;
        require(0 == msg.data.length);&#13;
        buy();  // only internal call here!&#13;
    }&#13;
&#13;
    /// @notice crowdsale participation&#13;
    function buy() public payable {     // dont mark as external!&#13;
        buyInternal(msg.sender, msg.value, 0);&#13;
    }&#13;
&#13;
&#13;
    // INTERNAL&#13;
&#13;
    /// @dev payment processing&#13;
    function buyInternal(address investor, uint payment, uint extraBonuses)&#13;
    internal&#13;
    nonReentrant&#13;
    {&#13;
        require(payment &gt;= getMinInvestment());&#13;
        require(getCurrentTime() &gt;= getStartTime() || ! mustApplyTimeCheck(investor, payment) /* for final check */);&#13;
        if (getCurrentTime() &gt;= getEndTime()) {&#13;
&#13;
            finish();&#13;
        }&#13;
&#13;
        if (m_finished) {&#13;
            // saving provided gas&#13;
            investor.transfer(payment);&#13;
            return;&#13;
        }&#13;
&#13;
        uint startingWeiCollected = getWeiCollected();&#13;
        uint startingInvariant = this.balance.add(startingWeiCollected);&#13;
&#13;
        uint change;&#13;
        if (hasHardCap()) {&#13;
            // return or update payment if needed&#13;
            uint paymentAllowed = getMaximumFunds().sub(getWeiCollected());&#13;
            assert(0 != paymentAllowed);&#13;
&#13;
            if (paymentAllowed &lt; payment) {&#13;
                change = payment.sub(paymentAllowed);&#13;
                payment = paymentAllowed;&#13;
            }&#13;
        }&#13;
&#13;
        // issue tokens&#13;
        uint tokens = calculateTokens(investor, payment, extraBonuses);&#13;
        m_token.mint(investor, tokens);&#13;
        m_tokensMinted += tokens;&#13;
&#13;
        // record payment&#13;
        storeInvestment(investor, payment);&#13;
        assert((!hasHardCap() || getWeiCollected() &lt;= getMaximumFunds()) &amp;&amp; getWeiCollected() &gt; startingWeiCollected);&#13;
        FundTransfer(investor, payment, true);&#13;
&#13;
        if (hasHardCap() &amp;&amp; getWeiCollected() == getMaximumFunds())&#13;
        finish();&#13;
&#13;
        if (change &gt; 0)&#13;
        investor.transfer(change);&#13;
&#13;
        assert(startingInvariant == this.balance.add(getWeiCollected()).add(change));&#13;
    }&#13;
&#13;
    function finish() internal {&#13;
        if (m_finished)&#13;
        return;&#13;
&#13;
        if (getWeiCollected() &gt;= getMinimumFunds())&#13;
        wcOnCrowdsaleSuccess();&#13;
        else&#13;
        wcOnCrowdsaleFailure();&#13;
&#13;
        m_finished = true;&#13;
    }&#13;
&#13;
&#13;
    // Other pluggables&#13;
&#13;
    /// @dev says if crowdsale time bounds must be checked&#13;
    function mustApplyTimeCheck(address /*investor*/, uint /*payment*/) constant internal returns (bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @notice whether to apply hard cap check logic via getMaximumFunds() method&#13;
    function hasHardCap() constant internal returns (bool) {&#13;
        return getMaximumFunds() != 0;&#13;
    }&#13;
&#13;
    /// @dev to be overridden in tests&#13;
    function getCurrentTime() internal constant returns (uint) {&#13;
        return now;&#13;
    }&#13;
&#13;
    /// @notice maximum investments to be accepted during pre-ICO&#13;
    function getMaximumFunds() internal constant returns (uint);&#13;
&#13;
    /// @notice minimum amount of funding to consider crowdsale as successful&#13;
    function getMinimumFunds() internal constant returns (uint);&#13;
&#13;
    /// @notice start time of the pre-ICO&#13;
    function getStartTime() internal constant returns (uint);&#13;
&#13;
    /// @notice end time of the pre-ICO&#13;
    function getEndTime() internal constant returns (uint);&#13;
&#13;
    /// @notice minimal amount of investment&#13;
    function getMinInvestment() public constant returns (uint) {&#13;
        return 10 finney;&#13;
    }&#13;
&#13;
    /// @dev calculates token amount for given investment&#13;
    function calculateTokens(address investor, uint payment, uint extraBonuses) internal constant returns (uint);&#13;
&#13;
&#13;
    // ICrowdsaleStat&#13;
&#13;
    function getWeiCollected() public constant returns (uint) {&#13;
        return getTotalInvestmentsStored();&#13;
    }&#13;
&#13;
    /// @notice amount of tokens minted (NOT equal to totalSupply() in case token is reused!)&#13;
    function getTokenMinted() public constant returns (uint) {&#13;
        return m_tokensMinted;&#13;
    }&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @dev contract responsible for token accounting&#13;
    MintableToken public m_token;&#13;
&#13;
    uint m_tokensMinted;&#13;
&#13;
    bool m_finished = false;&#13;
}&#13;
&#13;
&#13;
/// @title Stateful mixin add state to contact and handlers for it&#13;
contract SimpleStateful {&#13;
    enum State { INIT, RUNNING, PAUSED, FAILED, SUCCEEDED }&#13;
&#13;
    event StateChanged(State _state);&#13;
&#13;
    modifier requiresState(State _state) {&#13;
        require(m_state == _state);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier exceptState(State _state) {&#13;
        require(m_state != _state);&#13;
        _;&#13;
    }&#13;
&#13;
    function changeState(State _newState) internal {&#13;
        assert(m_state != _newState);&#13;
&#13;
        if (State.INIT == m_state) {&#13;
            assert(State.RUNNING == _newState);&#13;
        }&#13;
        else if (State.RUNNING == m_state) {&#13;
            assert(State.PAUSED == _newState || State.FAILED == _newState || State.SUCCEEDED == _newState);&#13;
        }&#13;
        else if (State.PAUSED == m_state) {&#13;
            assert(State.RUNNING == _newState || State.FAILED == _newState);&#13;
        }&#13;
        else assert(false);&#13;
&#13;
        m_state = _newState;&#13;
        StateChanged(m_state);&#13;
    }&#13;
&#13;
    function getCurrentState() internal view returns(State) {&#13;
        return m_state;&#13;
    }&#13;
&#13;
    /// @dev state of sale&#13;
    State public m_state = State.INIT;&#13;
}&#13;
&#13;
&#13;
&#13;
/**&#13;
 * Stores investments in FundsRegistry.&#13;
 */&#13;
contract MetropolFundsRegistryWalletConnector is IInvestmentsWalletConnector {&#13;
&#13;
    function MetropolFundsRegistryWalletConnector(address _fundsAddress)&#13;
    public&#13;
    {&#13;
        require(_fundsAddress!=address(0));&#13;
        m_fundsAddress = FundsRegistry(_fundsAddress);&#13;
    }&#13;
&#13;
    /// @dev process and forward investment&#13;
    function storeInvestment(address investor, uint payment) internal&#13;
    {&#13;
        m_fundsAddress.invested.value(payment)(investor);&#13;
    }&#13;
&#13;
    /// @dev total investments amount stored using storeInvestment()&#13;
    function getTotalInvestmentsStored() internal constant returns (uint)&#13;
    {&#13;
        return m_fundsAddress.totalInvested();&#13;
    }&#13;
&#13;
    /// @dev called in case crowdsale succeeded&#13;
    function wcOnCrowdsaleSuccess() internal {&#13;
        m_fundsAddress.changeState(FundsRegistry.State.SUCCEEDED);&#13;
        m_fundsAddress.detachController();&#13;
    }&#13;
&#13;
    /// @dev called in case crowdsale failed&#13;
    function wcOnCrowdsaleFailure() internal {&#13;
        m_fundsAddress.changeState(FundsRegistry.State.REFUNDING);&#13;
    }&#13;
&#13;
    /// @notice address of wallet which stores funds&#13;
    FundsRegistry public m_fundsAddress;&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * Crowdsale with state&#13;
 */&#13;
contract StatefulReturnableCrowdsale is&#13;
SimpleCrowdsaleBase,&#13;
SimpleStateful,&#13;
multiowned,&#13;
MetropolFundsRegistryWalletConnector&#13;
{&#13;
&#13;
    /** Last recorded funds */&#13;
    uint256 public m_lastFundsAmount;&#13;
&#13;
    event Withdraw(address payee, uint amount);&#13;
&#13;
    /**&#13;
     * Automatic check for unaccounted withdrawals&#13;
     * @param _investor optional refund parameter&#13;
     * @param _payment optional refund parameter&#13;
     */&#13;
    modifier fundsChecker(address _investor, uint _payment) {&#13;
        uint atTheBeginning = getTotalInvestmentsStored();&#13;
        if (atTheBeginning &lt; m_lastFundsAmount) {&#13;
            changeState(State.PAUSED);&#13;
            if (_payment &gt; 0) {&#13;
                _investor.transfer(_payment);     // we cant throw (have to save state), so refunding this way&#13;
            }&#13;
            // note that execution of further (but not preceding!) modifiers and functions ends here&#13;
        } else {&#13;
            _;&#13;
&#13;
            if (getTotalInvestmentsStored() &lt; atTheBeginning) {&#13;
                changeState(State.PAUSED);&#13;
            } else {&#13;
                m_lastFundsAmount = getTotalInvestmentsStored();&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Triggers some state changes based on current time&#13;
     */&#13;
    modifier timedStateChange() {&#13;
        if (getCurrentState() == State.INIT &amp;&amp; getCurrentTime() &gt;= getStartTime()) {&#13;
            changeState(State.RUNNING);&#13;
        }&#13;
&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
     * Constructor&#13;
     */&#13;
    function StatefulReturnableCrowdsale(&#13;
    address _token,&#13;
    address _funds,&#13;
    address[] _owners,&#13;
    uint _signaturesRequired&#13;
    )&#13;
    public&#13;
    SimpleCrowdsaleBase(_token)&#13;
    multiowned(_owners, _signaturesRequired)&#13;
    MetropolFundsRegistryWalletConnector(_funds)&#13;
    validAddress(_token)&#13;
    validAddress(_funds)&#13;
    {&#13;
    }&#13;
&#13;
    function pauseCrowdsale()&#13;
    public&#13;
    onlyowner&#13;
    requiresState(State.RUNNING)&#13;
    {&#13;
        changeState(State.PAUSED);&#13;
    }&#13;
    function continueCrowdsale()&#13;
    public&#13;
    onlymanyowners(sha3(msg.data))&#13;
    requiresState(State.PAUSED)&#13;
    {&#13;
        changeState(State.RUNNING);&#13;
&#13;
        if (getCurrentTime() &gt;= getEndTime()) {&#13;
            finish();&#13;
        }&#13;
    }&#13;
    function failCrowdsale()&#13;
    public&#13;
    onlymanyowners(sha3(msg.data))&#13;
    requiresState(State.PAUSED)&#13;
    {&#13;
        wcOnCrowdsaleFailure();&#13;
        m_finished = true;&#13;
    }&#13;
&#13;
    function withdrawPayments()&#13;
    public&#13;
    nonReentrant&#13;
    requiresState(State.FAILED)&#13;
    {&#13;
        Withdraw(msg.sender, m_fundsAddress.m_weiBalances(msg.sender));&#13;
        m_fundsAddress.withdrawPayments(msg.sender);&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
     * Additional check of contributing process since we have state&#13;
     */&#13;
    function buyInternal(address _investor, uint _payment, uint _extraBonuses)&#13;
    internal&#13;
    timedStateChange&#13;
    exceptState(State.PAUSED)&#13;
    fundsChecker(_investor, _payment)&#13;
    {&#13;
        if (!mustApplyTimeCheck(_investor, _payment)) {&#13;
            require(State.RUNNING == m_state || State.INIT == m_state);&#13;
        }&#13;
        else&#13;
        {&#13;
            require(State.RUNNING == m_state);&#13;
        }&#13;
&#13;
        super.buyInternal(_investor, _payment, _extraBonuses);&#13;
    }&#13;
&#13;
&#13;
    /// @dev called in case crowdsale succeeded&#13;
    function wcOnCrowdsaleSuccess() internal {&#13;
        super.wcOnCrowdsaleSuccess();&#13;
&#13;
        changeState(State.SUCCEEDED);&#13;
    }&#13;
&#13;
    /// @dev called in case crowdsale failed&#13;
    function wcOnCrowdsaleFailure() internal {&#13;
        super.wcOnCrowdsaleFailure();&#13;
&#13;
        changeState(State.FAILED);&#13;
    }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * MetropolCrowdsale&#13;
 */&#13;
contract MetropolCrowdsale is StatefulReturnableCrowdsale {&#13;
&#13;
    uint256 public m_startTimestamp;&#13;
    uint256 public m_softCap;&#13;
    uint256 public m_hardCap;&#13;
    uint256 public m_exchangeRate;&#13;
    address public m_foundersTokensStorage;&#13;
    bool public m_initialSettingsSet = false;&#13;
&#13;
    modifier requireSettingsSet() {&#13;
        require(m_initialSettingsSet);&#13;
        _;&#13;
    }&#13;
&#13;
    function MetropolCrowdsale(address _token, address _funds, address[] _owners)&#13;
        public&#13;
        StatefulReturnableCrowdsale(_token, _funds, _owners, 2)&#13;
    {&#13;
        require(3 == _owners.length);&#13;
&#13;
        //2030-01-01, not to start crowdsale&#13;
        m_startTimestamp = 1893456000;&#13;
    }&#13;
&#13;
    /**&#13;
     * Set exchange rate before start&#13;
     */&#13;
    function setInitialSettings(&#13;
            address _foundersTokensStorage,&#13;
            uint256 _startTimestamp,&#13;
            uint256 _softCapInEther,&#13;
            uint256 _hardCapInEther,&#13;
            uint256 _tokensForOneEther&#13;
        )&#13;
        public&#13;
        timedStateChange&#13;
        requiresState(State.INIT)&#13;
        onlymanyowners(sha3(msg.data))&#13;
        validAddress(_foundersTokensStorage)&#13;
    {&#13;
        //no check for settings set&#13;
        //can be set multiple times before ICO&#13;
&#13;
        require(_startTimestamp!=0);&#13;
        require(_softCapInEther!=0);&#13;
        require(_hardCapInEther!=0);&#13;
        require(_tokensForOneEther!=0);&#13;
&#13;
        m_startTimestamp = _startTimestamp;&#13;
        m_softCap = _softCapInEther * 1 ether;&#13;
        m_hardCap = _hardCapInEther * 1 ether;&#13;
        m_exchangeRate = _tokensForOneEther;&#13;
        m_foundersTokensStorage = _foundersTokensStorage;&#13;
&#13;
        m_initialSettingsSet = true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Set exchange rate before start&#13;
     */&#13;
    function setExchangeRate(uint256 _tokensForOneEther)&#13;
        public&#13;
        timedStateChange&#13;
        requiresState(State.INIT)&#13;
        onlymanyowners(sha3(msg.data))&#13;
    {&#13;
        m_exchangeRate = _tokensForOneEther;&#13;
    }&#13;
&#13;
    /**&#13;
     * withdraw payments by investor on fail&#13;
     */&#13;
    function withdrawPayments() public requireSettingsSet {&#13;
        getToken().burn(&#13;
            msg.sender,&#13;
            getToken().balanceOf(msg.sender)&#13;
        );&#13;
&#13;
        super.withdrawPayments();&#13;
    }&#13;
&#13;
&#13;
    // INTERNAL&#13;
    /**&#13;
     * Additional check of initial settings set&#13;
     */&#13;
    function buyInternal(address _investor, uint _payment, uint _extraBonuses)&#13;
        internal&#13;
        requireSettingsSet&#13;
    {&#13;
        super.buyInternal(_investor, _payment, _extraBonuses);&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
     * All users except deployer must check time before contributing&#13;
     */&#13;
    function mustApplyTimeCheck(address investor, uint payment) constant internal returns (bool) {&#13;
        return !isOwner(investor);&#13;
    }&#13;
&#13;
    /**&#13;
     * For min investment check&#13;
     */&#13;
    function getMinInvestment() public constant returns (uint) {&#13;
        return 1 wei;&#13;
    }&#13;
&#13;
    /**&#13;
     * Get collected funds (internally from FundsRegistry)&#13;
     */&#13;
    function getWeiCollected() public constant returns (uint) {&#13;
        return getTotalInvestmentsStored();&#13;
    }&#13;
&#13;
    /**&#13;
     * Minimum amount of funding to consider crowdsale as successful&#13;
     */&#13;
    function getMinimumFunds() internal constant returns (uint) {&#13;
        return m_softCap;&#13;
    }&#13;
&#13;
    /**&#13;
     * Maximum investments to be accepted during crowdsale&#13;
     */&#13;
    function getMaximumFunds() internal constant returns (uint) {&#13;
        return m_hardCap;&#13;
    }&#13;
&#13;
    /**&#13;
     * Start time of the crowdsale&#13;
     */&#13;
    function getStartTime() internal constant returns (uint) {&#13;
        return m_startTimestamp;&#13;
    }&#13;
&#13;
    /**&#13;
     * End time of the crowdsale&#13;
     */&#13;
    function getEndTime() internal constant returns (uint) {&#13;
        return m_startTimestamp + 60 days;&#13;
    }&#13;
&#13;
    /**&#13;
     * Formula for calculating tokens from contributed ether&#13;
     */&#13;
    function calculateTokens(address /*investor*/, uint payment, uint /*extraBonuses*/)&#13;
        internal&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        uint256 secondMonth = m_startTimestamp + 30 days;&#13;
        if (getCurrentTime() &lt;= secondMonth) {&#13;
            return payment.mul(m_exchangeRate);&#13;
        } else if (getCurrentTime() &lt;= secondMonth + 1 weeks) {&#13;
            return payment.mul(m_exchangeRate).mul(100).div(105);&#13;
        } else if (getCurrentTime() &lt;= secondMonth + 2 weeks) {&#13;
            return payment.mul(m_exchangeRate).mul(100).div(110);&#13;
        } else if (getCurrentTime() &lt;= secondMonth + 3 weeks) {&#13;
            return payment.mul(m_exchangeRate).mul(100).div(115);&#13;
        } else if (getCurrentTime() &lt;= secondMonth + 4 weeks) {&#13;
            return payment.mul(m_exchangeRate).mul(100).div(120);&#13;
        } else {&#13;
            return payment.mul(m_exchangeRate).mul(100).div(125);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Additional on-success actions&#13;
     */&#13;
    function wcOnCrowdsaleSuccess() internal {&#13;
        super.wcOnCrowdsaleSuccess();&#13;
&#13;
        //20% of total totalSupply to team&#13;
        m_token.mint(&#13;
            m_foundersTokensStorage,&#13;
            getToken().totalSupply().mul(20).div(80)&#13;
        );&#13;
&#13;
&#13;
        getToken().startCirculation();&#13;
        getToken().detachController();&#13;
    }&#13;
&#13;
    /**&#13;
     * Returns attached token&#13;
     */&#13;
    function getToken() internal returns(MetropolToken) {&#13;
        return MetropolToken(m_token);&#13;
    }&#13;
}