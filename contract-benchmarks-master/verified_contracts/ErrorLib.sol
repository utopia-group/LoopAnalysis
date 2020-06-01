/// @title Token Register Contract
/// @author Daniel Wang - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e286838c8b878ea2">[email protected]</a>loopring.org&gt;.&#13;
library ErrorLib {&#13;
&#13;
    event Error(string message);&#13;
&#13;
    /// @dev Check if condition hold, if not, log an exception and revert.&#13;
    function orThrow(bool condition, string message) public constant {&#13;
        if (!condition) {&#13;
            error(message);&#13;
        }&#13;
    }&#13;
&#13;
    function error(string message) public constant {&#13;
        Error(message);&#13;
        revert();&#13;
    }&#13;
}