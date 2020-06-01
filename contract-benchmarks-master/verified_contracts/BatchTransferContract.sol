pragma solidity ^0.4.11;

library Math {
  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/// @title Loopring Refund Program
/// @author Kongliang Zhong - <<span class="__cf_email__" data-cfemail="741f1b1a13181d151a1334181b1b04061d1a135a1b0613">[email protected]</span>&gt;.&#13;
/// For more information, please visit https://loopring.org.&#13;
contract BatchTransferContract {&#13;
    using SafeMath for uint;&#13;
    using Math for uint;&#13;
&#13;
    address public owner;&#13;
&#13;
    function BatchTransferContract(address _owner) public {&#13;
        owner = _owner;&#13;
    }&#13;
&#13;
    function () payable {&#13;
        // do nothing.&#13;
    }&#13;
&#13;
    function batchRefund(address[] investors, uint[] ethAmounts) public payable {&#13;
        require(msg.sender == owner);&#13;
        require(investors.length &gt; 0);&#13;
        require(investors.length == ethAmounts.length);&#13;
&#13;
        uint total = 0;&#13;
        for (uint i = 0; i &lt; investors.length; i++) {&#13;
            total += ethAmounts[i];&#13;
        }&#13;
&#13;
        require(total &lt;= this.balance);&#13;
&#13;
        for (i = 0; i &lt; investors.length; i++) {&#13;
            if (ethAmounts[i] &gt; 0) {&#13;
                investors[i].transfer(ethAmounts[i]);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function drain(uint ethAmount) public payable {&#13;
        require(msg.sender == owner);&#13;
&#13;
        uint amount = ethAmount.min256(this.balance);&#13;
        if (amount &gt; 0) {&#13;
          owner.transfer(amount);&#13;
        }&#13;
    }&#13;
}