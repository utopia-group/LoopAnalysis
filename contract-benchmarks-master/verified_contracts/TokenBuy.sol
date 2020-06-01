pragma solidity 0.4.23;

// File: contracts/ACOTokenCrowdsale.sol

interface ACOTokenCrowdsale {
    function buyTokens(address beneficiary) external payable;
    function hasEnded() external view returns (bool);
}

// File: contracts/lib/DS-Math.sol

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.4.23;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    // function max(uint x, uint y) internal pure returns (uint z) {
    //     return x >= y ? x : y;
    // }
    // function imin(int x, int y) internal pure returns (int z) {
    //     return x <= y ? x : y;
    // }
    // function imax(int x, int y) internal pure returns (int z) {
    //     return x >= y ? x : y;
    // }

    // uint constant WAD = 10 ** 18;
    // uint constant RAY = 10 ** 27;

    // function wmul(uint x, uint y) internal pure returns (uint z) {
    //     z = add(mul(x, y), WAD / 2) / WAD;
    // }
    // function rmul(uint x, uint y) internal pure returns (uint z) {
    //     z = add(mul(x, y), RAY / 2) / RAY;
    // }
    // function wdiv(uint x, uint y) internal pure returns (uint z) {
    //     z = add(mul(x, WAD), y / 2) / y;
    // }
    // function rdiv(uint x, uint y) internal pure returns (uint z) {
    //     z = add(mul(x, RAY), y / 2) / y;
    // }

    // // This famous algorithm is called "exponentiation by squaring"
    // // and calculates x^n with x as fixed-point and n as regular unsigned.
    // //
    // // It's O(log n), instead of O(n) for naive repeated multiplication.
    // //
    // // These facts are why it works:
    // //
    // //  If n is even, then x^n = (x^2)^(n/2).
    // //  If n is odd,  then x^n = x * x^(n-1),
    // //   and applying the equation for even x gives
    // //    x^n = x * (x^2)^((n-1) / 2).
    // //
    // //  Also, EVM division is flooring and
    // //    floor[(n-1) / 2] = floor[n / 2].
    // //
    // function rpow(uint x, uint n) internal pure returns (uint z) {
    //     z = n % 2 != 0 ? x : RAY;

    //     for (n /= 2; n != 0; n /= 2) {
    //         x = rmul(x, x);

    //         if (n % 2 != 0) {
    //             z = rmul(z, x);
    //         }
    //     }
    // }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/lifecycle/TokenDestructible.sol

/**
 * @title TokenDestructible:
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="87f5e2eae4e8c7b5">[email protected]</a>π.com&gt;&#13;
 * @dev Base contract that can be destroyed by owner. All funds in contract including&#13;
 * listed tokens will be sent to the owner.&#13;
 */&#13;
contract TokenDestructible is Ownable {&#13;
&#13;
  constructor() public payable { }&#13;
&#13;
  /**&#13;
   * @notice Terminate contract and refund to owner&#13;
   * @param tokens List of addresses of ERC20 or ERC20Basic token contracts to&#13;
   refund.&#13;
   * @notice The called token contracts could try to re-enter this contract. Only&#13;
   supply token contracts you trust.&#13;
   */&#13;
  function destroy(address[] tokens) onlyOwner public {&#13;
&#13;
    // Transfer tokens to owner&#13;
    for (uint256 i = 0; i &lt; tokens.length; i++) {&#13;
      ERC20Basic token = ERC20Basic(tokens[i]);&#13;
      uint256 balance = token.balanceOf(this);&#13;
      token.transfer(owner, balance);&#13;
    }&#13;
&#13;
    // Transfer Eth to owner and terminate contract&#13;
    selfdestruct(owner);&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/ownership/Claimable.sol&#13;
&#13;
/**&#13;
 * @title Claimable&#13;
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.&#13;
 * This allows the new owner to accept the transfer.&#13;
 */&#13;
contract Claimable is Ownable {&#13;
  address public pendingOwner;&#13;
&#13;
  /**&#13;
   * @dev Modifier throws if called by any account other than the pendingOwner.&#13;
   */&#13;
  modifier onlyPendingOwner() {&#13;
    require(msg.sender == pendingOwner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to set the pendingOwner address.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) onlyOwner public {&#13;
    pendingOwner = newOwner;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the pendingOwner address to finalize the transfer.&#13;
   */&#13;
  function claimOwnership() onlyPendingOwner public {&#13;
    emit OwnershipTransferred(owner, pendingOwner);&#13;
    owner = pendingOwner;&#13;
    pendingOwner = address(0);&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender)&#13;
    public view returns (uint256);&#13;
&#13;
  function transferFrom(address from, address to, uint256 value)&#13;
    public returns (bool);&#13;
&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(&#13;
    address indexed owner,&#13;
    address indexed spender,&#13;
    uint256 value&#13;
  );&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol&#13;
&#13;
/**&#13;
 * @title SafeERC20&#13;
 * @dev Wrappers around ERC20 operations that throw on failure.&#13;
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,&#13;
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.&#13;
 */&#13;
library SafeERC20 {&#13;
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {&#13;
    require(token.transfer(to, value));&#13;
  }&#13;
&#13;
  function safeTransferFrom(&#13;
    ERC20 token,&#13;
    address from,&#13;
    address to,&#13;
    uint256 value&#13;
  )&#13;
    internal&#13;
  {&#13;
    require(token.transferFrom(from, to, value));&#13;
  }&#13;
&#13;
  function safeApprove(ERC20 token, address spender, uint256 value) internal {&#13;
    require(token.approve(spender, value));&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/TokenBuy.sol&#13;
&#13;
/// @title Group-buy contract for Token ICO&#13;
/// @author Joe Wasson&#13;
/// @notice Allows for group purchase of the Token ICO. This is done&#13;
///   in two phases:&#13;
///     a) contributions initiate a purchase on demand.&#13;
///     b) tokens are collected when they are unfrozen&#13;
contract TokenBuy is Pausable, Claimable, TokenDestructible, DSMath {&#13;
    using SafeERC20 for ERC20Basic;&#13;
&#13;
    /// @notice Token ICO contract&#13;
    ACOTokenCrowdsale public crowdsaleContract;&#13;
&#13;
    /// @notice Token contract&#13;
    ERC20Basic public tokenContract;&#13;
&#13;
    /// @notice Map of contributors and their token balances&#13;
    mapping(address =&gt; uint) public balances;&#13;
&#13;
    /// @notice List of contributors to the sale&#13;
    address[] public contributors;&#13;
&#13;
    /// @notice Total amount contributed to the sale&#13;
    uint public totalContributions;&#13;
&#13;
    /// @notice Total number of tokens purchased&#13;
    uint public totalTokensPurchased;&#13;
&#13;
    /// @notice Emitted whenever a contribution is made&#13;
    event Purchase(address indexed sender, uint ethAmount, uint tokensPurchased);&#13;
&#13;
    /// @notice Emitted whenever tokens are collected fromthe contract&#13;
    event Collection(address indexed recipient, uint amount);&#13;
&#13;
    /// @notice Time when locked funds in the contract can be retrieved.&#13;
    uint constant unlockTime = 1543622400; // 2018-12-01 00:00:00 GMT&#13;
&#13;
    /// @notice Guards against executing the function if the sale&#13;
    ///    is not running.&#13;
    modifier whenSaleRunning() {&#13;
        require(!crowdsaleContract.hasEnded());&#13;
        _;&#13;
    }&#13;
&#13;
    /// @param crowdsale the Crowdsale contract (or a wrapper around it)&#13;
    /// @param token the token contract&#13;
    constructor(ACOTokenCrowdsale crowdsale, ERC20Basic token) public {&#13;
        require(crowdsale != address(0x0));&#13;
        require(token != address(0x0));&#13;
        crowdsaleContract = crowdsale;&#13;
        tokenContract = token;&#13;
    }&#13;
&#13;
    /// @notice returns the number of contributors in the list of contributors&#13;
    /// @return count of contributors&#13;
    /// @dev As the `collectAll` function is called the contributor array is cleaned up&#13;
    ///     consequently this method only returns the remaining contributor count.&#13;
    function contributorCount() public view returns (uint) {&#13;
        return contributors.length;&#13;
    }&#13;
&#13;
    /// @dev Dispatches between buying and collecting&#13;
    function() public payable {&#13;
        if (msg.value == 0) {&#13;
            collectFor(msg.sender);&#13;
        } else {&#13;
            buy();&#13;
        }&#13;
    }&#13;
&#13;
    /// @notice Executes a purchase.&#13;
    function buy() whenNotPaused whenSaleRunning private {&#13;
        address buyer = msg.sender;&#13;
        totalContributions += msg.value;&#13;
        uint tokensPurchased = purchaseTokens();&#13;
        totalTokensPurchased = add(totalTokensPurchased, tokensPurchased);&#13;
&#13;
        uint previousBalance = balances[buyer];&#13;
        balances[buyer] = add(previousBalance, tokensPurchased);&#13;
&#13;
        // new contributor&#13;
        if (previousBalance == 0) {&#13;
            contributors.push(buyer);&#13;
        }&#13;
&#13;
        emit Purchase(buyer, msg.value, tokensPurchased);&#13;
    }&#13;
&#13;
    function purchaseTokens() private returns (uint tokensPurchased) {&#13;
        address me = address(this);&#13;
        uint previousBalance = tokenContract.balanceOf(me);&#13;
        crowdsaleContract.buyTokens.value(msg.value)(me);&#13;
        uint newBalance = tokenContract.balanceOf(me);&#13;
&#13;
        require(newBalance &gt; previousBalance); // Fail on underflow or purchase of 0&#13;
        return newBalance - previousBalance;&#13;
    }&#13;
&#13;
    /// @notice Allows users to collect purchased tokens after the sale.&#13;
    /// @param recipient the address to collect tokens for&#13;
    /// @dev Here we don't transfer zero tokens but this is an arbitrary decision.&#13;
    function collectFor(address recipient) private {&#13;
        uint tokensOwned = balances[recipient];&#13;
        if (tokensOwned == 0) return;&#13;
&#13;
        delete balances[recipient];&#13;
        tokenContract.safeTransfer(recipient, tokensOwned);&#13;
        emit Collection(recipient, tokensOwned);&#13;
    }&#13;
&#13;
    /// @notice Collects the balances for members of the purchase&#13;
    /// @param max the maximum number of members to process (for gas purposes)&#13;
    function collectAll(uint8 max) public returns (uint8 collected) {&#13;
        max = uint8(min(max, contributors.length));&#13;
        require(max &gt; 0, "can't collect for zero users");&#13;
&#13;
        uint index = contributors.length - 1;&#13;
        for(uint offset = 0; offset &lt; max; ++offset) {&#13;
            address recipient = contributors[index - offset];&#13;
&#13;
            if (balances[recipient] &gt; 0) {&#13;
                collected++;&#13;
                collectFor(recipient);&#13;
            }&#13;
        }&#13;
&#13;
        contributors.length -= offset;&#13;
    }&#13;
&#13;
    /// @notice Shuts down the contract&#13;
    function destroy(address[] tokens) onlyOwner public {&#13;
        require(now &gt; unlockTime || (contributorCount() == 0 &amp;&amp; paused));&#13;
&#13;
        super.destroy(tokens);&#13;
    }&#13;
}