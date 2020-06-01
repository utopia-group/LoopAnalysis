/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/
pragma solidity ^0.4.11;

/**
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}

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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

/// @title TokenTransferDelegate - Acts as a middle man to transfer ERC20 tokens
/// on behalf of different versioned of Loopring protocol to avoid ERC20
/// re-authorization.
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ea8e8b84838f86aa8685859a9883848dc485988d">[email protected]</a>&gt;.&#13;
contract TokenTransferDelegate is Ownable {&#13;
    using Math for uint;&#13;
&#13;
    ////////////////////////////////////////////////////////////////////////////&#13;
    /// Variables                                                            ///&#13;
    ////////////////////////////////////////////////////////////////////////////&#13;
&#13;
    uint lastVersion = 0;&#13;
    address[] public versions;&#13;
    mapping (address =&gt; uint) public versioned;&#13;
&#13;
&#13;
    ////////////////////////////////////////////////////////////////////////////&#13;
    /// Modifiers                                                            ///&#13;
    ////////////////////////////////////////////////////////////////////////////&#13;
&#13;
    modifier isVersioned(address addr) {&#13;
        if (versioned[addr] == 0) {&#13;
            revert();&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
    modifier notVersioned(address addr) {&#13;
        if (versioned[addr] &gt; 0) {&#13;
            revert();&#13;
        }&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
    ////////////////////////////////////////////////////////////////////////////&#13;
    /// Events                                                               ///&#13;
    ////////////////////////////////////////////////////////////////////////////&#13;
&#13;
    event VersionAdded(address indexed addr, uint version);&#13;
&#13;
    event VersionRemoved(address indexed addr, uint version);&#13;
&#13;
&#13;
    ////////////////////////////////////////////////////////////////////////////&#13;
    /// Public Functions                                                     ///&#13;
    ////////////////////////////////////////////////////////////////////////////&#13;
&#13;
    /// @dev Add a Loopring protocol address.&#13;
    /// @param addr A loopring protocol address.&#13;
    function addVersion(address addr)&#13;
        onlyOwner&#13;
        notVersioned(addr)&#13;
        {&#13;
        versioned[addr] = ++lastVersion;&#13;
        versions.push(addr);&#13;
        VersionAdded(addr, lastVersion);&#13;
    }&#13;
&#13;
    /// @dev Remove a Loopring protocol address.&#13;
    /// @param addr A loopring protocol address.&#13;
    function removeVersion(address addr)&#13;
        onlyOwner&#13;
        isVersioned(addr)&#13;
        {&#13;
        uint version = versioned[addr];&#13;
        delete versioned[addr];&#13;
&#13;
        uint length = versions.length;&#13;
        for (uint i = 0; i &lt; length; i++) {&#13;
            if (versions[i] == addr) {&#13;
                versions[i] = versions[length - 1];&#13;
                versions.length -= 1;&#13;
                break;&#13;
            }&#13;
        }&#13;
        VersionRemoved(addr, version);&#13;
    }&#13;
&#13;
&#13;
    /// @return Amount of ERC20 token that can be spent by this contract.&#13;
    /// @param tokenAddress Address of token to transfer.&#13;
    /// @param _owner Address of the token owner.&#13;
    function getSpendable(&#13;
        address tokenAddress,&#13;
        address _owner&#13;
        )&#13;
        isVersioned(msg.sender)&#13;
        constant&#13;
        returns (uint) {&#13;
&#13;
        var token = ERC20(tokenAddress);&#13;
        return token&#13;
            .allowance(_owner, address(this))&#13;
            .min256(token.balanceOf(_owner));&#13;
    }&#13;
&#13;
&#13;
    /// @dev Invoke ERC20 transferFrom method.&#13;
    /// @param token Address of token to transfer.&#13;
    /// @param from Address to transfer token from.&#13;
    /// @param to Address to transfer token to.&#13;
    /// @param value Amount of token to transfer.&#13;
    /// @return Tansfer result.&#13;
    function transferToken(&#13;
        address token,&#13;
        address from,&#13;
        address to,&#13;
        uint value)&#13;
        isVersioned(msg.sender)&#13;
        returns (bool) {&#13;
        return ERC20(token).transferFrom(from, to, value);&#13;
    }&#13;
&#13;
    /// @dev Gets all versioned addresses.&#13;
    /// @return Array of versioned addresses.&#13;
    function getVersions()&#13;
        constant&#13;
        returns (address[]) {&#13;
        return versions;&#13;
    }&#13;
}