pragma solidity ^0.4.13;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="4735222a24280775">[email protected]</span>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private rentrancy_lock = false;&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * @notice If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one nonReentrant function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and a `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(!rentrancy_lock);&#13;
    rentrancy_lock = true;&#13;
    _;&#13;
    rentrancy_lock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
// Minimal Bitcoineum interface for proxy mining&#13;
contract BitcoineumInterface {&#13;
   function mine() payable;&#13;
   function claim(uint256 _blockNumber, address forCreditTo);&#13;
   function checkMiningAttempt(uint256 _blockNum, address _sender) constant public returns (bool);&#13;
   function checkWinning(uint256 _blockNum) constant public returns (bool);&#13;
   function transfer(address _to, uint256 _value) returns (bool);&#13;
   function balanceOf(address _owner) constant returns (uint256 balance);&#13;
   function currentDifficultyWei() constant public returns (uint256);&#13;
   }&#13;
&#13;
&#13;
// Sharkpool is a rolling window Bitcoineum miner&#13;
// Smart contract based virtual mining&#13;
// http://www.bitcoineum.com/&#13;
&#13;
contract SharkPool is Ownable, ReentrancyGuard {&#13;
&#13;
    string constant public pool_name = "SharkPool 100";&#13;
&#13;
    // Percentage of BTE pool takes for operations&#13;
    uint256 public pool_percentage = 0;&#13;
&#13;
    // Limiting users because of gas limits&#13;
    // I would not increase this value it could make the pool unstable&#13;
    uint256 constant public max_users = 100;&#13;
&#13;
    // Track total users to switch to degraded case when contract is full&#13;
    uint256 public total_users = 0;&#13;
&#13;
    uint256 public constant divisible_units = 10000000;&#13;
&#13;
    // How long will a payment event mine blocks for you&#13;
    uint256 public contract_period = 100;&#13;
    uint256 public mined_blocks = 1;&#13;
    uint256 public claimed_blocks = 1;&#13;
    uint256 public blockCreationRate = 0;&#13;
&#13;
    BitcoineumInterface base_contract;&#13;
&#13;
    struct user {&#13;
        uint256 start_block;&#13;
        uint256 end_block;&#13;
        uint256 proportional_contribution;&#13;
    }&#13;
&#13;
    mapping (address =&gt; user) public users;&#13;
    mapping (uint256 =&gt; uint256) public attempts;&#13;
    mapping(address =&gt; uint256) balances;&#13;
    uint8[] slots;&#13;
    address[256] public active_users; // Should equal max_users&#13;
&#13;
    function balanceOf(address _owner) constant returns (uint256 balance) {&#13;
      return balances[_owner];&#13;
    }&#13;
&#13;
    function set_pool_percentage(uint8 _percentage) external nonReentrant onlyOwner {&#13;
       // Just in case owner is compromised&#13;
       require(_percentage &lt; 6);&#13;
       pool_percentage = _percentage;&#13;
    }&#13;
&#13;
&#13;
    function find_contribution(address _who) constant external returns (uint256, uint256, uint256, uint256, uint256) {&#13;
      if (users[_who].start_block &gt; 0) {&#13;
         user memory u = users[_who];&#13;
         uint256 remaining_period= 0;&#13;
         if (u.end_block &gt; mined_blocks) {&#13;
            remaining_period = u.end_block - mined_blocks;&#13;
            } else {&#13;
            remaining_period = 0;&#13;
            }&#13;
         return (u.start_block, u.end_block,&#13;
                 u.proportional_contribution,&#13;
                 u.proportional_contribution * contract_period,&#13;
                 u.proportional_contribution * remaining_period);&#13;
      }&#13;
      return (0,0,0,0,0);&#13;
    }&#13;
&#13;
    function allocate_slot(address _who) internal {&#13;
       if(total_users &lt; max_users) { &#13;
            // Just push into active_users&#13;
            active_users[total_users] = _who;&#13;
            total_users += 1;&#13;
          } else {&#13;
            // The maximum users have been reached, can we allocate a free space?&#13;
            if (slots.length == 0) {&#13;
                // There isn't any room left&#13;
                revert();&#13;
            } else {&#13;
               uint8 location = slots[slots.length-1];&#13;
               active_users[location] = _who;&#13;
               delete slots[slots.length-1];&#13;
            }&#13;
          }&#13;
    }&#13;
&#13;
     function external_to_internal_block_number(uint256 _externalBlockNum) public constant returns (uint256) {&#13;
        // blockCreationRate is &gt; 0&#13;
        return _externalBlockNum / blockCreationRate;&#13;
     }&#13;
&#13;
     function available_slots() public constant returns (uint256) {&#13;
        if (total_users &lt; max_users) {&#13;
            return max_users - total_users;&#13;
        } else {&#13;
          return slots.length;&#13;
        }&#13;
     }&#13;
  &#13;
   event LogEvent(&#13;
       uint256 _info&#13;
   );&#13;
&#13;
    function get_bitcoineum_contract_address() public constant returns (address) {&#13;
       return 0x73dD069c299A5d691E9836243BcaeC9c8C1D8734; // Production&#13;
    &#13;
       // return 0x7e7a299da34a350d04d204cd80ab51d068ad530f; // Testing&#13;
    }&#13;
&#13;
    // iterate over all account holders&#13;
    // and balance transfer proportional bte&#13;
    // balance should be 0 aftwards in a perfect world&#13;
    function distribute_reward(uint256 _totalAttempt, uint256 _balance) internal {&#13;
      uint256 remaining_balance = _balance;&#13;
      for (uint8 i = 0; i &lt; total_users; i++) {&#13;
          address user_address = active_users[i];&#13;
          if (user_address &gt; 0 &amp;&amp; remaining_balance != 0) {&#13;
              uint256 proportion = users[user_address].proportional_contribution;&#13;
              uint256 divided_portion = (proportion * divisible_units) / _totalAttempt;&#13;
              uint256 payout = (_balance * divided_portion) / divisible_units;&#13;
              if (payout &gt; remaining_balance) {&#13;
                 payout = remaining_balance;&#13;
              }&#13;
              balances[user_address] = balances[user_address] + payout;&#13;
              remaining_balance = remaining_balance - payout;&#13;
          }&#13;
      }&#13;
    }&#13;
&#13;
    function SharkPool() {&#13;
      blockCreationRate = 50; // match bte&#13;
      base_contract = BitcoineumInterface(get_bitcoineum_contract_address());&#13;
    }&#13;
&#13;
    function current_external_block() public constant returns (uint256) {&#13;
        return block.number;&#13;
    }&#13;
&#13;
&#13;
    function calculate_minimum_contribution() public constant returns (uint256)  {&#13;
       return base_contract.currentDifficultyWei() / 10000000 * contract_period;&#13;
    }&#13;
&#13;
    // A default ether tx without gas specified will fail.&#13;
    function () payable {&#13;
         require(msg.value &gt;= calculate_minimum_contribution());&#13;
&#13;
         // Did the user already contribute&#13;
         user storage current_user = users[msg.sender];&#13;
&#13;
         // Does user exist already&#13;
         if (current_user.start_block &gt; 0) {&#13;
            if (current_user.end_block &gt; mined_blocks) {&#13;
                uint256 periods_left = current_user.end_block - mined_blocks;&#13;
                uint256 amount_remaining = current_user.proportional_contribution * periods_left;&#13;
                amount_remaining = amount_remaining + msg.value;&#13;
                amount_remaining = amount_remaining / contract_period;&#13;
                current_user.proportional_contribution = amount_remaining;&#13;
            } else {&#13;
               current_user.proportional_contribution = msg.value / contract_period;&#13;
            }&#13;
&#13;
          // If the user exists and has a balance let's transfer it to them&#13;
          do_redemption();&#13;
&#13;
          } else {&#13;
               current_user.proportional_contribution = msg.value / contract_period;&#13;
               allocate_slot(msg.sender);&#13;
          }&#13;
          current_user.start_block = mined_blocks;&#13;
          current_user.end_block = mined_blocks + contract_period;&#13;
         }&#13;
&#13;
    &#13;
    // Proxy mining to token&#13;
   function mine() external nonReentrant&#13;
   {&#13;
     // Did someone already try to mine this block?&#13;
     uint256 _blockNum = external_to_internal_block_number(current_external_block());&#13;
     require(!base_contract.checkMiningAttempt(_blockNum, this));&#13;
&#13;
     // Alright nobody mined lets iterate over our active_users&#13;
&#13;
     uint256 total_attempt = 0;&#13;
     uint8 total_ejected = 0; &#13;
&#13;
     for (uint8 i=0; i &lt; total_users; i++) {&#13;
         address user_address = active_users[i];&#13;
         if (user_address &gt; 0) {&#13;
             // This user exists&#13;
             user memory u = users[user_address];&#13;
             if (u.end_block &lt;= mined_blocks) {&#13;
                // This user needs to be ejected, no more attempts left&#13;
                // but we limit to 20 to prevent gas issues on slot insert&#13;
                if (total_ejected &lt; 10) {&#13;
                    delete active_users[i];&#13;
                    slots.push(i);&#13;
                    delete users[active_users[i]];&#13;
                    total_ejected = total_ejected + 1;&#13;
                }&#13;
             } else {&#13;
               // This user is still active&#13;
               total_attempt = total_attempt + u.proportional_contribution;&#13;
             }&#13;
         }&#13;
     }&#13;
     if (total_attempt &gt; 0) {&#13;
        // Now we have a total contribution amount&#13;
        attempts[_blockNum] = total_attempt;&#13;
        base_contract.mine.value(total_attempt)();&#13;
        mined_blocks = mined_blocks + 1;&#13;
     }&#13;
   }&#13;
&#13;
   function claim(uint256 _blockNumber, address forCreditTo)&#13;
                  nonReentrant&#13;
                  external returns (bool) {&#13;
                  &#13;
                  // Did we win the block in question&#13;
                  require(base_contract.checkWinning(_blockNumber));&#13;
&#13;
                  uint256 initial_balance = base_contract.balanceOf(this);&#13;
&#13;
                  // We won let's get our reward&#13;
                  base_contract.claim(_blockNumber, this);&#13;
&#13;
                  uint256 balance = base_contract.balanceOf(this);&#13;
                  uint256 total_attempt = attempts[_blockNumber];&#13;
&#13;
                  distribute_reward(total_attempt, balance - initial_balance);&#13;
                  claimed_blocks = claimed_blocks + 1;&#13;
                  }&#13;
&#13;
   function do_redemption() internal {&#13;
     uint256 balance = balances[msg.sender];&#13;
     if (balance &gt; 0) {&#13;
        uint256 owner_cut = (balance / 100) * pool_percentage;&#13;
        uint256 remainder = balance - owner_cut;&#13;
        if (owner_cut &gt; 0) {&#13;
            base_contract.transfer(owner, owner_cut);&#13;
        }&#13;
        base_contract.transfer(msg.sender, remainder);&#13;
        balances[msg.sender] = 0;&#13;
    }&#13;
   }&#13;
&#13;
   function redeem() external nonReentrant&#13;
     {&#13;
        do_redemption();&#13;
     }&#13;
&#13;
   function checkMiningAttempt(uint256 _blockNum, address _sender) constant public returns (bool) {&#13;
      return base_contract.checkMiningAttempt(_blockNum, _sender);&#13;
   }&#13;
   &#13;
   function checkWinning(uint256 _blockNum) constant public returns (bool) {&#13;
     return base_contract.checkWinning(_blockNum);&#13;
   }&#13;
&#13;
}