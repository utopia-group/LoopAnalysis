/**
 * RatesProvider.sol
 * Provides rates, conversion methods and tools for ETH and CHF currencies.

 * The unflattened code is available through this github tag:
 * https://github.com/MtPelerin/MtPelerin-protocol/tree/etherscan-verify-batch-1

 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved

 * @notice All matters regarding the intellectual property of this code 
 * @notice or software are subject to Swiss Law without reference to its 
 * @notice conflicts of law rules.

 * @notice License for each contract is available in the respective file
 * @notice or in the LICENSE.md file.
 * @notice https://github.com/MtPelerin/

 * @notice Code by OpenZeppelin is copyrighted and licensed on their repository:
 * @notice https://github.com/OpenZeppelin/openzeppelin-solidity
 */


pragma solidity ^0.4.24;

// File: contracts/zeppelin/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/interface/IRatesProvider.sol

/**
 * @title IRatesProvider
 * @dev IRatesProvider interface
 *
 * @author Cyril Lapinte - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="eb8892998287c5878a9b82859f8eab869f9b8e878e998285c5888486">[email protected]</a>&gt;&#13;
 *&#13;
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved&#13;
 * @notice Please refer to the top of this file for the license.&#13;
 */&#13;
contract IRatesProvider {&#13;
  function rateWEIPerCHFCent() public view returns (uint256);&#13;
  function convertWEIToCHFCent(uint256 _amountWEI)&#13;
    public view returns (uint256);&#13;
&#13;
  function convertCHFCentToWEI(uint256 _amountCHFCent)&#13;
    public view returns (uint256);&#13;
}&#13;
&#13;
// File: contracts/zeppelin/ownership/Ownable.sol&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
&#13;
  event OwnershipRenounced(address indexed previousOwner);&#13;
  event OwnershipTransferred(&#13;
    address indexed previousOwner,&#13;
    address indexed newOwner&#13;
  );&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  constructor() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to relinquish control of the contract.&#13;
   */&#13;
  function renounceOwnership() public onlyOwner {&#13;
    emit OwnershipRenounced(owner);&#13;
    owner = address(0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param _newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address _newOwner) public onlyOwner {&#13;
    _transferOwnership(_newOwner);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfers control of the contract to a newOwner.&#13;
   * @param _newOwner The address to transfer ownership to.&#13;
   */&#13;
  function _transferOwnership(address _newOwner) internal {&#13;
    require(_newOwner != address(0));&#13;
    emit OwnershipTransferred(owner, _newOwner);&#13;
    owner = _newOwner;&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/Authority.sol&#13;
&#13;
/**&#13;
 * @title Authority&#13;
 * @dev The Authority contract has an authority address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 * Authority means to represent a legal entity that is entitled to specific rights&#13;
 *&#13;
 * @author Cyril Lapinte - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6d0e141f040143010c1d040319082d00191d0801081f0403430e0200">[email protected]</a>&gt;&#13;
 *&#13;
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved&#13;
 * @notice Please refer to the top of this file for the license.&#13;
 *&#13;
 * Error messages&#13;
 * AU01: Message sender must be an authority&#13;
 */&#13;
contract Authority is Ownable {&#13;
&#13;
  address authority;&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the authority.&#13;
   */&#13;
  modifier onlyAuthority {&#13;
    require(msg.sender == authority, "AU01");&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev return the address associated to the authority&#13;
   */&#13;
  function authorityAddress() public view returns (address) {&#13;
    return authority;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev rdefines an authority&#13;
   * @param _name the authority name&#13;
   * @param _address the authority address.&#13;
   */&#13;
  function defineAuthority(string _name, address _address) public onlyOwner {&#13;
    emit AuthorityDefined(_name, _address);&#13;
    authority = _address;&#13;
  }&#13;
&#13;
  event AuthorityDefined(&#13;
    string name,&#13;
    address _address&#13;
  );&#13;
}&#13;
&#13;
// File: contracts/RatesProvider.sol&#13;
&#13;
/**&#13;
 * @title RatesProvider&#13;
 * @dev RatesProvider interface&#13;
 *&#13;
 * @author Cyril Lapinte - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e1829893888dcf8d8091888f9584a18c9591848d8493888fcf828e8c">[email protected]</a>&gt;&#13;
 *&#13;
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved&#13;
 * @notice Please refer to the top of this file for the license.&#13;
 *&#13;
 * Error messages&#13;
 */&#13;
contract RatesProvider is IRatesProvider, Authority {&#13;
  using SafeMath for uint256;&#13;
&#13;
  // WEICHF rate is in ETH_wei/CHF_cents with no fractional parts&#13;
  uint256 public rateWEIPerCHFCent;&#13;
&#13;
  /**&#13;
   * @dev constructor&#13;
   */&#13;
  constructor() public {&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev convert rate from ETHCHF to WEICents&#13;
   */&#13;
  function convertRateFromETHCHF(&#13;
    uint256 _rateETHCHF,&#13;
    uint256 _rateETHCHFDecimal)&#13;
    public pure returns (uint256)&#13;
  {&#13;
    if (_rateETHCHF == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    return uint256(&#13;
      10**(_rateETHCHFDecimal.add(18 - 2))&#13;
    ).div(_rateETHCHF);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev convert rate from WEICents to ETHCHF&#13;
   */&#13;
  function convertRateToETHCHF(&#13;
    uint256 _rateWEIPerCHFCent,&#13;
    uint256 _rateETHCHFDecimal)&#13;
    public pure returns (uint256)&#13;
  {&#13;
    if (_rateWEIPerCHFCent == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    return uint256(&#13;
      10**(_rateETHCHFDecimal.add(18 - 2))&#13;
    ).div(_rateWEIPerCHFCent);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev convert CHF to ETH&#13;
   */&#13;
  function convertCHFCentToWEI(uint256 _amountCHFCent)&#13;
    public view returns (uint256)&#13;
  {&#13;
    return _amountCHFCent.mul(rateWEIPerCHFCent);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev convert ETH to CHF&#13;
   */&#13;
  function convertWEIToCHFCent(uint256 _amountETH)&#13;
    public view returns (uint256)&#13;
  {&#13;
    if (rateWEIPerCHFCent == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    return _amountETH.div(rateWEIPerCHFCent);&#13;
  }&#13;
&#13;
  /* Current ETHCHF rates */&#13;
  function rateWEIPerCHFCent() public view returns (uint256) {&#13;
    return rateWEIPerCHFCent;&#13;
  }&#13;
  &#13;
  /**&#13;
   * @dev rate ETHCHF&#13;
   */&#13;
  function rateETHCHF(uint256 _rateETHCHFDecimal)&#13;
    public view returns (uint256)&#13;
  {&#13;
    return convertRateToETHCHF(rateWEIPerCHFCent, _rateETHCHFDecimal);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev define rate&#13;
   */&#13;
  function defineRate(uint256 _rateWEIPerCHFCent)&#13;
    public onlyAuthority&#13;
  {&#13;
    rateWEIPerCHFCent = _rateWEIPerCHFCent;&#13;
    emit Rate(currentTime(), _rateWEIPerCHFCent);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev define rate with decimals&#13;
   */&#13;
  function defineETHCHFRate(uint256 _rateETHCHF, uint256 _rateETHCHFDecimal)&#13;
    public onlyAuthority&#13;
  {&#13;
    // The rate is inverted to maximize the decimals stored&#13;
    defineRate(convertRateFromETHCHF(_rateETHCHF, _rateETHCHFDecimal));&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev current time&#13;
   */&#13;
  function currentTime() private view returns (uint256) {&#13;
    // solium-disable-next-line security/no-block-members&#13;
    return now;&#13;
  }&#13;
&#13;
  event Rate(uint256 at, uint256 rateWEIPerCHFCent);&#13;
}