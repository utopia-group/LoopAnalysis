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



/// @title ITradeHistory
/// @dev Stores the trade history and cancelled data of orders
/// @author Brecht Devos - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="51332334323925113d3e3e2123383f367f3e2336">[email protected]</a>&gt;.&#13;
contract ITradeHistory {&#13;
&#13;
    // The following map is used to keep trace of order fill and cancellation&#13;
    // history.&#13;
    mapping (bytes32 =&gt; uint) public filled;&#13;
&#13;
    // This map is used to keep trace of order's cancellation history.&#13;
    mapping (address =&gt; mapping (bytes32 =&gt; bool)) public cancelled;&#13;
&#13;
    // A map from a broker to its cutoff timestamp.&#13;
    mapping (address =&gt; uint) public cutoffs;&#13;
&#13;
    // A map from a broker to its trading-pair cutoff timestamp.&#13;
    mapping (address =&gt; mapping (bytes20 =&gt; uint)) public tradingPairCutoffs;&#13;
&#13;
    // A map from a broker to an order owner to its cutoff timestamp.&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) public cutoffsOwner;&#13;
&#13;
    // A map from a broker to an order owner to its trading-pair cutoff timestamp.&#13;
    mapping (address =&gt; mapping (address =&gt; mapping (bytes20 =&gt; uint))) public tradingPairCutoffsOwner;&#13;
&#13;
&#13;
    function batchUpdateFilled(&#13;
        bytes32[] calldata filledInfo&#13;
        )&#13;
        external;&#13;
&#13;
    function setCancelled(&#13;
        address broker,&#13;
        bytes32 orderHash&#13;
        )&#13;
        external;&#13;
&#13;
    function setCutoffs(&#13;
        address broker,&#13;
        uint cutoff&#13;
        )&#13;
        external;&#13;
&#13;
    function setTradingPairCutoffs(&#13;
        address broker,&#13;
        bytes20 tokenPair,&#13;
        uint cutoff&#13;
        )&#13;
        external;&#13;
&#13;
    function setCutoffsOfOwner(&#13;
        address broker,&#13;
        address owner,&#13;
        uint cutoff&#13;
        )&#13;
        external;&#13;
&#13;
    function setTradingPairCutoffsOfOwner(&#13;
        address broker,&#13;
        address owner,&#13;
        bytes20 tokenPair,&#13;
        uint cutoff&#13;
        )&#13;
        external;&#13;
&#13;
    function batchGetFilledAndCheckCancelled(&#13;
        bytes32[] calldata orderInfo&#13;
        )&#13;
        external&#13;
        view&#13;
        returns (uint[] memory fills);&#13;
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
/// @title Utility Functions for uint&#13;
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="472326292e222b072b282837352e292069283520">[email protected]</a>&gt;&#13;
library MathUint {&#13;
&#13;
    function mul(&#13;
        uint a,&#13;
        uint b&#13;
        )&#13;
        internal&#13;
        pure&#13;
        returns (uint c)&#13;
    {&#13;
        c = a * b;&#13;
        require(a == 0 || c / a == b, "INVALID_VALUE");&#13;
    }&#13;
&#13;
    function sub(&#13;
        uint a,&#13;
        uint b&#13;
        )&#13;
        internal&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        require(b &lt;= a, "INVALID_VALUE");&#13;
        return a - b;&#13;
    }&#13;
&#13;
    function add(&#13;
        uint a,&#13;
        uint b&#13;
        )&#13;
        internal&#13;
        pure&#13;
        returns (uint c)&#13;
    {&#13;
        c = a + b;&#13;
        require(c &gt;= a, "INVALID_VALUE");&#13;
    }&#13;
&#13;
    function hasRoundingError(&#13;
        uint value,&#13;
        uint numerator,&#13;
        uint denominator&#13;
        )&#13;
        internal&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        uint multiplied = mul(value, numerator);&#13;
        uint remainder = multiplied % denominator;&#13;
        // Return true if the rounding error is larger than 1%&#13;
        return mul(remainder, 100) &gt; multiplied;&#13;
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
/// @title An Implementation of ITradeHistory.&#13;
/// @author Brecht Devos - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f6948493959e82b69a999986849f9891d8998491">[email protected]</a>&gt;.&#13;
contract TradeHistory is ITradeHistory, Authorizable, Killable, NoDefaultFunc {&#13;
    using MathUint for uint;&#13;
&#13;
    function batchUpdateFilled(&#13;
        bytes32[] calldata filledInfo&#13;
        )&#13;
        external&#13;
        onlyAuthorized&#13;
        notSuspended&#13;
    {&#13;
        uint length = filledInfo.length;&#13;
        require(length % 2 == 0, INVALID_SIZE);&#13;
&#13;
        uint start = 68;&#13;
        uint end = start + length * 32;&#13;
        for (uint p = start; p &lt; end; p += 64) {&#13;
            bytes32 hash;&#13;
            uint filledAmount;&#13;
            assembly {&#13;
                hash := calldataload(add(p,  0))&#13;
                filledAmount := calldataload(add(p, 32))&#13;
            }&#13;
            filled[hash] = filledAmount;&#13;
        }&#13;
    }&#13;
&#13;
    function setCancelled(&#13;
        address broker,&#13;
        bytes32 orderHash&#13;
        )&#13;
        external&#13;
        onlyAuthorized&#13;
        notSuspended&#13;
    {&#13;
        cancelled[broker][orderHash] = true;&#13;
    }&#13;
&#13;
    function setCutoffs(&#13;
        address broker,&#13;
        uint    cutoff&#13;
        )&#13;
        external&#13;
        onlyAuthorized&#13;
        notSuspended&#13;
    {&#13;
        require(cutoffs[broker] &lt; cutoff, INVALID_VALUE);&#13;
        cutoffs[broker] = cutoff;&#13;
    }&#13;
&#13;
    function setTradingPairCutoffs(&#13;
        address broker,&#13;
        bytes20 tokenPair,&#13;
        uint    cutoff&#13;
        )&#13;
        external&#13;
        onlyAuthorized&#13;
        notSuspended&#13;
    {&#13;
        require(tradingPairCutoffs[broker][tokenPair] &lt; cutoff, INVALID_VALUE);&#13;
        tradingPairCutoffs[broker][tokenPair] = cutoff;&#13;
    }&#13;
&#13;
    function setCutoffsOfOwner(&#13;
        address broker,&#13;
        address owner,&#13;
        uint    cutoff&#13;
        )&#13;
        external&#13;
        onlyAuthorized&#13;
        notSuspended&#13;
    {&#13;
        require(cutoffsOwner[broker][owner] &lt; cutoff, INVALID_VALUE);&#13;
        cutoffsOwner[broker][owner] = cutoff;&#13;
    }&#13;
&#13;
    function setTradingPairCutoffsOfOwner(&#13;
        address broker,&#13;
        address owner,&#13;
        bytes20 tokenPair,&#13;
        uint    cutoff&#13;
        )&#13;
        external&#13;
        onlyAuthorized&#13;
        notSuspended&#13;
    {&#13;
        require(tradingPairCutoffsOwner[broker][owner][tokenPair] &lt; cutoff, INVALID_VALUE);&#13;
        tradingPairCutoffsOwner[broker][owner][tokenPair] = cutoff;&#13;
    }&#13;
&#13;
    function batchGetFilledAndCheckCancelled(&#13;
        bytes32[] calldata batch&#13;
        )&#13;
        external&#13;
        view&#13;
        returns (uint[] memory fills)&#13;
    {&#13;
        uint length = batch.length;&#13;
        require(length % 5 == 0, INVALID_SIZE);&#13;
&#13;
        uint start = 68;&#13;
        uint end = start + length * 32;&#13;
        uint i = 0;&#13;
        fills = new uint[](length / 5);&#13;
        for (uint p = start; p &lt; end; p += 160) {&#13;
            address broker;&#13;
            address owner;&#13;
            bytes32 hash;&#13;
            uint validSince;&#13;
            bytes20 tradingPair;&#13;
            assembly {&#13;
                broker := calldataload(add(p,  0))&#13;
                owner := calldataload(add(p, 32))&#13;
                hash := calldataload(add(p, 64))&#13;
                validSince := calldataload(add(p, 96))&#13;
                tradingPair := calldataload(add(p, 128))&#13;
            }&#13;
            bool valid = !cancelled[broker][hash];&#13;
            valid = valid &amp;&amp; validSince &gt; tradingPairCutoffs[broker][tradingPair];&#13;
            valid = valid &amp;&amp; validSince &gt; cutoffs[broker];&#13;
            valid = valid &amp;&amp; validSince &gt; tradingPairCutoffsOwner[broker][owner][tradingPair];&#13;
            valid = valid &amp;&amp; validSince &gt; cutoffsOwner[broker][owner];&#13;
&#13;
            fills[i++] = valid ? filled[hash] : ~uint(0);&#13;
        }&#13;
    }&#13;
}