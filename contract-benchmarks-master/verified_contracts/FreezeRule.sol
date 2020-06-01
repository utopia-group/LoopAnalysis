/**
 * FreezeRule.sol
 * Rule to restrict individual addresses from sending or receiving MPS tokens.

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

// File: contracts/zeppelin/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/Authority.sol

/**
 * @title Authority
 * @dev The Authority contract has an authority address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * Authority means to represent a legal entity that is entitled to specific rights
 *
 * @author Cyril Lapinte - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b6d5cfc4dfda98dad7c6dfd8c2d3f6dbc2c6d3dad3c4dfd898d5d9db">[email protected]</a>&gt;&#13;
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
// File: contracts/interface/IRule.sol&#13;
&#13;
/**&#13;
 * @title IRule&#13;
 * @dev IRule interface&#13;
 * @author Cyril Lapinte - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="accfd5dec5c082c0cddcc5c2d8c9ecc1d8dcc9c0c9dec5c282cfc3c1">[email protected]</a>&gt;&#13;
 *&#13;
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved&#13;
 * @notice Please refer to the top of this file for the license.&#13;
 **/&#13;
interface IRule {&#13;
  function isAddressValid(address _address) external view returns (bool);&#13;
  function isTransferValid(address _from, address _to, uint256 _amount)&#13;
    external view returns (bool);&#13;
}&#13;
&#13;
// File: contracts/rule/FreezeRule.sol&#13;
&#13;
/**&#13;
 * @title FreezeRule&#13;
 * @dev FreezeRule contract&#13;
 * This rule allow a legal authority to enforce a freeze of assets.&#13;
 *&#13;
 * @author Cyril Lapinte - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="71120803181d5f1d1001181f0514311c0501141d1403181f5f121e1c">[email protected]</a>&gt;&#13;
 *&#13;
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved&#13;
 * @notice Please refer to the top of this file for the license.&#13;
 *&#13;
 * Error messages&#13;
 * E01: The address is frozen&#13;
 */&#13;
contract FreezeRule is IRule, Authority {&#13;
&#13;
  mapping(address =&gt; uint256) freezer;&#13;
  uint256 allFreezedUntil;&#13;
&#13;
  /**&#13;
   * @dev is rule frozen&#13;
   */&#13;
  function isFrozen() public view returns (bool) {&#13;
    // solium-disable-next-line security/no-block-members&#13;
    return allFreezedUntil &gt; now ;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev is address frozen&#13;
   */&#13;
  function isAddressFrozen(address _address) public view returns (bool) {&#13;
    // solium-disable-next-line security/no-block-members&#13;
    return freezer[_address] &gt; now;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev allow authority to freeze the address&#13;
   * @param _until allows to auto unlock if the frozen time is known initially.&#13;
   * otherwise infinity can be used&#13;
   */&#13;
  function freezeAddress(address _address, uint256 _until)&#13;
    public onlyAuthority returns (bool)&#13;
  {&#13;
    freezer[_address] = _until;&#13;
    emit Freeze(_address, _until);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev allow authority to freeze several addresses&#13;
   * @param _until allows to auto unlock if the frozen time is known initially.&#13;
   * otherwise infinity can be used&#13;
   */&#13;
  function freezeManyAddresses(address[] _addresses, uint256 _until)&#13;
    public onlyAuthority returns (bool)&#13;
  {&#13;
    for (uint256 i = 0; i &lt; _addresses.length; i++) {&#13;
      freezer[_addresses[i]] = _until;&#13;
      emit Freeze(_addresses[i], _until);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev freeze all until&#13;
   */&#13;
  function freezeAll(uint256 _until) public&#13;
    onlyAuthority returns (bool)&#13;
  {&#13;
    allFreezedUntil = _until;&#13;
    emit FreezeAll(_until);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev validates an address&#13;
   */&#13;
  function isAddressValid(address _address) public view returns (bool) {&#13;
    return !isFrozen() &amp;&amp; !isAddressFrozen(_address);&#13;
  }&#13;
&#13;
   /**&#13;
   * @dev validates a transfer &#13;
   */&#13;
  function isTransferValid(address _from, address _to, uint256 /* _amount */)&#13;
    public view returns (bool)&#13;
  {&#13;
    return !isFrozen() &amp;&amp; (!isAddressFrozen(_from) &amp;&amp; !isAddressFrozen(_to));&#13;
  }&#13;
&#13;
  event FreezeAll(uint256 until);&#13;
  event Freeze(address _address, uint256 until);&#13;
}