// sendlimiter
// limit funds held on a contract
// @authors:
// Cody Burns <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="395d56574d495857505a795a565d404e5b4c4b574a175a5654">[email protected]</a>&gt;&#13;
// license: Apache 2.0&#13;
// version:&#13;
&#13;
pragma solidity ^0.4.19;&#13;
&#13;
// Intended use:  &#13;
// cross deploy to limit funds on a chin identifier&#13;
// Status: functional&#13;
// still needs:&#13;
// submit pr and issues to https://github.com/realcodywburns/&#13;
//version 0.1.0&#13;
&#13;
&#13;
contract sendlimiter{&#13;
 function () public payable {&#13;
     require(this.balance + msg.value &lt; 100000000);}&#13;
}