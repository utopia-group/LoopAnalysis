pragma solidity 0.4.15;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}



/// @title StandardToken which circulation can be delayed and started by another contract.
/// @dev To be used as a mixin contract.
/// The contract is created in disabled state: circulation is disabled.
contract CirculatingToken is StandardToken {

    event CirculationEnabled();

    modifier requiresCirculation {
        require(m_isCirculating);
        _;
    }


    // PUBLIC interface

    function transfer(address _to, uint256 _value) requiresCirculation returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) requiresCirculation returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) requiresCirculation returns (bool) {
        return super.approve(_spender, _value);
    }


    // INTERNAL functions

    function enableCirculation() internal returns (bool) {
        if (m_isCirculating)
            return false;

        m_isCirculating = true;
        CirculationEnabled();
        return true;
    }


    // FIELDS

    /// @notice are the circulation started?
    bool public m_isCirculating;
}


// Code taken from https://github.com/ethereum/dapp-bin/blob/master/wallet/wallet.sol
// Audit, refactoring and improvements by github.com/Eenae

// @authors:
// Gav Wood <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0c6b4c69786468697a226f6361">[email protected]</a>&gt;&#13;
// inheritable "property" contract that enables methods to be protected by requiring the acquiescence of either a&#13;
// single, or, crucially, each of a number of, designated owners.&#13;
// usage:&#13;
// use modifiers onlyowner (just own owned) or onlymanyowners(hash), whereby the same hash must be provided by&#13;
// some number (specified in constructor) of the set of owners (specified in the constructor, modifiable) before the&#13;
// interior is executed.&#13;
&#13;
&#13;
/// note: during any ownership changes all pending operations (waiting for more signatures) are cancelled&#13;
// TODO acceptOwnership&#13;
contract multiowned {&#13;
&#13;
	// TYPES&#13;
&#13;
    // struct for the status of a pending operation.&#13;
    struct MultiOwnedOperationPendingState {&#13;
        // count of confirmations needed&#13;
        uint yetNeeded;&#13;
&#13;
        // bitmap of confirmations where owner #ownerIndex's decision corresponds to 2**ownerIndex bit&#13;
        uint ownersDone;&#13;
&#13;
        // position of this operation key in m_multiOwnedPendingIndex&#13;
        uint index;&#13;
    }&#13;
&#13;
	// EVENTS&#13;
&#13;
    event Confirmation(address owner, bytes32 operation);&#13;
    event Revoke(address owner, bytes32 operation);&#13;
    event FinalConfirmation(address owner, bytes32 operation);&#13;
&#13;
    // some others are in the case of an owner changing.&#13;
    event OwnerChanged(address oldOwner, address newOwner);&#13;
    event OwnerAdded(address newOwner);&#13;
    event OwnerRemoved(address oldOwner);&#13;
&#13;
    // the last one is emitted if the required signatures change&#13;
    event RequirementChanged(uint newRequirement);&#13;
&#13;
	// MODIFIERS&#13;
&#13;
    // simple single-sig function modifier.&#13;
    modifier onlyowner {&#13;
        require(isOwner(msg.sender));&#13;
        _;&#13;
    }&#13;
    // multi-sig function modifier: the operation must have an intrinsic hash in order&#13;
    // that later attempts can be realised as the same underlying operation and&#13;
    // thus count as confirmations.&#13;
    modifier onlymanyowners(bytes32 _operation) {&#13;
        if (confirmAndCheck(_operation)) {&#13;
            _;&#13;
        }&#13;
        // Even if required number of confirmations has't been collected yet,&#13;
        // we can't throw here - because changes to the state have to be preserved.&#13;
        // But, confirmAndCheck itself will throw in case sender is not an owner.&#13;
    }&#13;
&#13;
    modifier validNumOwners(uint _numOwners) {&#13;
        require(_numOwners &gt; 0 &amp;&amp; _numOwners &lt;= c_maxOwners);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier multiOwnedValidRequirement(uint _required, uint _numOwners) {&#13;
        require(_required &gt; 0 &amp;&amp; _required &lt;= _numOwners);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerExists(address _address) {&#13;
        require(isOwner(_address));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerDoesNotExist(address _address) {&#13;
        require(!isOwner(_address));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier multiOwnedOperationIsActive(bytes32 _operation) {&#13;
        require(isOperationActive(_operation));&#13;
        _;&#13;
    }&#13;
&#13;
	// METHODS&#13;
&#13;
    // constructor is given number of sigs required to do protected "onlymanyowners" transactions&#13;
    // as well as the selection of addresses capable of confirming them (msg.sender is not added to the owners!).&#13;
    function multiowned(address[] _owners, uint _required)&#13;
        validNumOwners(_owners.length)&#13;
        multiOwnedValidRequirement(_required, _owners.length)&#13;
    {&#13;
        assert(c_maxOwners &lt;= 255);&#13;
&#13;
        m_numOwners = _owners.length;&#13;
        m_multiOwnedRequired = _required;&#13;
&#13;
        for (uint i = 0; i &lt; _owners.length; ++i)&#13;
        {&#13;
            address owner = _owners[i];&#13;
            // invalid and duplicate addresses are not allowed&#13;
            require(0 != owner &amp;&amp; !isOwner(owner) /* not isOwner yet! */);&#13;
&#13;
            uint currentOwnerIndex = checkOwnerIndex(i + 1 /* first slot is unused */);&#13;
            m_owners[currentOwnerIndex] = owner;&#13;
            m_ownerIndex[owner] = currentOwnerIndex;&#13;
        }&#13;
&#13;
        assertOwnersAreConsistent();&#13;
    }&#13;
&#13;
    // Replaces an owner `_from` with another `_to`.&#13;
    // All pending operations will be canceled!&#13;
    function changeOwner(address _from, address _to)&#13;
        external&#13;
        ownerExists(_from)&#13;
        ownerDoesNotExist(_to)&#13;
        onlymanyowners(sha3(msg.data))&#13;
    {&#13;
        assertOwnersAreConsistent();&#13;
&#13;
        clearPending();&#13;
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_from]);&#13;
        m_owners[ownerIndex] = _to;&#13;
        m_ownerIndex[_from] = 0;&#13;
        m_ownerIndex[_to] = ownerIndex;&#13;
&#13;
        assertOwnersAreConsistent();&#13;
        OwnerChanged(_from, _to);&#13;
    }&#13;
&#13;
    // All pending operations will be canceled!&#13;
    function addOwner(address _owner)&#13;
        external&#13;
        ownerDoesNotExist(_owner)&#13;
        validNumOwners(m_numOwners + 1)&#13;
        onlymanyowners(sha3(msg.data))&#13;
    {&#13;
        assertOwnersAreConsistent();&#13;
&#13;
        clearPending();&#13;
        m_numOwners++;&#13;
        m_owners[m_numOwners] = _owner;&#13;
        m_ownerIndex[_owner] = checkOwnerIndex(m_numOwners);&#13;
&#13;
        assertOwnersAreConsistent();&#13;
        OwnerAdded(_owner);&#13;
    }&#13;
&#13;
    // All pending operations will be canceled!&#13;
    function removeOwner(address _owner)&#13;
        external&#13;
        ownerExists(_owner)&#13;
        validNumOwners(m_numOwners - 1)&#13;
        multiOwnedValidRequirement(m_multiOwnedRequired, m_numOwners - 1)&#13;
        onlymanyowners(sha3(msg.data))&#13;
    {&#13;
        assertOwnersAreConsistent();&#13;
&#13;
        clearPending();&#13;
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_owner]);&#13;
        m_owners[ownerIndex] = 0;&#13;
        m_ownerIndex[_owner] = 0;&#13;
        //make sure m_numOwners is equal to the number of owners and always points to the last owner&#13;
        reorganizeOwners();&#13;
&#13;
        assertOwnersAreConsistent();&#13;
        OwnerRemoved(_owner);&#13;
    }&#13;
&#13;
    // All pending operations will be canceled!&#13;
    function changeRequirement(uint _newRequired)&#13;
        external&#13;
        multiOwnedValidRequirement(_newRequired, m_numOwners)&#13;
        onlymanyowners(sha3(msg.data))&#13;
    {&#13;
        m_multiOwnedRequired = _newRequired;&#13;
        clearPending();&#13;
        RequirementChanged(_newRequired);&#13;
    }&#13;
&#13;
    // Gets an owner by 0-indexed position&#13;
    function getOwner(uint ownerIndex) public constant returns (address) {&#13;
        return m_owners[ownerIndex + 1];&#13;
    }&#13;
&#13;
    function getOwners() public constant returns (address[]) {&#13;
        address[] memory result = new address[](m_numOwners);&#13;
        for (uint i = 0; i &lt; m_numOwners; i++)&#13;
            result[i] = getOwner(i);&#13;
&#13;
        return result;&#13;
    }&#13;
&#13;
    function isOwner(address _addr) public constant returns (bool) {&#13;
        return m_ownerIndex[_addr] &gt; 0;&#13;
    }&#13;
&#13;
    // Tests ownership of the current caller.&#13;
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to&#13;
    // addOwner/changeOwner and to isOwner.&#13;
    function amIOwner() external constant onlyowner returns (bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
    // Revokes a prior confirmation of the given operation&#13;
    function revoke(bytes32 _operation)&#13;
        external&#13;
        multiOwnedOperationIsActive(_operation)&#13;
        onlyowner&#13;
    {&#13;
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);&#13;
        var pending = m_multiOwnedPending[_operation];&#13;
        require(pending.ownersDone &amp; ownerIndexBit &gt; 0);&#13;
&#13;
        assertOperationIsConsistent(_operation);&#13;
&#13;
        pending.yetNeeded++;&#13;
        pending.ownersDone -= ownerIndexBit;&#13;
&#13;
        assertOperationIsConsistent(_operation);&#13;
        Revoke(msg.sender, _operation);&#13;
    }&#13;
&#13;
    function hasConfirmed(bytes32 _operation, address _owner)&#13;
        external&#13;
        constant&#13;
        multiOwnedOperationIsActive(_operation)&#13;
        ownerExists(_owner)&#13;
        returns (bool)&#13;
    {&#13;
        return !(m_multiOwnedPending[_operation].ownersDone &amp; makeOwnerBitmapBit(_owner) == 0);&#13;
    }&#13;
&#13;
    // INTERNAL METHODS&#13;
&#13;
    function confirmAndCheck(bytes32 _operation)&#13;
        private&#13;
        onlyowner&#13;
        returns (bool)&#13;
    {&#13;
        if (512 == m_multiOwnedPendingIndex.length)&#13;
            // In case m_multiOwnedPendingIndex grows too much we have to shrink it: otherwise at some point&#13;
            // we won't be able to do it because of block gas limit.&#13;
            // Yes, pending confirmations will be lost. Dont see any security or stability implications.&#13;
            // TODO use more graceful approach like compact or removal of clearPending completely&#13;
            clearPending();&#13;
&#13;
        var pending = m_multiOwnedPending[_operation];&#13;
&#13;
        // if we're not yet working on this operation, switch over and reset the confirmation status.&#13;
        if (! isOperationActive(_operation)) {&#13;
            // reset count of confirmations needed.&#13;
            pending.yetNeeded = m_multiOwnedRequired;&#13;
            // reset which owners have confirmed (none) - set our bitmap to 0.&#13;
            pending.ownersDone = 0;&#13;
            pending.index = m_multiOwnedPendingIndex.length++;&#13;
            m_multiOwnedPendingIndex[pending.index] = _operation;&#13;
            assertOperationIsConsistent(_operation);&#13;
        }&#13;
&#13;
        // determine the bit to set for this owner.&#13;
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);&#13;
        // make sure we (the message sender) haven't confirmed this operation previously.&#13;
        if (pending.ownersDone &amp; ownerIndexBit == 0) {&#13;
            // ok - check if count is enough to go ahead.&#13;
            assert(pending.yetNeeded &gt; 0);&#13;
            if (pending.yetNeeded == 1) {&#13;
                // enough confirmations: reset and run interior.&#13;
                delete m_multiOwnedPendingIndex[m_multiOwnedPending[_operation].index];&#13;
                delete m_multiOwnedPending[_operation];&#13;
                FinalConfirmation(msg.sender, _operation);&#13;
                return true;&#13;
            }&#13;
            else&#13;
            {&#13;
                // not enough: record that this owner in particular confirmed.&#13;
                pending.yetNeeded--;&#13;
                pending.ownersDone |= ownerIndexBit;&#13;
                assertOperationIsConsistent(_operation);&#13;
                Confirmation(msg.sender, _operation);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    // Reclaims free slots between valid owners in m_owners.&#13;
    // TODO given that its called after each removal, it could be simplified.&#13;
    function reorganizeOwners() private {&#13;
        uint free = 1;&#13;
        while (free &lt; m_numOwners)&#13;
        {&#13;
            // iterating to the first free slot from the beginning&#13;
            while (free &lt; m_numOwners &amp;&amp; m_owners[free] != 0) free++;&#13;
&#13;
            // iterating to the first occupied slot from the end&#13;
            while (m_numOwners &gt; 1 &amp;&amp; m_owners[m_numOwners] == 0) m_numOwners--;&#13;
&#13;
            // swap, if possible, so free slot is located at the end after the swap&#13;
            if (free &lt; m_numOwners &amp;&amp; m_owners[m_numOwners] != 0 &amp;&amp; m_owners[free] == 0)&#13;
            {&#13;
                // owners between swapped slots should't be renumbered - that saves a lot of gas&#13;
                m_owners[free] = m_owners[m_numOwners];&#13;
                m_ownerIndex[m_owners[free]] = free;&#13;
                m_owners[m_numOwners] = 0;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function clearPending() private onlyowner {&#13;
        uint length = m_multiOwnedPendingIndex.length;&#13;
        for (uint i = 0; i &lt; length; ++i) {&#13;
            if (m_multiOwnedPendingIndex[i] != 0)&#13;
                delete m_multiOwnedPending[m_multiOwnedPendingIndex[i]];&#13;
        }&#13;
        delete m_multiOwnedPendingIndex;&#13;
    }&#13;
&#13;
    function checkOwnerIndex(uint ownerIndex) private constant returns (uint) {&#13;
        assert(0 != ownerIndex &amp;&amp; ownerIndex &lt;= c_maxOwners);&#13;
        return ownerIndex;&#13;
    }&#13;
&#13;
    function makeOwnerBitmapBit(address owner) private constant returns (uint) {&#13;
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[owner]);&#13;
        return 2 ** ownerIndex;&#13;
    }&#13;
&#13;
    function isOperationActive(bytes32 _operation) private constant returns (bool) {&#13;
        return 0 != m_multiOwnedPending[_operation].yetNeeded;&#13;
    }&#13;
&#13;
&#13;
    function assertOwnersAreConsistent() private constant {&#13;
        assert(m_numOwners &gt; 0);&#13;
        assert(m_numOwners &lt;= c_maxOwners);&#13;
        assert(m_owners[0] == 0);&#13;
        assert(0 != m_multiOwnedRequired &amp;&amp; m_multiOwnedRequired &lt;= m_numOwners);&#13;
    }&#13;
&#13;
    function assertOperationIsConsistent(bytes32 _operation) private constant {&#13;
        var pending = m_multiOwnedPending[_operation];&#13;
        assert(0 != pending.yetNeeded);&#13;
        assert(m_multiOwnedPendingIndex[pending.index] == _operation);&#13;
        assert(pending.yetNeeded &lt;= m_multiOwnedRequired);&#13;
    }&#13;
&#13;
&#13;
   	// FIELDS&#13;
&#13;
    uint constant c_maxOwners = 250;&#13;
&#13;
    // the number of owners that must confirm the same operation before it is run.&#13;
    uint public m_multiOwnedRequired;&#13;
&#13;
&#13;
    // pointer used to find a free slot in m_owners&#13;
    uint public m_numOwners;&#13;
&#13;
    // list of owners (addresses),&#13;
    // slot 0 is unused so there are no owner which index is 0.&#13;
    // TODO could we save space at the end of the array for the common case of &lt;10 owners? and should we?&#13;
    address[256] internal m_owners;&#13;
&#13;
    // index on the list of owners to allow reverse lookup: owner address =&gt; index in m_owners&#13;
    mapping(address =&gt; uint) internal m_ownerIndex;&#13;
&#13;
&#13;
    // the ongoing operations.&#13;
    mapping(bytes32 =&gt; MultiOwnedOperationPendingState) internal m_multiOwnedPending;&#13;
    bytes32[] internal m_multiOwnedPendingIndex;&#13;
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
    /// @notice sets the controller&#13;
    function setController(address _controller) external onlymanyowners(sha3(msg.data)) {&#13;
        m_controller = _controller;&#13;
        ControllerSet(m_controller);&#13;
    }&#13;
&#13;
    /// @notice ability for controller to step down&#13;
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
/// @title StandardToken which can be minted by another contract.&#13;
contract MintableMultiownedToken is MultiownedControlled, StandardToken {&#13;
&#13;
    /// @dev parameters of an extra token emission&#13;
    struct EmissionInfo {&#13;
        // tokens created&#13;
        uint256 created;&#13;
&#13;
        // totalSupply at the moment of emission (excluding created tokens)&#13;
        uint256 totalSupplyWas;&#13;
    }&#13;
&#13;
    event Mint(address indexed to, uint256 amount);&#13;
    event Emission(uint256 tokensCreated, uint256 totalSupplyWas, uint256 time);&#13;
    event Dividend(address indexed to, uint256 amount);&#13;
&#13;
&#13;
    // PUBLIC interface&#13;
&#13;
    function MintableMultiownedToken(address[] _owners, uint _signaturesRequired, address _minter)&#13;
        MultiownedControlled(_owners, _signaturesRequired, _minter)&#13;
    {&#13;
        dividendsPool = this;   // or any other special unforgeable value, actually&#13;
&#13;
        // emission #0 is a dummy: because of default value 0 in m_lastAccountEmission&#13;
        m_emissions.push(EmissionInfo({created: 0, totalSupplyWas: 0}));&#13;
    }&#13;
&#13;
    /// @notice Request dividends for current account.&#13;
    function requestDividends() external {&#13;
        payDividendsTo(msg.sender);&#13;
    }&#13;
&#13;
    /// @notice hook on standard ERC20#transfer to pay dividends&#13;
    function transfer(address _to, uint256 _value) returns (bool) {&#13;
        payDividendsTo(msg.sender);&#13;
        payDividendsTo(_to);&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    /// @notice hook on standard ERC20#transferFrom to pay dividends&#13;
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {&#13;
        payDividendsTo(_from);&#13;
        payDividendsTo(_to);&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    // Disabled: this could be undesirable because sum of (balanceOf() for each token owner) != totalSupply&#13;
    // (but: sum of (balances[owner] for each token owner) == totalSupply!).&#13;
    //&#13;
    // @notice hook on standard ERC20#balanceOf to take dividends into consideration&#13;
    // function balanceOf(address _owner) constant returns (uint256) {&#13;
    //     var (hasNewDividends, dividends) = calculateDividendsFor(_owner);&#13;
    //     return hasNewDividends ? super.balanceOf(_owner).add(dividends) : super.balanceOf(_owner);&#13;
    // }&#13;
&#13;
&#13;
    /// @dev mints new tokens&#13;
    function mint(address _to, uint256 _amount) external onlyController {&#13;
        require(m_externalMintingEnabled);&#13;
        payDividendsTo(_to);&#13;
        mintInternal(_to, _amount);&#13;
    }&#13;
&#13;
    /// @dev disables mint(), irreversible!&#13;
    function disableMinting() external onlyController {&#13;
        require(m_externalMintingEnabled);&#13;
        m_externalMintingEnabled = false;&#13;
    }&#13;
&#13;
&#13;
    // INTERNAL functions&#13;
&#13;
    /**&#13;
     * @notice Starts new token emission&#13;
     * @param _tokensCreated Amount of tokens to create&#13;
     * @dev Dividends are not distributed immediately as it could require billions of gas,&#13;
     * instead they are `pulled` by a holder from dividends pool account before any update to the holder account occurs.&#13;
     */&#13;
    function emissionInternal(uint256 _tokensCreated) internal {&#13;
        require(0 != _tokensCreated);&#13;
        require(_tokensCreated &lt; totalSupply / 2);  // otherwise it looks like an error&#13;
&#13;
        uint256 totalSupplyWas = totalSupply;&#13;
&#13;
        m_emissions.push(EmissionInfo({created: _tokensCreated, totalSupplyWas: totalSupplyWas}));&#13;
        mintInternal(dividendsPool, _tokensCreated);&#13;
&#13;
        Emission(_tokensCreated, totalSupplyWas, now);&#13;
    }&#13;
&#13;
    function mintInternal(address _to, uint256 _amount) internal {&#13;
        totalSupply = totalSupply.add(_amount);&#13;
        balances[_to] = balances[_to].add(_amount);&#13;
        Mint(_to, _amount);&#13;
    }&#13;
&#13;
    /// @dev adds dividends to the account _to&#13;
    function payDividendsTo(address _to) internal {&#13;
        var (hasNewDividends, dividends) = calculateDividendsFor(_to);&#13;
        if (!hasNewDividends)&#13;
            return;&#13;
&#13;
        if (0 != dividends) {&#13;
            balances[dividendsPool] = balances[dividendsPool].sub(dividends);&#13;
            balances[_to] = balances[_to].add(dividends);&#13;
        }&#13;
        m_lastAccountEmission[_to] = getLastEmissionNum();&#13;
    }&#13;
&#13;
    /// @dev calculates dividends for the account _for&#13;
    /// @return (true if state has to be updated, dividend amount (could be 0!))&#13;
    function calculateDividendsFor(address _for) constant internal returns (bool hasNewDividends, uint dividends) {&#13;
        assert(_for != dividendsPool);  // no dividends for the pool!&#13;
&#13;
        uint256 lastEmissionNum = getLastEmissionNum();&#13;
        uint256 lastAccountEmissionNum = m_lastAccountEmission[_for];&#13;
        assert(lastAccountEmissionNum &lt;= lastEmissionNum);&#13;
        if (lastAccountEmissionNum == lastEmissionNum)&#13;
            return (false, 0);&#13;
&#13;
        uint256 initialBalance = balances[_for];    // beware of recursion!&#13;
        if (0 == initialBalance)&#13;
            return (true, 0);&#13;
&#13;
        uint256 balance = initialBalance;&#13;
        for (uint256 emissionToProcess = lastAccountEmissionNum + 1; emissionToProcess &lt;= lastEmissionNum; emissionToProcess++) {&#13;
            EmissionInfo storage emission = m_emissions[emissionToProcess];&#13;
            assert(0 != emission.created &amp;&amp; 0 != emission.totalSupplyWas);&#13;
&#13;
            uint256 dividend = balance.mul(emission.created).div(emission.totalSupplyWas);&#13;
            Dividend(_for, dividend);&#13;
&#13;
            balance = balance.add(dividend);&#13;
        }&#13;
&#13;
        return (true, balance.sub(initialBalance));&#13;
    }&#13;
&#13;
    function getLastEmissionNum() private constant returns (uint256) {&#13;
        return m_emissions.length - 1;&#13;
    }&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @notice if this true then token is still externally mintable (but this flag does't affect emissions!)&#13;
    bool public m_externalMintingEnabled = true;&#13;
&#13;
    /// @dev internal address of dividends in balances mapping.&#13;
    address dividendsPool;&#13;
&#13;
    /// @notice record of issued dividend emissions&#13;
    EmissionInfo[] public m_emissions;&#13;
&#13;
    /// @dev for each token holder: last emission (index in m_emissions) which was processed for this holder&#13;
    mapping(address =&gt; uint256) m_lastAccountEmission;&#13;
}&#13;
&#13;
&#13;
/// @title Storiqa coin contract&#13;
contract STQToken is CirculatingToken, MintableMultiownedToken {&#13;
&#13;
&#13;
    // PUBLIC interface&#13;
&#13;
    function STQToken(address[] _owners)&#13;
        MintableMultiownedToken(_owners, 2, /* minter: */ address(0))&#13;
    {&#13;
        require(3 == _owners.length);&#13;
    }&#13;
&#13;
    /// @notice Allows token transfers&#13;
    function startCirculation() external onlyController {&#13;
        assert(enableCirculation());    // must be called once&#13;
    }&#13;
&#13;
    /// @notice Starts new token emission&#13;
    /// @param _tokensCreatedInSTQ Amount of STQ (not STQ-wei!) to create, like 30 000 or so&#13;
    function emission(uint256 _tokensCreatedInSTQ) external onlymanyowners(sha3(msg.data)) {&#13;
        emissionInternal(_tokensCreatedInSTQ.mul(uint256(10) ** uint256(decimals)));&#13;
    }&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    string public constant name = 'Storiqa Token';&#13;
    string public constant symbol = 'STQ';&#13;
    uint8 public constant decimals = 18;&#13;
}