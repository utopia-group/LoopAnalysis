pragma solidity ^0.4.18;

// File: contracts/UidCheckerInterface.sol

interface UidCheckerInterface {

  function isUid(
    string _uid
  )
  public
  pure returns (bool);

}

// File: contracts/UidCheckerForTwitter.sol

/**
 * @title UidCheckerForTwitter
 * @author Francesco Sullo <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="ddbbafbcb3beb8aebeb29daea8b1b1b2f3beb2">[email protected]</a>&gt;&#13;
 * @dev Checks if a uid is a Twitter uid&#13;
 */&#13;
&#13;
contract UidCheckerForTwitter&#13;
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
    if (uid.length == 0 || uid.length &gt; 20) {&#13;
      return false;&#13;
    } else {&#13;
      for (uint i = 0; i &lt; uid.length; i++) {&#13;
        if (uid[i] &lt; 48 || uid[i] &gt; 57) {&#13;
          return false;&#13;
        }&#13;
      }&#13;
    }&#13;
    return true;&#13;
  }&#13;
&#13;
}