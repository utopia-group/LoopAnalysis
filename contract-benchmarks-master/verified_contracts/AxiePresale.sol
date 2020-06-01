pragma solidity ^0.4.19;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: zeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e290878f818da2d0">[email protected]</a>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be send to this contract by:&#13;
 * calling functions labeled `payable`&#13;
 * `selfdestruct(contract_address)`&#13;
 * mining directly to the contract address&#13;
*/&#13;
contract HasNoEther is Ownable {&#13;
&#13;
  /**&#13;
  * @dev Constructor that rejects incoming Ether&#13;
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we&#13;
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable&#13;
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively&#13;
  * we could use assembly to access msg.value.&#13;
  */&#13;
  function HasNoEther() public payable {&#13;
    require(msg.value == 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Disallows direct send by settings a default function without the `payable` flag.&#13;
   */&#13;
  function() external {&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer all Ether held by the contract to the owner.&#13;
   */&#13;
  function reclaimEther() external onlyOwner {&#13;
    assert(owner.send(this.balance));&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/AxiePresale.sol&#13;
&#13;
contract AxiePresale is HasNoEther, Pausable {&#13;
  using SafeMath for uint256;&#13;
&#13;
  uint8 constant public CLASS_BEAST = 0;&#13;
  uint8 constant public CLASS_AQUATIC = 2;&#13;
  uint8 constant public CLASS_PLANT = 4;&#13;
&#13;
  uint256 constant public INITIAL_PRICE_INCREMENT = 1600 szabo; // 0.0016 Ether&#13;
  uint256 constant public INITIAL_PRICE = INITIAL_PRICE_INCREMENT;&#13;
  uint256 constant public REF_CREDITS_PER_AXIE = 5;&#13;
&#13;
  mapping (uint8 =&gt; uint256) public currentPrices;&#13;
  mapping (uint8 =&gt; uint256) public priceIncrements;&#13;
&#13;
  mapping (uint8 =&gt; uint256) public totalAxiesAdopted;&#13;
  mapping (address =&gt; mapping (uint8 =&gt; uint256)) public axiesAdopted;&#13;
&#13;
  mapping (address =&gt; uint256) public referralCredits;&#13;
  mapping (address =&gt; uint256) public axiesRewarded;&#13;
  uint256 public totalAxiesRewarded;&#13;
&#13;
  event AxiesAdopted(&#13;
    address indexed adopter,&#13;
    uint8 indexed clazz,&#13;
    uint256 quantity,&#13;
    address indexed referrer&#13;
  );&#13;
&#13;
  event AxiesRewarded(address indexed receiver, uint256 quantity);&#13;
&#13;
  event AdoptedAxiesRedeemed(address indexed receiver, uint8 indexed clazz, uint256 quantity);&#13;
  event RewardedAxiesRedeemed(address indexed receiver, uint256 quantity);&#13;
&#13;
  function AxiePresale() public {&#13;
    priceIncrements[CLASS_BEAST] = priceIncrements[CLASS_AQUATIC] = //&#13;
      priceIncrements[CLASS_PLANT] = INITIAL_PRICE_INCREMENT;&#13;
&#13;
    currentPrices[CLASS_BEAST] = currentPrices[CLASS_AQUATIC] = //&#13;
      currentPrices[CLASS_PLANT] = INITIAL_PRICE;&#13;
  }&#13;
&#13;
  function axiesPrice(&#13;
    uint256 beastQuantity,&#13;
    uint256 aquaticQuantity,&#13;
    uint256 plantQuantity&#13;
  )&#13;
    public&#13;
    view&#13;
    returns (uint256 totalPrice)&#13;
  {&#13;
    uint256 price;&#13;
&#13;
    (price,,) = _axiesPrice(CLASS_BEAST, beastQuantity);&#13;
    totalPrice = totalPrice.add(price);&#13;
&#13;
    (price,,) = _axiesPrice(CLASS_AQUATIC, aquaticQuantity);&#13;
    totalPrice = totalPrice.add(price);&#13;
&#13;
    (price,,) = _axiesPrice(CLASS_PLANT, plantQuantity);&#13;
    totalPrice = totalPrice.add(price);&#13;
  }&#13;
&#13;
  function adoptAxies(&#13;
    uint256 beastQuantity,&#13;
    uint256 aquaticQuantity,&#13;
    uint256 plantQuantity,&#13;
    address referrer&#13;
  )&#13;
    public&#13;
    payable&#13;
    whenNotPaused&#13;
  {&#13;
    require(beastQuantity &lt;= 3);&#13;
    require(aquaticQuantity &lt;= 3);&#13;
    require(plantQuantity &lt;= 3);&#13;
&#13;
    address adopter = msg.sender;&#13;
    address actualReferrer = 0x0;&#13;
&#13;
    // An adopter cannot be his/her own referrer.&#13;
    if (referrer != adopter) {&#13;
      actualReferrer = referrer;&#13;
    }&#13;
&#13;
    uint256 value = msg.value;&#13;
    uint256 price;&#13;
&#13;
    if (beastQuantity &gt; 0) {&#13;
      price = _adoptAxies(&#13;
        adopter,&#13;
        CLASS_BEAST,&#13;
        beastQuantity,&#13;
        actualReferrer&#13;
      );&#13;
&#13;
      require(value &gt;= price);&#13;
      value -= price;&#13;
    }&#13;
&#13;
    if (aquaticQuantity &gt; 0) {&#13;
      price = _adoptAxies(&#13;
        adopter,&#13;
        CLASS_AQUATIC,&#13;
        aquaticQuantity,&#13;
        actualReferrer&#13;
      );&#13;
&#13;
      require(value &gt;= price);&#13;
      value -= price;&#13;
    }&#13;
&#13;
    if (plantQuantity &gt; 0) {&#13;
      price = _adoptAxies(&#13;
        adopter,&#13;
        CLASS_PLANT,&#13;
        plantQuantity,&#13;
        actualReferrer&#13;
      );&#13;
&#13;
      require(value &gt;= price);&#13;
      value -= price;&#13;
    }&#13;
&#13;
    msg.sender.transfer(value);&#13;
&#13;
    // The current referral is ignored if the referrer's address is 0x0.&#13;
    if (actualReferrer != 0x0) {&#13;
      uint256 numCredit = referralCredits[actualReferrer]&#13;
        .add(beastQuantity)&#13;
        .add(aquaticQuantity)&#13;
        .add(plantQuantity);&#13;
&#13;
      uint256 numReward = numCredit / REF_CREDITS_PER_AXIE;&#13;
&#13;
      if (numReward &gt; 0) {&#13;
        referralCredits[actualReferrer] = numCredit % REF_CREDITS_PER_AXIE;&#13;
        axiesRewarded[actualReferrer] = axiesRewarded[actualReferrer].add(numReward);&#13;
        totalAxiesRewarded = totalAxiesRewarded.add(numReward);&#13;
        AxiesRewarded(actualReferrer, numReward);&#13;
      } else {&#13;
        referralCredits[actualReferrer] = numCredit;&#13;
      }&#13;
    }&#13;
  }&#13;
&#13;
  function redeemAdoptedAxies(&#13;
    address receiver,&#13;
    uint256 beastQuantity,&#13;
    uint256 aquaticQuantity,&#13;
    uint256 plantQuantity&#13;
  )&#13;
    public&#13;
    onlyOwner&#13;
    whenNotPaused&#13;
    returns (&#13;
      uint256 /* remainingBeastQuantity */,&#13;
      uint256 /* remainingAquaticQuantity */,&#13;
      uint256 /* remainingPlantQuantity */&#13;
    )&#13;
  {&#13;
    return (&#13;
      _redeemAdoptedAxies(receiver, CLASS_BEAST, beastQuantity),&#13;
      _redeemAdoptedAxies(receiver, CLASS_AQUATIC, aquaticQuantity),&#13;
      _redeemAdoptedAxies(receiver, CLASS_PLANT, plantQuantity)&#13;
    );&#13;
  }&#13;
&#13;
  function redeemRewardedAxies(&#13;
    address receiver,&#13;
    uint256 quantity&#13;
  )&#13;
    public&#13;
    onlyOwner&#13;
    whenNotPaused&#13;
    returns (uint256 remainingQuantity)&#13;
  {&#13;
    remainingQuantity = axiesRewarded[receiver] = axiesRewarded[receiver].sub(quantity);&#13;
&#13;
    if (quantity &gt; 0) {&#13;
      // This requires that rewarded Axies are always included in the total&#13;
      // to make sure overflow won't happen.&#13;
      totalAxiesRewarded -= quantity;&#13;
&#13;
      RewardedAxiesRedeemed(receiver, quantity);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Calculate price of Axies from the same class.&#13;
   * @param clazz The class of Axies.&#13;
   * @param quantity Number of Axies to be calculated.&#13;
   */&#13;
  function _axiesPrice(&#13;
    uint8 clazz,&#13;
    uint256 quantity&#13;
  )&#13;
    private&#13;
    view&#13;
    returns (uint256 totalPrice, uint256 priceIncrement, uint256 currentPrice)&#13;
  {&#13;
    priceIncrement = priceIncrements[clazz];&#13;
    currentPrice = currentPrices[clazz];&#13;
&#13;
    uint256 nextPrice;&#13;
&#13;
    for (uint256 i = 0; i &lt; quantity; i++) {&#13;
      totalPrice = totalPrice.add(currentPrice);&#13;
      nextPrice = currentPrice.add(priceIncrement);&#13;
&#13;
      if (nextPrice / 100 finney != currentPrice / 100 finney) {&#13;
        priceIncrement &gt;&gt;= 1;&#13;
      }&#13;
&#13;
      currentPrice = nextPrice;&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Adopt some Axies from the same class.&#13;
   * @param adopter Address of the adopter.&#13;
   * @param clazz The class of adopted Axies.&#13;
   * @param quantity Number of Axies to be adopted, this should be positive.&#13;
   * @param referrer Address of the referrer.&#13;
   */&#13;
  function _adoptAxies(&#13;
    address adopter,&#13;
    uint8 clazz,&#13;
    uint256 quantity,&#13;
    address referrer&#13;
  )&#13;
    private&#13;
    returns (uint256 totalPrice)&#13;
  {&#13;
    (totalPrice, priceIncrements[clazz], currentPrices[clazz]) = _axiesPrice(clazz, quantity);&#13;
&#13;
    axiesAdopted[adopter][clazz] = axiesAdopted[adopter][clazz].add(quantity);&#13;
    totalAxiesAdopted[clazz] = totalAxiesAdopted[clazz].add(quantity);&#13;
&#13;
    AxiesAdopted(&#13;
      adopter,&#13;
      clazz,&#13;
      quantity,&#13;
      referrer&#13;
    );&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Redeem adopted Axies from the same class.&#13;
   * @param receiver Address of the receiver.&#13;
   * @param clazz The class of adopted Axies.&#13;
   * @param quantity Number of adopted Axies to be redeemed.&#13;
   */&#13;
  function _redeemAdoptedAxies(&#13;
    address receiver,&#13;
    uint8 clazz,&#13;
    uint256 quantity&#13;
  )&#13;
    private&#13;
    returns (uint256 remainingQuantity)&#13;
  {&#13;
    remainingQuantity = axiesAdopted[receiver][clazz] = axiesAdopted[receiver][clazz].sub(quantity);&#13;
&#13;
    if (quantity &gt; 0) {&#13;
      // This requires that adopted Axies are always included in the total&#13;
      // to make sure overflow won't happen.&#13;
      totalAxiesAdopted[clazz] -= quantity;&#13;
&#13;
      AdoptedAxiesRedeemed(receiver, clazz, quantity);&#13;
    }&#13;
  }&#13;
}