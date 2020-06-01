pragma solidity ^0.4.15;

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
    require(newOwner != address(0));      
    owner = newOwner;
  }

}

interface OraclizeI {
    // address public cbAddress;
    function cbAddress() constant returns (address); // Reads public variable cbAddress 
    function query(uint _timestamp, string _datasource, string _arg) payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) payable returns (bytes32 _id);
    function getPrice(string _datasoaurce) returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) returns (uint _dsprice);
    function useCoupon(string _coupon);
    function setProofType(byte _proofType);
    function setConfig(bytes32 _config);
    function setCustomGasPrice(uint _gasPrice);
    function randomDS_getSessionPubKeyHash() returns(bytes32);
}

interface OraclizeAddrResolverI {
    function getAddress() returns (address _addr);
}

// this is a reduced and optimize version of the usingOracalize contract in https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.4.sol
contract myUsingOracalize is Ownable {
    OraclizeAddrResolverI OAR;
    OraclizeI public oraclize;
    uint public oracalize_gaslimit = 100000;

    function myUsingOracalize() {
        oraclize_setNetwork();
        update_oracalize();
    }

    function update_oracalize() public {
        oraclize = OraclizeI(OAR.getAddress());
    }
    
    function oraclize_query(string datasource, string arg1, string arg2) internal returns (bytes32 id) {
        uint price = oraclize.getPrice(datasource, oracalize_gaslimit);
        if (price > 1 ether + tx.gasprice*oracalize_gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, oracalize_gaslimit);
    }
    
    function oraclize_getPrice(string datasource) internal returns (uint) {
        return oraclize.getPrice(datasource, oracalize_gaslimit);
    }

    function setGasLimit(uint _newLimit) onlyOwner public {
        oracalize_gaslimit = _newLimit;
    }
    
    function oraclize_setNetwork() internal {
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
        }
        else if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
        }
        else if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
        }
        else if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
        }
        else if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        }
        else if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
        }
        else if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
        }
        else {
            revert();
        }
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
        return _size;
    }

    // This will not throw error on wrong input, but instead consume large and unknown amount of gas
    // This should never occure as it's use with the ShapeShift deposit return value is checked before calling function
    function parseAddr(string _a) internal returns (address){
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i=2; i<2+2*20; i+=2){
            iaddr *= 256;
            b1 = uint160(tmp[i]);
            b2 = uint160(tmp[i+1]);
            if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
            else if ((b1 >= 65)&&(b1 <= 70)) b1 -= 55;
            else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
            if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
            else if ((b2 >= 65)&&(b2 <= 70)) b2 -= 55;
            else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
            iaddr += (b1*16+b2);
        }
        return address(iaddr);
    }
}

/// @title Inter-crypto currency converter
/// @author Jack Tanner - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6e04001a5f582e070d400f0d401b05">[email protected]</a>&gt;&#13;
contract InterCrypto is Ownable, myUsingOracalize {&#13;
    // _______________VARIABLES_______________&#13;
    struct Transaction {&#13;
        address returnAddress;&#13;
        uint amount;&#13;
    }&#13;
&#13;
    mapping (uint =&gt; Transaction) public transactions;&#13;
    uint transactionCount = 0;&#13;
    mapping (bytes32 =&gt; uint) oracalizeMyId2transactionID;&#13;
    mapping (address =&gt; uint) public recoverable;&#13;
&#13;
    // _______________EVENTS_______________&#13;
    event TransactionStarted(uint indexed transactionID);&#13;
    event TransactionSentToShapeShift(uint indexed transactionID, address indexed returnAddress, address indexed depositAddress, uint amount);&#13;
    event TransactionAborted(uint indexed transactionID, string reason);&#13;
    event Recovered(address indexed recoveredTo, uint amount);&#13;
&#13;
    // _______________EXTERNAL FUNCTIONS_______________&#13;
    // constructor&#13;
    function InterCrypto() {}&#13;
&#13;
    // suicide function&#13;
    function kill() onlyOwner external {&#13;
        selfdestruct(owner);&#13;
    }&#13;
&#13;
    // Default function which will accept Ether&#13;
    function () payable {}&#13;
&#13;
    // Return the price of using Oracalize&#13;
    function getInterCryptoPrice() constant public returns (uint) {&#13;
        return oraclize_getPrice('URL');&#13;
    }&#13;
&#13;
    // Create a cryptocurrency conversion using Oracalize and Shapeshift return address = msg.sender&#13;
    function sendToOtherBlockchain1(string _coinSymbol, string _toAddress) external payable returns(uint) {&#13;
        return engine(_coinSymbol, _toAddress, msg.sender);&#13;
    }&#13;
    &#13;
    // Create a cryptocurrency conversion using Oracalize and custom Shapeshift return address&#13;
    function sendToOtherBlockchain2(string _coinSymbol, string _toAddress, address _returnAddress) external payable returns(uint) {&#13;
        return engine(_coinSymbol, _toAddress, _returnAddress);&#13;
    }&#13;
&#13;
    // Callback function for Oracalize&#13;
    function __callback(bytes32 myid, string result) {&#13;
        if (msg.sender != oraclize.cbAddress()) revert();&#13;
&#13;
        uint transactionID = oracalizeMyId2transactionID[myid];&#13;
        Transaction memory transaction = transactions[transactionID];&#13;
        &#13;
        if( bytes(result).length == 0 ) {&#13;
            TransactionAborted(transactionID, "Oracalize return value was invalid, this is probably due to incorrect sendToOtherBlockchain() argments");&#13;
            recoverable[transaction.returnAddress] += transaction.amount;&#13;
            transaction.amount = 0;&#13;
        }&#13;
        else {&#13;
            address depositAddress = parseAddr(result);&#13;
            require(depositAddress != msg.sender); // prevent DAO tpe recursion hack that can potentially be done by oracalize&#13;
            uint sendAmount = transaction.amount;&#13;
            transaction.amount = 0;&#13;
            if (depositAddress.send(sendAmount))&#13;
                TransactionSentToShapeShift(transactionID, transaction.returnAddress, depositAddress, sendAmount);&#13;
            else {&#13;
                TransactionAborted(transactionID, "transaction to address returned by Oracalize failed");&#13;
                recoverable[transaction.returnAddress] += sendAmount;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    // Cancel a transaction that has not been completed&#13;
    // Note that this should only be required if Oracalize should fail to respond&#13;
    function cancelTransaction(uint transactionID) external {&#13;
        Transaction memory transaction = transactions[transactionID];&#13;
        &#13;
        if (transaction.amount &gt; 0) {&#13;
            require(msg.sender == transaction.returnAddress);&#13;
            recoverable[msg.sender] += transaction.amount;&#13;
            transaction.amount = 0;&#13;
            TransactionAborted(transactionID, "transaction cancelled by creator");&#13;
        }&#13;
    }&#13;
&#13;
    // Send any pending funds back to their owner&#13;
    function recover() external {&#13;
        uint amount = recoverable[msg.sender];&#13;
        recoverable[msg.sender] = 0;&#13;
        if (msg.sender.send(amount)) {&#13;
            Recovered(msg.sender, amount);&#13;
        }&#13;
        else {&#13;
            recoverable[msg.sender] = amount;&#13;
        }&#13;
    }&#13;
    // _______________PUBLIC FUNCTIONS_______________&#13;
&#13;
&#13;
    // _______________INTERNAL FUNCTIONS_______________&#13;
    // Request for a ShapeShift transaction to be made&#13;
    function engine(string _coinSymbol, string _toAddress, address _returnAddress) internal returns(uint transactionID) {&#13;
        // Example arguments:&#13;
        // "ltc", "LbZcDdMeP96ko85H21TQii98YFF9RgZg3D"   Litecoin&#13;
        // "btc", "1L8oRijgmkfcZDYA21b73b6DewLtyYs87s"   Bitcoin&#13;
        // "dash", "Xoopows17idkTwNrMZuySXBwQDorsezQAx"  Dash&#13;
        // "zec", "t1N7tf1xRxz5cBK51JADijLDWS592FPJtya"  ZCash&#13;
        // "doge", "DMAFvwTH2upni7eTau8au6Rktgm2bUkMei"   Dogecoin&#13;
        // See https://info.shapeshift.io/about&#13;
        // Test symbol pairs using ShapeShift API (shapeshift.io/validateAddress/[address]/[coinSymbol]) or by creating a test&#13;
        // transaction first whenever possible before using it with InterCrypto&#13;
        &#13;
        transactionID = transactionCount++;&#13;
&#13;
        if (!isValidateParameter(_coinSymbol, 6) || !isValidateParameter(_toAddress, 120)) { // Waves smbol is "waves" , Monero integrated addresses are 106 characters&#13;
            TransactionAborted(transactionID, "input parameters are too long or contain invalid symbols");&#13;
            recoverable[msg.sender] += msg.value;&#13;
            return;&#13;
        }&#13;
        &#13;
        uint oracalizePrice = getInterCryptoPrice();&#13;
&#13;
        if (msg.value &gt; oracalizePrice) {&#13;
            Transaction memory transaction = Transaction(_returnAddress, msg.value-oracalizePrice);&#13;
            transactions[transactionID] = transaction;&#13;
            &#13;
            // Create post data string like ' {"withdrawal":"LbZcDdMeP96ko85H21TQii98YFF9RgZg3D","pair":"eth_ltc","returnAddress":"558999ff2e0daefcb4fcded4c89e07fdf9ccb56c"}'&#13;
            string memory postData = createShapeShiftTransactionPost(_coinSymbol, _toAddress);&#13;
&#13;
            // TODO: send custom gasLimit for retrn transaction equal to the exact cost of __callback. Note that this should only be donewhen the contract is finalized&#13;
            bytes32 myQueryId = oraclize_query("URL", "json(https://shapeshift.io/shift).deposit", postData);&#13;
            &#13;
            if (myQueryId == 0) {&#13;
                TransactionAborted(transactionID, "unexpectedly high Oracalize price when calling oracalize_query");&#13;
                recoverable[msg.sender] += msg.value-oracalizePrice;&#13;
                transaction.amount = 0;&#13;
                return;&#13;
            }&#13;
            oracalizeMyId2transactionID[myQueryId] = transactionID;&#13;
            TransactionStarted(transactionID);&#13;
        }&#13;
        else {&#13;
            TransactionAborted(transactionID, "Not enough Ether sent to cover Oracalize fee");&#13;
            // transactions[transactionID].amount = 0;&#13;
            recoverable[msg.sender] += msg.value;&#13;
        }&#13;
    }&#13;
    &#13;
    // Adapted from https://github.com/kieranelby/KingOfTheEtherThrone/blob/master/contracts/KingOfTheEtherThrone.sol&#13;
    function isValidateParameter(string _parameter, uint maxSize) constant internal returns (bool allowed) {&#13;
        bytes memory parameterBytes = bytes(_parameter);&#13;
        uint lengthBytes = parameterBytes.length;&#13;
        if (lengthBytes &lt; 1 ||&#13;
            lengthBytes &gt; maxSize) {&#13;
            return false;&#13;
        }&#13;
        &#13;
        for (uint i = 0; i &lt; lengthBytes; i++) {&#13;
            byte b = parameterBytes[i];&#13;
            if ( !(&#13;
                (b &gt;= 48 &amp;&amp; b &lt;= 57) || // 0 - 9&#13;
                (b &gt;= 65 &amp;&amp; b &lt;= 90) || // A - Z&#13;
                (b &gt;= 97 &amp;&amp; b &lt;= 122)   // a - z&#13;
            )) {&#13;
                return false;&#13;
            }&#13;
        }&#13;
        return true;&#13;
    }&#13;
    &#13;
    function concatBytes(bytes b1, bytes b2, bytes b3, bytes b4, bytes b5, bytes b6, bytes b7) internal returns (bytes bFinal) {&#13;
        bFinal = new bytes(b1.length + b2.length + b3.length + b4.length + b5.length + b6.length + b7.length);&#13;
&#13;
        uint i = 0;&#13;
        uint j;&#13;
        for (j = 0; j &lt; b1.length; j++) bFinal[i++] = b1[j];&#13;
        for (j = 0; j &lt; b2.length; j++) bFinal[i++] = b2[j];&#13;
        for (j = 0; j &lt; b3.length; j++) bFinal[i++] = b3[j];&#13;
        for (j = 0; j &lt; b4.length; j++) bFinal[i++] = b4[j];&#13;
        for (j = 0; j &lt; b5.length; j++) bFinal[i++] = b5[j];&#13;
        for (j = 0; j &lt; b6.length; j++) bFinal[i++] = b6[j];&#13;
        for (j = 0; j &lt; b7.length; j++) bFinal[i++] = b7[j];&#13;
    }&#13;
&#13;
    function createShapeShiftTransactionPost(string _coinSymbol, string _toAddress) internal returns (string sFinal) {&#13;
        string memory s1 = ' {"withdrawal":"';&#13;
        string memory s3 = '","pair":"eth_';&#13;
        string memory s5 = '","returnAddress":"';&#13;
        string memory s7 = '"}';&#13;
&#13;
        bytes memory bFinal = concatBytes(bytes(s1), bytes(_toAddress), bytes(s3), bytes(_coinSymbol), bytes(s5), bytes(addressToBytes(msg.sender)), bytes(s7));&#13;
&#13;
        sFinal = string(bFinal);&#13;
    }&#13;
&#13;
        // Authored by https://github.com/axic&#13;
    function nibbleToChar(uint nibble) internal returns (uint ret) {&#13;
        if (nibble &gt; 9)&#13;
        return nibble + 87; // nibble + 'a'- 10&#13;
        else&#13;
        return nibble + 48; // '0'&#13;
    }&#13;
&#13;
    // Authored by https://github.com/axic&#13;
    function addressToBytes(address _address) internal returns (bytes) {&#13;
        uint160 tmp = uint160(_address);&#13;
&#13;
        // 40 bytes of space, but actually uses 64 bytes&#13;
        string memory holder = "                                        ";&#13;
        bytes memory ret = bytes(holder);&#13;
&#13;
        // NOTE: this is written in an expensive way, as out-of-order array access&#13;
        //       is not supported yet, e.g. we cannot go in reverse easily&#13;
        //       (or maybe it is a bug: https://github.com/ethereum/solidity/issues/212)&#13;
        uint j = 0;&#13;
        for (uint i = 0; i &lt; 20; i++) {&#13;
            uint _tmp = tmp / (2 ** (8*(19-i))); // shr(tmp, 8*(19-i))&#13;
            uint nb1 = (_tmp / 0x10) &amp; 0x0f;     // shr(tmp, 8) &amp; 0x0f&#13;
            uint nb2 = _tmp &amp; 0x0f;&#13;
            ret[j++] = byte(nibbleToChar(nb1));&#13;
            ret[j++] = byte(nibbleToChar(nb2));&#13;
        }&#13;
&#13;
        return ret;&#13;
    }&#13;
&#13;
    // _______________PRIVATE FUNCTIONS_______________&#13;
&#13;
}