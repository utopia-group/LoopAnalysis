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

/// @title Airdrop Helper - Allows to send GRGs to multiple users.
/// @author Gabriele Rigo - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d0b7b1b290a2b9b7bfb2bcbfb3bbfeb3bfbd">[email protected]</a>&gt;&#13;
// solhint-disable-next-line&#13;
contract HSendBatchTokens {&#13;
    &#13;
    mapping (address =&gt; mapping (address =&gt; bool)) private wasAirdropped;&#13;
&#13;
    /*&#13;
     * CORE FUNCTIONS&#13;
     */&#13;
    /// @dev Allows sending 1 ERC20 standard token with 18 decimals to a group of accounts.&#13;
    /// @param _targets Array of target addresses.&#13;
    /// @param _token Address of the target token.&#13;
    /// @return Bool the transaction was successful.&#13;
    function sendBatchTokens(&#13;
        address[] calldata _targets,&#13;
        address _token)&#13;
        external&#13;
        returns (bool success)&#13;
    {&#13;
        uint256 length = _targets.length;&#13;
        uint256 amount = 1 * 10 ** 18;&#13;
        Token token = Token(_token);&#13;
        require(&#13;
            token.transferFrom(&#13;
                msg.sender,&#13;
                address(this),&#13;
                (amount * length)&#13;
            )&#13;
        );&#13;
        for (uint256 i = 0; i &lt; length; i++) {&#13;
            if (token.balanceOf(_targets[i]) &gt; uint256(0)) continue;&#13;
            if(wasAirdropped[_token][_targets[i]]) continue;&#13;
            wasAirdropped[_token][_targets[i]] = true;&#13;
            require(&#13;
                token.transfer(&#13;
                    _targets[i],&#13;
                    amount&#13;
                )&#13;
            );&#13;
        }&#13;
        if (token.balanceOf(address(this)) &gt; uint256(0)) {&#13;
            require(&#13;
                token.transfer(&#13;
                    msg.sender,&#13;
                    token.balanceOf(address(this))&#13;
                )&#13;
            );&#13;
        }&#13;
        success = true;&#13;
    }&#13;
    &#13;
    /*&#13;
     * EXTERNAL VIEW FUNCTIONS&#13;
     */&#13;
    /// @dev Returns wether an account has been airdropped a specific token.&#13;
    /// @param _token Address of the target token.&#13;
    /// @param _target Address of the target holder.&#13;
    /// @return Bool the transaction was successful.&#13;
    function hasReceivedAirdrop(&#13;
        address _token,&#13;
        address _target)&#13;
        external&#13;
        view&#13;
        returns (bool)&#13;
    {&#13;
        return wasAirdropped[_token][_target];&#13;
    }&#13;
}