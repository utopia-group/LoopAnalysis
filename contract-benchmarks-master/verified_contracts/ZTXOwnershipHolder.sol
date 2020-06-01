pragma solidity 0.4.24;

// File: contracts/ZTXInterface.sol

contract ZTXInterface {
    function transferOwnership(address _newOwner) public;
    function mint(address _to, uint256 amount) public returns (bool);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function unpause() public;
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: contracts/ZTXOwnershipHolder.sol

/**
 * @title ZTXOwnershipHolder - Sole responsibility is to hold and transfer ZTX ownership
 * @author Gustavo Guimaraes - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8fe8fafcfbeef9e0cff5fae3fafdeafffaede3e6eca1e6e0">[email protected]</a>&gt;&#13;
 * @author Timo Hedke - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1a6e7377755a606f766f687f6a6f78767379347375">[email protected]</a>&gt;&#13;
 */&#13;
contract ZTXOwnershipHolder is Ownable {&#13;
&#13;
      /**&#13;
     * @dev Constructor for the airdrop contract&#13;
     * @param _ztx ZTX contract address&#13;
     * @param newZuluOwner New ZTX owner address&#13;
     */&#13;
    function transferZTXOwnership(address _ztx, address newZuluOwner) external onlyOwner{&#13;
        ZTXInterface(_ztx).transferOwnership(newZuluOwner);&#13;
    }&#13;
}