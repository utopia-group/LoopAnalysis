pragma solidity ^0.4.18;

// File: contracts/UidCheckerInterface.sol

interface UidCheckerInterface {

  function isUid(
    string _uid
  )
  public
  pure returns (bool);

}

// File: contracts/UidCheckerForReddit.sol

/**
 * @title UidCheckerForReddit
 * @author Francesco Sullo <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="385e4a59565b5d4b5b57784b4d545457165b57">[email protected]</a>&gt;&#13;
 * @dev Checks if a uid is a Reddit uid&#13;
 */&#13;
&#13;
&#13;
&#13;
contract UidCheckerForReddit&#13;
is UidCheckerInterface&#13;
{&#13;
&#13;
  string public fromVersion = "1.0.0";&#13;
&#13;
  function isUid(&#13;
    string _uid&#13;
  )&#13;
  public&#13;
  pure&#13;
  returns (bool)&#13;
  {&#13;
    bytes memory uid = bytes(_uid);&#13;
    if (uid.length &lt; 3 || uid.length &gt; 20) {&#13;
      return false;&#13;
    } else {&#13;
      for (uint i = 0; i &lt; uid.length; i++) {&#13;
        if (!(&#13;
        uid[i] == 45 || uid[i] == 95&#13;
        || (uid[i] &gt;= 48 &amp;&amp; uid[i] &lt;= 57)&#13;
        // it requires lowercases, to not risk conflicts&#13;
        // even if Reddit allows lower and upper cases&#13;
        || (uid[i] &gt;= 97 &amp;&amp; uid[i] &lt;= 122)&#13;
        )) {&#13;
          return false;&#13;
        }&#13;
      }&#13;
    }&#13;
    return true;&#13;
  }&#13;
&#13;
}