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


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

/// @title UintUtil
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="086c6966616d6448646767787a61666f26677a6f">[email protected]</a>&gt;&#13;
/// @dev uint utility functions&#13;
library UintLib {&#13;
    using SafeMath  for uint;&#13;
&#13;
    function tolerantSub(uint x, uint y) constant returns (uint z) {&#13;
        if (x &gt;= y) z = x - y;&#13;
        else z = 0;&#13;
    }&#13;
&#13;
    function next(uint i, uint size) internal constant returns (uint) {&#13;
        return (i + 1) % size;&#13;
    }&#13;
&#13;
    function prev(uint i, uint size) internal constant returns (uint) {&#13;
        return (i + size - 1) % size;&#13;
    }&#13;
&#13;
    /// @dev calculate the square of Coefficient of Variation (CV)&#13;
    /// https://en.wikipedia.org/wiki/Coefficient_of_variation&#13;
    function cvsquare(&#13;
        uint[] arr,&#13;
        uint scale&#13;
        )&#13;
        internal&#13;
        constant&#13;
        returns (uint) {&#13;
&#13;
        uint len = arr.length;&#13;
        require(len &gt; 1);&#13;
        require(scale &gt; 0);&#13;
&#13;
        uint avg = 0;&#13;
        for (uint i = 0; i &lt; len; i++) {&#13;
            avg += arr[i];&#13;
        }&#13;
&#13;
        avg = avg.div(len);&#13;
&#13;
        if (avg == 0) {&#13;
            return 0;&#13;
        }&#13;
&#13;
        uint cvs = 0;&#13;
        for (i = 0; i &lt; len; i++) {&#13;
            uint sub = 0;&#13;
            if (arr[i] &gt; avg) {&#13;
                sub = arr[i] - avg;&#13;
            } else {&#13;
                sub = avg - arr[i];&#13;
            }&#13;
            cvs += sub.mul(sub);&#13;
        }&#13;
        return cvs&#13;
            .mul(scale)&#13;
            .div(avg)&#13;
            .mul(scale)&#13;
            .div(avg)&#13;
            .div(len - 1);&#13;
    }&#13;
}