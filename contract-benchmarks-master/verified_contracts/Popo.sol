pragma solidity ^0.4.24;
/**
 * @title POPO v1.3.1
 *
 * This product is protected under license.  Any unauthorized copy, modification, or use without 
 * express written consent from the creators is prohibited.
 * 
 * WARNING:  THIS PRODUCT IS HIGHLY ADDICTIVE.  IF YOU HAVE AN ADDICTIVE NATURE.  DO NOT PLAY.
 */
// Author: https://playpopo.com
// Contact: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e59589849c958a958a91808488a58288848c89cb868a88">[email protected]</a>&#13;
library PopoDatasets {&#13;
&#13;
  struct Order {&#13;
    uint256 pID;&#13;
    uint256 createTime;&#13;
    uint256 createDayIndex;&#13;
    uint256 orderValue;&#13;
    uint256 refund;&#13;
    uint256 withdrawn;&#13;
    bool hasWithdrawn;&#13;
  }&#13;
  &#13;
  struct Player {&#13;
    address addr;&#13;
    bytes32 name;&#13;
&#13;
    bool inviteEnable;&#13;
    uint256 inviterPID;&#13;
    uint256 [] inviteePIDs;&#13;
    uint256 inviteReward1;&#13;
    uint256 inviteReward2;&#13;
    uint256 inviteReward3;&#13;
    uint256 inviteRewardWithdrawn;&#13;
&#13;
    uint256 [] oIDs;&#13;
    uint256 lastOrderDayIndex;&#13;
    uint256 dayEthIn;&#13;
  }&#13;
&#13;
}&#13;
contract PopoEvents {&#13;
&#13;
  event onEnableInvite&#13;
  (&#13;
    uint256 pID,&#13;
    address pAddr,&#13;
    bytes32 pName,&#13;
    uint256 timeStamp&#13;
  );&#13;
  &#13;
&#13;
  event onSetInviter&#13;
  (&#13;
    uint256 pID,&#13;
    address pAddr,&#13;
    uint256 indexed inviterPID,&#13;
    address indexed inviterAddr,&#13;
    bytes32 indexed inviterName,&#13;
    uint256 timeStamp&#13;
  );&#13;
&#13;
  event onOrder&#13;
  (&#13;
    uint256 indexed pID,&#13;
    address indexed pAddr,&#13;
    uint256 indexed dayIndex,&#13;
    uint256 oID,&#13;
    uint256 value,&#13;
    uint256 timeStamp&#13;
  );&#13;
&#13;
  event onWithdrawOrderRefund&#13;
  (&#13;
    uint256 indexed pID,&#13;
    address indexed pAddr,&#13;
    uint256 oID,&#13;
    uint256 value,&#13;
    uint256 timeStamp&#13;
  );&#13;
&#13;
  event onWithdrawOrderRefundToOrder&#13;
  (&#13;
    uint256 indexed pID,&#13;
    address indexed pAddr,&#13;
    uint256 oID,&#13;
    uint256 value,&#13;
    uint256 timeStamp&#13;
  );&#13;
&#13;
  event onWithdrawInviteReward&#13;
  (&#13;
    uint256 indexed pID,&#13;
    address indexed pAddr,&#13;
    uint256 value,&#13;
    uint256 timeStamp&#13;
  );&#13;
&#13;
  event onWithdrawInviteRewardToOrder&#13;
  (&#13;
    uint256 indexed pID,&#13;
    address indexed pAddr,&#13;
    uint256 value,&#13;
    uint256 timeStamp&#13;
  );&#13;
    &#13;
}&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the&#13;
    // benefit is lost if 'b' is also tested.&#13;
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    // uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return a / b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
library NameFilter {&#13;
  &#13;
    using SafeMath for *;&#13;
&#13;
    /**&#13;
     * @dev filters name strings&#13;
     * -converts uppercase to lower case.  &#13;
     * -makes sure it does not start/end with a space&#13;
     * -makes sure it does not contain multiple spaces in a row&#13;
     * -cannot be only numbers&#13;
     * -cannot start with 0x &#13;
     * -restricts characters to A-Z, a-z, 0-9, and space.&#13;
     * @return reprocessed string in bytes32 format&#13;
     */&#13;
    function nameFilter(string _input)&#13;
        internal&#13;
        pure&#13;
        returns(bytes32)&#13;
    {&#13;
        bytes memory _temp = bytes(_input);&#13;
        uint256 _length = _temp.length;&#13;
        &#13;
        //sorry limited to 32 characters&#13;
        require (_length &lt;= 32 &amp;&amp; _length &gt; 0, "string must be between 1 and 32 characters");&#13;
        // make sure it doesnt start with or end with space&#13;
        require(_temp[0] != 0x20 &amp;&amp; _temp[_length.sub(1)] != 0x20, "string cannot start or end with space");&#13;
        // make sure first two characters are not 0x&#13;
        if (_temp[0] == 0x30)&#13;
        {&#13;
            require(_temp[1] != 0x78, "string cannot start with 0x");&#13;
            require(_temp[1] != 0x58, "string cannot start with 0X");&#13;
        }&#13;
        &#13;
        // create a bool to track if we have a non number character&#13;
        bool _hasNonNumber;&#13;
        &#13;
        // convert &amp; check&#13;
        for (uint256 i = 0; i &lt; _length; i = i.add(1))&#13;
        {&#13;
            // if its uppercase A-Z&#13;
            if (_temp[i] &gt; 0x40 &amp;&amp; _temp[i] &lt; 0x5b)&#13;
            {&#13;
                // convert to lower case a-z&#13;
                _temp[i] = byte(uint(_temp[i]) + 32);&#13;
                &#13;
                // we have a non number&#13;
                if (_hasNonNumber == false)&#13;
                    _hasNonNumber = true;&#13;
            } else {&#13;
                require&#13;
                (&#13;
                    // require character is a space&#13;
                    _temp[i] == 0x20 || &#13;
                    // OR lowercase a-z&#13;
                    (_temp[i] &gt; 0x60 &amp;&amp; _temp[i] &lt; 0x7b) ||&#13;
                    // or 0-9&#13;
                    (_temp[i] &gt; 0x2f &amp;&amp; _temp[i] &lt; 0x3a),&#13;
                    "string contains invalid characters"&#13;
                );&#13;
                // make sure theres not 2x spaces in a row&#13;
                if (_temp[i] == 0x20)&#13;
                    require(_temp[i.add(1)] != 0x20, "string cannot contain consecutive spaces");&#13;
                &#13;
                // see if we have a character other than a number&#13;
                if (_hasNonNumber == false &amp;&amp; (_temp[i] &lt; 0x30 || _temp[i] &gt; 0x39))&#13;
                    _hasNonNumber = true;    &#13;
            }&#13;
        }&#13;
        &#13;
        require(_hasNonNumber == true, "string cannot be only numbers");&#13;
        &#13;
        bytes32 _ret;&#13;
        assembly {&#13;
            _ret := mload(add(_temp, 32))&#13;
        }&#13;
        return (_ret);&#13;
    }&#13;
}&#13;
contract SafePopo {&#13;
&#13;
  using SafeMath for *;&#13;
&#13;
  bool public activated_;&#13;
  uint256 public activated_time_;&#13;
&#13;
  modifier isHuman() {&#13;
    address _addr = msg.sender;&#13;
    uint256 _codeLength;&#13;
      &#13;
    assembly {_codeLength := extcodesize(_addr)}&#13;
    require (_codeLength == 0, "sorry humans only");&#13;
    _;&#13;
  }&#13;
&#13;
  modifier isWithinLimits(uint256 _eth) {&#13;
    require (_eth &gt;= 0.1 ether, "0.1 ether at least");&#13;
    require (_eth &lt;= 10000000 ether, "no, too much ether");&#13;
    _;    &#13;
  }&#13;
&#13;
  modifier isActivated() {&#13;
    require (activated_ == true, "popo is not activated"); &#13;
    _;&#13;
  }&#13;
&#13;
  modifier onlyCEO() {&#13;
    require &#13;
    (&#13;
      msg.sender == 0x5927774a0438f452747b847E4e9097884DA6afE9 || &#13;
      msg.sender == 0xA2CDecFe929Eccbd519A6c98b1220b16f5b6B0B5&#13;
    );&#13;
    _;&#13;
  }&#13;
&#13;
  modifier onlyCommunityLeader() { &#13;
    require &#13;
    (&#13;
      msg.sender == 0xede5Adf9F68C02537Cc1737CFF4506BCfFAAB63d || &#13;
      msg.sender == 0x7400A7B7D67814B0d8B27362CC198F4Ae2840e16&#13;
    );&#13;
    _;&#13;
  }&#13;
&#13;
  function activate() &#13;
    onlyCEO()&#13;
    onlyCommunityLeader()&#13;
    public&#13;
  {&#13;
    require (activated_ == false, "popo has been activated already");&#13;
&#13;
    activated_ = true;&#13;
    activated_time_ = now;&#13;
  }&#13;
  &#13;
}&#13;
contract CorePopo is SafePopo, PopoEvents {&#13;
&#13;
  uint256 public startTime_;&#13;
&#13;
  uint256 public teamPot_;&#13;
  uint256 public communityPot_;&#13;
  &#13;
  mapping (uint256 =&gt; uint256) public day_ethIn;&#13;
  uint256 public ethIn_;&#13;
&#13;
  uint256 public dayEthInLimit_ = 300 ether;&#13;
  uint256 public playerDayEthInLimit_ = 10 ether;&#13;
&#13;
  uint256 public pIDIndex_;&#13;
  mapping (uint256 =&gt; PopoDatasets.Player) public pID_Player_;&#13;
  mapping (address =&gt; uint256) public addr_pID_;&#13;
  mapping (bytes32 =&gt; uint256) public name_pID_;&#13;
&#13;
  mapping (uint256 =&gt; uint256) public inviteePID_inviteReward1_;&#13;
&#13;
  uint256 public oIDIndex_;&#13;
  mapping (uint256 =&gt; PopoDatasets.Order) public oID_Order_;&#13;
&#13;
  uint256 [] public refundOIDs_;&#13;
  uint256 public refundOIDIndex_;&#13;
&#13;
  function determinePID ()&#13;
    internal&#13;
  {&#13;
    if (addr_pID_[msg.sender] != 0) {&#13;
      return;&#13;
    }&#13;
&#13;
    pIDIndex_ = pIDIndex_.add(1);&#13;
    &#13;
    pID_Player_[pIDIndex_].addr = msg.sender;&#13;
&#13;
    addr_pID_[msg.sender] = pIDIndex_;&#13;
  }&#13;
&#13;
  function getDayIndex (uint256 _time)&#13;
    internal&#13;
    view&#13;
    returns (uint256) &#13;
  {&#13;
    return _time.sub(activated_time_).div(1 days).add(1);&#13;
  }&#13;
  &#13;
}&#13;
contract InvitePopo is CorePopo {&#13;
&#13;
  using NameFilter for string;&#13;
  &#13;
  function enableInvite (string _nameString, bytes32 _inviterName)&#13;
    isActivated()&#13;
    isHuman()&#13;
    public&#13;
    payable&#13;
  {&#13;
    require (msg.value == 0.01 ether, "enable invite need 0.01 ether");     &#13;
&#13;
    determinePID();&#13;
    determineInviter(addr_pID_[msg.sender], _inviterName);&#13;
   &#13;
    require (pID_Player_[addr_pID_[msg.sender]].inviteEnable == false, "you can only enable invite once");&#13;
&#13;
    bytes32 _name = _nameString.nameFilter();&#13;
    require (name_pID_[_name] == 0, "your name is already registered by others");&#13;
    &#13;
    pID_Player_[addr_pID_[msg.sender]].name = _name;&#13;
    pID_Player_[addr_pID_[msg.sender]].inviteEnable = true;&#13;
&#13;
    name_pID_[_name] = addr_pID_[msg.sender];&#13;
&#13;
    communityPot_ = communityPot_.add(msg.value);&#13;
&#13;
    emit PopoEvents.onEnableInvite&#13;
    (&#13;
      addr_pID_[msg.sender],&#13;
      msg.sender,&#13;
      _name,&#13;
      now&#13;
    );&#13;
  }&#13;
&#13;
  function enableInviteOfSU (string _nameString) &#13;
    onlyCEO()&#13;
    onlyCommunityLeader()&#13;
    isActivated()&#13;
    isHuman()&#13;
    public&#13;
  {&#13;
    determinePID();&#13;
   &#13;
    require (pID_Player_[addr_pID_[msg.sender]].inviteEnable == false, "you can only enable invite once");&#13;
&#13;
    bytes32 _name = _nameString.nameFilter();&#13;
    require (name_pID_[_name] == 0, "your name is already registered by others");&#13;
    &#13;
    name_pID_[_name] = addr_pID_[msg.sender];&#13;
&#13;
    pID_Player_[addr_pID_[msg.sender]].name = _name;&#13;
    pID_Player_[addr_pID_[msg.sender]].inviteEnable = true;&#13;
  }&#13;
&#13;
  function determineInviter (uint256 _pID, bytes32 _inviterName) &#13;
    internal&#13;
  {&#13;
    if (pID_Player_[_pID].inviterPID != 0) {&#13;
      return;&#13;
    }&#13;
&#13;
    uint256 _inviterPID = name_pID_[_inviterName];&#13;
    require (_inviterPID != 0, "your inviter name must be registered");&#13;
    require (pID_Player_[_inviterPID].inviteEnable == true, "your inviter must enable invite");&#13;
    require (_inviterPID != _pID, "you can not invite yourself");&#13;
&#13;
    pID_Player_[_pID].inviterPID = _inviterPID;&#13;
&#13;
    emit PopoEvents.onSetInviter&#13;
    (&#13;
      _pID,&#13;
      msg.sender,&#13;
      _inviterPID,&#13;
      pID_Player_[_inviterPID].addr,&#13;
      _inviterName,&#13;
      now&#13;
    );&#13;
  }&#13;
&#13;
  function distributeInviteReward (uint256 _pID, uint256 _inviteReward1, uint256 _inviteReward2, uint256 _inviteReward3, uint256 _percent) &#13;
    internal&#13;
    returns (uint256)&#13;
  {&#13;
    uint256 inviterPID = pID_Player_[_pID].inviterPID;&#13;
    if (pID_Player_[inviterPID].inviteEnable) &#13;
    {&#13;
      pID_Player_[inviterPID].inviteReward1 = pID_Player_[inviterPID].inviteReward1.add(_inviteReward1);&#13;
&#13;
      if (inviteePID_inviteReward1_[_pID] == 0) {&#13;
        pID_Player_[inviterPID].inviteePIDs.push(_pID);&#13;
      }&#13;
      inviteePID_inviteReward1_[_pID] = inviteePID_inviteReward1_[_pID].add(_inviteReward1);&#13;
&#13;
      _percent = _percent.sub(5);&#13;
    } &#13;
    &#13;
    uint256 inviterPID_inviterPID = pID_Player_[inviterPID].inviterPID;&#13;
    if (pID_Player_[inviterPID_inviterPID].inviteEnable) &#13;
    {&#13;
      pID_Player_[inviterPID_inviterPID].inviteReward2 = pID_Player_[inviterPID_inviterPID].inviteReward2.add(_inviteReward2);&#13;
&#13;
      _percent = _percent.sub(2);&#13;
    }&#13;
&#13;
    uint256 inviterPID_inviterPID_inviterPID = pID_Player_[inviterPID_inviterPID].inviterPID;&#13;
    if (pID_Player_[inviterPID_inviterPID_inviterPID].inviteEnable) &#13;
    {&#13;
      pID_Player_[inviterPID_inviterPID_inviterPID].inviteReward3 = pID_Player_[inviterPID_inviterPID_inviterPID].inviteReward3.add(_inviteReward3);&#13;
&#13;
      _percent = _percent.sub(1);&#13;
    } &#13;
&#13;
    return&#13;
    (&#13;
      _percent&#13;
    );&#13;
  }&#13;
  &#13;
}&#13;
contract OrderPopo is InvitePopo {&#13;
&#13;
  function setDayEthInLimit (uint256 dayEthInLimit) &#13;
    onlyCEO()&#13;
    onlyCommunityLeader()&#13;
    public&#13;
  {&#13;
    dayEthInLimit_ = dayEthInLimit;&#13;
  }&#13;
&#13;
  function setPlayerDayEthInLimit (uint256 playerDayEthInLimit) &#13;
    onlyCEO()&#13;
    onlyCommunityLeader()&#13;
    public&#13;
  {&#13;
    playerDayEthInLimit_ = playerDayEthInLimit;&#13;
  }&#13;
  &#13;
  function order (bytes32 _inviterName)&#13;
    isActivated()&#13;
    isHuman()&#13;
    isWithinLimits(msg.value)&#13;
    public&#13;
    payable&#13;
  {&#13;
    uint256 _now = now;&#13;
    uint256 _nowDayIndex = getDayIndex(_now);&#13;
&#13;
    require (_nowDayIndex &gt; 2, "only third day can order");&#13;
            &#13;
    determinePID();&#13;
    determineInviter(addr_pID_[msg.sender], _inviterName);&#13;
&#13;
    orderCore(_now, _nowDayIndex, msg.value);&#13;
  }&#13;
&#13;
  function orderInternal (uint256 _value, bytes32 _inviterName)&#13;
    internal&#13;
  {&#13;
    uint256 _now = now;&#13;
    uint256 _nowDayIndex = getDayIndex(_now);&#13;
&#13;
    require (_nowDayIndex &gt; 2, "only third day can order");&#13;
            &#13;
    determinePID();&#13;
    determineInviter(addr_pID_[msg.sender], _inviterName);&#13;
&#13;
    orderCore(_now, _nowDayIndex, _value);&#13;
  }&#13;
&#13;
  function orderCore (uint256 _now, uint256 _nowDayIndex, uint256 _value)&#13;
    private&#13;
  {&#13;
    teamPot_ = teamPot_.add(_value.mul(3).div(100));&#13;
    communityPot_ = communityPot_.add(_value.mul(4).div(100));&#13;
&#13;
    require (day_ethIn[_nowDayIndex] &lt; dayEthInLimit_, "beyond the day eth in limit");&#13;
    day_ethIn[_nowDayIndex] = day_ethIn[_nowDayIndex].add(_value);&#13;
    ethIn_ = ethIn_.add(_value);&#13;
&#13;
    uint256 _pID = addr_pID_[msg.sender];&#13;
&#13;
    if (pID_Player_[_pID].lastOrderDayIndex == _nowDayIndex) {&#13;
      require (pID_Player_[_pID].dayEthIn &lt; playerDayEthInLimit_, "beyond the player day eth in limit");&#13;
      pID_Player_[_pID].dayEthIn = pID_Player_[_pID].dayEthIn.add(_value);&#13;
    } else {&#13;
      pID_Player_[_pID].lastOrderDayIndex = _nowDayIndex;&#13;
      pID_Player_[_pID].dayEthIn = _value;&#13;
    }&#13;
&#13;
    oIDIndex_ = oIDIndex_.add(1);&#13;
    &#13;
    oID_Order_[oIDIndex_].pID = _pID;&#13;
    oID_Order_[oIDIndex_].createTime = _now;&#13;
    oID_Order_[oIDIndex_].createDayIndex = _nowDayIndex;&#13;
    oID_Order_[oIDIndex_].orderValue = _value;&#13;
&#13;
    pID_Player_[_pID].oIDs.push(oIDIndex_);&#13;
&#13;
    refundOIDs_.push(oIDIndex_);&#13;
&#13;
    uint256 _percent = 33;&#13;
    if (pID_Player_[_pID].oIDs.length &lt; 3) {&#13;
      _percent = distributeInviteReward(_pID, _value.mul(5).div(100), _value.mul(2).div(100), _value.mul(1).div(100), _percent);&#13;
      refund(_nowDayIndex, _value.mul(_percent).div(100));&#13;
    } else {&#13;
      refund(_nowDayIndex, _value.mul(_percent).div(100));&#13;
    }&#13;
&#13;
    emit PopoEvents.onOrder&#13;
    (&#13;
      _pID,&#13;
      msg.sender,&#13;
      _nowDayIndex,&#13;
      oIDIndex_,&#13;
      _value,&#13;
      now&#13;
    );&#13;
  }&#13;
&#13;
  function refund (uint256 _nowDayIndex, uint256 _pot)&#13;
    private&#13;
  {&#13;
    while&#13;
    (&#13;
      (_pot &gt; 0) &amp;&amp;&#13;
      (refundOIDIndex_ &lt; refundOIDs_.length)&#13;
    )&#13;
    {&#13;
      (_pot, refundOIDIndex_) = doRefund(_nowDayIndex, refundOIDIndex_, _pot);&#13;
    }&#13;
  }&#13;
  &#13;
  function doRefund (uint256 _nowDayIndex, uint256 _refundOIDIndex, uint256 _pot)&#13;
    private&#13;
    returns (uint256, uint256)&#13;
  {&#13;
    uint256 _refundOID = refundOIDs_[_refundOIDIndex];&#13;
&#13;
    uint _orderState = getOrderStateHelper(_nowDayIndex, _refundOID);&#13;
    if (_orderState != 1) {&#13;
      return&#13;
      (&#13;
        _pot,&#13;
        _refundOIDIndex.add(1)&#13;
      );&#13;
    }&#13;
&#13;
    uint256 _maxRefund = oID_Order_[_refundOID].orderValue.mul(60).div(100);&#13;
    if (oID_Order_[_refundOID].refund &lt; _maxRefund) {&#13;
      uint256 _needRefund = _maxRefund.sub(oID_Order_[_refundOID].refund);&#13;
&#13;
      if &#13;
      (&#13;
        _needRefund &gt; _pot&#13;
      ) &#13;
      {&#13;
        oID_Order_[_refundOID].refund = oID_Order_[_refundOID].refund.add(_pot);&#13;
&#13;
        return&#13;
        (&#13;
          0,&#13;
          _refundOIDIndex&#13;
        );&#13;
      } &#13;
      else&#13;
      {&#13;
        oID_Order_[_refundOID].refund = oID_Order_[_refundOID].refund.add(_needRefund);&#13;
&#13;
        return&#13;
        (&#13;
          _pot.sub(_needRefund),&#13;
          _refundOIDIndex.add(1)&#13;
        );&#13;
      }&#13;
    }&#13;
    else&#13;
    {&#13;
      return&#13;
      (&#13;
        _pot,&#13;
        _refundOIDIndex.add(1)&#13;
      );&#13;
    }&#13;
  }&#13;
&#13;
  function getOrderStateHelper (uint256 _nowDayIndex, uint256 _oID)&#13;
    internal&#13;
    view&#13;
    returns (uint)&#13;
  {&#13;
    PopoDatasets.Order memory _order = oID_Order_[_oID];&#13;
    &#13;
    if &#13;
    (&#13;
      _order.hasWithdrawn&#13;
    ) &#13;
    {&#13;
      return&#13;
      (&#13;
        3&#13;
      );&#13;
    } &#13;
    else &#13;
    {&#13;
      if &#13;
      (&#13;
        _nowDayIndex &lt; _order.createDayIndex || &#13;
        _nowDayIndex &gt; _order.createDayIndex.add(5)&#13;
      )&#13;
      {&#13;
        return&#13;
        (&#13;
          2&#13;
        );&#13;
      }&#13;
      else &#13;
      {&#13;
        return&#13;
        (&#13;
          1&#13;
        );&#13;
      }&#13;
    }&#13;
  }&#13;
  &#13;
}&#13;
contract InspectorPopo is OrderPopo {&#13;
&#13;
  function getAdminDashboard () &#13;
    onlyCEO()&#13;
    onlyCommunityLeader()&#13;
    public&#13;
    view &#13;
    returns (uint256, uint256)&#13;
  {&#13;
    return&#13;
    (&#13;
      teamPot_,&#13;
      communityPot_&#13;
    ); &#13;
  }&#13;
&#13;
  function getDayEthIn (uint256 _dayIndex) &#13;
    onlyCEO()&#13;
    onlyCommunityLeader()&#13;
    public&#13;
    view &#13;
    returns (uint256)&#13;
  {&#13;
    return&#13;
    (&#13;
      day_ethIn[_dayIndex]&#13;
    ); &#13;
  }&#13;
&#13;
  function getAddressLost (address _addr) &#13;
    onlyCEO()&#13;
    onlyCommunityLeader()&#13;
    public&#13;
    view &#13;
    returns (uint256) &#13;
  {&#13;
    uint256 _now = now;&#13;
    uint256 _nowDayIndex = getDayIndex(_now);&#13;
&#13;
    uint256 pID = addr_pID_[_addr];&#13;
    require (pID != 0, "address need to be registered");&#13;
    &#13;
    uint256 _orderValue = 0;&#13;
    uint256 _actualTotalRefund = 0;&#13;
&#13;
    uint256 [] memory _oIDs = pID_Player_[pID].oIDs;&#13;
    for (uint256 _index = 0; _index &lt; _oIDs.length; _index = _index.add(1)) {&#13;
      PopoDatasets.Order memory _order = oID_Order_[_oIDs[_index]];&#13;
      _orderValue = _orderValue.add(_order.orderValue);&#13;
      _actualTotalRefund = _actualTotalRefund.add(getOrderActualTotalRefundHelper(_nowDayIndex, _oIDs[_index]));&#13;
    }&#13;
&#13;
    if (_orderValue &gt; _actualTotalRefund) {&#13;
      return &#13;
      (&#13;
        _orderValue.sub(_actualTotalRefund)&#13;
      );&#13;
    }&#13;
    else&#13;
    {&#13;
      return &#13;
      (&#13;
        0&#13;
      );&#13;
    }&#13;
  }&#13;
&#13;
  function getInviteInfo () &#13;
    public&#13;
    view&#13;
    returns (bool, bytes32, uint256, bytes32, uint256, uint256, uint256, uint256)&#13;
  {&#13;
    uint256 _pID = addr_pID_[msg.sender];&#13;
&#13;
    return &#13;
    (&#13;
      pID_Player_[_pID].inviteEnable,&#13;
      pID_Player_[_pID].name,&#13;
      pID_Player_[_pID].inviterPID,&#13;
      pID_Player_[pID_Player_[_pID].inviterPID].name,&#13;
      pID_Player_[_pID].inviteReward1,&#13;
      pID_Player_[_pID].inviteReward2,&#13;
      pID_Player_[_pID].inviteReward3,&#13;
      pID_Player_[_pID].inviteRewardWithdrawn&#13;
    );&#13;
  }&#13;
&#13;
  function getInviteePIDs () &#13;
    public&#13;
    view&#13;
    returns (uint256 []) &#13;
  {&#13;
    uint256 _pID = addr_pID_[msg.sender];&#13;
&#13;
    return &#13;
    (&#13;
      pID_Player_[_pID].inviteePIDs&#13;
    );&#13;
  }&#13;
&#13;
  function getInviteeInfo (uint256 _inviteePID) &#13;
    public&#13;
    view&#13;
    returns (uint256, bytes32) &#13;
  {&#13;
&#13;
    require (pID_Player_[_inviteePID].inviterPID == addr_pID_[msg.sender], "you must have invited this player");&#13;
&#13;
    return &#13;
    (&#13;
      inviteePID_inviteReward1_[_inviteePID],&#13;
      pID_Player_[_inviteePID].name&#13;
    );&#13;
  }&#13;
&#13;
  function getOrderInfo () &#13;
    public&#13;
    view&#13;
    returns (bool, uint256 []) &#13;
  {&#13;
    uint256 _now = now;&#13;
    uint256 _nowDayIndex = getDayIndex(_now);&#13;
&#13;
    uint256 _pID = addr_pID_[msg.sender];&#13;
&#13;
    bool _isWithinPlayerDayEthInLimits = true;&#13;
    if&#13;
    (&#13;
      (pID_Player_[_pID].lastOrderDayIndex == _nowDayIndex) &amp;&amp;&#13;
      (pID_Player_[_pID].dayEthIn &gt;= playerDayEthInLimit_) &#13;
    )&#13;
    {&#13;
      _isWithinPlayerDayEthInLimits = false;&#13;
    }&#13;
&#13;
    return &#13;
    (&#13;
      _isWithinPlayerDayEthInLimits,&#13;
      pID_Player_[_pID].oIDs&#13;
    );&#13;
  }&#13;
&#13;
  function getOrder (uint256 _oID) &#13;
    public&#13;
    view&#13;
    returns (uint256, uint256, uint256, uint, uint256)&#13;
  {&#13;
    uint256 _now = now;&#13;
    uint256 _nowDayIndex = getDayIndex(_now);&#13;
&#13;
    require (oID_Order_[_oID].pID == addr_pID_[msg.sender], "only owner can get its order");&#13;
&#13;
    return &#13;
    (&#13;
      oID_Order_[_oID].createTime,&#13;
      oID_Order_[_oID].createDayIndex,&#13;
      oID_Order_[_oID].orderValue,&#13;
      getOrderStateHelper(_nowDayIndex, _oID),&#13;
      getOrderActualTotalRefundHelper(_nowDayIndex, _oID)&#13;
    );&#13;
  }&#13;
&#13;
  function getOverall ()&#13;
    public&#13;
    view &#13;
    returns (uint256, uint256, uint256, uint256, uint256, bool, uint256)&#13;
  {&#13;
    uint256 _now = now;&#13;
    uint256 _nowDayIndex = getDayIndex(_now);&#13;
    uint256 _tommorrow = _nowDayIndex.mul(1 days).add(activated_time_);&#13;
    bool _isWithinDayEthInLimits = day_ethIn[_nowDayIndex] &lt; dayEthInLimit_ ? true : false;&#13;
&#13;
    return (&#13;
      _now,&#13;
      _nowDayIndex,&#13;
      _tommorrow,&#13;
      ethIn_,&#13;
      dayEthInLimit_,&#13;
      _isWithinDayEthInLimits,&#13;
      playerDayEthInLimit_&#13;
    ); &#13;
  }&#13;
&#13;
  function getOrderActualTotalRefundHelper (uint256 _nowDayIndex, uint256 _oID) &#13;
    internal&#13;
    view &#13;
    returns (uint256)&#13;
  {&#13;
    if (oID_Order_[_oID].hasWithdrawn) {&#13;
      return&#13;
      (&#13;
        oID_Order_[_oID].withdrawn&#13;
      );&#13;
    }&#13;
&#13;
    uint256 _actualTotalRefund = oID_Order_[_oID].orderValue.mul(60).div(100);&#13;
    uint256 _dayGap = _nowDayIndex.sub(oID_Order_[_oID].createDayIndex);&#13;
    if (_dayGap &gt; 0) {&#13;
      _dayGap = _dayGap &gt; 5 ? 5 : _dayGap;&#13;
      uint256 _maxRefund = oID_Order_[_oID].orderValue.mul(12).mul(_dayGap).div(100);&#13;
&#13;
      if (oID_Order_[_oID].refund &lt; _maxRefund)&#13;
      {&#13;
        _actualTotalRefund = _actualTotalRefund.add(oID_Order_[_oID].refund);&#13;
      } &#13;
      else &#13;
      {&#13;
        _actualTotalRefund = _actualTotalRefund.add(_maxRefund);&#13;
      }&#13;
    }&#13;
    return&#13;
    (&#13;
      _actualTotalRefund&#13;
    );&#13;
  }&#13;
&#13;
}&#13;
contract WithdrawPopo is InspectorPopo {&#13;
&#13;
  function withdrawOrderRefund(uint256 _oID)&#13;
    isActivated()&#13;
    isHuman()&#13;
    public&#13;
  {&#13;
    uint256 _now = now;&#13;
    uint256 _nowDayIndex = getDayIndex(_now);&#13;
&#13;
    PopoDatasets.Order memory _order = oID_Order_[_oID];&#13;
    require (_order.pID == addr_pID_[msg.sender], "only owner can withdraw");&#13;
    require (!_order.hasWithdrawn, "order refund has been withdrawn");&#13;
&#13;
    uint256 _actualTotalRefund = getOrderActualTotalRefundHelper(_nowDayIndex, _oID);&#13;
    require (_actualTotalRefund &gt; 0, "no order refund need to be withdrawn");&#13;
&#13;
    msg.sender.transfer(_actualTotalRefund);&#13;
&#13;
    oID_Order_[_oID].withdrawn = _actualTotalRefund;&#13;
    oID_Order_[_oID].hasWithdrawn = true;&#13;
&#13;
    uint256 _totalRefund = _order.orderValue.mul(60).div(100);&#13;
    _totalRefund = _totalRefund.add(_order.refund);&#13;
    communityPot_ = communityPot_.add(_totalRefund.sub(_actualTotalRefund));&#13;
&#13;
    emit PopoEvents.onWithdrawOrderRefund&#13;
    (&#13;
      _order.pID,&#13;
      msg.sender,&#13;
      _oID,&#13;
      _actualTotalRefund,&#13;
      now&#13;
    );&#13;
  }&#13;
&#13;
  function withdrawOrderRefundToOrder(uint256 _oID)&#13;
    isActivated()&#13;
    isHuman()&#13;
    public&#13;
  {&#13;
    uint256 _now = now;&#13;
    uint256 _nowDayIndex = getDayIndex(_now);&#13;
&#13;
    PopoDatasets.Order memory _order = oID_Order_[_oID];&#13;
    require (_order.pID == addr_pID_[msg.sender], "only owner can withdraw");&#13;
    require (!_order.hasWithdrawn, "order refund has been withdrawn");&#13;
&#13;
    uint256 _actualTotalRefund = getOrderActualTotalRefundHelper(_nowDayIndex, _oID);&#13;
    require (_actualTotalRefund &gt; 0, "no order refund need to be withdrawn");&#13;
&#13;
    orderInternal(_actualTotalRefund, pID_Player_[pID_Player_[_order.pID].inviterPID].name);&#13;
&#13;
    oID_Order_[_oID].withdrawn = _actualTotalRefund;&#13;
    oID_Order_[_oID].hasWithdrawn = true;&#13;
&#13;
    uint256 _totalRefund = _order.orderValue.mul(60).div(100);&#13;
    _totalRefund = _totalRefund.add(_order.refund);&#13;
    communityPot_ = communityPot_.add(_totalRefund.sub(_actualTotalRefund));&#13;
&#13;
    emit PopoEvents.onWithdrawOrderRefundToOrder&#13;
    (&#13;
      _order.pID,&#13;
      msg.sender,&#13;
      _oID,&#13;
      _actualTotalRefund,&#13;
      now&#13;
    );&#13;
  }&#13;
&#13;
  function withdrawInviteReward ()&#13;
    isActivated()&#13;
    isHuman()&#13;
    public&#13;
  {&#13;
    uint256 _pID = addr_pID_[msg.sender];&#13;
&#13;
    uint256 _withdrawal = pID_Player_[_pID].inviteReward1&#13;
                            .add(pID_Player_[_pID].inviteReward2)&#13;
                            .add(pID_Player_[_pID].inviteReward3)&#13;
                            .sub(pID_Player_[_pID].inviteRewardWithdrawn);&#13;
    require (_withdrawal &gt; 0, "you have no invite reward to withdraw");&#13;
&#13;
    msg.sender.transfer(_withdrawal);&#13;
&#13;
    pID_Player_[_pID].inviteRewardWithdrawn = pID_Player_[_pID].inviteRewardWithdrawn.add(_withdrawal);&#13;
&#13;
    emit PopoEvents.onWithdrawInviteReward&#13;
    (&#13;
      _pID,&#13;
      msg.sender,&#13;
      _withdrawal,&#13;
      now&#13;
    );&#13;
  }&#13;
&#13;
  function withdrawInviteRewardToOrder ()&#13;
    isActivated()&#13;
    isHuman()&#13;
    public&#13;
  {&#13;
    uint256 _pID = addr_pID_[msg.sender];&#13;
&#13;
    uint256 _withdrawal = pID_Player_[_pID].inviteReward1&#13;
                            .add(pID_Player_[_pID].inviteReward2)&#13;
                            .add(pID_Player_[_pID].inviteReward3)&#13;
                            .sub(pID_Player_[_pID].inviteRewardWithdrawn);&#13;
    require (_withdrawal &gt; 0, "you have no invite reward to withdraw");&#13;
&#13;
    orderInternal(_withdrawal, pID_Player_[pID_Player_[_pID].inviterPID].name);&#13;
&#13;
    pID_Player_[_pID].inviteRewardWithdrawn = pID_Player_[_pID].inviteRewardWithdrawn.add(_withdrawal);&#13;
&#13;
    emit PopoEvents.onWithdrawInviteRewardToOrder&#13;
    (&#13;
      _pID,&#13;
      msg.sender,&#13;
      _withdrawal,&#13;
      now&#13;
    );&#13;
  }&#13;
&#13;
  function withdrawTeamPot ()&#13;
    onlyCEO()&#13;
    isActivated()&#13;
    isHuman()&#13;
    public&#13;
  {&#13;
    if (teamPot_ &lt;= 0) {&#13;
      return;&#13;
    }&#13;
&#13;
    msg.sender.transfer(teamPot_);&#13;
    teamPot_ = 0;&#13;
  }&#13;
&#13;
  function withdrawCommunityPot ()&#13;
    onlyCommunityLeader()&#13;
    isActivated()&#13;
    isHuman()&#13;
    public&#13;
  {&#13;
    if (communityPot_ &lt;= 0) {&#13;
      return;&#13;
    }&#13;
&#13;
    msg.sender.transfer(communityPot_);&#13;
    communityPot_ = 0;&#13;
  }&#13;
&#13;
}&#13;
contract Popo is WithdrawPopo {&#13;
  &#13;
  constructor()&#13;
    public &#13;
  {&#13;
&#13;
  }&#13;
  &#13;
}