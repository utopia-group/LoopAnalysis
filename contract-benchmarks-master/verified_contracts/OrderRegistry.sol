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



/// @title IOrderRegistry
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="781c1916111d1438141717080a11161f56170a1f">[email protected]</a>&gt;.&#13;
contract IOrderRegistry {&#13;
&#13;
    /// @dev   Returns wether the order hash was registered in the registry.&#13;
    /// @param broker The broker of the order&#13;
    /// @param orderHash The hash of the order&#13;
    /// @return True if the order hash was registered, else false.&#13;
    function isOrderHashRegistered(&#13;
        address broker,&#13;
        bytes32 orderHash&#13;
        )&#13;
        external&#13;
        view&#13;
        returns (bool);&#13;
&#13;
    /// @dev   Registers an order in the registry.&#13;
    ///        msg.sender needs to be the broker of the order.&#13;
    /// @param orderHash The hash of the order&#13;
    function registerOrderHash(&#13;
        bytes32 orderHash&#13;
        )&#13;
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
/// @title Errors&#13;
contract Errors {&#13;
    string constant ZERO_VALUE                 = "ZERO_VALUE";&#13;
    string constant ZERO_ADDRESS               = "ZERO_ADDRESS";&#13;
    string constant INVALID_VALUE              = "INVALID_VALUE";&#13;
    string constant INVALID_ADDRESS            = "INVALID_ADDRESS";&#13;
    string constant INVALID_SIZE               = "INVALID_SIZE";&#13;
    string constant INVALID_SIG                = "INVALID_SIG";&#13;
    string constant INVALID_STATE              = "INVALID_STATE";&#13;
    string constant NOT_FOUND                  = "NOT_FOUND";&#13;
    string constant ALREADY_EXIST              = "ALREADY_EXIST";&#13;
    string constant REENTRY                    = "REENTRY";&#13;
    string constant UNAUTHORIZED               = "UNAUTHORIZED";&#13;
    string constant UNIMPLEMENTED              = "UNIMPLEMENTED";&#13;
    string constant UNSUPPORTED                = "UNSUPPORTED";&#13;
    string constant TRANSFER_FAILURE           = "TRANSFER_FAILURE";&#13;
    string constant WITHDRAWAL_FAILURE         = "WITHDRAWAL_FAILURE";&#13;
    string constant BURN_FAILURE               = "BURN_FAILURE";&#13;
    string constant BURN_RATE_FROZEN           = "BURN_RATE_FROZEN";&#13;
    string constant BURN_RATE_MINIMIZED        = "BURN_RATE_MINIMIZED";&#13;
    string constant UNAUTHORIZED_ONCHAIN_ORDER = "UNAUTHORIZED_ONCHAIN_ORDER";&#13;
    string constant INVALID_CANDIDATE          = "INVALID_CANDIDATE";&#13;
    string constant ALREADY_VOTED              = "ALREADY_VOTED";&#13;
    string constant NOT_OWNER                  = "NOT_OWNER";&#13;
}&#13;
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
/// @title An Implementation of IBrokerRegistry.&#13;
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="066267686f636a466a696976746f686128697461">[email protected]</a>&gt;.&#13;
contract OrderRegistry is IOrderRegistry, NoDefaultFunc {&#13;
&#13;
    mapping (address =&gt; mapping (bytes32 =&gt; bool)) public hashMap;&#13;
&#13;
    event OrderRegistered(address broker, bytes32 orderHash);&#13;
&#13;
    function isOrderHashRegistered(&#13;
        address broker,&#13;
        bytes32 orderHash&#13;
        )&#13;
        external&#13;
        view&#13;
        returns (bool)&#13;
    {&#13;
        return hashMap[broker][orderHash];&#13;
    }&#13;
&#13;
    function registerOrderHash(&#13;
        bytes32 orderHash&#13;
        )&#13;
        external&#13;
    {&#13;
        require(hashMap[msg.sender][orderHash] == false, ALREADY_EXIST);&#13;
        hashMap[msg.sender][orderHash] = true;&#13;
        emit OrderRegistered(msg.sender, orderHash);&#13;
    }&#13;
}