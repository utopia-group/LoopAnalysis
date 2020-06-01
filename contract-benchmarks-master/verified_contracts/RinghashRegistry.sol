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
pragma solidity ^0.4.15;

/// @title Token Register Contract
/// @author Kongliang Zhong - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="791216171e151018171e39151616090b10171e57160b1e">[email protected]</a>&gt;,&#13;
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3c585d525559507c5053534c4e55525b12534e5b">[email protected]</a>&gt;.&#13;
library Uint8Lib {&#13;
    function xorReduce(&#13;
        uint8[] arr,&#13;
        uint    len&#13;
        )&#13;
        public&#13;
        constant&#13;
        returns (uint8 res) {&#13;
&#13;
        res = arr[0];&#13;
        for (uint i = 1; i &lt; len; i++) {&#13;
           res ^= arr[i];&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
/// @title Token Register Contract&#13;
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e581848b8c8089a5898a8a95978c8b82cb8a9782">[email protected]</a>&gt;.&#13;
library ErrorLib {&#13;
&#13;
    event Error(string message);&#13;
&#13;
    /// @dev Check if condition hold, if not, log an exception and revert.&#13;
    function orThrow(bool condition, string message) public constant {&#13;
        if (!condition) {&#13;
            error(message);&#13;
        }&#13;
    }&#13;
&#13;
    function error(string message) public constant {&#13;
        Error(message);&#13;
        revert();&#13;
    }&#13;
}&#13;
&#13;
/// @title Token Register Contract&#13;
/// @author Kongliang Zhong - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a6cdc9c8c1cacfc7c8c1e6cac9c9d6d4cfc8c188c9d4c1">[email protected]</a>&gt;,&#13;
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0e6a6f60676b624e6261617e7c67606920617c69">[email protected]</a>&gt;.&#13;
library Bytes32Lib {&#13;
&#13;
    function xorReduce(&#13;
        bytes32[]   arr,&#13;
        uint        len&#13;
        )&#13;
        public&#13;
        constant&#13;
        returns (bytes32 res) {&#13;
&#13;
        res = arr[0];&#13;
        for (uint i = 1; i &lt; len; i++) {&#13;
            res = _xor(res, arr[i]);&#13;
        }&#13;
    }&#13;
&#13;
    function _xor(&#13;
        bytes32 bs1,&#13;
        bytes32 bs2&#13;
        )&#13;
        public&#13;
        constant&#13;
        returns (bytes32 res) {&#13;
&#13;
        bytes memory temp = new bytes(32);&#13;
        for (uint i = 0; i &lt; 32; i++) {&#13;
            temp[i] = bs1[i] ^ bs2[i];&#13;
        }&#13;
        string memory str = string(temp);&#13;
        assembly {&#13;
            res := mload(add(str, 32))&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
contract RinghashRegistry {&#13;
    using Bytes32Lib    for bytes32[];&#13;
    using ErrorLib      for bool;&#13;
    using Uint8Lib      for uint8[];&#13;
&#13;
    uint public blocksToLive;&#13;
&#13;
    struct Submission {&#13;
        address feeRecepient;&#13;
        uint block;&#13;
    }&#13;
&#13;
    mapping (bytes32 =&gt; Submission) submissions;&#13;
&#13;
    function RinghashRegistry(uint _blocksToLive) public {&#13;
        require(_blocksToLive &gt; 0);&#13;
        blocksToLive = _blocksToLive;&#13;
    }&#13;
&#13;
    function submitRinghash(&#13;
        uint        ringSize,&#13;
        address     feeRecepient,&#13;
        // bool        throwIfLRCIsInsuffcient,&#13;
        uint8[]     vList,&#13;
        bytes32[]   rList,&#13;
        bytes32[]   sList)&#13;
        public {&#13;
        bytes32 ringhash = calculateRinghash(&#13;
            ringSize,&#13;
            // feeRecepient,&#13;
            // throwIfLRCIsInsuffcient,&#13;
            vList,&#13;
            rList,&#13;
            sList);&#13;
&#13;
        canSubmit(ringhash, feeRecepient)&#13;
            .orThrow("Ringhash submitted");&#13;
&#13;
        submissions[ringhash] = Submission(feeRecepient, block.number);&#13;
    }&#13;
&#13;
    function canSubmit(&#13;
        bytes32 ringhash,&#13;
        address feeRecepient&#13;
        )&#13;
        public&#13;
        constant&#13;
        returns (bool) {&#13;
&#13;
        var submission = submissions[ringhash];&#13;
        return (submission.feeRecepient == address(0)&#13;
            || submission.block + blocksToLive &lt; block.number&#13;
            || submission.feeRecepient == feeRecepient);&#13;
    }&#13;
&#13;
    /// @return True if a ring's hash has ever been submitted; false otherwise.&#13;
    function ringhashFound(bytes32 ringhash)&#13;
        public&#13;
        constant&#13;
        returns (bool) {&#13;
&#13;
        return submissions[ringhash].feeRecepient != address(0);&#13;
    }&#13;
&#13;
    /// @dev Calculate the hash of a ring.&#13;
    function calculateRinghash(&#13;
        uint        ringSize,&#13;
        // address     feeRecepient,&#13;
        // bool        throwIfLRCIsInsuffcient,&#13;
        uint8[]     vList,&#13;
        bytes32[]   rList,&#13;
        bytes32[]   sList&#13;
        )&#13;
        public&#13;
        constant&#13;
        returns (bytes32) {&#13;
&#13;
        (ringSize == vList.length - 1&#13;
            &amp;&amp; ringSize == rList.length - 1&#13;
            &amp;&amp; ringSize == sList.length - 1)&#13;
            .orThrow("invalid ring data");&#13;
&#13;
        return keccak256(&#13;
            // feeRecepient,&#13;
            // throwIfLRCIsInsuffcient,&#13;
            vList.xorReduce(ringSize),&#13;
            rList.xorReduce(ringSize),&#13;
            sList.xorReduce(ringSize));&#13;
    }&#13;
}