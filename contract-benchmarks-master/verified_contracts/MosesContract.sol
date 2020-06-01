pragma solidity ^0.4.24;


contract Ownable {

  address public owner;
  
  mapping(address => uint8) public operators;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() 
    public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Throws if called by any account other than the operator
   */
  modifier onlyOperator() {
    require(operators[msg.sender] == uint8(1)); 
    _;
  }

  /**
   * @dev operator management
   */
  function operatorManager(address[] _operators,uint8 flag) 
    public 
    onlyOwner 
    returns(bool){
      for(uint8 i = 0; i< _operators.length; i++) {
        if(flag == uint8(0)){
          operators[_operators[i]] = 1;
        } else {
          delete operators[_operators[i]];
        }
      }
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) 
    public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
  }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {

  event Pause();

  event Unpause();

  bool public paused = false;

  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused 
    returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused 
    returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}


// ERC20 Token
contract ERC20Token {

    function balanceOf(address _owner) constant public returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);
}


/**
 *  预测事件合约对象 
 *  @author linq <<span class="__cf_email__" data-cfemail="ffcecfcec7cfcacccec9c9bf8e8ed19c9092">[email protected]</span>&gt;&#13;
 */&#13;
contract GuessBaseBiz is Pausable {&#13;
    &#13;
  // MOS合约地址 &#13;
  address public mosContractAddress = 0x420a43153DA24B9e2aedcEC2B8158A8653a3317e;&#13;
  // 平台地址&#13;
  address public platformAddress = 0xe0F969610699f88612518930D88C0dAB39f67985;&#13;
  // 平台手续费&#13;
  uint256 public serviceChargeRate = 5;&#13;
  // 平台维护费&#13;
  uint256 public maintenanceChargeRate = 0;&#13;
  // 单次上限&#13;
  uint256 public upperLimit = 1000 * 10 ** 18;&#13;
  // 单次下限&#13;
  uint256 public lowerLimit = 1 * 10 ** 18;&#13;
  &#13;
  &#13;
  ERC20Token MOS;&#13;
  &#13;
  // =============================== Event ===============================&#13;
    &#13;
  // 创建预测事件成功后广播&#13;
  event CreateGuess(uint256 indexed id, address indexed creator);&#13;
&#13;
//   直投事件&#13;
//   event Deposit(uint256 indexed id,address indexed participant,uint256 optionId,uint256 bean);&#13;
&#13;
  // 代投事件  &#13;
  event DepositAgent(address indexed participant, uint256 indexed id, uint256 optionId, uint256 totalBean);&#13;
&#13;
  // 公布选项事件 &#13;
  event PublishOption(uint256 indexed id, uint256 indexed optionId, uint256 odds);&#13;
&#13;
  // 预测事件流拍事件&#13;
  event Abortive(uint256 indexed id);&#13;
  &#13;
  constructor() public {&#13;
      MOS = ERC20Token(mosContractAddress);&#13;
  }&#13;
&#13;
  struct Guess {&#13;
    // 预测事件ID&#13;
    uint256 id;&#13;
    // 预测事件创建者&#13;
    address creator;&#13;
    // 预测标题&#13;
    string title;&#13;
    // 数据源名称+数据源链接&#13;
    string source;&#13;
    // 预测事件分类&#13;
    string category;&#13;
    // 是否下架 1.是 0.否&#13;
    uint8 disabled;&#13;
    // 预测事件描述&#13;
    bytes desc;&#13;
    // 开始时间&#13;
    uint256 startAt;&#13;
    // 封盘时间  &#13;
    uint256 endAt; &#13;
    // 是否结束&#13;
    uint8 finished; &#13;
    // 是否流拍&#13;
    uint8 abortive; &#13;
    // // 选项ID&#13;
    // uint256[] optionIds;&#13;
    // // 选项名称&#13;
    // bytes32[] optionNames;&#13;
  }&#13;
&#13;
//   // 订单&#13;
//   struct Order {&#13;
//     address user;&#13;
//     uint256 bean;&#13;
//   }&#13;
&#13;
  // 平台代理订单&#13;
  struct AgentOrder {&#13;
    address participant;&#13;
    string ipfsBase58;&#13;
    string dataHash;&#13;
    uint256 bean;&#13;
  }&#13;
  &#13;
  struct Option {&#13;
    // 选项ID&#13;
    uint256 id;&#13;
    // 选项名称&#13;
    bytes32 name;&#13;
  } &#13;
  &#13;
&#13;
  // 存储所有的预测事件&#13;
  mapping (uint256 =&gt; Guess) public guesses;&#13;
  // 存储所有的预测事件选项 &#13;
  mapping (uint256 =&gt; Option[]) public options;&#13;
&#13;
  // 存储所有用户直投订单&#13;
//   mapping (uint256 =&gt; mapping(uint256 =&gt; Order[])) public orders;&#13;
&#13;
  // 通过预测事件ID和选项ID，存储该选项所有参与的地址&#13;
  mapping (uint256 =&gt; mapping (uint256 =&gt; AgentOrder[])) public agentOrders;&#13;
  &#13;
  // 存储事件总投注 &#13;
  mapping (uint256 =&gt; uint256) public guessTotalBean;&#13;
  &#13;
  // 存储某选项总投注 &#13;
  mapping (uint256 =&gt; mapping(uint256 =&gt; uint256)) public optionTotalBean;&#13;
&#13;
  // 存储某选项某用户总投注 &#13;
//   mapping (uint256 =&gt; mapping(address =&gt; uint256)) public userOptionTotalBean;&#13;
&#13;
  /**&#13;
   * 预测事件状态&#13;
   */&#13;
  enum GuessStatus {&#13;
    // 未开始&#13;
    NotStarted, &#13;
    // 进行中&#13;
    Progress,&#13;
    // 待公布&#13;
    Deadline,&#13;
    // 已结束&#13;
    Finished,&#13;
    // 流拍&#13;
    Abortive&#13;
  }&#13;
&#13;
  // 判断是否为禁用状态&#13;
  function disabled(uint256 id) public view returns(bool) {&#13;
      if(guesses[id].disabled == 0){&#13;
          return false;&#13;
      }else {&#13;
          return true;&#13;
      }&#13;
  }&#13;
&#13;
 /**&#13;
   * 获取预测事件状态&#13;
   * &#13;
   * 未开始&#13;
   *     未到开始时间&#13;
   * 进行中&#13;
   *     在开始到结束时间范围内&#13;
   * 待公布/已截止&#13;
   *     已经过了结束时间，并且finished为0&#13;
   * 已结束&#13;
   *     已经过了结束时间，并且finished为1,abortive=0&#13;
   * 流拍&#13;
   *     abortive=1，并且finished为1 流拍。（退币）&#13;
   */&#13;
  function getGuessStatus(uint256 guessId) &#13;
    internal &#13;
    view&#13;
    returns(GuessStatus) {&#13;
      GuessStatus gs;&#13;
      Guess memory guess = guesses[guessId];&#13;
      uint256 _now = now; &#13;
      if(guess.startAt &gt; _now) {&#13;
        gs = GuessStatus.NotStarted;&#13;
      } else if((guess.startAt &lt;= _now &amp;&amp; _now &lt;= guess.endAt)&#13;
                 &amp;&amp; guess.finished == 0 &#13;
                 &amp;&amp; guess.abortive == 0 ) {&#13;
        gs = GuessStatus.Progress;&#13;
      } else if(_now &gt; guess.endAt &amp;&amp; guess.finished == 0) {&#13;
        gs = GuessStatus.Deadline;&#13;
      } else if(_now &gt; guess.endAt &amp;&amp; guess.finished == 1 &amp;&amp; guess.abortive == 0) {&#13;
        gs = GuessStatus.Finished;  &#13;
      } else if(guess.abortive == 1 &amp;&amp; guess.finished == 1){&#13;
        gs = GuessStatus.Abortive; &#13;
      }&#13;
    return gs;&#13;
  }&#13;
  &#13;
  //判断选项是否存在&#13;
  function optionExist(uint256 guessId,uint256 optionId)&#13;
    internal&#13;
    view&#13;
    returns(bool){&#13;
      Option[] memory _options = options[guessId];&#13;
      for (uint8 i = 0; i &lt; _options.length; i++) {&#13;
         if(optionId == _options[i].id){&#13;
            return true;&#13;
         }&#13;
      }&#13;
      return false;&#13;
  }&#13;
    &#13;
  function() public payable {&#13;
  }&#13;
&#13;
  /**&#13;
   * 修改预测系统变量&#13;
   * @author linq&#13;
   */&#13;
  function modifyVariable&#13;
    (&#13;
        address _platformAddress, &#13;
        uint256 _serviceChargeRate, &#13;
        uint256 _maintenanceChargeRate,&#13;
        uint256 _upperLimit,&#13;
        uint256 _lowerLimit&#13;
    ) &#13;
    public &#13;
    onlyOwner {&#13;
      platformAddress = _platformAddress;&#13;
      serviceChargeRate = _serviceChargeRate;&#13;
      maintenanceChargeRate = _maintenanceChargeRate;&#13;
      upperLimit = _upperLimit * 10 ** 18;&#13;
      lowerLimit = _lowerLimit * 10 ** 18;&#13;
  }&#13;
  &#13;
   // 创建预测事件&#13;
  function createGuess(&#13;
       uint256 _id, &#13;
       string _title,&#13;
       string _source, &#13;
       string _category,&#13;
       uint8 _disabled,&#13;
       bytes _desc, &#13;
       uint256 _startAt, &#13;
       uint256 _endAt,&#13;
       uint256[] _optionId, &#13;
       bytes32[] _optionName&#13;
       ) &#13;
       public &#13;
       whenNotPaused {&#13;
        require(guesses[_id].id == uint256(0), "The current guess already exists !!!");&#13;
        require(_optionId.length == _optionName.length, "please check options !!!");&#13;
        &#13;
        guesses[_id] = Guess(_id,&#13;
              msg.sender,&#13;
              _title,&#13;
              _source,&#13;
              _category,&#13;
              _disabled,&#13;
              _desc,&#13;
              _startAt,&#13;
              _endAt,&#13;
              0,&#13;
              0&#13;
            );&#13;
            &#13;
        Option[] storage _options = options[_id];&#13;
        for (uint8 i = 0;i &lt; _optionId.length; i++) {&#13;
            require(!optionExist(_id,_optionId[i]),"The current optionId already exists !!!");&#13;
            _options.push(Option(_optionId[i],_optionName[i]));&#13;
        }&#13;
    &#13;
    emit CreateGuess(_id, msg.sender);&#13;
  }&#13;
&#13;
&#13;
    /**&#13;
     * 审核|更新预测事件&#13;
     */&#13;
    function auditGuess&#13;
    (&#13;
        uint256 _id,&#13;
        string _title,&#13;
        uint8 _disabled,&#13;
        bytes _desc, &#13;
        uint256 _endAt) &#13;
        public &#13;
        onlyOwner&#13;
    {&#13;
        require(guesses[_id].id != uint256(0), "The current guess not exists !!!");&#13;
        require(getGuessStatus(_id) == GuessStatus.NotStarted, "The guess cannot audit !!!");&#13;
        Guess storage guess = guesses[_id];&#13;
        guess.title = _title;&#13;
        guess.disabled = _disabled;&#13;
        guess.desc = _desc;&#13;
        guess.endAt = _endAt;&#13;
   }&#13;
&#13;
  /**&#13;
   * 用户直接参与事件预测&#13;
   */ &#13;
//   function deposit(uint256 id, uint256 optionId, uint256 bean) &#13;
//     public&#13;
//     payable&#13;
//     whenNotPaused&#13;
//     returns (bool) {&#13;
//       require(!disabled(id), "The guess disabled!!!");&#13;
//       require(getGuessStatus(id) == GuessStatus.Progress, "The guess cannot participate !!!");&#13;
//       require(bean &gt;= lowerLimit &amp;&amp; bean &lt;= upperLimit, "Bean quantity nonconformity!!!");&#13;
      &#13;
//       // 存储用户订单&#13;
//       Order memory order = Order(msg.sender, bean);&#13;
//       orders[id][optionId].push(order);&#13;
//       // 某用户订单该选项总投注数&#13;
//       userOptionTotalBean[optionId][msg.sender] += bean;&#13;
//       // 存储事件总投注&#13;
//       guessTotalBean[id] += bean;&#13;
//       MOS.transferFrom(msg.sender, address(this), bean);&#13;
    &#13;
//       emit Deposit(id, msg.sender, optionId, bean);&#13;
//       return true;&#13;
//   }&#13;
&#13;
   /**&#13;
    * 平台代理用户参与事件预测&#13;
    */&#13;
  function depositAgent&#13;
  (&#13;
      uint256 id, &#13;
      uint256 optionId, &#13;
      string ipfsBase58,&#13;
      string dataHash,&#13;
      uint256 totalBean&#13;
  ) &#13;
    public&#13;
    onlyOperator&#13;
    whenNotPaused&#13;
    returns (bool) {&#13;
    require(guesses[id].id != uint256(0), "The current guess not exists !!!");&#13;
    require(optionExist(id, optionId),"The current optionId not exists !!!");&#13;
    require(!disabled(id), "The guess disabled!!!");&#13;
    require(getGuessStatus(id) == GuessStatus.Deadline, "The guess cannot participate !!!");&#13;
    &#13;
    // 通过预测事件ID和选项ID，存储该选项所有参与的地址&#13;
    AgentOrder[] storage _agentOrders = agentOrders[id][optionId];&#13;
    &#13;
     AgentOrder memory agentOrder = AgentOrder(msg.sender,ipfsBase58,dataHash,totalBean);&#13;
    _agentOrders.push(agentOrder);&#13;
   &#13;
    MOS.transferFrom(msg.sender, address(this), totalBean);&#13;
    &#13;
    // 某用户订单该选项总投注数&#13;
    // userOptionTotalBean[optionId][msg.sender] += totalBean;&#13;
    // 订单选项总投注 &#13;
    optionTotalBean[id][optionId] += totalBean;&#13;
    // 存储事件总投注&#13;
    guessTotalBean[id] += totalBean;&#13;
    &#13;
    emit DepositAgent(msg.sender, id, optionId, totalBean);&#13;
    return true;&#13;
  }&#13;
  &#13;
&#13;
    /**&#13;
     * 公布事件的结果&#13;
     */ &#13;
    function publishOption(uint256 id, uint256 optionId) &#13;
      public &#13;
      onlyOwner&#13;
      whenNotPaused&#13;
      returns (bool) {&#13;
      require(guesses[id].id != uint256(0), "The current guess not exists !!!");&#13;
      require(optionExist(id, optionId),"The current optionId not exists !!!");&#13;
      require(!disabled(id), "The guess disabled!!!");&#13;
      require(getGuessStatus(id) == GuessStatus.Deadline, "The guess cannot publish !!!");&#13;
      Guess storage guess = guesses[id];&#13;
      guess.finished = 1;&#13;
      // 该预测时间总投注 &#13;
      uint256 totalBean = guessTotalBean[id];&#13;
      // 成功选项投注总数&#13;
      uint256 _optionTotalBean = optionTotalBean[id][optionId];&#13;
      // 判断是否低赔率事件&#13;
      uint256 odds = totalBean * (100 - serviceChargeRate - maintenanceChargeRate) / _optionTotalBean;&#13;
      &#13;
      AgentOrder[] memory _agentOrders = agentOrders[id][optionId];&#13;
      if(odds &gt;= uint256(100)){&#13;
        // 平台收取手续费&#13;
        uint256 platformFee = totalBean * (serviceChargeRate + maintenanceChargeRate) / 100;&#13;
        MOS.transfer(platformAddress, platformFee);&#13;
        &#13;
        for(uint8 i = 0; i&lt; _agentOrders.length; i++){&#13;
            MOS.transfer(_agentOrders[i].participant, (totalBean - platformFee) &#13;
                        * _agentOrders[i].bean &#13;
                        / _optionTotalBean);&#13;
        }&#13;
      } else {&#13;
        // 低赔率事件，平台不收取手续费&#13;
        for(uint8 j = 0; j&lt; _agentOrders.length; j++){&#13;
            MOS.transfer(_agentOrders[j].participant, totalBean&#13;
                        * _agentOrders[j].bean&#13;
                        / _optionTotalBean);&#13;
        }&#13;
      }&#13;
&#13;
      emit PublishOption(id, optionId, odds);&#13;
      return true;&#13;
    }&#13;
    &#13;
    &#13;
    /**&#13;
     * 事件流拍&#13;
     */&#13;
    function abortive(uint256 id) &#13;
        public &#13;
        onlyOwner&#13;
        returns(bool) {&#13;
        require(guesses[id].id != uint256(0), "The current guess not exists !!!");&#13;
        require(getGuessStatus(id) == GuessStatus.Progress ||&#13;
                getGuessStatus(id) == GuessStatus.Deadline, "The guess cannot abortive !!!");&#13;
    &#13;
        Guess storage guess = guesses[id];&#13;
        guess.abortive = 1;&#13;
        guess.finished = 1;&#13;
        // 退回&#13;
        Option[] memory _options = options[id];&#13;
        &#13;
        for(uint8 i = 0; i&lt; _options.length;i ++){&#13;
            //代投退回&#13;
            AgentOrder[] memory _agentOrders = agentOrders[id][_options[i].id];&#13;
            for(uint8 j = 0; j &lt; _agentOrders.length; j++){&#13;
                uint256 _bean = _agentOrders[j].bean;&#13;
                MOS.transfer(_agentOrders[j].participant, _bean);&#13;
            }&#13;
        }&#13;
        emit Abortive(id);&#13;
        return true;&#13;
    }&#13;
    &#13;
    // /**&#13;
    //  * 获取事件投注总额 &#13;
    //  */ &#13;
    // function guessTotalBeanOf(uint256 id) public view returns(uint256){&#13;
    //     return guessTotalBean[id];&#13;
    // }&#13;
    &#13;
    // /**&#13;
    //  * 获取事件选项代投订单信息&#13;
    //  */ &#13;
    // function agentOrdersOf(uint256 id,uint256 optionId) &#13;
    //     public &#13;
    //     view &#13;
    //     returns(&#13;
    //         address participant,&#13;
    //         address[] users,&#13;
    //         uint256[] beans&#13;
    //     ) {&#13;
    //     AgentOrder[] memory agentOrder = agentOrders[id][optionId];&#13;
    //     return (&#13;
    //         agentOrder.participant, &#13;
    //         agentOrder.users, &#13;
    //         agentOrder.beans&#13;
    //     );&#13;
    // }&#13;
    &#13;
    &#13;
    // /**&#13;
    //  * 获取用户直投订单 &#13;
    //  */ &#13;
    // function ordersOf(uint256 id, uint256 optionId) public view &#13;
    //     returns(address[] users,uint256[] beans){&#13;
    //     Order[] memory _orders = orders[id][optionId];&#13;
    //     address[] memory _users;&#13;
    //     uint256[] memory _beans;&#13;
        &#13;
    //     for (uint8 i = 0; i &lt; _orders.length; i++) {&#13;
    //         _users[i] = _orders[i].user;&#13;
    //         _beans[i] = _orders[i].bean;&#13;
    //     }&#13;
    //     return (_users, _beans);&#13;
    // }&#13;
&#13;
}&#13;
&#13;
&#13;
contract MosesContract is GuessBaseBiz {&#13;
//   // MOS合约地址 &#13;
//   address internal INITIAL_MOS_CONTRACT_ADDRESS = 0x001439818dd11823c45fff01af0cd6c50934e27ac0;&#13;
//   // 平台地址&#13;
//   address internal INITIAL_PLATFORM_ADDRESS = 0x00063150d38ac0b008abe411ab7e4fb8228ecead3e;&#13;
//   // 平台手续费&#13;
//   uint256 internal INITIAL_SERVICE_CHARGE_RATE = 5;&#13;
//   // 平台维护费&#13;
//   uint256 internal INITIAL_MAINTENANCE_CHARGE_RATE = 0;&#13;
//   // 单次上限&#13;
//   uint256 UPPER_LIMIT = 1000 * 10 ** 18;&#13;
//   // 单次下限&#13;
//   uint256 LOWER_LIMIT = 1 * 10 ** 18;&#13;
  &#13;
  &#13;
  constructor(address[] _operators) public {&#13;
    for(uint8 i = 0; i&lt; _operators.length; i++) {&#13;
        operators[_operators[i]] = uint8(1);&#13;
    }&#13;
  }&#13;
&#13;
    /**&#13;
     *  Recovery donated ether&#13;
     */&#13;
    function collectEtherBack(address collectorAddress) public onlyOwner {&#13;
        uint256 b = address(this).balance;&#13;
        require(b &gt; 0);&#13;
        require(collectorAddress != 0x0);&#13;
&#13;
        collectorAddress.transfer(b);&#13;
    }&#13;
&#13;
    /**&#13;
    *  Recycle other ERC20 tokens&#13;
    */&#13;
    function collectOtherTokens(address tokenContract, address collectorAddress) onlyOwner public returns (bool) {&#13;
        ERC20Token t = ERC20Token(tokenContract);&#13;
&#13;
        uint256 b = t.balanceOf(address(this));&#13;
        return t.transfer(collectorAddress, b);&#13;
    }&#13;
&#13;
}