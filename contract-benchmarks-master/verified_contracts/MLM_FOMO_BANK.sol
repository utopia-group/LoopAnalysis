pragma solidity ^0.4.25;

/*  
     ==================================================================
    ||  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ||
    ||  + Digital Multi Level Marketing in Ethereum smart-contract +  ||
    ||  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ||
     ==================================================================
     
    https://ethmlm.com
    https://t.me/ethmlm
    
    
         ``..................``  ``....................``  ``..``             ``.``          
        `..,,,,,,,,,,,,,,,,,,.` ``.,,,,,,,,,,,,,,,,,,,,.`  `.,,.`            `..,.``         
        `.:::::,,,,,,,,,,,,,,.```.,,,,,,,:::::::,,,,,,,.`  `,::,.            `.,:,.`         
        `,:;:,,...............`  `.......,,:;::,,.......`  .,::,.`           `.:;,.`         
        `,:;:,.```````````````   ````````.,:::,.````````   .,::,.`           `.:;,.`         
     ++++++++++++++++++++    ++++++++++++++++++++++,   ,+++.,::,.`        ++++.:;,.`         
     ####################    ######################:   ,###.,::,.`        ####.:;,.`         
     ###';'';;:::::::::::````:::::::::+###;;'';::::.   ,###.,::,.`````````####,:;,.`         
     ###;,:;:,,.............``        +###.,::,`       ,###.,:;:,,........####::;,.`         
     ###;,:;:::,,,,,,,,,,,,,.`        +###.,::,`       ,###.,:;::,,,,,,,,,####::;,.`         
     ###;,:;::,,,,,,,,,,,,,,.`        +###.,::,`       ,###.,:;::,,,,,,,,,####::;,.`         
     ###;,:;:,..............``        +###.,::,`       ,###.,:::,.````````####,:;,.`         
     ###;,:;:.``````````````          +###.,::,`       ,###.,::,.`        ####,:;,.`         
     ###################              +###.,::,`       ,######################.:;,.`         
     ###################              +###.,::,`       ,######################.:;,.`         
     ###;,:;:.````````````````        +###.,::,`       ,###.,::,.`        ####.:;,.`         
     ###;,:;:,................``      +###.,::,`       ,###.,::,.`        ####.:;,.`         
     ###;,:;:::,,,,,,,,,,,,,,,.`      +###.,::,`       ,###.,::,.`        ####.:;,.`         
     ###:.,,,,,,,,,,,,,,,,,,,,.`      +###`.,,.`       ,###`.,,.`         ####.,,,.`         
     ###:`....................``      +###``..``       ,###``..``         ####`...`          
     ###: `````````````````````       +### ````        ,### ````          #### ```           
     #####################            +###             ,###               ####               
     #####################            +###             ,###               ####               
     ,,,,,,,,,,,,,,,,,,,,,     `````` .,,,`````        `,,,     ```````   ,,,,        `````` 
        `..,,,.``             `..,,.``   ``.,.`                `..,,,.``             `..,,.``
        `.::::,.`            `.,:::,.`   `.,:,.`               `.,:::,.`            `.,:::,.`
        .,:;;;:,.`           .,:;;;:.`   `,:;,.`               .,:;;;:,.`           .,:;;;:,`
        .,:;::::,`          `.,:;;;:.`   `,:;,.`               .,:;::::,`          `.,:::;:,`
        .,::::::,.`        `.,::::;:.`   `,:;,.`               .,:;::::,.`        `.,::::;:,`
    .#####+::,,::,`       ######::;:.,###`,:;,.`            ######::::::,`       +#####::;:,`
    .######:,,,::,.`      ######,:;:.,###`,:;,.`            ######:,,,::,.`      ######,,;:,`
    .######+,..,::,`     #######,:;:.,###`,:;,.`            ###'###,..,::,`     #######.,;:,`
    .###.###,.`.,:,.`   .##+####.:;:.,###`,:;,.`            ###.###,.`.,:,.`    #######.,;:,`
    .###.+###.``,::,`   ###:####.:;:.,###`,:;,.`            ###.'###.`.,::,`   ###:####.,;:,`
    .###.,###. `.,:,.` :##':####.:;:.,###`,:;,.`            ###.,###,``.,:,.` `##+:####.,;:,`
    .###.,+###  `,::,.`###:,####.:;:.,###`,:;,.`            ###.,'###` `,::,. ###:,####.,;:,`
    .###.,:###` `.,::.'##;:,####.:;:.,###`,:;,.`            ###.,:###, `.,::.,##':,####.,;:,`
    .###.,:'###  `,::,###:,.####.:;:.,###`,:;,.`            ###.,:;###  `,::,###:,.####.,;:,`
    .###.,::###` `.,:+##::,`####.:;:.,###`,:;,.`            ###.,::###: `.,:'##;:,`####.,;:,`
    .###.,::;###  `,:###:,.`####.:;:.,###`,:;:,............`###.,::,###  `,:###:,.`####.,;:,`
    .###.,::,###. `.###::,` ####.:;:.,###`,:;::,,,,,,,,,,,,.###.,::,###; `.+##;:,` ####.,;:,`
    .###`.::.,###  `##+:,.` ####.,:,.,###`.,:::,,,,,,,,,,,,.###`.,:,.###  `###:,.` ####.,:,.`
    .###`....`###, ###,..`  ####`.,.`,###``.,,,,,,,,,,,,,,..###`....`###' +##,..`  ####`.,.``
    .### ```` `###`##'```   ####`````,### ``````````````````### ````  ### ##+```   ####````` 
    .###       ######       ####     .###                   ###       +#####       ####      
    .###        ####,       ####     .#################     ###        ####'       ####      
    .###        ####        ####     .#################     ###        '###        ####     
    

*/

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}
/**
 * Utility library of inline functions on addresses
 */
library Address {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param account address of the account to check
   * @return whether the target address is a contract
   */
  function isContract(address account) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(account) }
    return size > 0;
  }

}
/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="087a6d656b67483a">[email protected]</a>π.com&gt;, Eenae &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2b4a474e534e526b46425349525f4e58054244">[email protected]</a>&gt;&#13;
 * @dev If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /// @dev counter to allow mutex lock with only one SSTORE operation&#13;
  uint256 private _guardCounter;&#13;
&#13;
  constructor() internal {&#13;
    // The counter starts at one to prevent changing it from zero to a non-zero&#13;
    // value, which is a more expensive operation.&#13;
    _guardCounter = 1;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * Calling a `nonReentrant` function from another `nonReentrant`&#13;
   * function is not supported. It is possible to prevent this from happening&#13;
   * by making the `nonReentrant` function external, and make it call a&#13;
   * `private` function that does the actual work.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    _guardCounter += 1;&#13;
    uint256 localCounter = _guardCounter;&#13;
    _;&#13;
    require(localCounter == _guardCounter);&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
contract MLM_FOMO_BANK is Ownable {&#13;
    using SafeMath for uint256;&#13;
    &#13;
    //  time to win FOMO bank&#13;
    uint public fomo_period = 3600;     // 1 hour&#13;
    &#13;
    //  FOMO bank balance&#13;
    uint public balance;&#13;
    //  next winner address&#13;
    address public winner;&#13;
    //  win time&#13;
    uint public finish_time;&#13;
    &#13;
    //  MLM contract&#13;
    address _mlm;&#13;
    &#13;
    //  only MLM contract can call method&#13;
    modifier onlyMLM() {&#13;
        require(msg.sender == _mlm);&#13;
        _;&#13;
    }&#13;
&#13;
    &#13;
    event Win(address indexed user, uint amount);&#13;
    &#13;
    &#13;
    function SetMLM(address mlm) public onlyOwner {&#13;
        _mlm = mlm;&#13;
    }&#13;
    &#13;
    //  fill the bank&#13;
    function AddToBank(address user) public payable onlyMLM {&#13;
        //  check for winner&#13;
        CheckWinner();&#13;
        &#13;
        // save last payment info&#13;
        balance = balance.add(msg.value);&#13;
        winner = user;&#13;
        finish_time = now + fomo_period;&#13;
    }&#13;
    &#13;
    // check winner&#13;
    function CheckWinner() internal {&#13;
        if(now &gt; finish_time &amp;&amp; winner != address(0)){&#13;
            emit Win(winner, balance);&#13;
            &#13;
            //  it should not be reentrancy, but just in case&#13;
            uint prev_balance = balance;&#13;
            balance = 0;&#13;
            //  send ethers to winner&#13;
            winner.transfer(prev_balance);&#13;
            winner = address(0);&#13;
        }&#13;
    }&#13;
    &#13;
    //  get cuurent FOMO info {balance, finish_time, winner }&#13;
    function GetInfo() public view returns (uint, uint, address) {&#13;
        return (&#13;
            balance,&#13;
            finish_time,&#13;
            winner&#13;
        );&#13;
    }&#13;
}&#13;
&#13;
contract MLM is Ownable, ReentrancyGuard {&#13;
    using SafeMath for uint256;&#13;
    using Address for address;&#13;
    &#13;
    // FOMO bank contract&#13;
    MLM_FOMO_BANK _fomo;&#13;
    &#13;
    struct userStruct {&#13;
        address[] referrers;    //  array with 3 level referrers&#13;
        address[] referrals;    //  array with referrals&#13;
        uint next_payment;      //  time to next payments, seconds&#13;
        bool isRegitered;       //  is user registered&#13;
        bytes32 ref_link;       //  referral link&#13;
    }&#13;
    &#13;
    // mapping with users&#13;
    mapping(address=&gt;userStruct) users;&#13;
    //  mapping with referral links&#13;
    mapping(bytes32=&gt;address) ref_to_users;&#13;
    &#13;
    uint public min_paymnet = 100 finney;               //  minimum payment amount 0,1ETH&#13;
    uint public min_time_to_add = 604800;               //  Time need to add after miimum payment, seconds | 1 week&#13;
    uint[] public reward_parts = [35, 25, 15, 15, 10];  //  how much need to send to referrers, %&#13;
&#13;
    event RegisterEvent(address indexed user, address indexed referrer);&#13;
    event PayEvent(address indexed payer, uint amount, bool[3] levels);&#13;
    &#13;
    &#13;
    constructor(MLM_FOMO_BANK fomo) public {&#13;
        //  set FOMO contract&#13;
        _fomo = fomo;&#13;
    }&#13;
    &#13;
&#13;
&#13;
    function() public payable {&#13;
        //  sender should not be a contract&#13;
        require(!address(msg.sender).isContract());&#13;
        //  user should be registered&#13;
        require(users[msg.sender].isRegitered);&#13;
        //  referrer address is 0x00 because user is already registered and referrer is stored on the first payment&#13;
        Pay(0x00);&#13;
    }&#13;
    &#13;
    &#13;
    /*&#13;
    Make a payment&#13;
    --------------&#13;
    [bytes32 referrer_addr] - referrer's address. it is used only on first payment to save sender as a referral&#13;
    */&#13;
    function Pay(bytes32 referrer_addr) public payable nonReentrant {&#13;
        //  sender should not be a contract&#13;
        require(!address(msg.sender).isContract());&#13;
        //  check minimum amount&#13;
        require(msg.value &gt;= min_paymnet);&#13;
        &#13;
        //  if it is a first payment need to register sender&#13;
        if(!users[msg.sender].isRegitered){&#13;
            _register(referrer_addr);&#13;
        }&#13;
        &#13;
        uint amount = msg.value;&#13;
        //  what referrer levels will received a payments, need on UI&#13;
        bool[3] memory levels = [false,false,false];&#13;
        //  iterate of sender's referrers&#13;
        for(uint i = 0; i &lt; users[msg.sender].referrers.length; i++){&#13;
            //  referrer address at level i&#13;
            address ref = users[msg.sender].referrers[i];&#13;
            //  if referrer is active need to pay him&#13;
            if(users[ref].next_payment &gt; now){&#13;
                //  calculate reward part, i.e. 0.1 * 35 / 100  = 0.035&#13;
                uint reward = amount.mul(reward_parts[i]).div(100);&#13;
                //  send reward to referrer&#13;
                ref.transfer(reward);&#13;
                //  set referrer's level ad payment&#13;
                levels[i] = true;&#13;
            }&#13;
        }&#13;
        &#13;
        //  what address will be saved to FOMO bank, referrer or current sender&#13;
        address fomo_user = msg.sender;&#13;
        if(users[msg.sender].referrers.length&gt;0 &amp;&amp; users[users[msg.sender].referrers[0]].next_payment &gt; now)&#13;
            fomo_user = users[msg.sender].referrers[0];&#13;
            &#13;
        //  send 15% to FOMO bank and store selceted user&#13;
        _fomo.AddToBank.value(amount.mul(reward_parts[3]).div(100)).gas(gasleft())(fomo_user);&#13;
        &#13;
        // prolong referral link life&#13;
        if(now &gt; users[msg.sender].next_payment)&#13;
            users[msg.sender].next_payment = now.add(amount.mul(min_time_to_add).div(min_paymnet));&#13;
        else &#13;
            users[msg.sender].next_payment = users[msg.sender].next_payment.add(amount.mul(min_time_to_add).div(min_paymnet));&#13;
        &#13;
        emit PayEvent(msg.sender, amount, levels);&#13;
    }&#13;
    &#13;
    &#13;
    &#13;
    function _register(bytes32 referrer_addr) internal {&#13;
        // sender should not be registered&#13;
        require(!users[msg.sender].isRegitered);&#13;
        &#13;
        // get referrer address&#13;
        address referrer = ref_to_users[referrer_addr];&#13;
        // users could not be a referrer&#13;
        require(referrer!=msg.sender);&#13;
        &#13;
        //  if there is referrer&#13;
        if(referrer != address(0)){&#13;
            //  set refferers for currnet user&#13;
            _setReferrers(referrer, 0);&#13;
        }&#13;
        //  mark user as registered&#13;
        users[msg.sender].isRegitered = true;&#13;
        //  calculate referral link&#13;
        _getReferralLink(referrer);&#13;
        &#13;
&#13;
        emit RegisterEvent(msg.sender, referrer);&#13;
    }&#13;
    &#13;
    //  generate a referral link&#13;
    function _getReferralLink(address referrer) internal {&#13;
        do{&#13;
            users[msg.sender].ref_link = keccak256(abi.encodePacked(uint(msg.sender) ^  uint(referrer) ^ now));&#13;
        } while(ref_to_users[users[msg.sender].ref_link] != address(0));&#13;
        ref_to_users[users[msg.sender].ref_link] = msg.sender;&#13;
    }&#13;
    &#13;
    // set referrers&#13;
    function _setReferrers(address referrer, uint level) internal {&#13;
        //  set referrer only for active user other case use his referrer&#13;
        if(users[referrer].next_payment &gt; now){&#13;
            users[msg.sender].referrers.push(referrer);&#13;
            if(level == 0){&#13;
                //  add current user to referrer's referrals list&#13;
                users[referrer].referrals.push(msg.sender);&#13;
            }&#13;
            level++;&#13;
        }&#13;
        //  set referrers for 3 levels&#13;
        if(level&lt;3 &amp;&amp; users[referrer].referrers.length&gt;0)&#13;
            _setReferrers(users[referrer].referrers[0], level);&#13;
    }&#13;
    &#13;
    /*  Get user info&#13;
    &#13;
        uint next_payment&#13;
        bool isRegitered&#13;
        bytes32 ref_link&#13;
    */&#13;
    function GetUser() public view returns(uint, bool, bytes32) {&#13;
        return (&#13;
            users[msg.sender].next_payment,&#13;
            users[msg.sender].isRegitered,&#13;
            users[msg.sender].ref_link&#13;
        );&#13;
    }&#13;
    &#13;
    // Get sender's referrers&#13;
    function GetReferrers() public view returns(address[] memory) {&#13;
        return users[msg.sender].referrers;&#13;
    }&#13;
    &#13;
    //  Get sender's referrals&#13;
    function GetReferrals() public view returns(address[] memory) {&#13;
        return users[msg.sender].referrals;&#13;
    }&#13;
    &#13;
    //  Project's owner can widthdraw contract's balance&#13;
    function widthdraw(address to, uint amount) public onlyOwner {&#13;
        to.transfer(amount);&#13;
    }&#13;
}