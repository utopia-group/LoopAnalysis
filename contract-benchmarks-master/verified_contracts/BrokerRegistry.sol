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



/// @title IBrokerRegistry
/// @dev A broker is an account that can submit orders on behalf of other
///      accounts. When registering a broker, the owner can also specify a
///      pre-deployed BrokerInterceptor to hook into the exchange smart contracts.
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b8dcd9d6d1ddd4f8d4d7d7c8cad1d6df96d7cadf">[email protected]</a>&gt;.&#13;
contract IBrokerRegistry {&#13;
    event BrokerRegistered(&#13;
        address owner,&#13;
        address broker,&#13;
        address interceptor&#13;
    );&#13;
&#13;
    event BrokerUnregistered(&#13;
        address owner,&#13;
        address broker,&#13;
        address interceptor&#13;
    );&#13;
&#13;
    event AllBrokersUnregistered(&#13;
        address owner&#13;
    );&#13;
&#13;
    /// @dev   Validates if the broker was registered for the order owner and&#13;
    ///        returns the possible BrokerInterceptor to be used.&#13;
    /// @param owner The owner of the order&#13;
    /// @param broker The broker of the order&#13;
    /// @return True if the broker was registered for the owner&#13;
    ///         and the BrokerInterceptor to use.&#13;
    function getBroker(&#13;
        address owner,&#13;
        address broker&#13;
        )&#13;
        external&#13;
        view&#13;
        returns(&#13;
            bool registered,&#13;
            address interceptor&#13;
        );&#13;
&#13;
    /// @dev   Gets all registered brokers for an owner.&#13;
    /// @param owner The owner&#13;
    /// @param start The start index of the list of brokers&#13;
    /// @param count The number of brokers to return&#13;
    /// @return The list of requested brokers and corresponding BrokerInterceptors&#13;
    function getBrokers(&#13;
        address owner,&#13;
        uint    start,&#13;
        uint    count&#13;
        )&#13;
        external&#13;
        view&#13;
        returns (&#13;
            address[] memory brokers,&#13;
            address[] memory interceptors&#13;
        );&#13;
&#13;
    /// @dev   Registers a broker for msg.sender and an optional&#13;
    ///        corresponding BrokerInterceptor.&#13;
    /// @param broker The broker to register&#13;
    /// @param interceptor The optional BrokerInterceptor to use (0x0 allowed)&#13;
    function registerBroker(&#13;
        address broker,&#13;
        address interceptor&#13;
        )&#13;
        external;&#13;
&#13;
    /// @dev   Unregisters a broker for msg.sender&#13;
    /// @param broker The broker to unregister&#13;
    function unregisterBroker(&#13;
        address broker&#13;
        )&#13;
        external;&#13;
&#13;
    /// @dev   Unregisters all brokers for msg.sender&#13;
    function unregisterAllBrokers(&#13;
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
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="660207080f030a260a090916140f080148091401">[email protected]</a>&gt;.&#13;
contract BrokerRegistry is IBrokerRegistry, NoDefaultFunc {&#13;
    struct Broker {&#13;
        address owner;&#13;
        address addr;&#13;
        address interceptor;&#13;
    }&#13;
&#13;
    mapping (address =&gt; Broker[]) public brokersMap;&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) public positionMap;&#13;
&#13;
    function getBroker(&#13;
        address owner,&#13;
        address addr&#13;
        )&#13;
        external&#13;
        view&#13;
        returns(&#13;
            bool registered,&#13;
            address interceptor&#13;
        )&#13;
    {&#13;
        uint pos = positionMap[owner][addr];&#13;
        if (pos == 0) {&#13;
            registered = false;&#13;
        } else {&#13;
            registered = true;&#13;
            Broker storage broker = brokersMap[owner][pos - 1];&#13;
            interceptor = broker.interceptor;&#13;
        }&#13;
    }&#13;
&#13;
    function getBrokers(&#13;
        address owner,&#13;
        uint    start,&#13;
        uint    count&#13;
        )&#13;
        external&#13;
        view&#13;
        returns (&#13;
            address[] memory brokers,&#13;
            address[] memory interceptors&#13;
        )&#13;
    {&#13;
        Broker[] storage _brokers = brokersMap[owner];&#13;
        uint size = _brokers.length;&#13;
&#13;
        if (start &gt;= size) {&#13;
            return (brokers, interceptors);&#13;
        }&#13;
&#13;
        uint end = start + count;&#13;
        if (end &gt; size) {&#13;
            end = size;&#13;
        }&#13;
&#13;
        brokers = new address[](end - start);&#13;
        interceptors = new address[](end - start);&#13;
&#13;
        for (uint i = start; i &lt; end; i++) {&#13;
            brokers[i - start] = _brokers[i].addr;&#13;
            interceptors[i - start] = _brokers[i].interceptor;&#13;
        }&#13;
    }&#13;
&#13;
    function registerBroker(&#13;
        address broker,&#13;
        address interceptor  // 0x0 allowed&#13;
        )&#13;
        external&#13;
    {&#13;
        require(address(0x0) != broker, ZERO_ADDRESS);&#13;
        require(&#13;
            0 == positionMap[msg.sender][broker],&#13;
            ALREADY_EXIST&#13;
        );&#13;
&#13;
        if (interceptor != address(0x0)) {&#13;
            require(isContract(interceptor), INVALID_ADDRESS);&#13;
        }&#13;
&#13;
        Broker[] storage brokers = brokersMap[msg.sender];&#13;
        Broker memory b = Broker(&#13;
            msg.sender,&#13;
            broker,&#13;
            interceptor&#13;
        );&#13;
&#13;
        brokers.push(b);&#13;
        positionMap[msg.sender][broker] = brokers.length;&#13;
&#13;
        emit BrokerRegistered(&#13;
            msg.sender,&#13;
            broker,&#13;
            interceptor&#13;
        );&#13;
    }&#13;
&#13;
    function unregisterBroker(&#13;
        address addr&#13;
        )&#13;
        external&#13;
    {&#13;
        require(address(0x0) != addr, ZERO_ADDRESS);&#13;
&#13;
        uint pos = positionMap[msg.sender][addr];&#13;
        require(pos != 0, NOT_FOUND);&#13;
&#13;
        Broker[] storage brokers = brokersMap[msg.sender];&#13;
        uint size = brokers.length;&#13;
&#13;
        address interceptor = brokers[pos - 1].interceptor;&#13;
        if (pos != size) {&#13;
            Broker storage lastOne = brokers[size - 1];&#13;
            brokers[pos - 1] = lastOne;&#13;
            positionMap[lastOne.owner][lastOne.addr] = pos;&#13;
        }&#13;
&#13;
        brokers.length -= 1;&#13;
        delete positionMap[msg.sender][addr];&#13;
&#13;
        emit BrokerUnregistered(&#13;
            msg.sender,&#13;
            addr,&#13;
            interceptor&#13;
        );&#13;
    }&#13;
&#13;
    function unregisterAllBrokers(&#13;
        )&#13;
        external&#13;
    {&#13;
        Broker[] storage brokers = brokersMap[msg.sender];&#13;
&#13;
        for (uint i = 0; i &lt; brokers.length; i++) {&#13;
            delete positionMap[msg.sender][brokers[i].addr];&#13;
        }&#13;
        delete brokersMap[msg.sender];&#13;
&#13;
        emit AllBrokersUnregistered(msg.sender);&#13;
    }&#13;
&#13;
    // Currently here to work around InternalCompilerErrors when implemented&#13;
    // in a library. Because extcodesize is used the function cannot be pure,&#13;
    // so view is used which sometimes gives InternalCompilerErrors when&#13;
    // combined with internal.&#13;
    function isContract(&#13;
        address addr&#13;
        )&#13;
        public&#13;
        view&#13;
        returns (bool)&#13;
    {&#13;
        uint size;&#13;
        assembly { size := extcodesize(addr) }&#13;
        return size &gt; 0;&#13;
    }&#13;
}