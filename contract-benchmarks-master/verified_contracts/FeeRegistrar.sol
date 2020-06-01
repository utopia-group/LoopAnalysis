//! FeeRegistrar contract.
//! By Parity Technologies, 2017.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.16;

// From Owned.sol
contract Owned {
  /// STORAGE
  address public owner = msg.sender;

  /// EVENTS
  event NewOwner(address indexed old, address indexed current);

  /// MODIFIERS
  modifier only_owner { require (msg.sender == owner); _; }

  /// RESTRICTED PUBLIC METHODS
  function setOwner(address _new) public only_owner { NewOwner(owner, _new); owner = _new; }
}

/// @title Delegated Contract
/// @notice This contract can be used to have a a system of delegates
/// who can be authorized to execute certain methods. A (super-)owner
/// is set, who can modify the delegates.
contract Delegated is Owned {
  /// STORAGE
  mapping (address => bool) delegates;

  /// MODIFIERS
  modifier only_delegate { require (msg.sender == owner || delegates[msg.sender]); _; }

  /// PUBLIC METHODS
  function delegate(address who) public constant returns (bool) { return who == owner || delegates[who]; }

  /// RESTRICTED PUBLIC METHODS
  function addDelegate(address _new) public only_owner { delegates[_new] = true; }
  function removeDelegate(address _old) public only_owner { delete delegates[_old]; }
}

/// @title Fee Registrar
/// @author Nicolas Gotchac <<span class="__cf_email__" data-cfemail="4c22252f23202d3f0c3c2d3e253835622523">[email protected]</span>&gt;&#13;
/// @notice This contract records fee payments. The address who deploys the contract&#13;
/// is set as the `owner` of the contract (which can be later modified). The `fee`&#13;
/// which users will have to pay must be specified, as well as the address of the treasury&#13;
/// to which the fee will be forwarded to.&#13;
/// A payment is a transaction with the value set as the `fee` value, and an address is&#13;
/// given as an argument. The given address will be marked as _paid for_, and the number&#13;
/// of times it was paid for will be recorded. We also record who is at the origin of the&#13;
/// payment.&#13;
/// For example, Alice can pay for Bob, and Eve can pay for Bob as well. This contract&#13;
/// will record that Bob is marked as paid, 2 times, by Alice and Eve.&#13;
/// A payment can be revoked by specified delegates, and the fund should be restored to&#13;
/// the payer of the fee.&#13;
contract FeeRegistrar is Delegated {&#13;
  /// STORAGE&#13;
  address public treasury;&#13;
  uint public fee;&#13;
&#13;
  // a mapping of addresses to the origin of payments struct&#13;
  mapping(address =&gt; address[]) s_paid;&#13;
&#13;
&#13;
  /// EVENTS&#13;
  event Paid (address who, address payer);&#13;
&#13;
&#13;
  /// CONSTRUCTOR&#13;
&#13;
  /// @notice Contructor method of the contract, which&#13;
  /// will set the `treasury` where payments will be send to,&#13;
  /// and the `fee` users have to pay&#13;
  /// @param _treasury The address to which the payments will be forwarded&#13;
  /// @param _fee The fee users have to pay, in wei&#13;
  function FeeRegistrar (address _treasury, uint _fee) public {&#13;
    owner = msg.sender;&#13;
    treasury = _treasury;&#13;
    fee = _fee;&#13;
  }&#13;
&#13;
&#13;
  /// PUBLIC CONSTANT METHODS&#13;
&#13;
  /// @notice Returns for the given address the number of times&#13;
  /// it was paid for, and an array of addresses who actually paid for the fee&#13;
  /// (as one might pay the fee for another address)&#13;
  /// @param who The address of the payer whose info we check&#13;
  /// @return The count (number of payments) and the origins (the senders of the&#13;
  /// payment)&#13;
  function payer (address who) public constant returns (uint count, address[] origins) {&#13;
    address[] memory m_origins = s_paid[who];&#13;
&#13;
    return (m_origins.length, m_origins);&#13;
  }&#13;
&#13;
  /// @notice Returns whether the given address paid or not&#13;
  /// @param who The address whose payment status we check&#13;
  /// @ return Whether the address is marked as paid or not&#13;
  function paid (address who) public constant returns (bool) {&#13;
    return s_paid[who].length &gt; 0;&#13;
  }&#13;
&#13;
&#13;
  /// PUBLIC METHODS&#13;
&#13;
  /// @notice This method is used to pay for the fee. You can pay&#13;
  /// the fee for one address (then marked as paid), from another&#13;
  /// address. The origin of the transaction, the&#13;
  /// fee payer (`msg.sender`) is stored in an array.&#13;
  /// The value of the transaction must&#13;
  /// match the fee that was set in the contructor.&#13;
  /// The only restriction is that you can't pay for the null&#13;
  /// address.&#13;
  /// You also can't pay more than 10 times for the same address&#13;
  /// The value that is received is directly transfered to the&#13;
  /// `treasury`.&#13;
  /// @param who The address which should be marked as paid.&#13;
  function pay (address who) external payable {&#13;
    // We first check that the given address is not the null address&#13;
    require(who != 0x0);&#13;
    // Then check that the value matches with the fee&#13;
    require(msg.value == fee);&#13;
    // Maximum 10 payments per address&#13;
    require(s_paid[who].length &lt; 10);&#13;
&#13;
    s_paid[who].push(msg.sender);&#13;
&#13;
    // Send the paid event&#13;
    Paid(who, msg.sender);&#13;
&#13;
    // Send the message value to the treasury&#13;
    treasury.transfer(msg.value);&#13;
  }&#13;
&#13;
&#13;
  /// RESTRICTED (owner or delegate only) PUBLIC METHODS&#13;
&#13;
  /// @notice This method can only be called by the contract&#13;
  /// owner, and can be used to virtually create a new payment,&#13;
  /// by `origin` for `who`.&#13;
  /// @param who The address that `origin` paid for&#13;
  /// @param origin The virtual sender of the payment&#13;
  function inject (address who, address origin) external only_owner {&#13;
    // Add the origin address to the list of payers&#13;
    s_paid[who].push(origin);&#13;
    // Emit the `Paid` event&#13;
    Paid(who, origin);&#13;
  }&#13;
&#13;
  /// @notice This method can be called by authorized persons only,&#13;
  /// and can issue a refund of the fee to the `origin` address who&#13;
  /// paid the fee for `who`.&#13;
  /// @param who The address that `origin` paid for&#13;
  /// @param origin The sender of the payment, to which we shall&#13;
  /// send the refund&#13;
  function revoke (address who, address origin) payable external only_delegate {&#13;
    // The value must match the current fee, so we can refund&#13;
    // the payer, since the contract doesn't hold anything.&#13;
    require(msg.value == fee);&#13;
    bool found;&#13;
&#13;
    // Go through the list of payers to find&#13;
    // the remove the right one&#13;
    // NB : this list is limited to 10 items,&#13;
    //      @see the `pay` method&#13;
    for (uint i = 0; i &lt; s_paid[who].length; i++) {&#13;
      if (s_paid[who][i] != origin) {&#13;
        continue;&#13;
      }&#13;
&#13;
      // If the origin payer is found&#13;
      found = true;&#13;
&#13;
      uint last = s_paid[who].length - 1;&#13;
&#13;
      // Switch the last element of the array&#13;
      // with the one to remove&#13;
      s_paid[who][i] = s_paid[who][last];&#13;
&#13;
      // Remove the last element of the array&#13;
      delete s_paid[who][last];&#13;
      s_paid[who].length -= 1;&#13;
&#13;
      break;&#13;
    }&#13;
&#13;
    // Ensure that the origin payer has been found&#13;
    require(found);&#13;
&#13;
    // Refund the fee to the origin payer&#13;
    origin.transfer(msg.value);&#13;
  }&#13;
&#13;
  /// @notice Change the address of the treasury, the address to which&#13;
  /// the payments are forwarded to. Only the owner of the contract&#13;
  /// can execute this method.&#13;
  /// @param _treasury The new treasury address&#13;
  function setTreasury (address _treasury) external only_owner {&#13;
    treasury = _treasury;&#13;
  }&#13;
}