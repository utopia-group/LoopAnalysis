// sendblocker
// prevent any funds from incoming
// @authors:
// Cody Burns <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3c585352484c5d52555f7c5f5358454b5e494e524f125f5351">[email protected]</a>&gt;&#13;
// license: Apache 2.0&#13;
// version:&#13;
&#13;
pragma solidity ^0.4.19;&#13;
&#13;
// Intended use:  &#13;
// cross deploy to prevent unintended chain getting funds&#13;
// Status: functional&#13;
// still needs:&#13;
// submit pr and issues to https://github.com/realcodywburns/&#13;
//version 0.1.0&#13;
&#13;
contract sendblocker{&#13;
 function () public {assert(0&gt;0);}&#13;
    &#13;
}