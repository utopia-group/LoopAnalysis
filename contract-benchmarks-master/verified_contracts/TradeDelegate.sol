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
pragma solidity 0.5.0;


/// @title Errors
contract Errors {
    string constant ZERO_VALUE                 = "ZERO_VALUE";
    string constant ZERO_ADDRESS               = "ZERO_ADDRESS";
    string constant INVALID_VALUE              = "INVALID_VALUE";
    string constant INVALID_ADDRESS            = "INVALID_ADDRESS";
    string constant INVALID_SIZE               = "INVALID_SIZE";
    string constant INVALID_SIG                = "INVALID_SIG";
    string constant INVALID_STATE              = "INVALID_STATE";
    string constant NOT_FOUND                  = "NOT_FOUND";
    string constant ALREADY_EXIST              = "ALREADY_EXIST";
    string constant REENTRY                    = "REENTRY";
    string constant UNAUTHORIZED               = "UNAUTHORIZED";
    string constant UNIMPLEMENTED              = "UNIMPLEMENTED";
    string constant UNSUPPORTED                = "UNSUPPORTED";
    string constant TRANSFER_FAILURE           = "TRANSFER_FAILURE";
    string constant WITHDRAWAL_FAILURE         = "WITHDRAWAL_FAILURE";
    string constant BURN_FAILURE               = "BURN_FAILURE";
    string constant BURN_RATE_FROZEN           = "BURN_RATE_FROZEN";
    string constant BURN_RATE_MINIMIZED        = "BURN_RATE_MINIMIZED";
    string constant UNAUTHORIZED_ONCHAIN_ORDER = "UNAUTHORIZED_ONCHAIN_ORDER";
    string constant INVALID_CANDIDATE          = "INVALID_CANDIDATE";
    string constant ALREADY_VOTED              = "ALREADY_VOTED";
    string constant NOT_OWNER                  = "NOT_OWNER";
}
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



/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic
///      authorization control functions, this simplifies the implementation of
///      "user permissions".
contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /// @dev The Ownable constructor sets the original `owner` of the contract
    ///      to the sender.
    constructor()
        public
    {
        owner = msg.sender;
    }

    /// @dev Throws if called by any account other than the owner.
    modifier onlyOwner()
    {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    /// @dev Allows the current owner to transfer control of the contract to a
    ///      newOwner.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(
        address newOwner
        )
        public
        onlyOwner
    {
        require(newOwner != address(0x0), "ZERO_ADDRESS");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}



/// @title Claimable
/// @dev Extension for the Ownable contract, where the ownership needs
///      to be claimed. This allows the new owner to accept the transfer.
contract Claimable is Ownable {
    address public pendingOwner;

    /// @dev Modifier throws if called by any account other than the pendingOwner.
    modifier onlyPendingOwner() {
        require(msg.sender == pendingOwner, "UNAUTHORIZED");
        _;
    }

    /// @dev Allows the current owner to set the pendingOwner address.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(
        address newOwner
        )
        public
        onlyOwner
    {
        require(newOwner != address(0x0) && newOwner != owner, "INVALID_ADDRESS");
        pendingOwner = newOwner;
    }

    /// @dev Allows the pendingOwner address to finalize the transfer.
    function claimOwnership()
        public
        onlyPendingOwner
    {
        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0x0);
    }
}
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



/// @title ITradeDelegate
/// @dev Acts as a middle man to transfer ERC20 tokens on behalf of different
/// versions of Loopring protocol to avoid ERC20 re-authorization.
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3450555a5d515874585b5b44465d5a531a5b4653">[email protected]</a>&gt;.&#13;
contract ITradeDelegate {&#13;
&#13;
    function batchTransfer(&#13;
        bytes32[] calldata batch&#13;
        )&#13;
        external;&#13;
&#13;
&#13;
    /// @dev Add a Loopring protocol address.&#13;
    /// @param addr A loopring protocol address.&#13;
    function authorizeAddress(&#13;
        address addr&#13;
        )&#13;
        external;&#13;
&#13;
    /// @dev Remove a Loopring protocol address.&#13;
    /// @param addr A loopring protocol address.&#13;
    function deauthorizeAddress(&#13;
        address addr&#13;
        )&#13;
        external;&#13;
&#13;
    function isAddressAuthorized(&#13;
        address addr&#13;
        )&#13;
        public&#13;
        view&#13;
        returns (bool);&#13;
&#13;
&#13;
    function suspend()&#13;
        external;&#13;
&#13;
    function resume()&#13;
        external;&#13;
&#13;
    function kill()&#13;
        external;&#13;
}&#13;
&#13;
/*&#13;
&#13;
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).&#13;
&#13;
  Licensed under the Apache License, Version 2.0 (the "License");&#13;
  you may not use this file except in compliance with the License.&#13;
  You may obtain a copy of the License at&#13;
&#13;
  http://www.apache.org/licenses/LICENSE-2.0&#13;
&#13;
  Unless required by applicable law or agreed to in writing, software&#13;
  distributed under the License is distributed on an "AS IS" BASIS,&#13;
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.&#13;
  See the License for the specific language governing permissions and&#13;
  limitations under the License.&#13;
*/&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/// @title Authorizable&#13;
/// @dev The Authorizable contract allows a contract to be used by other contracts&#13;
///      by authorizing it by the contract owner.&#13;
contract Authorizable is Claimable, Errors  {&#13;
&#13;
    event AddressAuthorized(&#13;
        address indexed addr&#13;
    );&#13;
&#13;
    event AddressDeauthorized(&#13;
        address indexed addr&#13;
    );&#13;
&#13;
    // The list of all authorized addresses&#13;
    address[] authorizedAddresses;&#13;
&#13;
    mapping (address =&gt; uint) private positionMap;&#13;
&#13;
    struct AuthorizedAddress {&#13;
        uint    pos;&#13;
        address addr;&#13;
    }&#13;
&#13;
    modifier onlyAuthorized()&#13;
    {&#13;
        require(positionMap[msg.sender] &gt; 0, UNAUTHORIZED);&#13;
        _;&#13;
    }&#13;
&#13;
    function authorizeAddress(&#13;
        address addr&#13;
        )&#13;
        external&#13;
        onlyOwner&#13;
    {&#13;
        require(address(0x0) != addr, ZERO_ADDRESS);&#13;
        require(0 == positionMap[addr], ALREADY_EXIST);&#13;
        require(isContract(addr), INVALID_ADDRESS);&#13;
&#13;
        authorizedAddresses.push(addr);&#13;
        positionMap[addr] = authorizedAddresses.length;&#13;
        emit AddressAuthorized(addr);&#13;
    }&#13;
&#13;
    function deauthorizeAddress(&#13;
        address addr&#13;
        )&#13;
        external&#13;
        onlyOwner&#13;
    {&#13;
        require(address(0x0) != addr, ZERO_ADDRESS);&#13;
&#13;
        uint pos = positionMap[addr];&#13;
        require(pos != 0, NOT_FOUND);&#13;
&#13;
        uint size = authorizedAddresses.length;&#13;
        if (pos != size) {&#13;
            address lastOne = authorizedAddresses[size - 1];&#13;
            authorizedAddresses[pos - 1] = lastOne;&#13;
            positionMap[lastOne] = pos;&#13;
        }&#13;
&#13;
        authorizedAddresses.length -= 1;&#13;
        delete positionMap[addr];&#13;
&#13;
        emit AddressDeauthorized(addr);&#13;
    }&#13;
&#13;
    function isAddressAuthorized(&#13;
        address addr&#13;
        )&#13;
        public&#13;
        view&#13;
        returns (bool)&#13;
    {&#13;
        return positionMap[addr] &gt; 0;&#13;
    }&#13;
&#13;
    function isContract(&#13;
        address addr&#13;
        )&#13;
        internal&#13;
        view&#13;
        returns (bool)&#13;
    {&#13;
        uint size;&#13;
        assembly { size := extcodesize(addr) }&#13;
        return size &gt; 0;&#13;
    }&#13;
&#13;
}&#13;
&#13;
/*&#13;
&#13;
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).&#13;
&#13;
  Licensed under the Apache License, Version 2.0 (the "License");&#13;
  you may not use this file except in compliance with the License.&#13;
  You may obtain a copy of the License at&#13;
&#13;
  http://www.apache.org/licenses/LICENSE-2.0&#13;
&#13;
  Unless required by applicable law or agreed to in writing, software&#13;
  distributed under the License is distributed on an "AS IS" BASIS,&#13;
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.&#13;
  See the License for the specific language governing permissions and&#13;
  limitations under the License.&#13;
*/&#13;
&#13;
&#13;
&#13;
/// @title ERC20 safe transfer&#13;
/// @dev see https://github.com/sec-bit/badERC20Fix&#13;
/// @author Brecht Devos - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f2908097919a86b29e9d9d82809b9c95dc9d8095">[email protected]</a>&gt;&#13;
library ERC20SafeTransfer {&#13;
&#13;
    function safeTransfer(&#13;
        address token,&#13;
        address to,&#13;
        uint256 value)&#13;
        internal&#13;
        returns (bool success)&#13;
    {&#13;
        // A transfer is successful when 'call' is successful and depending on the token:&#13;
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)&#13;
        // - A single boolean is returned: this boolean needs to be true (non-zero)&#13;
&#13;
        // bytes4(keccak256("transfer(address,uint256)")) = 0xa9059cbb&#13;
        bytes memory callData = abi.encodeWithSelector(&#13;
            bytes4(0xa9059cbb),&#13;
            to,&#13;
            value&#13;
        );&#13;
        (success, ) = token.call(callData);&#13;
        return checkReturnValue(success);&#13;
    }&#13;
&#13;
    function safeTransferFrom(&#13;
        address token,&#13;
        address from,&#13;
        address to,&#13;
        uint256 value)&#13;
        internal&#13;
        returns (bool success)&#13;
    {&#13;
        // A transferFrom is successful when 'call' is successful and depending on the token:&#13;
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)&#13;
        // - A single boolean is returned: this boolean needs to be true (non-zero)&#13;
&#13;
        // bytes4(keccak256("transferFrom(address,address,uint256)")) = 0x23b872dd&#13;
        bytes memory callData = abi.encodeWithSelector(&#13;
            bytes4(0x23b872dd),&#13;
            from,&#13;
            to,&#13;
            value&#13;
        );&#13;
        (success, ) = token.call(callData);&#13;
        return checkReturnValue(success);&#13;
    }&#13;
&#13;
    function checkReturnValue(&#13;
        bool success&#13;
        )&#13;
        internal&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        // A transfer/transferFrom is successful when 'call' is successful and depending on the token:&#13;
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)&#13;
        // - A single boolean is returned: this boolean needs to be true (non-zero)&#13;
        if (success) {&#13;
            assembly {&#13;
                switch returndatasize()&#13;
                // Non-standard ERC20: nothing is returned so if 'call' was successful we assume the transfer succeeded&#13;
                case 0 {&#13;
                    success := 1&#13;
                }&#13;
                // Standard ERC20: a single boolean value is returned which needs to be true&#13;
                case 32 {&#13;
                    returndatacopy(0, 0, 32)&#13;
                    success := mload(0)&#13;
                }&#13;
                // None of the above: not successful&#13;
                default {&#13;
                    success := 0&#13;
                }&#13;
            }&#13;
        }&#13;
        return success;&#13;
    }&#13;
&#13;
}&#13;
/*&#13;
&#13;
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).&#13;
&#13;
  Licensed under the Apache License, Version 2.0 (the "License");&#13;
  you may not use this file except in compliance with the License.&#13;
  You may obtain a copy of the License at&#13;
&#13;
  http://www.apache.org/licenses/LICENSE-2.0&#13;
&#13;
  Unless required by applicable law or agreed to in writing, software&#13;
  distributed under the License is distributed on an "AS IS" BASIS,&#13;
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.&#13;
  See the License for the specific language governing permissions and&#13;
  limitations under the License.&#13;
*/&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/// @title Killable&#13;
/// @dev The Killable contract allows the contract owner to suspend, resume or kill the contract&#13;
contract Killable is Claimable, Errors  {&#13;
&#13;
    bool public suspended = false;&#13;
&#13;
    modifier notSuspended()&#13;
    {&#13;
        require(!suspended, INVALID_STATE);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isSuspended()&#13;
    {&#13;
        require(suspended, INVALID_STATE);&#13;
        _;&#13;
    }&#13;
&#13;
    function suspend()&#13;
        external&#13;
        onlyOwner&#13;
        notSuspended&#13;
    {&#13;
        suspended = true;&#13;
    }&#13;
&#13;
    function resume()&#13;
        external&#13;
        onlyOwner&#13;
        isSuspended&#13;
    {&#13;
        suspended = false;&#13;
    }&#13;
&#13;
    /// owner must suspend the delegate first before invoking the kill method.&#13;
    function kill()&#13;
        external&#13;
        onlyOwner&#13;
        isSuspended&#13;
    {&#13;
        owner = address(0x0);&#13;
        emit OwnershipTransferred(owner, address(0x0));&#13;
    }&#13;
}&#13;
&#13;
/*&#13;
&#13;
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).&#13;
&#13;
  Licensed under the Apache License, Version 2.0 (the "License");&#13;
  you may not use this file except in compliance with the License.&#13;
  You may obtain a copy of the License at&#13;
&#13;
  http://www.apache.org/licenses/LICENSE-2.0&#13;
&#13;
  Unless required by applicable law or agreed to in writing, software&#13;
  distributed under the License is distributed on an "AS IS" BASIS,&#13;
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.&#13;
  See the License for the specific language governing permissions and&#13;
  limitations under the License.&#13;
*/&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/// @title NoDefaultFunc&#13;
/// @dev Disable default functions.&#13;
contract NoDefaultFunc is Errors {&#13;
    function ()&#13;
        external&#13;
        payable&#13;
    {&#13;
        revert(UNSUPPORTED);&#13;
    }&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title An Implementation of ITradeDelegate.&#13;
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d1b5b0bfb8b4bd91bdbebea1a3b8bfb6ffbea3b6">[email protected]</a>&gt;.&#13;
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c6ada9a8a1aaafa7a8a186aaa9a9b6b4afa8a1e8a9b4a1">[email protected]</a>&gt;.&#13;
contract TradeDelegate is ITradeDelegate, Authorizable, Killable, NoDefaultFunc {&#13;
    using ERC20SafeTransfer for address;&#13;
&#13;
    function batchTransfer(&#13;
        bytes32[] calldata batch&#13;
        )&#13;
        external&#13;
        onlyAuthorized&#13;
        notSuspended&#13;
    {&#13;
        uint length = batch.length;&#13;
        require(length % 4 == 0, INVALID_SIZE);&#13;
&#13;
        uint start = 68;&#13;
        uint end = start + length * 32;&#13;
        for (uint p = start; p &lt; end; p += 128) {&#13;
            address token;&#13;
            address from;&#13;
            address to;&#13;
            uint amount;&#13;
            assembly {&#13;
                token := calldataload(add(p,  0))&#13;
                from := calldataload(add(p, 32))&#13;
                to := calldataload(add(p, 64))&#13;
                amount := calldataload(add(p, 96))&#13;
            }&#13;
            require(&#13;
                token.safeTransferFrom(&#13;
                    from,&#13;
                    to,&#13;
                    amount&#13;
                ),&#13;
                TRANSFER_FAILURE&#13;
            );&#13;
        }&#13;
    }&#13;
}