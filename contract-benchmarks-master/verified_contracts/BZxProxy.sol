/*

  Copyright 2018 bZeroX, LLC

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.24;

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

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7c0e19111f133c4e">[email protected]</a>π.com&gt;&#13;
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
contract GasTracker {&#13;
&#13;
    uint internal gasUsed;&#13;
&#13;
    modifier tracksGas() {&#13;
        gasUsed = gasleft();&#13;
        _;&#13;
        gasUsed = 0;&#13;
    }&#13;
}&#13;
&#13;
contract BZxObjects {&#13;
&#13;
    struct LoanOrder {&#13;
        address maker;&#13;
        address loanTokenAddress;&#13;
        address interestTokenAddress;&#13;
        address collateralTokenAddress;&#13;
        address feeRecipientAddress;&#13;
        address oracleAddress;&#13;
        uint loanTokenAmount;&#13;
        uint interestAmount;&#13;
        uint initialMarginAmount;&#13;
        uint maintenanceMarginAmount;&#13;
        uint lenderRelayFee;&#13;
        uint traderRelayFee;&#13;
        uint expirationUnixTimestampSec;&#13;
        bytes32 loanOrderHash;&#13;
    }&#13;
&#13;
    struct LoanRef {&#13;
        bytes32 loanOrderHash;&#13;
        address trader;&#13;
    }&#13;
&#13;
    struct LoanPosition {&#13;
        address lender;&#13;
        address trader;&#13;
        address collateralTokenAddressFilled;&#13;
        address positionTokenAddressFilled;&#13;
        uint loanTokenAmountFilled;&#13;
        uint collateralTokenAmountFilled;&#13;
        uint positionTokenAmountFilled;&#13;
        uint loanStartUnixTimestampSec;&#13;
        uint index;&#13;
        bool active;&#13;
    }&#13;
&#13;
    struct InterestData {&#13;
        address lender;&#13;
        address interestTokenAddress;&#13;
        uint interestTotalAccrued;&#13;
        uint interestPaidSoFar;&#13;
    }&#13;
&#13;
    event LogLoanTaken (&#13;
        address lender,&#13;
        address trader,&#13;
        address collateralTokenAddressFilled,&#13;
        address positionTokenAddressFilled,&#13;
        uint loanTokenAmountFilled,&#13;
        uint collateralTokenAmountFilled,&#13;
        uint positionTokenAmountFilled,&#13;
        uint loanStartUnixTimestampSec,&#13;
        bool active,&#13;
        bytes32 loanOrderHash&#13;
    );&#13;
&#13;
    event LogLoanCancelled(&#13;
        address maker,&#13;
        uint cancelLoanTokenAmount,&#13;
        uint remainingLoanTokenAmount,&#13;
        bytes32 loanOrderHash&#13;
    );&#13;
&#13;
    event LogLoanClosed(&#13;
        address lender,&#13;
        address trader,&#13;
        bool isLiquidation,&#13;
        bytes32 loanOrderHash&#13;
    );&#13;
&#13;
    event LogPositionTraded(&#13;
        bytes32 loanOrderHash,&#13;
        address trader,&#13;
        address sourceTokenAddress,&#13;
        address destTokenAddress,&#13;
        uint sourceTokenAmount,&#13;
        uint destTokenAmount&#13;
    );&#13;
&#13;
    event LogMarginLevels(&#13;
        bytes32 loanOrderHash,&#13;
        address trader,&#13;
        uint initialMarginAmount,&#13;
        uint maintenanceMarginAmount,&#13;
        uint currentMarginAmount&#13;
    );&#13;
&#13;
    event LogWithdrawProfit(&#13;
        bytes32 loanOrderHash,&#13;
        address trader,&#13;
        uint profitWithdrawn,&#13;
        uint remainingPosition&#13;
    );&#13;
&#13;
    event LogPayInterest(&#13;
        bytes32 loanOrderHash,&#13;
        address lender,&#13;
        address trader,&#13;
        uint amountPaid,&#13;
        uint totalAccrued&#13;
    );&#13;
&#13;
    function buildLoanOrderStruct(&#13;
        bytes32 loanOrderHash,&#13;
        address[6] addrs,&#13;
        uint[9] uints) &#13;
        internal&#13;
        pure&#13;
        returns (LoanOrder) {&#13;
&#13;
        return LoanOrder({&#13;
            maker: addrs[0],&#13;
            loanTokenAddress: addrs[1],&#13;
            interestTokenAddress: addrs[2],&#13;
            collateralTokenAddress: addrs[3],&#13;
            feeRecipientAddress: addrs[4],&#13;
            oracleAddress: addrs[5],&#13;
            loanTokenAmount: uints[0],&#13;
            interestAmount: uints[1],&#13;
            initialMarginAmount: uints[2],&#13;
            maintenanceMarginAmount: uints[3],&#13;
            lenderRelayFee: uints[4],&#13;
            traderRelayFee: uints[5],&#13;
            expirationUnixTimestampSec: uints[6],&#13;
            loanOrderHash: loanOrderHash&#13;
        });&#13;
    }&#13;
}&#13;
&#13;
contract BZxStorage is BZxObjects, ReentrancyGuard, Ownable, GasTracker {&#13;
    uint internal constant MAX_UINT = 2**256 - 1;&#13;
&#13;
    address public bZRxTokenContract;&#13;
    address public vaultContract;&#13;
    address public oracleRegistryContract;&#13;
    address public bZxTo0xContract;&#13;
    bool public DEBUG_MODE = false;&#13;
&#13;
    mapping (bytes32 =&gt; LoanOrder) public orders; // mapping of loanOrderHash to taken loanOrders&#13;
    mapping (address =&gt; bytes32[]) public orderList; // mapping of lenders and trader addresses to array of loanOrderHashes&#13;
    mapping (bytes32 =&gt; address) public orderLender; // mapping of loanOrderHash to lender address&#13;
    mapping (bytes32 =&gt; address[]) public orderTraders; // mapping of loanOrderHash to array of trader addresses&#13;
    mapping (bytes32 =&gt; uint) public orderFilledAmounts; // mapping of loanOrderHash to loanTokenAmount filled&#13;
    mapping (bytes32 =&gt; uint) public orderCancelledAmounts; // mapping of loanOrderHash to loanTokenAmount cancelled&#13;
    mapping (address =&gt; address) public oracleAddresses; // mapping of oracles to their current logic contract&#13;
    mapping (bytes32 =&gt; mapping (address =&gt; LoanPosition)) public loanPositions; // mapping of loanOrderHash to mapping of traders to loanPositions&#13;
    mapping (bytes32 =&gt; mapping (address =&gt; uint)) public interestPaid; // mapping of loanOrderHash to mapping of traders to amount of interest paid so far to a lender&#13;
&#13;
    LoanRef[] public loanList; // array of loans that need to be checked for liquidation or expiration&#13;
}&#13;
&#13;
contract Proxiable {&#13;
    mapping (bytes4 =&gt; address) public targets;&#13;
&#13;
    function initialize(address _target) public;&#13;
&#13;
    function _replaceContract(address _target) internal {&#13;
        // bytes4(keccak256("initialize(address)")) == 0xc4d66de8&#13;
        require(_target.delegatecall(0xc4d66de8, _target), "Proxiable::_replaceContract: failed");&#13;
    }&#13;
}&#13;
&#13;
contract BZxProxy is BZxStorage, Proxiable {&#13;
&#13;
    function() public {&#13;
        address target = targets[msg.sig];&#13;
        bytes memory data = msg.data;&#13;
        assembly {&#13;
            let result := delegatecall(gas, target, add(data, 0x20), mload(data), 0, 0)&#13;
            let size := returndatasize&#13;
            let ptr := mload(0x40)&#13;
            returndatacopy(ptr, 0, size)&#13;
            switch result&#13;
            case 0 { revert(ptr, size) }&#13;
            default { return(ptr, size) }&#13;
        }&#13;
    }&#13;
&#13;
    function initialize(&#13;
        address)&#13;
        public&#13;
    {&#13;
        revert();&#13;
    }&#13;
&#13;
    /*&#13;
     * Owner only functions&#13;
     */&#13;
    function replaceContract(&#13;
        address _target)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        _replaceContract(_target);&#13;
    }&#13;
&#13;
    function setTarget(&#13;
        string _funcId,  // example: "takeLoanOrderAsTrader(address[6],uint256[9],address,uint256,bytes)"&#13;
        address _target) // logic contract address&#13;
        public&#13;
        onlyOwner&#13;
        returns(bytes4)&#13;
    {&#13;
        bytes4 f = bytes4(keccak256(abi.encodePacked(_funcId)));&#13;
        targets[f] = _target;&#13;
        return f;&#13;
    }&#13;
&#13;
    function setBZxAddresses(&#13;
        address _bZRxToken,&#13;
        address _vault,&#13;
        address _oracleregistry,&#13;
        address _exchange0xWrapper) &#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        if (_bZRxToken != address(0) &amp;&amp; _vault != address(0) &amp;&amp; _oracleregistry != address(0) &amp;&amp; _exchange0xWrapper != address(0))&#13;
        bZRxTokenContract = _bZRxToken;&#13;
        vaultContract = _vault;&#13;
        oracleRegistryContract = _oracleregistry;&#13;
        bZxTo0xContract = _exchange0xWrapper;&#13;
    }&#13;
&#13;
    function setDebugMode (&#13;
        bool _debug)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        if (DEBUG_MODE != _debug)&#13;
            DEBUG_MODE = _debug;&#13;
    }&#13;
&#13;
    function setBZRxToken (&#13;
        address _token)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        if (_token != address(0))&#13;
            bZRxTokenContract = _token;&#13;
    }&#13;
&#13;
    function setVault (&#13;
        address _vault)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        if (_vault != address(0))&#13;
            vaultContract = _vault;&#13;
    }&#13;
&#13;
    function setOracleRegistry (&#13;
        address _registry)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        if (_registry != address(0))&#13;
            oracleRegistryContract = _registry;&#13;
    }&#13;
&#13;
    function setOracleReference (&#13;
        address _oracle,&#13;
        address _logicContract)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        if (oracleAddresses[_oracle] != _logicContract)&#13;
            oracleAddresses[_oracle] = _logicContract;&#13;
    }&#13;
&#13;
    function set0xExchangeWrapper (&#13;
        address _wrapper)&#13;
        public&#13;
        onlyOwner&#13;
    {&#13;
        if (_wrapper != address(0))&#13;
            bZxTo0xContract = _wrapper;&#13;
    }&#13;
&#13;
    /*&#13;
     * View functions&#13;
     */&#13;
&#13;
    function getTarget(&#13;
        string _funcId) // example: "takeLoanOrderAsTrader(address[6],uint256[9],address,uint256,bytes)"&#13;
        public&#13;
        view&#13;
        returns (address)&#13;
    {&#13;
        return targets[bytes4(keccak256(abi.encodePacked(_funcId)))];&#13;
    }&#13;
}