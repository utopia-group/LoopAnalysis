pragma solidity ^0.4.23;

// File: contracts/common/Ownable.sol

/**
 * Ownable contract from Open zepplin
 * https://github.com/OpenZeppelin/openzeppelin-solidity/
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
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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

// File: contracts/common/ReentrancyGuard.sol

/**
 * Reentrancy guard from open Zepplin :
 * https://github.com/OpenZeppelin/openzeppelin-solidity/
 *
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a0d2c5cdc3cfe092">[email protected]</a>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private reentrancyLock = false;&#13;
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
    require(!reentrancyLock);&#13;
    reentrancyLock = true;&#13;
    _;&#13;
    reentrancyLock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/interfaces/ERC20Interface.sol&#13;
&#13;
interface ERC20 {&#13;
    function totalSupply() public view returns (uint supply);&#13;
    function balanceOf(address _owner) public view returns (uint balance);&#13;
    function transfer(address _to, uint _value) public returns (bool success);&#13;
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);&#13;
    function approve(address _spender, uint _value) public returns (bool success);&#13;
    function allowance(address _owner, address _spender) public view returns (uint remaining);&#13;
    function decimals() public view returns(uint digits);&#13;
    event Approval(address indexed _owner, address indexed _spender, uint _value);&#13;
}&#13;
&#13;
//TODO : Flattener does not like aliased imports. Not needed in actual codebase.&#13;
&#13;
interface IERC20Token {&#13;
    function totalSupply() public view returns (uint supply);&#13;
    function balanceOf(address _owner) public view returns (uint balance);&#13;
    function transfer(address _to, uint _value) public returns (bool success);&#13;
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);&#13;
    function approve(address _spender, uint _value) public returns (bool success);&#13;
    function allowance(address _owner, address _spender) public view returns (uint remaining);&#13;
    function decimals() public view returns(uint digits);&#13;
    event Approval(address indexed _owner, address indexed _spender, uint _value);&#13;
}&#13;
&#13;
&#13;
// File: contracts/interfaces/IBancorNetwork.sol&#13;
&#13;
contract IBancorNetwork {&#13;
    function convert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);&#13;
    function convertFor(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for) public payable returns (uint256);&#13;
    function convertForPrioritized2(&#13;
        IERC20Token[] _path,&#13;
        uint256 _amount,&#13;
        uint256 _minReturn,&#13;
        address _for,&#13;
        uint256 _block,&#13;
        uint8 _v,&#13;
        bytes32 _r,&#13;
        bytes32 _s)&#13;
        public payable returns (uint256);&#13;
&#13;
    // deprecated, backward compatibility&#13;
    function convertForPrioritized(&#13;
        IERC20Token[] _path,&#13;
        uint256 _amount,&#13;
        uint256 _minReturn,&#13;
        address _for,&#13;
        uint256 _block,&#13;
        uint256 _nonce,&#13;
        uint8 _v,&#13;
        bytes32 _r,&#13;
        bytes32 _s)&#13;
        public payable returns (uint256);&#13;
}&#13;
&#13;
/*&#13;
   Bancor Contract Registry interface&#13;
*/&#13;
contract IContractRegistry {&#13;
    function getAddress(bytes32 _contractName) public view returns (address);&#13;
}&#13;
&#13;
// File: contracts/TokenPaymentBancor.sol&#13;
&#13;
/*&#13;
 * @title Token Payment using Bancor API v0.1&#13;
 * @author Haresh G&#13;
 * @dev This contract is used to convert ETH to an ERC20 token on the Bancor network.&#13;
 * @notice It does not support ERC20 to ERC20 transfer.&#13;
 */&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
contract IndTokenPayment is Ownable, ReentrancyGuard {  &#13;
    IERC20Token[] public path;    &#13;
    address public destinationWallet;       &#13;
    uint256 public minConversionRate;&#13;
    IContractRegistry public bancorRegistry;&#13;
    bytes32 public constant BANCOR_NETWORK = "BancorNetwork";&#13;
    &#13;
    event conversionSucceded(address from,uint256 fromTokenVal,address dest,uint256 destTokenVal);    &#13;
    &#13;
    constructor(IERC20Token[] _path,&#13;
                address destWalletAddr,&#13;
                address bancorRegistryAddr,&#13;
                uint256 minConvRate){&#13;
        path = _path;&#13;
        bancorRegistry = IContractRegistry(bancorRegistryAddr);&#13;
        destinationWallet = destWalletAddr;         &#13;
        minConversionRate = minConvRate;&#13;
    }&#13;
&#13;
    function setConversionPath(IERC20Token[] _path) public onlyOwner {&#13;
        path = _path;&#13;
    }&#13;
    &#13;
    function setBancorRegistry(address bancorRegistryAddr) public onlyOwner {&#13;
        bancorRegistry = IContractRegistry(bancorRegistryAddr);&#13;
    }&#13;
&#13;
    function setMinConversionRate(uint256 minConvRate) public onlyOwner {&#13;
        minConversionRate = minConvRate;&#13;
    }    &#13;
&#13;
    function setDestinationWallet(address destWalletAddr) public onlyOwner {&#13;
        destinationWallet = destWalletAddr;&#13;
    }    &#13;
    &#13;
    function convertToInd() internal nonReentrant {&#13;
        assert(bancorRegistry.getAddress(BANCOR_NETWORK) != address(0));&#13;
        IBancorNetwork bancorNetwork = IBancorNetwork(bancorRegistry.getAddress(BANCOR_NETWORK));   &#13;
        //TODO : Compute minReturn&#13;
        uint256 minReturn =0;&#13;
        uint256 convTokens =  bancorNetwork.convertFor.value(msg.value)(path,msg.value,minReturn,destinationWallet);        &#13;
        assert(convTokens &gt; 0);&#13;
        emit conversionSucceded(msg.sender,msg.value,destinationWallet,convTokens);                                                                    &#13;
    }&#13;
&#13;
    //If accidentally tokens are transferred to this&#13;
    //contract. They can be withdrawn by the followin interface.&#13;
    function withdrawToken(IERC20Token anyToken) public onlyOwner nonReentrant returns(bool){&#13;
        if( anyToken != address(0x0) ) {&#13;
            assert(anyToken.transfer(destinationWallet, anyToken.balanceOf(this)));&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    //ETH cannot get locked in this contract. If it does, this can be used to withdraw&#13;
    //the locked ether.&#13;
    function withdrawEther() public onlyOwner nonReentrant returns(bool){&#13;
        if(address(this).balance &gt; 0){&#13;
            destinationWallet.transfer(address(this).balance);&#13;
        }        &#13;
        return true;&#13;
    }&#13;
 &#13;
    function () public payable {&#13;
        //Bancor contract can send the transfer back in case of error, which goes back into this&#13;
        //function ,convertToInd is non-reentrant.&#13;
        convertToInd();&#13;
    }&#13;
&#13;
    /*&#13;
    * Helper functions to debug contract. Not to be deployed&#13;
    *&#13;
    */&#13;
&#13;
    function getBancorContractAddress() public returns(address) {&#13;
        return bancorRegistry.getAddress(BANCOR_NETWORK);&#13;
    }&#13;
&#13;
}