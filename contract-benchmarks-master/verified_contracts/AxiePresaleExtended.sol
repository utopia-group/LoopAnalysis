pragma solidity ^0.4.19;

// File: zeppelin/contracts/ownership/Ownable.sol

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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin/contracts/lifecycle/Pausable.sol

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

// File: zeppelin/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: zeppelin/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="87f5e2eae4e8c7b5">[email protected]</span>π.com&gt;&#13;
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
  function HasNoEther() payable {&#13;
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
// File: contracts/presale/AxiePresale.sol&#13;
&#13;
contract AxiePresale is HasNoEther, Pausable {&#13;
  using SafeMath for uint256;&#13;
&#13;
  // No Axies can be adopted after this end date: Friday, March 16, 2018 11:59:59 PM GMT.&#13;
  uint256 constant public PRESALE_END_TIMESTAMP = 1521244799;&#13;
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
    require(now &lt;= PRESALE_END_TIMESTAMP);&#13;
&#13;
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
}&#13;
&#13;
// File: zeppelin/contracts/ownership/HasNoContracts.sol&#13;
&#13;
/**&#13;
 * @title Contracts that should not own Contracts&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="0c7e69616f634c3e">[email protected]</span>π.com&gt;&#13;
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner&#13;
 * of this contract to reclaim ownership of the contracts.&#13;
 */&#13;
contract HasNoContracts is Ownable {&#13;
&#13;
  /**&#13;
   * @dev Reclaim ownership of Ownable contracts&#13;
   * @param contractAddr The address of the Ownable to be reclaimed.&#13;
   */&#13;
  function reclaimContract(address contractAddr) external onlyOwner {&#13;
    Ownable contractInst = Ownable(contractAddr);&#13;
    contractInst.transferOwnership(owner);&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/presale/AxiePresaleExtended.sol&#13;
&#13;
contract AxiePresaleExtended is HasNoContracts, Pausable {&#13;
  using SafeMath for uint256;&#13;
&#13;
  // No Axies can be adopted after this end date: Monday, April 16, 2018 11:59:59 PM GMT.&#13;
  uint256 constant public PRESALE_END_TIMESTAMP = 1523923199;&#13;
&#13;
  // The total number of adopted Axies will be capped at 5250,&#13;
  // so the number of Axies which have Mystic parts will be capped roughly at 2000.&#13;
  uint256 constant public MAX_TOTAL_ADOPTED_AXIES = 5250;&#13;
&#13;
  uint8 constant public CLASS_BEAST = 0;&#13;
  uint8 constant public CLASS_AQUATIC = 2;&#13;
  uint8 constant public CLASS_PLANT = 4;&#13;
&#13;
  // The initial price increment and the initial price are for reference only&#13;
  uint256 constant public INITIAL_PRICE_INCREMENT = 1600 szabo; // 0.0016 Ether&#13;
  uint256 constant public INITIAL_PRICE = INITIAL_PRICE_INCREMENT;&#13;
&#13;
  uint256 constant public REF_CREDITS_PER_AXIE = 5;&#13;
&#13;
  AxiePresale public presaleContract;&#13;
  address public redemptionAddress;&#13;
&#13;
  mapping (uint8 =&gt; uint256) public currentPrice;&#13;
  mapping (uint8 =&gt; uint256) public priceIncrement;&#13;
&#13;
  mapping (uint8 =&gt; uint256) private _totalAdoptedAxies;&#13;
  mapping (uint8 =&gt; uint256) private _totalDeductedAdoptedAxies;&#13;
  mapping (address =&gt; mapping (uint8 =&gt; uint256)) private _numAdoptedAxies;&#13;
  mapping (address =&gt; mapping (uint8 =&gt; uint256)) private _numDeductedAdoptedAxies;&#13;
&#13;
  mapping (address =&gt; uint256) private _numRefCredits;&#13;
  mapping (address =&gt; uint256) private _numDeductedRefCredits;&#13;
  uint256 public numBountyCredits;&#13;
&#13;
  uint256 private _totalRewardedAxies;&#13;
  uint256 private _totalDeductedRewardedAxies;&#13;
  mapping (address =&gt; uint256) private _numRewardedAxies;&#13;
  mapping (address =&gt; uint256) private _numDeductedRewardedAxies;&#13;
&#13;
  event AxiesAdopted(&#13;
    address indexed _adopter,&#13;
    uint8 indexed _class,&#13;
    uint256 _quantity,&#13;
    address indexed _referrer&#13;
  );&#13;
&#13;
  event AxiesRewarded(address indexed _receiver, uint256 _quantity);&#13;
&#13;
  event AdoptedAxiesRedeemed(address indexed _receiver, uint8 indexed _class, uint256 _quantity);&#13;
  event RewardedAxiesRedeemed(address indexed _receiver, uint256 _quantity);&#13;
&#13;
  event RefCreditsMinted(address indexed _receiver, uint256 _numMintedCredits);&#13;
&#13;
  function AxiePresaleExtended() public payable {&#13;
    require(msg.value == 0);&#13;
    paused = true;&#13;
    numBountyCredits = 300;&#13;
  }&#13;
&#13;
  function () external payable {&#13;
    require(msg.sender == address(presaleContract));&#13;
  }&#13;
&#13;
  modifier whenNotInitialized {&#13;
    require(presaleContract == address(0));&#13;
    _;&#13;
  }&#13;
&#13;
  modifier whenInitialized {&#13;
    require(presaleContract != address(0));&#13;
    _;&#13;
  }&#13;
&#13;
  modifier onlyRedemptionAddress {&#13;
    require(msg.sender == redemptionAddress);&#13;
    _;&#13;
  }&#13;
&#13;
  function reclaimEther() external onlyOwner whenInitialized {&#13;
    presaleContract.reclaimEther();&#13;
    owner.transfer(this.balance);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev This must be called only once after the owner of the presale contract&#13;
   *  has been updated to this contract.&#13;
   */&#13;
  function initialize(address _presaleAddress) external onlyOwner whenNotInitialized {&#13;
    // Set the presale address.&#13;
    presaleContract = AxiePresale(_presaleAddress);&#13;
&#13;
    presaleContract.pause();&#13;
&#13;
    // Restore price increments from the old contract.&#13;
    priceIncrement[CLASS_BEAST] = presaleContract.priceIncrements(CLASS_BEAST);&#13;
    priceIncrement[CLASS_AQUATIC] = presaleContract.priceIncrements(CLASS_AQUATIC);&#13;
    priceIncrement[CLASS_PLANT] = presaleContract.priceIncrements(CLASS_PLANT);&#13;
&#13;
    // Restore current prices from the old contract.&#13;
    currentPrice[CLASS_BEAST] = presaleContract.currentPrices(CLASS_BEAST);&#13;
    currentPrice[CLASS_AQUATIC] = presaleContract.currentPrices(CLASS_AQUATIC);&#13;
    currentPrice[CLASS_PLANT] = presaleContract.currentPrices(CLASS_PLANT);&#13;
&#13;
    paused = false;&#13;
  }&#13;
&#13;
  function setRedemptionAddress(address _redemptionAddress) external onlyOwner whenInitialized {&#13;
    redemptionAddress = _redemptionAddress;&#13;
  }&#13;
&#13;
  function totalAdoptedAxies(&#13;
    uint8 _class,&#13;
    bool _deduction&#13;
  )&#13;
    external&#13;
    view&#13;
    whenInitialized&#13;
    returns (uint256 _number)&#13;
  {&#13;
    _number = _totalAdoptedAxies[_class]&#13;
      .add(presaleContract.totalAxiesAdopted(_class));&#13;
&#13;
    if (_deduction) {&#13;
      _number = _number.sub(_totalDeductedAdoptedAxies[_class]);&#13;
    }&#13;
  }&#13;
&#13;
  function numAdoptedAxies(&#13;
    address _owner,&#13;
    uint8 _class,&#13;
    bool _deduction&#13;
  )&#13;
    external&#13;
    view&#13;
    whenInitialized&#13;
    returns (uint256 _number)&#13;
  {&#13;
    _number = _numAdoptedAxies[_owner][_class]&#13;
      .add(presaleContract.axiesAdopted(_owner, _class));&#13;
&#13;
    if (_deduction) {&#13;
      _number = _number.sub(_numDeductedAdoptedAxies[_owner][_class]);&#13;
    }&#13;
  }&#13;
&#13;
  function numRefCredits(&#13;
    address _owner,&#13;
    bool _deduction&#13;
  )&#13;
    external&#13;
    view&#13;
    whenInitialized&#13;
    returns (uint256 _number)&#13;
  {&#13;
    _number = _numRefCredits[_owner]&#13;
      .add(presaleContract.referralCredits(_owner));&#13;
&#13;
    if (_deduction) {&#13;
      _number = _number.sub(_numDeductedRefCredits[_owner]);&#13;
    }&#13;
  }&#13;
&#13;
  function totalRewardedAxies(&#13;
    bool _deduction&#13;
  )&#13;
    external&#13;
    view&#13;
    whenInitialized&#13;
    returns (uint256 _number)&#13;
  {&#13;
    _number = _totalRewardedAxies&#13;
      .add(presaleContract.totalAxiesRewarded());&#13;
&#13;
    if (_deduction) {&#13;
      _number = _number.sub(_totalDeductedRewardedAxies);&#13;
    }&#13;
  }&#13;
&#13;
  function numRewardedAxies(&#13;
    address _owner,&#13;
    bool _deduction&#13;
  )&#13;
    external&#13;
    view&#13;
    whenInitialized&#13;
    returns (uint256 _number)&#13;
  {&#13;
    _number = _numRewardedAxies[_owner]&#13;
      .add(presaleContract.axiesRewarded(_owner));&#13;
&#13;
    if (_deduction) {&#13;
      _number = _number.sub(_numDeductedRewardedAxies[_owner]);&#13;
    }&#13;
  }&#13;
&#13;
  function axiesPrice(&#13;
    uint256 _beastQuantity,&#13;
    uint256 _aquaticQuantity,&#13;
    uint256 _plantQuantity&#13;
  )&#13;
    external&#13;
    view&#13;
    whenInitialized&#13;
    returns (uint256 _totalPrice)&#13;
  {&#13;
    uint256 price;&#13;
&#13;
    (price,,) = _sameClassAxiesPrice(CLASS_BEAST, _beastQuantity);&#13;
    _totalPrice = _totalPrice.add(price);&#13;
&#13;
    (price,,) = _sameClassAxiesPrice(CLASS_AQUATIC, _aquaticQuantity);&#13;
    _totalPrice = _totalPrice.add(price);&#13;
&#13;
    (price,,) = _sameClassAxiesPrice(CLASS_PLANT, _plantQuantity);&#13;
    _totalPrice = _totalPrice.add(price);&#13;
  }&#13;
&#13;
  function adoptAxies(&#13;
    uint256 _beastQuantity,&#13;
    uint256 _aquaticQuantity,&#13;
    uint256 _plantQuantity,&#13;
    address _referrer&#13;
  )&#13;
    external&#13;
    payable&#13;
    whenInitialized&#13;
    whenNotPaused&#13;
  {&#13;
    require(now &lt;= PRESALE_END_TIMESTAMP);&#13;
    require(_beastQuantity &lt;= 3 &amp;&amp; _aquaticQuantity &lt;= 3 &amp;&amp; _plantQuantity &lt;= 3);&#13;
&#13;
    uint256 _totalAdopted = this.totalAdoptedAxies(CLASS_BEAST, false)&#13;
      .add(this.totalAdoptedAxies(CLASS_AQUATIC, false))&#13;
      .add(this.totalAdoptedAxies(CLASS_PLANT, false))&#13;
      .add(_beastQuantity)&#13;
      .add(_aquaticQuantity)&#13;
      .add(_plantQuantity);&#13;
&#13;
    require(_totalAdopted &lt;= MAX_TOTAL_ADOPTED_AXIES);&#13;
&#13;
    address _adopter = msg.sender;&#13;
    address _actualReferrer = 0x0;&#13;
&#13;
    // An adopter cannot be his/her own referrer.&#13;
    if (_referrer != _adopter) {&#13;
      _actualReferrer = _referrer;&#13;
    }&#13;
&#13;
    uint256 _value = msg.value;&#13;
    uint256 _price;&#13;
&#13;
    if (_beastQuantity &gt; 0) {&#13;
      _price = _adoptSameClassAxies(&#13;
        _adopter,&#13;
        CLASS_BEAST,&#13;
        _beastQuantity,&#13;
        _actualReferrer&#13;
      );&#13;
&#13;
      require(_value &gt;= _price);&#13;
      _value -= _price;&#13;
    }&#13;
&#13;
    if (_aquaticQuantity &gt; 0) {&#13;
      _price = _adoptSameClassAxies(&#13;
        _adopter,&#13;
        CLASS_AQUATIC,&#13;
        _aquaticQuantity,&#13;
        _actualReferrer&#13;
      );&#13;
&#13;
      require(_value &gt;= _price);&#13;
      _value -= _price;&#13;
    }&#13;
&#13;
    if (_plantQuantity &gt; 0) {&#13;
      _price = _adoptSameClassAxies(&#13;
        _adopter,&#13;
        CLASS_PLANT,&#13;
        _plantQuantity,&#13;
        _actualReferrer&#13;
      );&#13;
&#13;
      require(_value &gt;= _price);&#13;
      _value -= _price;&#13;
    }&#13;
&#13;
    msg.sender.transfer(_value);&#13;
&#13;
    // The current referral is ignored if the referrer's address is 0x0.&#13;
    if (_actualReferrer != 0x0) {&#13;
      _applyRefCredits(&#13;
        _actualReferrer,&#13;
        _beastQuantity.add(_aquaticQuantity).add(_plantQuantity)&#13;
      );&#13;
    }&#13;
  }&#13;
&#13;
  function mintRefCredits(&#13;
    address _receiver,&#13;
    uint256 _numMintedCredits&#13;
  )&#13;
    external&#13;
    onlyOwner&#13;
    whenInitialized&#13;
    returns (uint256)&#13;
  {&#13;
    require(_receiver != address(0));&#13;
    numBountyCredits = numBountyCredits.sub(_numMintedCredits);&#13;
    _applyRefCredits(_receiver, _numMintedCredits);&#13;
    RefCreditsMinted(_receiver, _numMintedCredits);&#13;
    return numBountyCredits;&#13;
  }&#13;
&#13;
  function redeemAdoptedAxies(&#13;
    address _receiver,&#13;
    uint256 _beastQuantity,&#13;
    uint256 _aquaticQuantity,&#13;
    uint256 _plantQuantity&#13;
  )&#13;
    external&#13;
    onlyRedemptionAddress&#13;
    whenInitialized&#13;
    returns (&#13;
      uint256 /* remainingBeastQuantity */,&#13;
      uint256 /* remainingAquaticQuantity */,&#13;
      uint256 /* remainingPlantQuantity */&#13;
    )&#13;
  {&#13;
    return (&#13;
      _redeemSameClassAdoptedAxies(_receiver, CLASS_BEAST, _beastQuantity),&#13;
      _redeemSameClassAdoptedAxies(_receiver, CLASS_AQUATIC, _aquaticQuantity),&#13;
      _redeemSameClassAdoptedAxies(_receiver, CLASS_PLANT, _plantQuantity)&#13;
    );&#13;
  }&#13;
&#13;
  function redeemRewardedAxies(&#13;
    address _receiver,&#13;
    uint256 _quantity&#13;
  )&#13;
    external&#13;
    onlyRedemptionAddress&#13;
    whenInitialized&#13;
    returns (uint256 _remainingQuantity)&#13;
  {&#13;
    _remainingQuantity = this.numRewardedAxies(_receiver, true).sub(_quantity);&#13;
&#13;
    if (_quantity &gt; 0) {&#13;
      _numDeductedRewardedAxies[_receiver] = _numDeductedRewardedAxies[_receiver].add(_quantity);&#13;
      _totalDeductedRewardedAxies = _totalDeductedRewardedAxies.add(_quantity);&#13;
&#13;
      RewardedAxiesRedeemed(_receiver, _quantity);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Calculate price of Axies from the same class.&#13;
   * @param _class The class of Axies.&#13;
   * @param _quantity Number of Axies to be calculated.&#13;
   */&#13;
  function _sameClassAxiesPrice(&#13;
    uint8 _class,&#13;
    uint256 _quantity&#13;
  )&#13;
    private&#13;
    view&#13;
    returns (&#13;
      uint256 _totalPrice,&#13;
      uint256 /* should be _subsequentIncrement */ _currentIncrement,&#13;
      uint256 /* should be _subsequentPrice */ _currentPrice&#13;
    )&#13;
  {&#13;
    _currentIncrement = priceIncrement[_class];&#13;
    _currentPrice = currentPrice[_class];&#13;
&#13;
    uint256 _nextPrice;&#13;
&#13;
    for (uint256 i = 0; i &lt; _quantity; i++) {&#13;
      _totalPrice = _totalPrice.add(_currentPrice);&#13;
      _nextPrice = _currentPrice.add(_currentIncrement);&#13;
&#13;
      if (_nextPrice / 100 finney != _currentPrice / 100 finney) {&#13;
        _currentIncrement &gt;&gt;= 1;&#13;
      }&#13;
&#13;
      _currentPrice = _nextPrice;&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Adopt some Axies from the same class.&#13;
   * @dev The quantity MUST be positive.&#13;
   * @param _adopter Address of the adopter.&#13;
   * @param _class The class of adopted Axies.&#13;
   * @param _quantity Number of Axies to be adopted.&#13;
   * @param _referrer Address of the referrer.&#13;
   */&#13;
  function _adoptSameClassAxies(&#13;
    address _adopter,&#13;
    uint8 _class,&#13;
    uint256 _quantity,&#13;
    address _referrer&#13;
  )&#13;
    private&#13;
    returns (uint256 _totalPrice)&#13;
  {&#13;
    (_totalPrice, priceIncrement[_class], currentPrice[_class]) = _sameClassAxiesPrice(_class, _quantity);&#13;
&#13;
    _numAdoptedAxies[_adopter][_class] = _numAdoptedAxies[_adopter][_class].add(_quantity);&#13;
    _totalAdoptedAxies[_class] = _totalAdoptedAxies[_class].add(_quantity);&#13;
&#13;
    AxiesAdopted(&#13;
      _adopter,&#13;
      _class,&#13;
      _quantity,&#13;
      _referrer&#13;
    );&#13;
  }&#13;
&#13;
  function _applyRefCredits(address _receiver, uint256 _numAppliedCredits) private {&#13;
    _numRefCredits[_receiver] = _numRefCredits[_receiver].add(_numAppliedCredits);&#13;
&#13;
    uint256 _numCredits = this.numRefCredits(_receiver, true);&#13;
    uint256 _numRewards = _numCredits / REF_CREDITS_PER_AXIE;&#13;
&#13;
    if (_numRewards &gt; 0) {&#13;
      _numDeductedRefCredits[_receiver] = _numDeductedRefCredits[_receiver]&#13;
        .add(_numRewards.mul(REF_CREDITS_PER_AXIE));&#13;
&#13;
      _numRewardedAxies[_receiver] = _numRewardedAxies[_receiver].add(_numRewards);&#13;
      _totalRewardedAxies = _totalRewardedAxies.add(_numRewards);&#13;
&#13;
      AxiesRewarded(_receiver, _numRewards);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @notice Redeem adopted Axies from the same class.&#13;
   * @dev Emit the `AdoptedAxiesRedeemed` event if the quantity is positive.&#13;
   * @param _receiver The address of the receiver.&#13;
   * @param _class The class of adopted Axies.&#13;
   * @param _quantity The number of adopted Axies to be redeemed.&#13;
   */&#13;
  function _redeemSameClassAdoptedAxies(&#13;
    address _receiver,&#13;
    uint8 _class,&#13;
    uint256 _quantity&#13;
  )&#13;
    private&#13;
    returns (uint256 _remainingQuantity)&#13;
  {&#13;
    _remainingQuantity = this.numAdoptedAxies(_receiver, _class, true).sub(_quantity);&#13;
&#13;
    if (_quantity &gt; 0) {&#13;
      _numDeductedAdoptedAxies[_receiver][_class] = _numDeductedAdoptedAxies[_receiver][_class].add(_quantity);&#13;
      _totalDeductedAdoptedAxies[_class] = _totalDeductedAdoptedAxies[_class].add(_quantity);&#13;
&#13;
      AdoptedAxiesRedeemed(_receiver, _class, _quantity);&#13;
    }&#13;
  }&#13;
}