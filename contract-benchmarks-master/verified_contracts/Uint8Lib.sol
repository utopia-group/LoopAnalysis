/// @title Token Register Contract
/// @author Kongliang Zhong - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e68d8988818a8f878881a68a898996948f8881c8899481">[email protected]</a>&gt;,&#13;
/// @author Daniel Wang - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="eb8f8a85828e87ab8784849b9982858cc584998c">[email protected]</a>&gt;.&#13;
library Uint8Lib {&#13;
    function xorReduce(&#13;
        uint8[] arr,&#13;
        uint    len&#13;
        )&#13;
        public&#13;
        constant&#13;
        returns (uint8 res) {&#13;
&#13;
        res = arr[0];&#13;
        for (uint i = 1; i &lt; len; i++) {&#13;
           res ^= arr[i];&#13;
        }&#13;
    }&#13;
}