/**
 * MPSSaleConfig.sol
 * Configuration for the MPS token sale private phase.

 * More info about MPS : https://github.com/MtPelerin/MtPelerin-share-MPS

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

// File: contracts/interface/ISaleConfig.sol

/**
 * @title ISaleConfig interface
 *
 * @author Cyril Lapinte - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="94f7ede6fdf8baf8f5e4fdfae0f1d4f9e0e4f1f8f1e6fdfabaf7fbf9">[email protected]</a>&gt;&#13;
 *&#13;
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved&#13;
 * @notice Please refer to the top of this file for the license.&#13;
 */&#13;
contract ISaleConfig {&#13;
&#13;
  struct Tokensale {&#13;
    uint256 lotId;&#13;
    uint256 tokenPriceCHFCent;&#13;
  }&#13;
&#13;
  function tokenSupply() public pure returns (uint256);&#13;
  function tokensaleLotSupplies() public view returns (uint256[]);&#13;
&#13;
  function tokenizedSharePercent() public pure returns (uint256); &#13;
  function tokenPriceCHF() public pure returns (uint256);&#13;
&#13;
  function minimalCHFInvestment() public pure returns (uint256);&#13;
  function maximalCHFInvestment() public pure returns (uint256);&#13;
&#13;
  function tokensalesCount() public view returns (uint256);&#13;
  function lotId(uint256 _tokensaleId) public view returns (uint256);&#13;
  function tokenPriceCHFCent(uint256 _tokensaleId)&#13;
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
// File: contracts/mps/MPSSaleConfig.sol&#13;
&#13;
/**&#13;
 * @title MPSSaleConfig&#13;
 * @dev MPSSaleConfig contract&#13;
 * The contract configure the sale for the MPS token&#13;
 *&#13;
 * @author Cyril Lapinte - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="dbb8a2a9b2b7f5b7baabb2b5afbe9bb6afabbeb7bea9b2b5f5b8b4b6">[email protected]</a>&gt;&#13;
 *&#13;
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved&#13;
 * @notice Please refer to the top of this file for the license.&#13;
 */&#13;
contract MPSSaleConfig is ISaleConfig, Ownable {&#13;
&#13;
  // Token supply cap: 10M&#13;
  uint256 constant public TOKEN_SUPPLY = 10 ** 7;&#13;
 &#13;
  // 100% of Mt Pelerin's shares are tokenized&#13;
  uint256 constant public TOKENSALE_LOT1_SHARE_PERCENT = 5;&#13;
  uint256 constant public TOKENSALE_LOT2_SHARE_PERCENT = 95;&#13;
  uint256 constant public TOKENIZED_SHARE_PERCENT&#13;
  = TOKENSALE_LOT1_SHARE_PERCENT + TOKENSALE_LOT2_SHARE_PERCENT;&#13;
&#13;
  uint256 constant public TOKENSALE_LOT1_SUPPLY&#13;
  = TOKEN_SUPPLY * TOKENSALE_LOT1_SHARE_PERCENT / 100;&#13;
  uint256 constant public TOKENSALE_LOT2_SUPPLY&#13;
  = TOKEN_SUPPLY * TOKENSALE_LOT2_SHARE_PERCENT / 100;&#13;
&#13;
  uint256[] private tokensaleLotSuppliesArray&#13;
  = [ TOKENSALE_LOT1_SUPPLY, TOKENSALE_LOT2_SUPPLY ];&#13;
&#13;
  // Tokens amount per CHF Cents&#13;
  uint256 constant public TOKEN_PRICE_CHF_CENT = 500;&#13;
&#13;
  // Minimal CHF Cents investment&#13;
  uint256 constant public MINIMAL_CHF_CENT_INVESTMENT = 10 ** 4;&#13;
&#13;
  // Maximal CHF Cents investment&#13;
  uint256 constant public MAXIMAL_CHF_CENT_INVESTMENT = 10 ** 10;&#13;
&#13;
  Tokensale[] public tokensales;&#13;
&#13;
  /**&#13;
   * @dev constructor&#13;
   */&#13;
  constructor() public {&#13;
    tokensales.push(Tokensale(&#13;
      0,&#13;
      TOKEN_PRICE_CHF_CENT * 80 / 100&#13;
    ));&#13;
&#13;
    tokensales.push(Tokensale(&#13;
      0,&#13;
      TOKEN_PRICE_CHF_CENT&#13;
    ));&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev getter need to be declared to comply with ISaleConfig interface&#13;
   */&#13;
  function tokenSupply() public pure returns (uint256) {&#13;
    return TOKEN_SUPPLY;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev getter need to be declared to comply with ISaleConfig interface&#13;
   */&#13;
  function tokensaleLotSupplies() public view returns (uint256[]) {&#13;
    return tokensaleLotSuppliesArray;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev getter need to be declared to comply with ISaleConfig interface&#13;
   */&#13;
  function tokenizedSharePercent() public pure returns (uint256) {&#13;
    return TOKENIZED_SHARE_PERCENT;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev getter need to be declared to comply with ISaleConfig interface&#13;
   */&#13;
  function tokenPriceCHF() public pure returns (uint256) {&#13;
    return TOKEN_PRICE_CHF_CENT;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev getter need to be declared to comply with ISaleConfig interface&#13;
   */&#13;
  function minimalCHFInvestment() public pure returns (uint256) {&#13;
    return MINIMAL_CHF_CENT_INVESTMENT;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev getter need to be declared to comply with ISaleConfig interface&#13;
   */&#13;
  function maximalCHFInvestment() public pure returns (uint256) {&#13;
    return MAXIMAL_CHF_CENT_INVESTMENT;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev tokensale count&#13;
   */&#13;
  function tokensalesCount() public view returns (uint256) {&#13;
    return tokensales.length;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev getter need to be declared to comply with ISaleConfig interface&#13;
   */&#13;
  function lotId(uint256 _tokensaleId) public view returns (uint256) {&#13;
    return tokensales[_tokensaleId].lotId;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev getter need to be declared to comply with ISaleConfig interface&#13;
   */&#13;
  function tokenPriceCHFCent(uint256 _tokensaleId)&#13;
    public view returns (uint256)&#13;
  {&#13;
    return tokensales[_tokensaleId].tokenPriceCHFCent;&#13;
  }&#13;
}