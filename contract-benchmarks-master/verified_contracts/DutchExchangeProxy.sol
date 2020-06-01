pragma solidity ^0.4.21;

// File: @gnosis.pm/util-contracts/contracts/Proxy.sol

/// @title Proxied - indicates that a contract will be proxied. Also defines storage requirements for Proxy.
/// @author Alan Lu - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b2d3ded3dcf2d5dcddc1dbc19cc2df">[email protected]</a>&gt;&#13;
contract Proxied {&#13;
    address public masterCopy;&#13;
}&#13;
&#13;
/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="89fafdecefe8e7c9eee7e6fae0faa7f9e4">[email protected]</a>&gt;&#13;
contract Proxy is Proxied {&#13;
    /// @dev Constructor function sets address of master copy contract.&#13;
    /// @param _masterCopy Master copy address.&#13;
    function Proxy(address _masterCopy)&#13;
        public&#13;
    {&#13;
        require(_masterCopy != 0);&#13;
        masterCopy = _masterCopy;&#13;
    }&#13;
&#13;
    /// @dev Fallback function forwards all transactions and returns all received return data.&#13;
    function ()&#13;
        external&#13;
        payable&#13;
    {&#13;
        address _masterCopy = masterCopy;&#13;
        assembly {&#13;
            calldatacopy(0, 0, calldatasize())&#13;
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)&#13;
            returndatacopy(0, 0, returndatasize())&#13;
            switch success&#13;
            case 0 { revert(0, returndatasize()) }&#13;
            default { return(0, returndatasize()) }&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/DutchExchangeProxy.sol&#13;
&#13;
contract DutchExchangeProxy is Proxy {&#13;
  function DutchExchangeProxy(address _masterCopy) Proxy (_masterCopy) {&#13;
  }&#13;
}