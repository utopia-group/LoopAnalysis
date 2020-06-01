pragma solidity 0.4.23;

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/token/BasicToken.sol

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

// File: contracts/token/BurnableToken.sol

/**
 * @title Token which could be burned by any holder.
 */
contract BurnableToken is BasicToken {

    event Burn(address indexed from, uint256 amount);

    /**
     * Function to burn msg.sender's tokens.
     *
     * @param _amount amount of tokens to burn
     *
     * @return boolean that indicates if the operation was successful
     */
    function burn(uint256 _amount)
        public
        returns (bool)
    {
        address from = msg.sender;

        require(_amount > 0);
        require(_amount <= balances[from]);

        totalSupply = totalSupply.sub(_amount);
        balances[from] = balances[from].sub(_amount);
        Burn(from, _amount);
        Transfer(from, address(0), _amount);

        return true;
    }
}

// File: zeppelin-solidity/contracts/token/ERC20.sol

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

// File: zeppelin-solidity/contracts/token/StandardToken.sol

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

// File: contracts/token/TokenWithApproveAndCallMethod.sol

/// @title Utility interface for approveAndCall token function.
interface IApprovalRecipient {
    /**
     * @notice Signals that token holder approved spending of tokens and some action should be taken.
     *
     * @param _sender token holder which approved spending of his tokens
     * @param _value amount of tokens approved to be spent
     * @param _extraData any extra data token holder provided to the call
     *
     * @dev warning: implementors should validate sender of this message (it should be the token) and make no further
     *      assumptions unless validated them via ERC20 methods.
     */
    function receiveApproval(address _sender, uint256 _value, bytes _extraData) public;
}


/**
 * @title Mixin adds approveAndCall token function.
 */
contract TokenWithApproveAndCallMethod is StandardToken {

    /**
     * @notice Approves spending tokens and immediately triggers token recipient logic.
     *
     * @param _spender contract which supports IApprovalRecipient and allowed to receive tokens
     * @param _value amount of tokens approved to be spent
     * @param _extraData any extra data which to be provided to the _spender
     *
     * By invoking this utility function token holder could do two things in one transaction: approve spending his
     * tokens and execute some external contract which spends them on token holder's behalf.
     * It can't be known if _spender's invocation succeed or not.
     * This function will throw if approval failed.
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public {
        require(approve(_spender, _value));
        IApprovalRecipient(_spender).receiveApproval(msg.sender, _value, _extraData);
    }
}

// File: mixbytes-solidity/contracts/ownership/multiowned.sol

// Copyright (C) 2017  MixBytes, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

// Code taken from https://github.com/ethereum/dapp-bin/blob/master/wallet/wallet.sol
// Audit, refactoring and improvements by github.com/Eenae

// @authors:
// Gav Wood <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="99fed9fcedf1fdfcefb7faf6f4">[email protected]</a>&gt;&#13;
// inheritable "property" contract that enables methods to be protected by requiring the acquiescence of either a&#13;
// single, or, crucially, each of a number of, designated owners.&#13;
// usage:&#13;
// use modifiers onlyowner (just own owned) or onlymanyowners(hash), whereby the same hash must be provided by&#13;
// some number (specified in constructor) of the set of owners (specified in the constructor, modifiable) before the&#13;
// interior is executed.&#13;
&#13;
pragma solidity ^0.4.15;&#13;
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
        public&#13;
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
    /// @notice replaces an owner `_from` with another `_to`.&#13;
    /// @param _from address of owner to replace&#13;
    /// @param _to address of new owner&#13;
    // All pending operations will be canceled!&#13;
    function changeOwner(address _from, address _to)&#13;
        external&#13;
        ownerExists(_from)&#13;
        ownerDoesNotExist(_to)&#13;
        onlymanyowners(keccak256(msg.data))&#13;
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
    /// @notice adds an owner&#13;
    /// @param _owner address of new owner&#13;
    // All pending operations will be canceled!&#13;
    function addOwner(address _owner)&#13;
        external&#13;
        ownerDoesNotExist(_owner)&#13;
        validNumOwners(m_numOwners + 1)&#13;
        onlymanyowners(keccak256(msg.data))&#13;
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
    /// @notice removes an owner&#13;
    /// @param _owner address of owner to remove&#13;
    // All pending operations will be canceled!&#13;
    function removeOwner(address _owner)&#13;
        external&#13;
        ownerExists(_owner)&#13;
        validNumOwners(m_numOwners - 1)&#13;
        multiOwnedValidRequirement(m_multiOwnedRequired, m_numOwners - 1)&#13;
        onlymanyowners(keccak256(msg.data))&#13;
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
    /// @notice changes the required number of owner signatures&#13;
    /// @param _newRequired new number of signatures required&#13;
    // All pending operations will be canceled!&#13;
    function changeRequirement(uint _newRequired)&#13;
        external&#13;
        multiOwnedValidRequirement(_newRequired, m_numOwners)&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        m_multiOwnedRequired = _newRequired;&#13;
        clearPending();&#13;
        RequirementChanged(_newRequired);&#13;
    }&#13;
&#13;
    /// @notice Gets an owner by 0-indexed position&#13;
    /// @param ownerIndex 0-indexed owner position&#13;
    function getOwner(uint ownerIndex) public constant returns (address) {&#13;
        return m_owners[ownerIndex + 1];&#13;
    }&#13;
&#13;
    /// @notice Gets owners&#13;
    /// @return memory array of owners&#13;
    function getOwners() public constant returns (address[]) {&#13;
        address[] memory result = new address[](m_numOwners);&#13;
        for (uint i = 0; i &lt; m_numOwners; i++)&#13;
            result[i] = getOwner(i);&#13;
&#13;
        return result;&#13;
    }&#13;
&#13;
    /// @notice checks if provided address is an owner address&#13;
    /// @param _addr address to check&#13;
    /// @return true if it's an owner&#13;
    function isOwner(address _addr) public constant returns (bool) {&#13;
        return m_ownerIndex[_addr] &gt; 0;&#13;
    }&#13;
&#13;
    /// @notice Tests ownership of the current caller.&#13;
    /// @return true if it's an owner&#13;
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to&#13;
    // addOwner/changeOwner and to isOwner.&#13;
    function amIOwner() external constant onlyowner returns (bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @notice Revokes a prior confirmation of the given operation&#13;
    /// @param _operation operation value, typically keccak256(msg.data)&#13;
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
    /// @notice Checks if owner confirmed given operation&#13;
    /// @param _operation operation value, typically keccak256(msg.data)&#13;
    /// @param _owner an owner address&#13;
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
        // TODO block gas limit&#13;
        for (uint i = 0; i &lt; length; ++i) {&#13;
            if (m_multiOwnedPendingIndex[i] != 0)&#13;
                delete m_multiOwnedPending[m_multiOwnedPendingIndex[i]];&#13;
        }&#13;
        delete m_multiOwnedPendingIndex;&#13;
    }&#13;
&#13;
    function checkOwnerIndex(uint ownerIndex) private pure returns (uint) {&#13;
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
// File: mixbytes-solidity/contracts/security/ArgumentsChecker.sol&#13;
&#13;
// Copyright (C) 2017  MixBytes, LLC&#13;
&#13;
// Licensed under the Apache License, Version 2.0 (the "License").&#13;
// You may not use this file except in compliance with the License.&#13;
&#13;
// Unless required by applicable law or agreed to in writing, software&#13;
// distributed under the License is distributed on an "AS IS" BASIS,&#13;
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).&#13;
&#13;
pragma solidity ^0.4.15;&#13;
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
// File: contracts/BoomstarterToken.sol&#13;
&#13;
/**&#13;
 * @title Boomstarter project token.&#13;
 *&#13;
 * Standard ERC20 burnable token plus logic to support token freezing for crowdsales.&#13;
 */&#13;
contract BoomstarterToken is ArgumentsChecker, multiowned, BurnableToken, StandardToken, TokenWithApproveAndCallMethod {&#13;
&#13;
    // MODIFIERS&#13;
&#13;
    /// @dev makes transfer possible if tokens are unfrozen OR if the caller is a sale account&#13;
    modifier saleOrUnfrozen(address account) {&#13;
        require( (m_frozen == false) || isSale(account) );&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlySale(address account) {&#13;
        require(isSale(account));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier privilegedAllowed {&#13;
        require(m_allowPrivileged);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    // PUBLIC FUNCTIONS&#13;
&#13;
    /**&#13;
     * @notice Constructs token.&#13;
     *&#13;
     * @param _initialOwners initial multi-signatures, see comment below&#13;
     * @param _signaturesRequired quorum of multi-signatures&#13;
     *&#13;
     * Initial owners have power over the token contract only during bootstrap phase (early investments and token&#13;
     * sales). To be precise, the owners can set sales (which can transfer frozen tokens) during&#13;
     * bootstrap phase. After final token sale any control over the token removed by issuing disablePrivileged call.&#13;
     * For lifecycle example please see test/BootstarterTokenTest.js, 'test full lifecycle'.&#13;
     */&#13;
    function BoomstarterToken(address[] _initialOwners, uint _signaturesRequired)&#13;
        public&#13;
        multiowned(_initialOwners, _signaturesRequired)&#13;
    {&#13;
        totalSupply = MAX_SUPPLY;&#13;
        balances[msg.sender] = totalSupply;&#13;
        // mark initial owner as a sale to enable frozen transfer for them&#13;
        // as well as the option to set next sale without multi-signature&#13;
        m_sales[msg.sender] = true;&#13;
        Transfer(address(0), msg.sender, totalSupply);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Standard transfer() but with check of frozen status&#13;
     *&#13;
     * @param _to the address to transfer to&#13;
     * @param _value the amount to be transferred&#13;
     *&#13;
     * @return true iff operation was successfully completed&#13;
     */&#13;
    function transfer(address _to, uint256 _value)&#13;
        public&#13;
        saleOrUnfrozen(msg.sender)&#13;
        returns (bool)&#13;
    {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Standard transferFrom but incorporating frozen tokens logic&#13;
     *&#13;
     * @param _from address the address which you want to send tokens from&#13;
     * @param _to address the address which you want to transfer to&#13;
     * @param _value uint256 the amount of tokens to be transferred&#13;
     *&#13;
     * @return true iff operation was successfully completed&#13;
     */&#13;
    function transferFrom(address _from, address _to, uint256 _value)&#13;
        public&#13;
        saleOrUnfrozen(msg.sender)&#13;
        returns (bool)&#13;
    {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * Function to burn msg.sender's tokens. Overridden to prohibit burning frozen tokens&#13;
     *&#13;
     * @param _amount amount of tokens to burn&#13;
     *&#13;
     * @return boolean that indicates if the operation was successful&#13;
     */&#13;
    function burn(uint256 _amount)&#13;
        public&#13;
        saleOrUnfrozen(msg.sender)&#13;
        returns (bool)&#13;
    {&#13;
        return super.burn(_amount);&#13;
    }&#13;
&#13;
    // ADMINISTRATIVE FUNCTIONS&#13;
&#13;
    /**&#13;
     * @notice Sets sale status of an account.&#13;
     *&#13;
     * @param account account address&#13;
     * @param isSale enables this account to transfer tokens in frozen state&#13;
     *&#13;
     * Function is used only during token sale phase, before disablePrivileged() is called.&#13;
     */&#13;
    function setSale(address account, bool isSale)&#13;
        external&#13;
        validAddress(account)&#13;
        privilegedAllowed&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        m_sales[account] = isSale;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Same as setSale, but must be called from the current active sale and&#13;
     *         doesn't need multisigning (it's done in the finishSale call anyway)&#13;
     */&#13;
    function switchToNextSale(address _nextSale)&#13;
        external&#13;
        validAddress(_nextSale)&#13;
        onlySale(msg.sender)&#13;
    {&#13;
        m_sales[msg.sender] = false;&#13;
        m_sales[_nextSale] = true;&#13;
    }&#13;
&#13;
    /// @notice Make transfer of tokens available to everyone&#13;
    function thaw()&#13;
        external&#13;
        privilegedAllowed&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        m_frozen = false;&#13;
    }&#13;
&#13;
    /// @notice Disables further use of privileged functions: setSale, thaw&#13;
    function disablePrivileged()&#13;
        external&#13;
        privilegedAllowed&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        // shouldn't be frozen otherwise will be impossible to unfreeze&#13;
        require( false == m_frozen );&#13;
        m_allowPrivileged = false;&#13;
    }&#13;
&#13;
&#13;
    // INTERNAL FUNCTIONS&#13;
&#13;
    function isSale(address account) private view returns (bool) {&#13;
        return m_sales[account];&#13;
    }&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @notice set of sale accounts which can freeze tokens&#13;
    mapping (address =&gt; bool) public m_sales;&#13;
&#13;
    /// @notice allows privileged functions (token sale phase)&#13;
    bool public m_allowPrivileged = true;&#13;
&#13;
    /// @notice when true - all tokens are frozen and only sales can move their tokens&#13;
    ///         when false - all tokens are unfrozen and can be moved by their owners&#13;
    bool public m_frozen = true;&#13;
&#13;
    // CONSTANTS&#13;
&#13;
    string public constant name = "BoomstarterCoin";&#13;
    string public constant symbol = "BC";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    uint public constant MAX_SUPPLY = uint(36) * uint(1000000) * uint(10) ** uint(decimals);&#13;
}