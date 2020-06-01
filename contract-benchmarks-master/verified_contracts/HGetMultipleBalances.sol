/*

 Copyright 2018 RigoBlock, Rigo Investment Sagl.

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

interface Token {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);

    function balanceOf(address _who) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
}

/// @title Multiple Balances Helper - Allows to receive a list of pools for a specific group.
/// @author Gabriele Rigo - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="dbbcbab99ba9b2bcb4b9b7b4b8b0f5b8b4b6">[email protected]</a>&gt;&#13;
// solhint-disable-next-line&#13;
contract HGetMultipleBalances {&#13;
&#13;
    mapping (uint256 =&gt; address) private inLine;&#13;
    uint256 public numTokens = 0;&#13;
&#13;
    /*&#13;
     * CORE FUNCTIONS&#13;
     */&#13;
    /// @dev Allows associating a number to an address.&#13;
    /// @param _token Address of the target token.&#13;
    function addTokenAddress(&#13;
        address _token&#13;
        )&#13;
        external&#13;
    {&#13;
        ++numTokens;&#13;
        require (inLine[numTokens] == address(0));&#13;
        inLine[numTokens] = _token;&#13;
    }&#13;
&#13;
    /// @dev Allows associating a number to an address.&#13;
    /// @param _number Integer associated with the token address.&#13;
    /// @param _token Address of the target token.&#13;
    function numberToAddress(&#13;
        uint256 _number,&#13;
        address _token&#13;
        )&#13;
        external&#13;
    {&#13;
        require (inLine[_number] == address(0));&#13;
        inLine[_number] = _token;&#13;
    }&#13;
&#13;
    /*&#13;
     * PUBLIC VIEW FUNCTIONS&#13;
     */&#13;
    /// @dev Returns the token balance of an hodler.&#13;
    /// @param _token Address of the target token.&#13;
    /// @param _who Address of the target owner.&#13;
    /// @return Number of token balance.&#13;
    function getBalance(&#13;
        address _token,&#13;
        address _who&#13;
        )&#13;
        external&#13;
        view&#13;
        returns (uint256 amount)&#13;
    {&#13;
        amount = Token(_token).balanceOf(_who);&#13;
    }&#13;
&#13;
    /// @dev Returns positive token balance of an hodler.&#13;
    /// @param _tokenNumbers Addresses of the target token.&#13;
    /// @param _who Address of the target owner.&#13;
    /// @return Number of token balances and address of the token.&#13;
    function getMultiBalancesWithNumber(&#13;
        uint[] calldata _tokenNumbers,&#13;
        address _who&#13;
        )&#13;
        external&#13;
        view&#13;
        returns (&#13;
            uint256[] memory balances,&#13;
            address[] memory tokenAddresses&#13;
        )&#13;
    {&#13;
        uint256 length = _tokenNumbers.length;&#13;
        balances = new uint256[](length);&#13;
        tokenAddresses = new address[](length);&#13;
        for (uint256 i = 1; i &lt;= length; i++) {&#13;
            address targetToken = getAddressFromNumber(i);&#13;
            Token token = Token(targetToken);&#13;
            uint256 amount = token.balanceOf(_who);&#13;
            if (amount == 0) continue;&#13;
            balances[i] = amount;&#13;
            tokenAddresses[i] = targetToken;&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Returns positive token balance of an hodler.&#13;
    /// @param _who Address of the target owner.&#13;
    /// @return Array of numbers of token balances and address of the tokens.&#13;
    function getMultiBalances(&#13;
        address _who&#13;
        )&#13;
        external&#13;
        view&#13;
        returns (&#13;
            uint256[] memory balances,&#13;
            address[] memory tokenAddresses&#13;
        )&#13;
    {&#13;
        uint256 length = numTokens;&#13;
        balances = new uint256[](length);&#13;
        tokenAddresses = new address[](length);&#13;
        for (uint256 i = 1; i &lt;= length; i++) {&#13;
            address targetToken = getAddressFromNumber(i);&#13;
            Token token = Token(targetToken);&#13;
            uint256 amount = token.balanceOf(_who);&#13;
            if (amount == 0) continue;&#13;
            balances[i] = amount;&#13;
            tokenAddresses[i] = targetToken;&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Returns token balances of an hodler.&#13;
    /// @param _tokenAddresses Array of token addresses.&#13;
    /// @param _who Address of the target holder.&#13;
    /// @return Array of numbers of token balances of the tokens.&#13;
    function getMultiBalancesFromAddresses(&#13;
        address[] calldata _tokenAddresses,&#13;
        address _who)&#13;
        external&#13;
        view&#13;
        returns (uint256[] memory balances)&#13;
    {&#13;
        uint256 length = _tokenAddresses.length;&#13;
        balances = new uint256[](length);&#13;
        for (uint256 i = 0; i &lt; length; i++) {&#13;
            address targetToken = _tokenAddresses[i];&#13;
            Token token = Token(targetToken);&#13;
            uint256 amount = token.balanceOf(_who);&#13;
            balances[i] = amount;&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Returns token balances of an hodler.&#13;
    /// @param _tokenAddresses Array of token addresses.&#13;
    /// @param _who Address of the target holder.&#13;
    /// @return Array of numbers of token balances and addresses of the tokens.&#13;
    function getMultiBalancesAndAddressesFromAddresses(&#13;
        address[] calldata _tokenAddresses,&#13;
        address _who)&#13;
        external&#13;
        view&#13;
        returns (&#13;
            uint256[] memory balances,&#13;
            address[] memory tokenAddresses&#13;
        )&#13;
    {&#13;
        uint256 length = _tokenAddresses.length;&#13;
        balances = new uint256[](length);&#13;
        tokenAddresses = new address[](length);&#13;
        for (uint256 i = 0; i &lt; length; i++) {&#13;
            address targetToken = _tokenAddresses[i];&#13;
            Token token = Token(targetToken);&#13;
            uint256 amount = token.balanceOf(_who);&#13;
            balances[i] = amount;&#13;
            tokenAddresses[i] = targetToken;&#13;
        }&#13;
    }&#13;
    &#13;
    /// @dev Returns only positive token balances of an hodler.&#13;
    /// @param _tokenAddresses Array of token addresses.&#13;
    /// @param _who Address of the target holder.&#13;
    /// @return Array of numbers of token balances and addresses of the tokens.&#13;
    function getPositiveBalancesAndAddressesFromAddresses(&#13;
        address[] calldata _tokenAddresses,&#13;
        address _who)&#13;
        external&#13;
        view&#13;
        returns (&#13;
            uint256[] memory balances,&#13;
            address[] memory tokenAddresses&#13;
        )&#13;
    {&#13;
        uint256 length = _tokenAddresses.length;&#13;
        balances = new uint256[](length);&#13;
        tokenAddresses = new address[](length);&#13;
        for (uint256 i = 0; i &lt; length; i++) {&#13;
            address targetToken = _tokenAddresses[i];&#13;
            Token token = Token(targetToken);&#13;
            uint256 amount = token.balanceOf(_who);&#13;
            if (amount == 0) continue;&#13;
            balances[i] = amount;&#13;
            tokenAddresses[i] = targetToken;&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * INTERNAL FUNCTIONS&#13;
     */&#13;
    /// @dev Returns an address from a number.&#13;
    /// @param _number Number of the token in the token array.&#13;
    /// @return Address of the token.&#13;
    function getAddressFromNumber(&#13;
        uint256 _number)&#13;
        internal&#13;
        view&#13;
        returns (address)&#13;
    {&#13;
        return(inLine[_number]);&#13;
    }&#13;
}