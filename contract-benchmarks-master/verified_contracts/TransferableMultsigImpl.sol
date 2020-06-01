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
pragma solidity 0.4.21;
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
/// @title Transferable Multisignature Contract
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3054515e59555c705c5f5f4042595e571e5f4257">[email protected]</a>&gt;.&#13;
contract TransferableMultsig {&#13;
    // Note that address recovered from signatures must be strictly increasing.&#13;
    function execute(&#13;
        uint8[]   sigV,&#13;
        bytes32[] sigR,&#13;
        bytes32[] sigS,&#13;
        address   destination,&#13;
        uint      value,&#13;
        bytes     data&#13;
        )&#13;
        external;&#13;
    // Note that address recovered from signatures must be strictly increasing.&#13;
    function transferOwnership(&#13;
        uint8[]   sigV,&#13;
        bytes32[] sigR,&#13;
        bytes32[] sigS,&#13;
        uint      _threshold,&#13;
        address[] _owners&#13;
        )&#13;
        external;&#13;
}&#13;
/// @title An Implementation of TransferableMultsig。&#13;
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2347424d4a464f634f4c4c53514a4d440d4c5144">[email protected]</a>&gt;.&#13;
contract TransferableMultsigImpl is TransferableMultsig {&#13;
    uint public nonce;                  // (only) mutable state&#13;
    uint public threshold;              // immutable state&#13;
    mapping (address =&gt; bool) ownerMap; // immutable state&#13;
    address[] public owners;            // immutable state&#13;
    function TransferableMultsig(&#13;
        uint      _threshold,&#13;
        address[] _owners&#13;
        )&#13;
        public&#13;
    {&#13;
        updateOwners(_threshold, _owners);&#13;
    }&#13;
    // default function does nothing.&#13;
    function ()&#13;
        payable&#13;
        public&#13;
    {&#13;
    }&#13;
    function execute(&#13;
        uint8[]   sigV,&#13;
        bytes32[] sigR,&#13;
        bytes32[] sigS,&#13;
        address   destination,&#13;
        uint      value,&#13;
        bytes     data&#13;
        )&#13;
        external&#13;
    {&#13;
        // Follows ERC191 signature scheme:&#13;
        //    https://github.com/ethereum/EIPs/issues/191&#13;
        bytes32 txHash = keccak256(&#13;
            byte(0x19),&#13;
            byte(0),&#13;
            this,&#13;
            nonce++,&#13;
            destination,&#13;
            value,&#13;
            data&#13;
        );&#13;
        verifySignatures(&#13;
            sigV,&#13;
            sigR,&#13;
            sigS,&#13;
            txHash&#13;
        );&#13;
        require(&#13;
            destination.call.value(value)(data)&#13;
        );&#13;
    }&#13;
    function transferOwnership(&#13;
        uint8[]   sigV,&#13;
        bytes32[] sigR,&#13;
        bytes32[] sigS,&#13;
        uint      _threshold,&#13;
        address[] _owners&#13;
        )&#13;
        external&#13;
    {&#13;
        // Follows ERC191 signature scheme:&#13;
        //    https://github.com/ethereum/EIPs/issues/191&#13;
        bytes32 txHash = keccak256(&#13;
            byte(0x19),&#13;
            byte(0),&#13;
            this,&#13;
            nonce++,&#13;
            _threshold,&#13;
            _owners&#13;
        );&#13;
        verifySignatures(&#13;
            sigV,&#13;
            sigR,&#13;
            sigS,&#13;
            txHash&#13;
        );&#13;
        updateOwners(_threshold, _owners);&#13;
    }&#13;
    function verifySignatures(&#13;
        uint8[]   sigV,&#13;
        bytes32[] sigR,&#13;
        bytes32[] sigS,&#13;
        bytes32   txHash&#13;
        )&#13;
        view&#13;
        internal&#13;
    {&#13;
        uint _threshold = threshold;&#13;
        require(_threshold == sigR.length);&#13;
        require(_threshold == sigS.length);&#13;
        require(_threshold == sigV.length);&#13;
        address lastAddr = 0x0; // cannot have 0x0 as an owner&#13;
        for (uint i = 0; i &lt; threshold; i++) {&#13;
            address recovered = ecrecover(&#13;
                txHash,&#13;
                sigV[i],&#13;
                sigR[i],&#13;
                sigS[i]&#13;
            );&#13;
            require(recovered &gt; lastAddr &amp;&amp; ownerMap[recovered]);&#13;
            lastAddr = recovered;&#13;
        }&#13;
    }&#13;
    function updateOwners(&#13;
        uint      _threshold,&#13;
        address[] _owners&#13;
        )&#13;
        internal&#13;
    {&#13;
        require(_owners.length &lt;= 10);&#13;
        require(_threshold &lt;= _owners.length);&#13;
        require(_threshold != 0);&#13;
        // remove all current owners from ownerMap.&#13;
        address[] memory currentOwners = owners;&#13;
        for (uint i = 0; i &lt; currentOwners.length; i++) {&#13;
            ownerMap[currentOwners[i]] = false;&#13;
        }&#13;
        address lastAddr = 0x0;&#13;
        for (i = 0; i &lt; _owners.length; i++) {&#13;
            address owner = _owners[i];&#13;
            require(owner &gt; lastAddr);&#13;
            ownerMap[owner] = true;&#13;
            lastAddr = owner;&#13;
        }&#13;
        owners = _owners;&#13;
        threshold = _threshold;&#13;
    }&#13;
}