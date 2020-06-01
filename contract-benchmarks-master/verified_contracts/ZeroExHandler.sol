pragma solidity 0.4.21;

// File: contracts/ExchangeHandler.sol

/// @title Interface for all exchange handler contracts
interface ExchangeHandler {

    /// @dev Get the available amount left to fill for an order
    /// @param orderAddresses Array of address values needed for this DEX order
    /// @param orderValues Array of uint values needed for this DEX order
    /// @param exchangeFee Value indicating the fee for this DEX order
    /// @param v ECDSA signature parameter v
    /// @param r ECDSA signature parameter r
    /// @param s ECDSA signature parameter s
    /// @return Available amount left to fill for this order
    function getAvailableAmount(
        address[8] orderAddresses,
        uint256[6] orderValues,
        uint256 exchangeFee,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256);

    /// @dev Perform a buy order at the exchange
    /// @param orderAddresses Array of address values needed for each DEX order
    /// @param orderValues Array of uint values needed for each DEX order
    /// @param exchangeFee Value indicating the fee for this DEX order
    /// @param amountToFill Amount to fill in this order
    /// @param v ECDSA signature parameter v
    /// @param r ECDSA signature parameter r
    /// @param s ECDSA signature parameter s
    /// @return Amount filled in this order
    function performBuy(
        address[8] orderAddresses,
        uint256[6] orderValues,
        uint256 exchangeFee,
        uint256 amountToFill,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable returns (uint256);

    /// @dev Perform a sell order at the exchange
    /// @param orderAddresses Array of address values needed for each DEX order
    /// @param orderValues Array of uint values needed for each DEX order
    /// @param exchangeFee Value indicating the fee for this DEX order
    /// @param amountToFill Amount to fill in this order
    /// @param v ECDSA signature parameter v
    /// @param r ECDSA signature parameter r
    /// @param s ECDSA signature parameter s
    /// @return Amount filled in this order
    function performSell(
        address[8] orderAddresses,
        uint256[6] orderValues,
        uint256 exchangeFee,
        uint256 amountToFill,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256);
}

// File: contracts/ZeroExMock.sol

/*

  Copyright 2017 ZeroEx Intl.

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
 * Ownable
 *
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract ZXOwnable {
    address public owner;

    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract ZXToken {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

/// @title TokenTransferProxy - Transfers tokens on behalf of contracts that have been approved via decentralized governance.
/// @author Amir Bandeali - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bcddd1d5cefc8cc4ecced3d6d9dfc892dfd3d1">[email protected]</a>&gt;, Will Warren - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6b1c0207072b5b133b1904010e081f45080406">[email protected]</a>&gt;&#13;
contract ZeroExTokenTransferProxy is ZXOwnable {&#13;
&#13;
    /// @dev Only authorized addresses can invoke functions with this modifier.&#13;
    modifier onlyAuthorized {&#13;
        require(authorized[msg.sender]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier targetAuthorized(address target) {&#13;
        require(authorized[target]);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier targetNotAuthorized(address target) {&#13;
        require(!authorized[target]);&#13;
        _;&#13;
    }&#13;
&#13;
    mapping (address =&gt; bool) public authorized;&#13;
    address[] public authorities;&#13;
&#13;
    event LogAuthorizedAddressAdded(address indexed target, address indexed caller);&#13;
    event LogAuthorizedAddressRemoved(address indexed target, address indexed caller);&#13;
&#13;
    /*&#13;
     * Public functions&#13;
     */&#13;
&#13;
    /// @dev Authorizes an address.&#13;
    /// @param target Address to authorize.&#13;
    function addAuthorizedAddress(address target)&#13;
        public&#13;
        onlyOwner&#13;
        targetNotAuthorized(target)&#13;
    {&#13;
        authorized[target] = true;&#13;
        authorities.push(target);&#13;
        LogAuthorizedAddressAdded(target, msg.sender);&#13;
    }&#13;
&#13;
    /// @dev Removes authorizion of an address.&#13;
    /// @param target Address to remove authorization from.&#13;
    function removeAuthorizedAddress(address target)&#13;
        public&#13;
        onlyOwner&#13;
        targetAuthorized(target)&#13;
    {&#13;
        delete authorized[target];&#13;
        for (uint i = 0; i &lt; authorities.length; i++) {&#13;
            if (authorities[i] == target) {&#13;
                authorities[i] = authorities[authorities.length - 1];&#13;
                authorities.length -= 1;&#13;
                break;&#13;
            }&#13;
        }&#13;
        LogAuthorizedAddressRemoved(target, msg.sender);&#13;
    }&#13;
&#13;
    /// @dev Calls into ERC20 Token contract, invoking transferFrom.&#13;
    /// @param token Address of token to transfer.&#13;
    /// @param from Address to transfer token from.&#13;
    /// @param to Address to transfer token to.&#13;
    /// @param value Amount of token to transfer.&#13;
    /// @return Success of transfer.&#13;
    function transferFrom(&#13;
        address token,&#13;
        address from,&#13;
        address to,&#13;
        uint value)&#13;
        public&#13;
        onlyAuthorized&#13;
        returns (bool)&#13;
    {&#13;
        return ZXToken(token).transferFrom(from, to, value);&#13;
    }&#13;
&#13;
    /*&#13;
     * Public constant functions&#13;
     */&#13;
&#13;
    /// @dev Gets all authorized addresses.&#13;
    /// @return Array of authorized addresses.&#13;
    function getAuthorizedAddresses()&#13;
        public&#13;
        constant&#13;
        returns (address[])&#13;
    {&#13;
        return authorities;&#13;
    }&#13;
}&#13;
&#13;
contract ZXSafeMath {&#13;
    function safeMul(uint a, uint b) internal constant returns (uint256) {&#13;
        uint c = a * b;&#13;
        assert(a == 0 || c / a == b);&#13;
        return c;&#13;
    }&#13;
&#13;
    function safeDiv(uint a, uint b) internal constant returns (uint256) {&#13;
        uint c = a / b;&#13;
        return c;&#13;
    }&#13;
&#13;
    function safeSub(uint a, uint b) internal constant returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
&#13;
    function safeAdd(uint a, uint b) internal constant returns (uint256) {&#13;
        uint c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
&#13;
    function max64(uint64 a, uint64 b) internal constant returns (uint64) {&#13;
        return a &gt;= b ? a : b;&#13;
    }&#13;
&#13;
    function min64(uint64 a, uint64 b) internal constant returns (uint64) {&#13;
        return a &lt; b ? a : b;&#13;
    }&#13;
&#13;
    function max256(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
        return a &gt;= b ? a : b;&#13;
    }&#13;
&#13;
    function min256(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
        return a &lt; b ? a : b;&#13;
    }&#13;
}&#13;
&#13;
/// @title Exchange - Facilitates exchange of ERC20 tokens.&#13;
/// @author Amir Bandeali - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1d7c70746f5d2d654d6f7277787e69337e7270">[email protected]</a>&gt;, Will Warren - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1d6a7471715d2d654d6f7277787e69337e7270">[email protected]</a>&gt;&#13;
contract ZeroExExchange is ZXSafeMath {&#13;
&#13;
    // Error Codes&#13;
    enum Errors {&#13;
        ORDER_EXPIRED,                    // Order has already expired&#13;
        ORDER_FULLY_FILLED_OR_CANCELLED,  // Order has already been fully filled or cancelled&#13;
        ROUNDING_ERROR_TOO_LARGE,         // Rounding error too large&#13;
        INSUFFICIENT_BALANCE_OR_ALLOWANCE // Insufficient balance or allowance for token transfer&#13;
    }&#13;
&#13;
    string constant public VERSION = "1.0.0";&#13;
    uint16 constant public EXTERNAL_QUERY_GAS_LIMIT = 4999;    // Changes to state require at least 5000 gas&#13;
&#13;
    address public ZRX_TOKEN_CONTRACT;&#13;
    address public TOKEN_TRANSFER_PROXY_CONTRACT;&#13;
&#13;
    // Mappings of orderHash =&gt; amounts of takerTokenAmount filled or cancelled.&#13;
    mapping (bytes32 =&gt; uint) public filled;&#13;
    mapping (bytes32 =&gt; uint) public cancelled;&#13;
&#13;
    event LogFill(&#13;
        address indexed maker,&#13;
        address taker,&#13;
        address indexed feeRecipient,&#13;
        address makerToken,&#13;
        address takerToken,&#13;
        uint filledMakerTokenAmount,&#13;
        uint filledTakerTokenAmount,&#13;
        uint paidMakerFee,&#13;
        uint paidTakerFee,&#13;
        bytes32 indexed tokens, // keccak256(makerToken, takerToken), allows subscribing to a token pair&#13;
        bytes32 orderHash&#13;
    );&#13;
&#13;
    event LogCancel(&#13;
        address indexed maker,&#13;
        address indexed feeRecipient,&#13;
        address makerToken,&#13;
        address takerToken,&#13;
        uint cancelledMakerTokenAmount,&#13;
        uint cancelledTakerTokenAmount,&#13;
        bytes32 indexed tokens,&#13;
        bytes32 orderHash&#13;
    );&#13;
&#13;
    event LogError(uint8 indexed errorId, bytes32 indexed orderHash);&#13;
&#13;
    struct Order {&#13;
        address maker;&#13;
        address taker;&#13;
        address makerToken;&#13;
        address takerToken;&#13;
        address feeRecipient;&#13;
        uint makerTokenAmount;&#13;
        uint takerTokenAmount;&#13;
        uint makerFee;&#13;
        uint takerFee;&#13;
        uint expirationTimestampInSec;&#13;
        bytes32 orderHash;&#13;
    }&#13;
&#13;
    function ZeroExExchange(address _zrxToken, address _tokenTransferProxy) {&#13;
        ZRX_TOKEN_CONTRACT = _zrxToken;&#13;
        TOKEN_TRANSFER_PROXY_CONTRACT = _tokenTransferProxy;&#13;
    }&#13;
&#13;
    /*&#13;
    * Core exchange functions&#13;
    */&#13;
&#13;
    /// @dev Fills the input order.&#13;
    /// @param orderAddresses Array of order's maker, taker, makerToken, takerToken, and feeRecipient.&#13;
    /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, makerFee, takerFee, expirationTimestampInSec, and salt.&#13;
    /// @param fillTakerTokenAmount Desired amount of takerToken to fill.&#13;
    /// @param shouldThrowOnInsufficientBalanceOrAllowance Test if transfer will fail before attempting.&#13;
    /// @param v ECDSA signature parameter v.&#13;
    /// @param r ECDSA signature parameters r.&#13;
    /// @param s ECDSA signature parameters s.&#13;
    /// @return Total amount of takerToken filled in trade.&#13;
    function fillOrder(&#13;
          address[5] orderAddresses,&#13;
          uint[6] orderValues,&#13;
          uint fillTakerTokenAmount,&#13;
          bool shouldThrowOnInsufficientBalanceOrAllowance,&#13;
          uint8 v,&#13;
          bytes32 r,&#13;
          bytes32 s)&#13;
          public&#13;
          returns (uint filledTakerTokenAmount)&#13;
    {&#13;
        Order memory order = Order({&#13;
            maker: orderAddresses[0],&#13;
            taker: orderAddresses[1],&#13;
            makerToken: orderAddresses[2],&#13;
            takerToken: orderAddresses[3],&#13;
            feeRecipient: orderAddresses[4],&#13;
            makerTokenAmount: orderValues[0],&#13;
            takerTokenAmount: orderValues[1],&#13;
            makerFee: orderValues[2],&#13;
            takerFee: orderValues[3],&#13;
            expirationTimestampInSec: orderValues[4],&#13;
            orderHash: getOrderHash(orderAddresses, orderValues)&#13;
        });&#13;
&#13;
        require(order.taker == address(0) || order.taker == msg.sender);&#13;
        require(order.makerTokenAmount &gt; 0 &amp;&amp; order.takerTokenAmount &gt; 0 &amp;&amp; fillTakerTokenAmount &gt; 0);&#13;
        require(isValidSignature(&#13;
            order.maker,&#13;
            order.orderHash,&#13;
            v,&#13;
            r,&#13;
            s&#13;
        ));&#13;
&#13;
        if (block.timestamp &gt;= order.expirationTimestampInSec) {&#13;
            LogError(uint8(Errors.ORDER_EXPIRED), order.orderHash);&#13;
            return 0;&#13;
        }&#13;
&#13;
        uint remainingTakerTokenAmount = safeSub(order.takerTokenAmount, getUnavailableTakerTokenAmount(order.orderHash));&#13;
        filledTakerTokenAmount = min256(fillTakerTokenAmount, remainingTakerTokenAmount);&#13;
        if (filledTakerTokenAmount == 0) {&#13;
            LogError(uint8(Errors.ORDER_FULLY_FILLED_OR_CANCELLED), order.orderHash);&#13;
            return 0;&#13;
        }&#13;
&#13;
        if (isRoundingError(filledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount)) {&#13;
            LogError(uint8(Errors.ROUNDING_ERROR_TOO_LARGE), order.orderHash);&#13;
            return 0;&#13;
        }&#13;
&#13;
        if (!shouldThrowOnInsufficientBalanceOrAllowance &amp;&amp; !isTransferable(order, filledTakerTokenAmount)) {&#13;
            LogError(uint8(Errors.INSUFFICIENT_BALANCE_OR_ALLOWANCE), order.orderHash);&#13;
            return 0;&#13;
        }&#13;
&#13;
        uint filledMakerTokenAmount = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount);&#13;
        uint paidMakerFee;&#13;
        uint paidTakerFee;&#13;
        filled[order.orderHash] = safeAdd(filled[order.orderHash], filledTakerTokenAmount);&#13;
        require(transferViaTokenTransferProxy(&#13;
            order.makerToken,&#13;
            order.maker,&#13;
            msg.sender,&#13;
            filledMakerTokenAmount&#13;
        ));&#13;
        require(transferViaTokenTransferProxy(&#13;
            order.takerToken,&#13;
            msg.sender,&#13;
            order.maker,&#13;
            filledTakerTokenAmount&#13;
        ));&#13;
        if (order.feeRecipient != address(0)) {&#13;
            if (order.makerFee &gt; 0) {&#13;
                paidMakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.makerFee);&#13;
                require(transferViaTokenTransferProxy(&#13;
                    ZRX_TOKEN_CONTRACT,&#13;
                    order.maker,&#13;
                    order.feeRecipient,&#13;
                    paidMakerFee&#13;
                ));&#13;
            }&#13;
            if (order.takerFee &gt; 0) {&#13;
                paidTakerFee = getPartialAmount(filledTakerTokenAmount, order.takerTokenAmount, order.takerFee);&#13;
                require(transferViaTokenTransferProxy(&#13;
                    ZRX_TOKEN_CONTRACT,&#13;
                    msg.sender,&#13;
                    order.feeRecipient,&#13;
                    paidTakerFee&#13;
                ));&#13;
            }&#13;
        }&#13;
&#13;
        LogFill(&#13;
            order.maker,&#13;
            msg.sender,&#13;
            order.feeRecipient,&#13;
            order.makerToken,&#13;
            order.takerToken,&#13;
            filledMakerTokenAmount,&#13;
            filledTakerTokenAmount,&#13;
            paidMakerFee,&#13;
            paidTakerFee,&#13;
            keccak256(order.makerToken, order.takerToken),&#13;
            order.orderHash&#13;
        );&#13;
        return filledTakerTokenAmount;&#13;
    }&#13;
&#13;
    /// @dev Cancels the input order.&#13;
    /// @param orderAddresses Array of order's maker, taker, makerToken, takerToken, and feeRecipient.&#13;
    /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, makerFee, takerFee, expirationTimestampInSec, and salt.&#13;
    /// @param cancelTakerTokenAmount Desired amount of takerToken to cancel in order.&#13;
    /// @return Amount of takerToken cancelled.&#13;
    function cancelOrder(&#13;
        address[5] orderAddresses,&#13;
        uint[6] orderValues,&#13;
        uint cancelTakerTokenAmount)&#13;
        public&#13;
        returns (uint)&#13;
    {&#13;
        Order memory order = Order({&#13;
            maker: orderAddresses[0],&#13;
            taker: orderAddresses[1],&#13;
            makerToken: orderAddresses[2],&#13;
            takerToken: orderAddresses[3],&#13;
            feeRecipient: orderAddresses[4],&#13;
            makerTokenAmount: orderValues[0],&#13;
            takerTokenAmount: orderValues[1],&#13;
            makerFee: orderValues[2],&#13;
            takerFee: orderValues[3],&#13;
            expirationTimestampInSec: orderValues[4],&#13;
            orderHash: getOrderHash(orderAddresses, orderValues)&#13;
        });&#13;
&#13;
        require(order.maker == msg.sender);&#13;
        require(order.makerTokenAmount &gt; 0 &amp;&amp; order.takerTokenAmount &gt; 0 &amp;&amp; cancelTakerTokenAmount &gt; 0);&#13;
&#13;
        if (block.timestamp &gt;= order.expirationTimestampInSec) {&#13;
            LogError(uint8(Errors.ORDER_EXPIRED), order.orderHash);&#13;
            return 0;&#13;
        }&#13;
&#13;
        uint remainingTakerTokenAmount = safeSub(order.takerTokenAmount, getUnavailableTakerTokenAmount(order.orderHash));&#13;
        uint cancelledTakerTokenAmount = min256(cancelTakerTokenAmount, remainingTakerTokenAmount);&#13;
        if (cancelledTakerTokenAmount == 0) {&#13;
            LogError(uint8(Errors.ORDER_FULLY_FILLED_OR_CANCELLED), order.orderHash);&#13;
            return 0;&#13;
        }&#13;
&#13;
        cancelled[order.orderHash] = safeAdd(cancelled[order.orderHash], cancelledTakerTokenAmount);&#13;
&#13;
        LogCancel(&#13;
            order.maker,&#13;
            order.feeRecipient,&#13;
            order.makerToken,&#13;
            order.takerToken,&#13;
            getPartialAmount(cancelledTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount),&#13;
            cancelledTakerTokenAmount,&#13;
            keccak256(order.makerToken, order.takerToken),&#13;
            order.orderHash&#13;
        );&#13;
        return cancelledTakerTokenAmount;&#13;
    }&#13;
&#13;
    /*&#13;
    * Wrapper functions&#13;
    */&#13;
&#13;
    /// @dev Fills an order with specified parameters and ECDSA signature, throws if specified amount not filled entirely.&#13;
    /// @param orderAddresses Array of order's maker, taker, makerToken, takerToken, and feeRecipient.&#13;
    /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, makerFee, takerFee, expirationTimestampInSec, and salt.&#13;
    /// @param fillTakerTokenAmount Desired amount of takerToken to fill.&#13;
    /// @param v ECDSA signature parameter v.&#13;
    /// @param r ECDSA signature parameters r.&#13;
    /// @param s ECDSA signature parameters s.&#13;
    function fillOrKillOrder(&#13;
        address[5] orderAddresses,&#13;
        uint[6] orderValues,&#13;
        uint fillTakerTokenAmount,&#13;
        uint8 v,&#13;
        bytes32 r,&#13;
        bytes32 s)&#13;
        public&#13;
    {&#13;
        require(fillOrder(&#13;
            orderAddresses,&#13;
            orderValues,&#13;
            fillTakerTokenAmount,&#13;
            false,&#13;
            v,&#13;
            r,&#13;
            s&#13;
        ) == fillTakerTokenAmount);&#13;
    }&#13;
&#13;
    /// @dev Synchronously executes multiple fill orders in a single transaction.&#13;
    /// @param orderAddresses Array of address arrays containing individual order addresses.&#13;
    /// @param orderValues Array of uint arrays containing individual order values.&#13;
    /// @param fillTakerTokenAmounts Array of desired amounts of takerToken to fill in orders.&#13;
    /// @param shouldThrowOnInsufficientBalanceOrAllowance Test if transfers will fail before attempting.&#13;
    /// @param v Array ECDSA signature v parameters.&#13;
    /// @param r Array of ECDSA signature r parameters.&#13;
    /// @param s Array of ECDSA signature s parameters.&#13;
    function batchFillOrders(&#13;
        address[5][] orderAddresses,&#13;
        uint[6][] orderValues,&#13;
        uint[] fillTakerTokenAmounts,&#13;
        bool shouldThrowOnInsufficientBalanceOrAllowance,&#13;
        uint8[] v,&#13;
        bytes32[] r,&#13;
        bytes32[] s)&#13;
        public&#13;
    {&#13;
        for (uint i = 0; i &lt; orderAddresses.length; i++) {&#13;
            fillOrder(&#13;
                orderAddresses[i],&#13;
                orderValues[i],&#13;
                fillTakerTokenAmounts[i],&#13;
                shouldThrowOnInsufficientBalanceOrAllowance,&#13;
                v[i],&#13;
                r[i],&#13;
                s[i]&#13;
            );&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Synchronously executes multiple fillOrKill orders in a single transaction.&#13;
    /// @param orderAddresses Array of address arrays containing individual order addresses.&#13;
    /// @param orderValues Array of uint arrays containing individual order values.&#13;
    /// @param fillTakerTokenAmounts Array of desired amounts of takerToken to fill in orders.&#13;
    /// @param v Array ECDSA signature v parameters.&#13;
    /// @param r Array of ECDSA signature r parameters.&#13;
    /// @param s Array of ECDSA signature s parameters.&#13;
    function batchFillOrKillOrders(&#13;
        address[5][] orderAddresses,&#13;
        uint[6][] orderValues,&#13;
        uint[] fillTakerTokenAmounts,&#13;
        uint8[] v,&#13;
        bytes32[] r,&#13;
        bytes32[] s)&#13;
        public&#13;
    {&#13;
        for (uint i = 0; i &lt; orderAddresses.length; i++) {&#13;
            fillOrKillOrder(&#13;
                orderAddresses[i],&#13;
                orderValues[i],&#13;
                fillTakerTokenAmounts[i],&#13;
                v[i],&#13;
                r[i],&#13;
                s[i]&#13;
            );&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Synchronously executes multiple fill orders in a single transaction until total fillTakerTokenAmount filled.&#13;
    /// @param orderAddresses Array of address arrays containing individual order addresses.&#13;
    /// @param orderValues Array of uint arrays containing individual order values.&#13;
    /// @param fillTakerTokenAmount Desired total amount of takerToken to fill in orders.&#13;
    /// @param shouldThrowOnInsufficientBalanceOrAllowance Test if transfers will fail before attempting.&#13;
    /// @param v Array ECDSA signature v parameters.&#13;
    /// @param r Array of ECDSA signature r parameters.&#13;
    /// @param s Array of ECDSA signature s parameters.&#13;
    /// @return Total amount of fillTakerTokenAmount filled in orders.&#13;
    function fillOrdersUpTo(&#13;
        address[5][] orderAddresses,&#13;
        uint[6][] orderValues,&#13;
        uint fillTakerTokenAmount,&#13;
        bool shouldThrowOnInsufficientBalanceOrAllowance,&#13;
        uint8[] v,&#13;
        bytes32[] r,&#13;
        bytes32[] s)&#13;
        public&#13;
        returns (uint)&#13;
    {&#13;
        uint filledTakerTokenAmount = 0;&#13;
        for (uint i = 0; i &lt; orderAddresses.length; i++) {&#13;
            require(orderAddresses[i][3] == orderAddresses[0][3]); // takerToken must be the same for each order&#13;
            filledTakerTokenAmount = safeAdd(filledTakerTokenAmount, fillOrder(&#13;
                orderAddresses[i],&#13;
                orderValues[i],&#13;
                safeSub(fillTakerTokenAmount, filledTakerTokenAmount),&#13;
                shouldThrowOnInsufficientBalanceOrAllowance,&#13;
                v[i],&#13;
                r[i],&#13;
                s[i]&#13;
            ));&#13;
            if (filledTakerTokenAmount == fillTakerTokenAmount) break;&#13;
        }&#13;
        return filledTakerTokenAmount;&#13;
    }&#13;
&#13;
    /// @dev Synchronously cancels multiple orders in a single transaction.&#13;
    /// @param orderAddresses Array of address arrays containing individual order addresses.&#13;
    /// @param orderValues Array of uint arrays containing individual order values.&#13;
    /// @param cancelTakerTokenAmounts Array of desired amounts of takerToken to cancel in orders.&#13;
    function batchCancelOrders(&#13;
        address[5][] orderAddresses,&#13;
        uint[6][] orderValues,&#13;
        uint[] cancelTakerTokenAmounts)&#13;
        public&#13;
    {&#13;
        for (uint i = 0; i &lt; orderAddresses.length; i++) {&#13;
            cancelOrder(&#13;
                orderAddresses[i],&#13;
                orderValues[i],&#13;
                cancelTakerTokenAmounts[i]&#13;
            );&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
    * Constant public functions&#13;
    */&#13;
&#13;
    /// @dev Calculates Keccak-256 hash of order with specified parameters.&#13;
    /// @param orderAddresses Array of order's maker, taker, makerToken, takerToken, and feeRecipient.&#13;
    /// @param orderValues Array of order's makerTokenAmount, takerTokenAmount, makerFee, takerFee, expirationTimestampInSec, and salt.&#13;
    /// @return Keccak-256 hash of order.&#13;
    function getOrderHash(address[5] orderAddresses, uint[6] orderValues)&#13;
        public&#13;
        constant&#13;
        returns (bytes32)&#13;
    {&#13;
        return keccak256(&#13;
            address(this),&#13;
            orderAddresses[0], // maker&#13;
            orderAddresses[1], // taker&#13;
            orderAddresses[2], // makerToken&#13;
            orderAddresses[3], // takerToken&#13;
            orderAddresses[4], // feeRecipient&#13;
            orderValues[0],    // makerTokenAmount&#13;
            orderValues[1],    // takerTokenAmount&#13;
            orderValues[2],    // makerFee&#13;
            orderValues[3],    // takerFee&#13;
            orderValues[4],    // expirationTimestampInSec&#13;
            orderValues[5]     // salt&#13;
        );&#13;
    }&#13;
&#13;
    /// @dev Verifies that an order signature is valid.&#13;
    /// @param signer address of signer.&#13;
    /// @param hash Signed Keccak-256 hash.&#13;
    /// @param v ECDSA signature parameter v.&#13;
    /// @param r ECDSA signature parameters r.&#13;
    /// @param s ECDSA signature parameters s.&#13;
    /// @return Validity of order signature.&#13;
    function isValidSignature(&#13;
        address signer,&#13;
        bytes32 hash,&#13;
        uint8 v,&#13;
        bytes32 r,&#13;
        bytes32 s)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        return signer == ecrecover(&#13;
            keccak256("\x19Ethereum Signed Message:\n32", hash),&#13;
            v,&#13;
            r,&#13;
            s&#13;
        );&#13;
    }&#13;
&#13;
    /// @dev Checks if rounding error &gt; 0.1%.&#13;
    /// @param numerator Numerator.&#13;
    /// @param denominator Denominator.&#13;
    /// @param target Value to multiply with numerator/denominator.&#13;
    /// @return Rounding error is present.&#13;
    function isRoundingError(uint numerator, uint denominator, uint target)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        uint remainder = mulmod(target, numerator, denominator);&#13;
        if (remainder == 0) return false; // No rounding error.&#13;
&#13;
        uint errPercentageTimes1000000 = safeDiv(&#13;
            safeMul(remainder, 1000000),&#13;
            safeMul(numerator, target)&#13;
        );&#13;
        return errPercentageTimes1000000 &gt; 1000;&#13;
    }&#13;
&#13;
    /// @dev Calculates partial value given a numerator and denominator.&#13;
    /// @param numerator Numerator.&#13;
    /// @param denominator Denominator.&#13;
    /// @param target Value to calculate partial of.&#13;
    /// @return Partial value of target.&#13;
    function getPartialAmount(uint numerator, uint denominator, uint target)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        return safeDiv(safeMul(numerator, target), denominator);&#13;
    }&#13;
&#13;
    /// @dev Calculates the sum of values already filled and cancelled for a given order.&#13;
    /// @param orderHash The Keccak-256 hash of the given order.&#13;
    /// @return Sum of values already filled and cancelled.&#13;
    function getUnavailableTakerTokenAmount(bytes32 orderHash)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        return safeAdd(filled[orderHash], cancelled[orderHash]);&#13;
    }&#13;
&#13;
&#13;
    /*&#13;
    * Internal functions&#13;
    */&#13;
&#13;
    /// @dev Transfers a token using TokenTransferProxy transferFrom function.&#13;
    /// @param token Address of token to transferFrom.&#13;
    /// @param from Address transfering token.&#13;
    /// @param to Address receiving token.&#13;
    /// @param value Amount of token to transfer.&#13;
    /// @return Success of token transfer.&#13;
    function transferViaTokenTransferProxy(&#13;
        address token,&#13;
        address from,&#13;
        address to,&#13;
        uint value)&#13;
        internal&#13;
        returns (bool)&#13;
    {&#13;
        return ZeroExTokenTransferProxy(TOKEN_TRANSFER_PROXY_CONTRACT).transferFrom(token, from, to, value);&#13;
    }&#13;
&#13;
    /// @dev Checks if any order transfers will fail.&#13;
    /// @param order Order struct of params that will be checked.&#13;
    /// @param fillTakerTokenAmount Desired amount of takerToken to fill.&#13;
    /// @return Predicted result of transfers.&#13;
    function isTransferable(Order order, uint fillTakerTokenAmount)&#13;
        internal&#13;
        constant  // The called token contracts may attempt to change state, but will not be able to due to gas limits on getBalance and getAllowance.&#13;
        returns (bool)&#13;
    {&#13;
        address taker = msg.sender;&#13;
        uint fillMakerTokenAmount = getPartialAmount(fillTakerTokenAmount, order.takerTokenAmount, order.makerTokenAmount);&#13;
&#13;
        if (order.feeRecipient != address(0)) {&#13;
            bool isMakerTokenZRX = order.makerToken == ZRX_TOKEN_CONTRACT;&#13;
            bool isTakerTokenZRX = order.takerToken == ZRX_TOKEN_CONTRACT;&#13;
            uint paidMakerFee = getPartialAmount(fillTakerTokenAmount, order.takerTokenAmount, order.makerFee);&#13;
            uint paidTakerFee = getPartialAmount(fillTakerTokenAmount, order.takerTokenAmount, order.takerFee);&#13;
            uint requiredMakerZRX = isMakerTokenZRX ? safeAdd(fillMakerTokenAmount, paidMakerFee) : paidMakerFee;&#13;
            uint requiredTakerZRX = isTakerTokenZRX ? safeAdd(fillTakerTokenAmount, paidTakerFee) : paidTakerFee;&#13;
&#13;
            if (   getBalance(ZRX_TOKEN_CONTRACT, order.maker) &lt; requiredMakerZRX&#13;
                || getAllowance(ZRX_TOKEN_CONTRACT, order.maker) &lt; requiredMakerZRX&#13;
                || getBalance(ZRX_TOKEN_CONTRACT, taker) &lt; requiredTakerZRX&#13;
                || getAllowance(ZRX_TOKEN_CONTRACT, taker) &lt; requiredTakerZRX&#13;
            ) return false;&#13;
&#13;
            if (!isMakerTokenZRX &amp;&amp; (   getBalance(order.makerToken, order.maker) &lt; fillMakerTokenAmount // Don't double check makerToken if ZRX&#13;
                                     || getAllowance(order.makerToken, order.maker) &lt; fillMakerTokenAmount)&#13;
            ) return false;&#13;
            if (!isTakerTokenZRX &amp;&amp; (   getBalance(order.takerToken, taker) &lt; fillTakerTokenAmount // Don't double check takerToken if ZRX&#13;
                                     || getAllowance(order.takerToken, taker) &lt; fillTakerTokenAmount)&#13;
            ) return false;&#13;
        } else if (   getBalance(order.makerToken, order.maker) &lt; fillMakerTokenAmount&#13;
                   || getAllowance(order.makerToken, order.maker) &lt; fillMakerTokenAmount&#13;
                   || getBalance(order.takerToken, taker) &lt; fillTakerTokenAmount&#13;
                   || getAllowance(order.takerToken, taker) &lt; fillTakerTokenAmount&#13;
        ) return false;&#13;
&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Get token balance of an address.&#13;
    /// @param token Address of token.&#13;
    /// @param owner Address of owner.&#13;
    /// @return Token balance of owner.&#13;
    function getBalance(address token, address owner)&#13;
        internal&#13;
        constant  // The called token contract may attempt to change state, but will not be able to due to an added gas limit.&#13;
        returns (uint)&#13;
    {&#13;
        return Token(token).balanceOf.gas(EXTERNAL_QUERY_GAS_LIMIT)(owner); // Limit gas to prevent reentrancy&#13;
    }&#13;
&#13;
    /// @dev Get allowance of token given to TokenTransferProxy by an address.&#13;
    /// @param token Address of token.&#13;
    /// @param owner Address of owner.&#13;
    /// @return Allowance of token given to TokenTransferProxy by owner.&#13;
    function getAllowance(address token, address owner)&#13;
        internal&#13;
        constant  // The called token contract may attempt to change state, but will not be able to due to an added gas limit.&#13;
        returns (uint)&#13;
    {&#13;
        return Token(token).allowance.gas(EXTERNAL_QUERY_GAS_LIMIT)(owner, TOKEN_TRANSFER_PROXY_CONTRACT); // Limit gas to prevent reentrancy&#13;
    }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/math/SafeMath.sol&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
    c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    // uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return a / b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/ownership/Ownable.sol&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
&#13;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  function Ownable() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) public onlyOwner {&#13;
    require(newOwner != address(0));&#13;
    emit OwnershipTransferred(owner, newOwner);&#13;
    owner = newOwner;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  function totalSupply() public view returns (uint256);&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract Token is ERC20Basic {&#13;
  function allowance(address owner, address spender) public view returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
// File: contracts/ZeroExHandler.sol&#13;
&#13;
interface DepositToken {&#13;
    function deposit() external payable;&#13;
    function withdraw(uint amount) external payable;&#13;
    function balanceOf(address who) external returns(uint256);&#13;
}&#13;
&#13;
contract ZeroExHandler is ExchangeHandler, Ownable {&#13;
    address wethAddress;&#13;
    address public exchangeAddress;&#13;
    uint constant MAX_UINT = 2**256 - 1;&#13;
    mapping(address =&gt; bool) public tokenAllowanceSet;&#13;
&#13;
    event Order(&#13;
        address[8] addrs,&#13;
        uint256[6] values,&#13;
        uint256 value,&#13;
        address exc&#13;
    );&#13;
&#13;
    function ZeroExHandler(address _exchangeAddr, address _wethAddr) public {&#13;
        exchangeAddress = _exchangeAddr;&#13;
        wethAddress = _wethAddr;&#13;
    }&#13;
&#13;
    function() public payable { }&#13;
&#13;
    /*&#13;
     * Returns the remaining amount of the taker token available from this&#13;
     * order.&#13;
     */&#13;
    function getAvailableAmount(&#13;
        address[8] orderAddresses,&#13;
        uint256[6] orderValues,&#13;
        uint256 exchangeFee,&#13;
        uint8 v,&#13;
        bytes32 r,&#13;
        bytes32 s&#13;
    ) external returns (uint256) {&#13;
        if (!orderUsable(orderAddresses, orderValues)) {&#13;
            return 0;&#13;
        }&#13;
        address[5] memory newAddresses = convertAddressFormat(orderAddresses);&#13;
        bytes32 orderHash = ZeroExExchange(exchangeAddress).getOrderHash(newAddresses, orderValues);&#13;
        return SafeMath.sub(orderValues[1], ZeroExExchange(exchangeAddress).getUnavailableTakerTokenAmount(orderHash));&#13;
    }&#13;
&#13;
    /*&#13;
     * Spend ETH to acquire tokens&#13;
     */&#13;
    function performBuy(&#13;
        address[8] orderAddresses,&#13;
        uint256[6] orderValues,&#13;
        uint256 exchangeFee,&#13;
        uint256 amountToFill,&#13;
        uint8 v,&#13;
        bytes32 r,&#13;
        bytes32 s&#13;
    ) external payable returns (uint256) {&#13;
        require(orderUsable(orderAddresses, orderValues));&#13;
        require(orderAddresses[3] == wethAddress);&#13;
        require(amountToFill == msg.value);&#13;
        DepositToken(wethAddress).deposit.value(amountToFill)();&#13;
        address[5] memory newAddresses = convertAddressFormat(orderAddresses);&#13;
        bytes32 orderHash = ZeroExExchange(exchangeAddress).getOrderHash(newAddresses, orderValues);&#13;
        setAllowance(wethAddress);&#13;
        ZeroExExchange(exchangeAddress).fillOrder(newAddresses, orderValues, amountToFill, true, v, r, s);&#13;
        uint receivedAmount = getPartialAmount(amountToFill, orderValues[1], orderValues[0]);&#13;
        require(Token(newAddresses[2]).transfer(msg.sender, receivedAmount));&#13;
        return receivedAmount;&#13;
    }&#13;
&#13;
    /*&#13;
     * Spend tokens to acquire ETH&#13;
     */&#13;
    function performSell(&#13;
        address[8] orderAddresses,&#13;
        uint256[6] orderValues,&#13;
        uint256 exchangeFee,&#13;
        uint256 amountToFill,&#13;
        uint8 v,&#13;
        bytes32 r,&#13;
        bytes32 s&#13;
    ) external returns (uint256) {&#13;
        require(orderUsable(orderAddresses, orderValues));&#13;
        require(orderAddresses[2] == wethAddress);&#13;
        address[5] memory newAddresses = convertAddressFormat(orderAddresses);&#13;
        setAllowance(orderAddresses[3]);&#13;
        ZeroExExchange(exchangeAddress).fillOrder(newAddresses, orderValues, amountToFill, false, v, r, s);&#13;
        uint receivedAmount = getPartialAmount(amountToFill, orderValues[1], orderValues[0]);&#13;
        DepositToken(wethAddress).withdraw(receivedAmount);&#13;
        msg.sender.transfer(receivedAmount);&#13;
        return receivedAmount;&#13;
    }&#13;
&#13;
    function setAllowance(address token) internal {&#13;
        if(!tokenAllowanceSet[token]) {&#13;
            Token(token).approve(ZeroExExchange(exchangeAddress).TOKEN_TRANSFER_PROXY_CONTRACT(), MAX_UINT);&#13;
            tokenAllowanceSet[token] = true;&#13;
        }&#13;
    }&#13;
&#13;
    function orderUsable(&#13;
        address[8] orderAddresses,&#13;
        uint256[6] orderValues&#13;
    ) internal returns (bool) {&#13;
        return (&#13;
            (orderAddresses[1] == address(0) ||    // Order's taker is anybody&#13;
            orderAddresses[1] == address(this)) &amp;&amp; // Or the order's taker is this handler&#13;
            orderValues[3] == 0 &amp;&amp;                 // takerFees are 0&#13;
            orderValues[4] &gt; block.timestamp       // Order is not expired&#13;
        );&#13;
    }&#13;
&#13;
    function getPartialAmount(uint numerator, uint denominator, uint target)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        return SafeMath.div(SafeMath.mul(numerator, target), denominator);&#13;
    }&#13;
&#13;
    function convertAddressFormat(address[8] oldFormat) internal pure returns (address[5] newFormat) {&#13;
        for(uint256 i = 0; i &lt; newFormat.length; i++) {&#13;
            newFormat[i] = oldFormat[i];&#13;
        }&#13;
    }&#13;
}