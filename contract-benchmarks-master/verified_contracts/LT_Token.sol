pragma solidity ^0.4.25;

/*
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d1f0f0f0f091">[email protected]</a>@@@@@@@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f9d8d8d8d8b9">[email protected]</a>@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@@@@    @@@@@@@@@@@@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@---;@@    @@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="022f2f2f42">[email protected]</a>@    @@@@@@@@@@@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="765b36">[email protected]</a>@@@@@*@@@@@@@@@@@@@@@. @@@@@@@@@@@     @@@@@@@@@@@@@@@@@@@@  @@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="466706">[email protected]</a>@@@@&#13;
@@@@@---#@@   <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d6fb96">[email protected]</a>@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e3cececea3">[email protected]</a>@~   @@@@@@@@@@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fcd1bc">[email protected]</a>@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="476307">[email protected]</a>@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="446a04">[email protected]</a>@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="795439">[email protected]</a>@@. @@@@@@@@@@@ @@@ :@@@@@@@@@@@@@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="351875">[email protected]</a>@@  @@@@@@&#13;
@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="efc2c2c2af">[email protected]</a>@*   #@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="062b2b2b46">[email protected]</a>@@   <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1d205d">[email protected]</a>@@@@@@@@@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="547914">[email protected]</a>@@@@@@@@@@ @@@@@ @@@@. @@@@@@@@@@@ @@@  @@@@@@@@@@@@@@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0a2e4a">[email protected]</a>  @@@@@@@&#13;
@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="220f0f0f62">[email protected]</a>@.   ---*@@   ,@@@@@@@@@@@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c0ed80">[email protected]</a>@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="674327">[email protected]</a>@    @@    @@. @@@*   @@@@ @@@ #@@@@   @@@@@   @@@@@@*   @@@@@@@@&#13;
@@@@@@@*<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a4898989e4">[email protected]</a>@    <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d2ffac92">[email protected]</a>@    @@@@@@@@@@@@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="250865">[email protected]</a>@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e0c4a0">[email protected]</a>@@ @@@@@ @@@@. @@@ @@- @@@    :@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="614521">[email protected]</a># @@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a19ce1">[email protected]</a>@ @@@@@@  @@@@@@@@@&#13;
@@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="bbc59696c5fb">[email protected]</a>@    @@    @@@@@@@@@@@@@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c9e489">[email protected]</a>@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1b3f5b">[email protected]</a>@@ @@@@@ @@@@. @@  @@@ @@@ @@@  @@# @@@ @@@ @@@ @@@@@$   @@@@@@@@&#13;
@@@@@@@@@---*@-    .   @@@@@@@@@@@@@@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fed3be">[email protected]</a>@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a581e5">[email protected]</a>@@ @@@@@ @@@@. @@  @@@@@@@ @@@@ *@$ @@@@@@# @@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="eccdac">[email protected]</a>  @@@@@@@&#13;
@@@@@@@@@@------      @@@@@@@@@@@@@@@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f7dab7">[email protected]</a>@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a783e7">[email protected]</a>@@ @@@@@ @@@@. @@$ @@@@@@@ @@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="634723">[email protected]</a>@ @@@@@@@ @@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3d137d">[email protected]</a>@@ ,@@@@@@&#13;
@@@@@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7d505050503d">[email protected]</a>*    <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="467b06">[email protected]</a>@@@@@@@@@@@@@@@@@@@@@     <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="391779">[email protected]</a>@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c4e084">[email protected]</a>@@   @@@   @@. @@@     @@@      @@@     @@@     @@@  @@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8bafcb">[email protected]</a>@@@@&#13;
@@@@@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b39e9e9e9ef3">[email protected]</a>@    @@@@@@@@@@@@@@@@@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fa84848484dbba">[email protected]</a>@@~#@@@@:<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7a473a">[email protected]</a>@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b9c784f9">[email protected]</a>@:<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="176957">[email protected]</a>@@@$~*@@@@~~~:@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ceb0ef8e">[email protected]</a>@@@@@~;@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c4baba84">[email protected]</a>@@@@@*<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="394779">[email protected]</a>@@@@&#13;
@@@@@@@@@@~-----      @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@@@@;---~-        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@@@#<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8ea3a3a3ce">[email protected]</a>@    @@    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2b0606066b">[email protected]</a>@.   <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ddf09d">[email protected]</a>@@   <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="601e20">[email protected]</a>@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="507d7d7d10">[email protected]</a>@=   ,<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="be9393fe">[email protected]</a>@=   #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c1ecececfc81">[email protected]</a>@   <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f1dfb1dcdcdc">[email protected]</a>@@.   @@@@@@@@@@@@@@@@@@;@=#@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="795439">[email protected]</a>@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8aabcaa4">[email protected]</a>@@! @<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0d734d23">[email protected]</a>@@#*@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="775937">[email protected]</a>@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2f026f">[email protected]</a>@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f9c4d7b9">[email protected]</a>@@@@@#@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6e102e">[email protected]</a>@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="d7f697f9">[email protected]</a>@@:@@@:@ @@,@@@@*@ @@@@@&#13;
@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5c227171221c">[email protected]</a>@    @@*<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ac818181ec">[email protected]</a>@    @@@@@@@@@@@@@@@@@;@$#@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="542a14">[email protected]</a>@@@@@@@@ ,@@@@@@*@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a38de3">[email protected]</a><a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e5d8a5">[email protected]</a>@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="19243759">[email protected]</a>@@@@@*@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2e506e">[email protected]</a>@@@@@. #@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="98e6b5d8">[email protected]</a>@@@ @@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="133d53">[email protected]</a>@@@@@&#13;
@@@@;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a8858585e8">[email protected]</a>@    @@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="522c7f7f2c12">[email protected]</a>@    @@@@@@@@@@@@@@@@;@ #@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2a076a">[email protected]</a>@@@@@@@@ <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="760836">[email protected]</a>#@@@@*@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="16385638">[email protected]</a>, @<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="635e4d23">[email protected]</a><a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="052145">[email protected]</a>@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="416501">[email protected]</a>@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="406d00">[email protected]</a>@@@@@@@#@@@@,, @@@,@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="654825">[email protected]</a>@@@@@&#13;
@@@#<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="91bcbcbcd1">[email protected]</a>@    @@@@@@---*@@    @@@@@@@@@@@@@@@;@,#@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="fedfbe">[email protected]</a>@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="270a67">[email protected]</a> @@$ @,@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="83aec3">[email protected]</a>@#*@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="775937">[email protected]</a>@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b18c9ff1">[email protected]</a>@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="90eed0">[email protected]</a>@@*@@@@*@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ee90ae">[email protected]</a>@@@#@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e1c0a1">[email protected]</a>@@@@@@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="89a8c9">[email protected]</a>@<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5d701d">[email protected]</a>@@@@@&#13;
@@@@@@@@.   @@@@@@@@@@@@@@   <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b8c6f8">[email protected]</a>@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@@@;;;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e6c2a6">[email protected]</a>@@@@@@@@@@@@@=;;;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
Forever young:@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
DEFENG XU/LARRY YE/COINSSUL SKY/MR GUO/YIRANG ZHANG/MINGCONG WU/YIMING WANG/YANPENG ZHANG/HUANKAI JIN/KUN WANG/JUN GAO:)&#13;
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&gt;&gt;&gt; We are the best ^_^ &gt;&gt;&gt;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&#13;
&#13;
/*&#13;
COPYRIGHT (C) 2018 LITTLEBEEX TECHNOLOGY，ALL RIGHTS RESERVED.&#13;
&#13;
Permission is hereby granted, free of charge, to any person obtaining&#13;
a copy of this software and associated documentation files (the&#13;
"Software"), to deal in the Software without restriction, including&#13;
without limitation the rights to use, copy, modify, merge, publish,&#13;
distribute, sublicense, and/or sell copies of the Software, and to&#13;
permit persons to whom the Software is furnished to do so, subject to&#13;
the following conditions:&#13;
&#13;
The above copyright notice and this permission notice shall be included&#13;
in all copies or substantial portions of the Software.&#13;
&#13;
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS&#13;
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF&#13;
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.&#13;
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY&#13;
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,&#13;
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE&#13;
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.&#13;
*/&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
&#13;
contract Ownable {&#13;
  address public owner;&#13;
  event OwnershipRenounced(address indexed previousOwner);&#13;
  event OwnershipTransferred(&#13;
  address indexed previousOwner,&#13;
  address indexed newOwner&#13;
  );&#13;
&#13;
/**&#13;
* @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
* account.&#13;
*/&#13;
  constructor() public {&#13;
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
&#13;
  function transferOwnership(address newOwner) public onlyOwner {&#13;
    require(newOwner != address(0));&#13;
    emit OwnershipTransferred(owner, newOwner);&#13;
    owner = newOwner;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
&#13;
library SafeMath {&#13;
&#13;
/**&#13;
 * @dev Multiplies two numbers, throws on overflow.&#13;
 */&#13;
&#13;
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
&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    //assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    //assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
/**&#13;
* @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
*/&#13;
&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
/**&#13;
* @dev Adds two numbers, throws on overflow.&#13;
*/&#13;
&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
contract Pausable is Ownable {&#13;
  event Pause();&#13;
  event Unpause();&#13;
  bool public paused = false;&#13;
&#13;
/**&#13;
* @dev Modifier to make a function callable only when the contract is not paused.&#13;
*/&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
/**&#13;
* @dev Modifier to make a function callable only when the contract is paused.&#13;
*/&#13;
  modifier whenPaused() {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
/**&#13;
* @dev called by the owner to pause, triggers stopped state&#13;
*/&#13;
&#13;
  function pause() onlyOwner whenNotPaused public {&#13;
    paused = true;&#13;
    emit Pause();&#13;
  }&#13;
&#13;
/**&#13;
* @dev called by the owner to unpause, returns to normal state&#13;
*/&#13;
&#13;
  function unpause() onlyOwner whenPaused public {&#13;
    paused = false;&#13;
    emit Unpause();&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
&#13;
contract ERC20Basic is Pausable {&#13;
  function totalSupply() public view returns (uint256);&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) public view returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
  mapping (address =&gt; bool) public frozenAccount; //Accounts frozen indefinitely&#13;
  mapping (address =&gt; uint256) public frozenTimestamp; //Limited frozen accounts&#13;
  mapping(address =&gt; uint256) balances;&#13;
  uint256 totalSupply_;&#13;
&#13;
/**&#13;
* @dev total number of tokens in existence&#13;
*/&#13;
&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return totalSupply_;&#13;
  }&#13;
&#13;
/**&#13;
* @dev transfer token for a specified address&#13;
* @param _to The address to transfer to.&#13;
* @param _value The amount to be transferred.&#13;
*/&#13;
&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[msg.sender]);&#13;
    require(!frozenAccount[msg.sender]);&#13;
    require(now &gt; frozenTimestamp[msg.sender]);&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    emit Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
/**&#13;
* @dev Gets the balance of the specified address.&#13;
* @param _owner The address to query the the balance of.&#13;
* @return An uint256 representing the amount owned by the passed address.&#13;
*/&#13;
&#13;
  function balanceOf(address _owner) public view returns (uint256) {&#13;
    return balances[_owner];&#13;
  }&#13;
&#13;
  /**@dev Lock account */&#13;
&#13;
  function freeze(address _target,bool _freeze) public returns (bool) {&#13;
    require(msg.sender == owner);&#13;
    require(_target != address(0));&#13;
    frozenAccount[_target] = _freeze;&#13;
    return true;&#13;
  }&#13;
&#13;
  /**@dev Bulk lock account */&#13;
&#13;
  function multiFreeze(address[] _targets,bool[] _freezes) public returns (bool) {&#13;
    require(msg.sender == owner);&#13;
    require(_targets.length == _freezes.length);&#13;
    uint256 len = _targets.length;&#13;
    require(len &gt; 0);&#13;
    for (uint256 i = 0; i &lt; len; i= i.add(1)) {&#13;
      address _target = _targets[i];&#13;
      require(_target != address(0));&#13;
      bool _freeze = _freezes[i];&#13;
      frozenAccount[_target] = _freeze;&#13;
    }&#13;
    return true;&#13;
  }&#13;
&#13;
  /**@dev Lock accounts through timestamp refer to:https://www.epochconverter.com */&#13;
  &#13;
  function freezeWithTimestamp(address _target,uint256 _timestamp) public returns (bool) {&#13;
    require(msg.sender == owner);&#13;
    require(_target != address(0));&#13;
    frozenTimestamp[_target] = _timestamp;&#13;
    return true;&#13;
  }&#13;
&#13;
  /**@dev Batch lock accounts through timestamp refer to:https://www.epochconverter.com */&#13;
&#13;
  function multiFreezeWithTimestamp(address[] _targets,uint256[] _timestamps) public returns (bool) {&#13;
    require(msg.sender == owner);&#13;
    require(_targets.length == _timestamps.length);&#13;
    uint256 len = _targets.length;&#13;
    require(len &gt; 0);&#13;
    for (uint256 i = 0; i &lt; len; i = i.add(1)) {&#13;
      address _target = _targets[i];&#13;
      require(_target != address(0));&#13;
      uint256 _timestamp = _timestamps[i];&#13;
      frozenTimestamp[_target] = _timestamp;&#13;
    }&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 * @dev Implementation of the basic standard token.&#13;
 * @dev https://github.com/ethereum/EIPs/issues/20&#13;
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
&#13;
contract StandardToken is ERC20, BasicToken {&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
  &#13;
/**&#13;
* @dev Transfer tokens from one address to another&#13;
* @param _from address The address which you want to send tokens from&#13;
* @param _to address The address which you want to transfer to&#13;
* @param _value uint256 the amount of tokens to be transferred&#13;
*/&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
    require(!frozenAccount[_from]);&#13;
    require(!frozenAccount[_to]);&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    emit Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
/**&#13;
* @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
*&#13;
* Beware that changing an allowance with this method brings the risk that someone may use both the old&#13;
* and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this&#13;
* race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:&#13;
* https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
* @param _spender The address which will spend the funds.&#13;
* @param _value The amount of tokens to be spent.&#13;
*/&#13;
&#13;
  function approve(address _spender, uint256 _value) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = _value;&#13;
    emit Approval(msg.sender, _spender, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
/**&#13;
* @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
* @param _owner address The address which owns the funds.&#13;
* @param _spender address The address which will spend the funds.&#13;
* @return A uint256 specifying the amount of tokens still available for the spender.&#13;
*/&#13;
&#13;
  function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
/**&#13;
* @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
*&#13;
* approve should be called when allowed[_spender] == 0. To increment&#13;
* allowed value is better to use this function to avoid 2 calls (and wait until&#13;
* the first transaction is mined)&#13;
* @param _spender The address which will spend the funds.&#13;
* @param _addedValue The amount of tokens to increase the allowance by.&#13;
*/&#13;
&#13;
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
/**&#13;
* @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
*&#13;
* approve should be called when allowed[_spender] == 0. To decrement&#13;
* allowed value is better to use this function to avoid 2 calls (and wait until&#13;
* the first transaction is mined)&#13;
* From MonolithDAO Token.sol&#13;
* @param _spender The address which will spend the funds.&#13;
* @param _subtractedValue The amount of tokens to decrease the allowance by.&#13;
*/&#13;
&#13;
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {&#13;
    uint oldValue = allowed[msg.sender][_spender];&#13;
    if (_subtractedValue &gt; oldValue) {&#13;
      allowed[msg.sender][_spender] = 0;&#13;
    } else {&#13;
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
    }&#13;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Burn token&#13;
 * @dev Token can be destroyed.&#13;
 */&#13;
&#13;
contract BurnableToken is BasicToken {&#13;
  event Burn(address indexed burner, uint256 value);&#13;
&#13;
/**&#13;
* @dev Destroy the specified number of token.&#13;
* @param _value Number of destroyed token.&#13;
*/&#13;
&#13;
  function burn(uint256 _value) public {&#13;
    _burn(msg.sender, _value);&#13;
  }&#13;
&#13;
  function _burn(address _who, uint256 _value) internal {&#13;
    require(_value &lt;= balances[_who]);&#13;
    //No need to verify value &lt;= totalSupply，Because this means that the balance of the sender is greater than the total supply. This should be the assertion failure.&#13;
    balances[_who] = balances[_who].sub(_value);&#13;
    totalSupply_ = totalSupply_.sub(_value);&#13;
    emit Burn(_who, _value);&#13;
    emit Transfer(_who, address(0), _value);&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title StandardBurn token&#13;
 * @dev Add the burnFrom method to the ERC20 implementation.&#13;
 */&#13;
&#13;
contract StandardBurnableToken is BurnableToken, StandardToken {&#13;
&#13;
/**&#13;
* @dev Destroy a specific number of token from target address and reduce the allowable amount.&#13;
* @param _from address token Owner address&#13;
* @param _value uint256 Number of destroyed token&#13;
*/&#13;
&#13;
  function burnFrom(address _from, uint256 _value) public {&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
    //Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,&#13;
    //This method requires triggering an event with updated approval.&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    _burn(_from, _value);&#13;
  }&#13;
}&#13;
&#13;
contract MintableToken is StandardBurnableToken {&#13;
  event Mint(address indexed to, uint256 amount);&#13;
  event MintFinished();&#13;
  bool public mintingFinished = false;&#13;
  modifier canMint() {&#13;
  require(!mintingFinished);&#13;
  _;&#13;
  }&#13;
&#13;
/**&#13;
* @dev Function to mint tokens&#13;
* @param _to The address that will receive the minted tokens.&#13;
* @param _amount The amount of tokens to mint.&#13;
* @return A boolean that indicates if the operation was successful.&#13;
*/&#13;
&#13;
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {&#13;
    totalSupply_ = totalSupply_.add(_amount);&#13;
    balances[_to] = balances[_to].add(_amount);&#13;
    emit Mint(_to, _amount);&#13;
    emit Transfer(address(0), _to, _amount);&#13;
    return true;&#13;
  }&#13;
&#13;
/**&#13;
* @dev Function to stop minting new tokens.&#13;
* @return True if the operation was successful.&#13;
*/&#13;
&#13;
  function finishMinting() onlyOwner canMint public returns (bool) {&#13;
    mintingFinished = true;&#13;
    emit MintFinished();&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
contract CappedToken is MintableToken {&#13;
  uint256 public cap;&#13;
  constructor(uint256 _cap) public {&#13;
  require(_cap &gt; 0);&#13;
  cap = _cap;&#13;
  }&#13;
&#13;
/**&#13;
* @dev Function to mint tokens&#13;
* @param _to The address that will receive the minted tokens.&#13;
* @param _amount The amount of tokens to mint.&#13;
* @return A boolean that indicates if the operation was successful.&#13;
*/&#13;
   &#13;
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {&#13;
    require(totalSupply_.add(_amount) &lt;= cap);&#13;
    return super.mint(_to, _amount);&#13;
  }&#13;
}&#13;
&#13;
contract PausableToken is StandardToken {&#13;
&#13;
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.transfer(_to, _value);&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.transferFrom(_from, _to, _value);&#13;
  }&#13;
&#13;
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {&#13;
    return super.approve(_spender, _value);&#13;
  }&#13;
&#13;
  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {&#13;
    return super.increaseApproval(_spender, _addedValue);&#13;
  }&#13;
&#13;
  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {&#13;
    return super.decreaseApproval(_spender, _subtractedValue);&#13;
  }&#13;
}&#13;
&#13;
contract LT_Token is CappedToken, PausableToken {&#13;
  string public constant name = "LittleBeeX® Token"; // solium-disable-line uppercase&#13;
  string public constant symbol = "LT"; // solium-disable-line uppercase&#13;
  uint8 public constant decimals = 18; // solium-disable-line uppercase&#13;
  uint256 public constant INITIAL_SUPPLY = 0;&#13;
  uint256 public constant MAX_SUPPLY = 50 * 10000 * 10000 * (10 ** uint256(decimals));&#13;
&#13;
/**&#13;
* @dev Constructor that gives msg.sender all of existing tokens.&#13;
*/&#13;
  &#13;
  constructor() CappedToken(MAX_SUPPLY) public {&#13;
    totalSupply_ = INITIAL_SUPPLY;&#13;
    balances[msg.sender] = INITIAL_SUPPLY;&#13;
    emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);&#13;
  }&#13;
&#13;
/**&#13;
* @dev Function to mint tokens&#13;
* @param _to The address that will receive the minted tokens.&#13;
* @param _amount The amount of tokens to mint.&#13;
* @return A boolean that indicates if the operation was successful.&#13;
*/&#13;
  &#13;
  function mint(address _to, uint256 _amount) onlyOwner canMint whenNotPaused public returns (bool) {&#13;
    return super.mint(_to, _amount);&#13;
  }&#13;
&#13;
/**&#13;
* @dev Function to stop minting new tokens.&#13;
* @return True if the operation was successful.&#13;
*/&#13;
  &#13;
  function finishMinting() onlyOwner canMint whenNotPaused public returns (bool) {&#13;
    return super.finishMinting();&#13;
  }&#13;
&#13;
/**@dev Withdrawals from contracts can only be made to Owner.*/&#13;
&#13;
  function withdraw (uint256 _amount) public returns (bool) {&#13;
    require(msg.sender == owner);&#13;
    msg.sender.transfer(_amount);&#13;
    return true;&#13;
  }&#13;
&#13;
//The fallback function.&#13;
&#13;
  function() payable public {&#13;
    revert();&#13;
  }&#13;
}