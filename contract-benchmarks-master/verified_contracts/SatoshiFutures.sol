pragma solidity ^0.4.19;




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
// <ORACLIZE_API>
/*
Copyright (c) 2015-2016 Oraclize SRL
Copyright (c) 2016 Oraclize LTD



Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:



The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.



THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

// This api is currently targeted at 0.4.18, please import oraclizeAPI_pre0.4.sol or oraclizeAPI_0.4 where necessary


contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);
    function getPrice(string _datasource) public returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) public returns (uint _dsprice);
    function setProofType(byte _proofType) external;
    function setCustomGasPrice(uint _gasPrice) external;
    function randomDS_getSessionPubKeyHash() external constant returns(bytes32);
}
contract OraclizeAddrResolverI {
    function getAddress() public returns (address _addr);
}
contract usingOraclize {
    uint constant day = 60*60*24;
    uint constant week = 60*60*24*7;
    uint constant month = 60*60*24*30;
    byte constant proofType_NONE = 0x00;
    byte constant proofType_TLSNotary = 0x10;
    byte constant proofType_Android = 0x20;
    byte constant proofType_Ledger = 0x30;
    byte constant proofType_Native = 0xF0;
    byte constant proofStorage_IPFS = 0x01;
    uint8 constant networkID_auto = 0;
    uint8 constant networkID_mainnet = 1;
    uint8 constant networkID_testnet = 2;
    uint8 constant networkID_morden = 2;
    uint8 constant networkID_consensys = 161;

    OraclizeAddrResolverI OAR;

    OraclizeI oraclize;
    modifier oraclizeAPI {
        if((address(OAR)==0)||(getCodeSize(address(OAR))==0))
            oraclize_setNetwork(networkID_auto);

        if(address(oraclize) != OAR.getAddress())
            oraclize = OraclizeI(OAR.getAddress());

        _;
    }
    modifier coupon(string code){
        oraclize = OraclizeI(OAR.getAddress());
        _;
    }

    function oraclize_setNetwork(uint8 networkID) internal returns(bool){
      return oraclize_setNetwork();
      networkID; // silence the warning and remain backwards compatible
    }
    function oraclize_setNetwork() internal returns(bool){
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            OAR = OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
            oraclize_setNetworkName("eth_mainnet");
            return true;
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            OAR = OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
            oraclize_setNetworkName("eth_ropsten3");
            return true;
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
            OAR = OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
            oraclize_setNetworkName("eth_kovan");
            return true;
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
            OAR = OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
            oraclize_setNetworkName("eth_rinkeby");
            return true;
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
            return true;
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            OAR = OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
            return true;
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            OAR = OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
            return true;
        }
        return false;
    }

    function __callback(bytes32 myid, string result) public {
        __callback(myid, result, new bytes(0));
    }
    function __callback(bytes32 myid, string result, bytes proof) public {
      return;
      myid; result; proof; // Silence compiler warnings
    }

    function oraclize_getPrice(string datasource) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource);
    }

    function oraclize_getPrice(string datasource, uint gaslimit) oraclizeAPI internal returns (uint){
        return oraclize.getPrice(datasource, gaslimit);
    }

    function oraclize_query(string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(0, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query.value(price)(timestamp, datasource, arg);
    }
    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query_withGasLimit.value(price)(0, datasource, arg, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(0, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oraclize.query2.value(price)(timestamp, datasource, arg1, arg2);
    }
    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oraclize.query2_withGasLimit.value(price)(0, datasource, arg1, arg2, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, string[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        string[] memory dynargs = new string[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(0, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN.value(price)(timestamp, datasource, args);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[] argN, uint gaslimit) oraclizeAPI internal returns (bytes32 id){
        uint price = oraclize.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = ba2cbor(argN);
        return oraclize.queryN_withGasLimit.value(price)(0, datasource, args, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[1] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](1);
        dynargs[0] = args[0];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[2] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](2);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[3] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](3);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_query(string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[4] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](4);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        return oraclize_query(datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs);
    }
    function oraclize_query(uint timestamp, string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(timestamp, datasource, dynargs, gaslimit);
    }
    function oraclize_query(string datasource, bytes[5] args, uint gaslimit) oraclizeAPI internal returns (bytes32 id) {
        bytes[] memory dynargs = new bytes[](5);
        dynargs[0] = args[0];
        dynargs[1] = args[1];
        dynargs[2] = args[2];
        dynargs[3] = args[3];
        dynargs[4] = args[4];
        return oraclize_query(datasource, dynargs, gaslimit);
    }

    function oraclize_cbAddress() oraclizeAPI internal returns (address){
        return oraclize.cbAddress();
    }
    function oraclize_setProof(byte proofP) oraclizeAPI internal {
        return oraclize.setProofType(proofP);
    }
    function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
        return oraclize.setCustomGasPrice(gasPrice);
    }

    function oraclize_randomDS_getSessionPubKeyHash() oraclizeAPI internal returns (bytes32){
        return oraclize.randomDS_getSessionPubKeyHash();
    }

    function getCodeSize(address _addr) constant internal returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }

    function parseAddr(string _a) internal pure returns (address){
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

    function strCompare(string _a, string _b) internal pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

    function indexOf(string _haystack, string _needle) internal pure returns (int) {
        bytes memory h = bytes(_haystack);
        bytes memory n = bytes(_needle);
        if(h.length < 1 || n.length < 1 || (n.length > h.length))
            return -1;
        else if(h.length > (2**128 -1))
            return -1;
        else
        {
            uint subindex = 0;
            for (uint i = 0; i < h.length; i ++)
            {
                if (h[i] == n[0])
                {
                    subindex = 1;
                    while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex])
                    {
                        subindex++;
                    }
                    if(subindex == n.length)
                        return int(i);
                }
            }
            return -1;
        }
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a) internal pure returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b) internal pure returns (uint) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i=0; i<bresult.length; i++){
            if ((bresult[i] >= 48)&&(bresult[i] <= 57)){
                if (decimals){
                   if (_b == 0) break;
                    else _b--;
                }
                mint *= 10;
                mint += uint(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mint *= 10**_b;
        return mint;
    }

    function uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function stra2cbor(string[] arr) internal pure returns (bytes) {
            uint arrlen = arr.length;

            // get correct cbor output length
            uint outputlen = 0;
            bytes[] memory elemArray = new bytes[](arrlen);
            for (uint i = 0; i < arrlen; i++) {
                elemArray[i] = (bytes(arr[i]));
                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
            }
            uint ctr = 0;
            uint cborlen = arrlen + 0x80;
            outputlen += byte(cborlen).length;
            bytes memory res = new bytes(outputlen);

            while (byte(cborlen).length > ctr) {
                res[ctr] = byte(cborlen)[ctr];
                ctr++;
            }
            for (i = 0; i < arrlen; i++) {
                res[ctr] = 0x5F;
                ctr++;
                for (uint x = 0; x < elemArray[i].length; x++) {
                    // if there's a bug with larger strings, this may be the culprit
                    if (x % 23 == 0) {
                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                        elemcborlen += 0x40;
                        uint lctr = ctr;
                        while (byte(elemcborlen).length > ctr - lctr) {
                            res[ctr] = byte(elemcborlen)[ctr - lctr];
                            ctr++;
                        }
                    }
                    res[ctr] = elemArray[i][x];
                    ctr++;
                }
                res[ctr] = 0xFF;
                ctr++;
            }
            return res;
        }

    function ba2cbor(bytes[] arr) internal pure returns (bytes) {
            uint arrlen = arr.length;

            // get correct cbor output length
            uint outputlen = 0;
            bytes[] memory elemArray = new bytes[](arrlen);
            for (uint i = 0; i < arrlen; i++) {
                elemArray[i] = (bytes(arr[i]));
                outputlen += elemArray[i].length + (elemArray[i].length - 1)/23 + 3; //+3 accounts for paired identifier types
            }
            uint ctr = 0;
            uint cborlen = arrlen + 0x80;
            outputlen += byte(cborlen).length;
            bytes memory res = new bytes(outputlen);

            while (byte(cborlen).length > ctr) {
                res[ctr] = byte(cborlen)[ctr];
                ctr++;
            }
            for (i = 0; i < arrlen; i++) {
                res[ctr] = 0x5F;
                ctr++;
                for (uint x = 0; x < elemArray[i].length; x++) {
                    // if there's a bug with larger strings, this may be the culprit
                    if (x % 23 == 0) {
                        uint elemcborlen = elemArray[i].length - x >= 24 ? 23 : elemArray[i].length - x;
                        elemcborlen += 0x40;
                        uint lctr = ctr;
                        while (byte(elemcborlen).length > ctr - lctr) {
                            res[ctr] = byte(elemcborlen)[ctr - lctr];
                            ctr++;
                        }
                    }
                    res[ctr] = elemArray[i][x];
                    ctr++;
                }
                res[ctr] = 0xFF;
                ctr++;
            }
            return res;
        }


    string oraclize_network_name;
    function oraclize_setNetworkName(string _network_name) internal {
        oraclize_network_name = _network_name;
    }

    function oraclize_getNetworkName() internal view returns (string) {
        return oraclize_network_name;
    }

    function oraclize_newRandomDSQuery(uint _delay, uint _nbytes, uint _customGasLimit) internal returns (bytes32){
        require((_nbytes > 0) && (_nbytes <= 32));
        bytes memory nbytes = new bytes(1);
        nbytes[0] = byte(_nbytes);
        bytes memory unonce = new bytes(32);
        bytes memory sessionKeyHash = new bytes(32);
        bytes32 sessionKeyHash_bytes32 = oraclize_randomDS_getSessionPubKeyHash();
        assembly {
            mstore(unonce, 0x20)
            mstore(add(unonce, 0x20), xor(blockhash(sub(number, 1)), xor(coinbase, timestamp)))
            mstore(sessionKeyHash, 0x20)
            mstore(add(sessionKeyHash, 0x20), sessionKeyHash_bytes32)
        }
        bytes[3] memory args = [unonce, nbytes, sessionKeyHash];
        bytes32 queryId = oraclize_query(_delay, "random", args, _customGasLimit);
        oraclize_randomDS_setCommitment(queryId, keccak256(bytes8(_delay), args[1], sha256(args[0]), args[2]));
        return queryId;
    }

    function oraclize_randomDS_setCommitment(bytes32 queryId, bytes32 commitment) internal {
        oraclize_randomDS_args[queryId] = commitment;
    }

    mapping(bytes32=>bytes32) oraclize_randomDS_args;
    mapping(bytes32=>bool) oraclize_randomDS_sessionKeysHashVerified;

    function verifySig(bytes32 tosignh, bytes dersig, bytes pubkey) internal returns (bool){
        bool sigok;
        address signer;

        bytes32 sigr;
        bytes32 sigs;

        bytes memory sigr_ = new bytes(32);
        uint offset = 4+(uint(dersig[3]) - 0x20);
        sigr_ = copyBytes(dersig, offset, 32, sigr_, 0);
        bytes memory sigs_ = new bytes(32);
        offset += 32 + 2;
        sigs_ = copyBytes(dersig, offset+(uint(dersig[offset-1]) - 0x20), 32, sigs_, 0);

        assembly {
            sigr := mload(add(sigr_, 32))
            sigs := mload(add(sigs_, 32))
        }


        (sigok, signer) = safer_ecrecover(tosignh, 27, sigr, sigs);
        if (address(keccak256(pubkey)) == signer) return true;
        else {
            (sigok, signer) = safer_ecrecover(tosignh, 28, sigr, sigs);
            return (address(keccak256(pubkey)) == signer);
        }
    }

    function oraclize_randomDS_proofVerify__sessionKeyValidity(bytes proof, uint sig2offset) internal returns (bool) {
        bool sigok;

        // Step 6: verify the attestation signature, APPKEY1 must sign the sessionKey from the correct ledger app (CODEHASH)
        bytes memory sig2 = new bytes(uint(proof[sig2offset+1])+2);
        copyBytes(proof, sig2offset, sig2.length, sig2, 0);

        bytes memory appkey1_pubkey = new bytes(64);
        copyBytes(proof, 3+1, 64, appkey1_pubkey, 0);

        bytes memory tosign2 = new bytes(1+65+32);
        tosign2[0] = byte(1); //role
        copyBytes(proof, sig2offset-65, 65, tosign2, 1);
        bytes memory CODEHASH = hex"fd94fa71bc0ba10d39d464d0d8f465efeef0a2764e3887fcc9df41ded20f505c";
        copyBytes(CODEHASH, 0, 32, tosign2, 1+65);
        sigok = verifySig(sha256(tosign2), sig2, appkey1_pubkey);

        if (sigok == false) return false;


        // Step 7: verify the APPKEY1 provenance (must be signed by Ledger)
        bytes memory LEDGERKEY = hex"7fb956469c5c9b89840d55b43537e66a98dd4811ea0a27224272c2e5622911e8537a2f8e86a46baec82864e98dd01e9ccc2f8bc5dfc9cbe5a91a290498dd96e4";

        bytes memory tosign3 = new bytes(1+65);
        tosign3[0] = 0xFE;
        copyBytes(proof, 3, 65, tosign3, 1);

        bytes memory sig3 = new bytes(uint(proof[3+65+1])+2);
        copyBytes(proof, 3+65, sig3.length, sig3, 0);

        sigok = verifySig(sha256(tosign3), sig3, LEDGERKEY);

        return sigok;
    }

    modifier oraclize_randomDS_proofVerify(bytes32 _queryId, string _result, bytes _proof) {
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        require((_proof[0] == "L") && (_proof[1] == "P") && (_proof[2] == 1));

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        require(proofVerified);

        _;
    }

    function oraclize_randomDS_proofVerify__returnCode(bytes32 _queryId, string _result, bytes _proof) internal returns (uint8){
        // Step 1: the prefix has to match 'LP\x01' (Ledger Proof version 1)
        if ((_proof[0] != "L")||(_proof[1] != "P")||(_proof[2] != 1)) return 1;

        bool proofVerified = oraclize_randomDS_proofVerify__main(_proof, _queryId, bytes(_result), oraclize_getNetworkName());
        if (proofVerified == false) return 2;

        return 0;
    }

    function matchBytes32Prefix(bytes32 content, bytes prefix, uint n_random_bytes) internal pure returns (bool){
        bool match_ = true;
        

        for (uint256 i=0; i< n_random_bytes; i++) {
            if (content[i] != prefix[i]) match_ = false;
        }

        return match_;
    }

    function oraclize_randomDS_proofVerify__main(bytes proof, bytes32 queryId, bytes result, string context_name) internal returns (bool){

        // Step 2: the unique keyhash has to match with the sha256 of (context name + queryId)
        uint ledgerProofLength = 3+65+(uint(proof[3+65+1])+2)+32;
        bytes memory keyhash = new bytes(32);
        copyBytes(proof, ledgerProofLength, 32, keyhash, 0);
        if (!(keccak256(keyhash) == keccak256(sha256(context_name, queryId)))) return false;

        bytes memory sig1 = new bytes(uint(proof[ledgerProofLength+(32+8+1+32)+1])+2);
        copyBytes(proof, ledgerProofLength+(32+8+1+32), sig1.length, sig1, 0);

        // Step 3: we assume sig1 is valid (it will be verified during step 5) and we verify if 'result' is the prefix of sha256(sig1)
        if (!matchBytes32Prefix(sha256(sig1), result, uint(proof[ledgerProofLength+32+8]))) return false;

        // Step 4: commitment match verification, keccak256(delay, nbytes, unonce, sessionKeyHash) == commitment in storage.
        // This is to verify that the computed args match with the ones specified in the query.
        bytes memory commitmentSlice1 = new bytes(8+1+32);
        copyBytes(proof, ledgerProofLength+32, 8+1+32, commitmentSlice1, 0);

        bytes memory sessionPubkey = new bytes(64);
        uint sig2offset = ledgerProofLength+32+(8+1+32)+sig1.length+65;
        copyBytes(proof, sig2offset-64, 64, sessionPubkey, 0);

        bytes32 sessionPubkeyHash = sha256(sessionPubkey);
        if (oraclize_randomDS_args[queryId] == keccak256(commitmentSlice1, sessionPubkeyHash)){ //unonce, nbytes and sessionKeyHash match
            delete oraclize_randomDS_args[queryId];
        } else return false;


        // Step 5: validity verification for sig1 (keyhash and args signed with the sessionKey)
        bytes memory tosign1 = new bytes(32+8+1+32);
        copyBytes(proof, ledgerProofLength, 32+8+1+32, tosign1, 0);
        if (!verifySig(sha256(tosign1), sig1, sessionPubkey)) return false;

        // verify if sessionPubkeyHash was verified already, if not.. let's do it!
        if (oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] == false){
            oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash] = oraclize_randomDS_proofVerify__sessionKeyValidity(proof, sig2offset);
        }

        return oraclize_randomDS_sessionKeysHashVerified[sessionPubkeyHash];
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function copyBytes(bytes from, uint fromOffset, uint length, bytes to, uint toOffset) internal pure returns (bytes) {
        uint minLength = length + toOffset;

        // Buffer too small
        require(to.length >= minLength); // Should be a better way?

        // NOTE: the offset 32 is added to skip the `size` field of both bytes variables
        uint i = 32 + fromOffset;
        uint j = 32 + toOffset;

        while (i < (32 + fromOffset + length)) {
            assembly {
                let tmp := mload(add(from, i))
                mstore(add(to, j), tmp)
            }
            i += 32;
            j += 32;
        }

        return to;
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    // Duplicate Solidity's ecrecover, but catching the CALL return value
    function safer_ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal returns (bool, address) {
        // We do our own memory management here. Solidity uses memory offset
        // 0x40 to store the current end of memory. We write past it (as
        // writes are memory extensions), but don't update the offset so
        // Solidity will reuse it. The memory used here is only needed for
        // this context.

        // FIXME: inline assembly can't access return values
        bool ret;
        address addr;

        assembly {
            let size := mload(0x40)
            mstore(size, hash)
            mstore(add(size, 32), v)
            mstore(add(size, 64), r)
            mstore(add(size, 96), s)

            // NOTE: we can reuse the request memory because we deal with
            //       the return code
            ret := call(3000, 1, 0, size, 128, size, 32)
            addr := mload(size)
        }

        return (ret, addr);
    }

    // the following function has been written by Alex Beregszaszi (@axic), use it under the terms of the MIT license
    function ecrecovery(bytes32 hash, bytes sig) internal returns (bool, address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (sig.length != 65)
          return (false, 0);

        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))

            // Here we are loading the last 32 bytes. We exploit the fact that
            // 'mload' will pad with zeroes if we overread.
            // There is no 'mload8' to do this, but that would be nicer.
            v := byte(0, mload(add(sig, 96)))

            // Alternative solution:
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            // v := and(mload(add(sig, 65)), 255)
        }

        // albeit non-transactional signatures are not specified by the YP, one would expect it
        // to match the YP range of [27, 28]
        //
        // geth uses [0, 1] and some clients have followed. This might change, see:
        //  https://github.com/ethereum/go-ethereum/issues/2053
        if (v < 27)
          v += 27;

        if (v != 27 && v != 28)
            return (false, 0);

        return safer_ecrecover(hash, v, r, s);
    }

}
// </ORACLIZE_API>
/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0b6a796a686365626f4b65647f6f647f25656e7f">[email protected]</a>&gt;&#13;
 *&#13;
 * @dev Functionality in this library is largely implemented using an&#13;
 *      abstraction called a 'slice'. A slice represents a part of a string -&#13;
 *      anything from the entire string to a single character, or even no&#13;
 *      characters at all (a 0-length slice). Since a slice only has to specify&#13;
 *      an offset and a length, copying and manipulating slices is a lot less&#13;
 *      expensive than copying and manipulating the strings they reference.&#13;
 *&#13;
 *      To further reduce gas costs, most functions on slice that need to return&#13;
 *      a slice modify the original one instead of allocating a new one; for&#13;
 *      instance, `s.split(".")` will return the text up to the first '.',&#13;
 *      modifying s to only contain the remainder of the string after the '.'.&#13;
 *      In situations where you do not want to modify the original slice, you&#13;
 *      can make a copy first with `.copy()`, for example:&#13;
 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since&#13;
 *      Solidity has no memory management, it will result in allocating many&#13;
 *      short-lived slices that are later discarded.&#13;
 *&#13;
 *      Functions that return two slices come in two versions: a non-allocating&#13;
 *      version that takes the second slice as an argument, modifying it in&#13;
 *      place, and an allocating version that allocates and returns the second&#13;
 *      slice; see `nextRune` for example.&#13;
 *&#13;
 *      Functions that have to copy string data will return strings rather than&#13;
 *      slices; these can be cast back to slices for further processing if&#13;
 *      required.&#13;
 *&#13;
 *      For convenience, some functions are provided with non-modifying&#13;
 *      variants that create a new slice and return both; for instance,&#13;
 *      `s.splitNew('.')` leaves s unmodified, and returns two values&#13;
 *      corresponding to the left and right parts of the string.&#13;
 */&#13;
 &#13;
&#13;
&#13;
library strings {&#13;
    struct slice {&#13;
        uint _len;&#13;
        uint _ptr;&#13;
    }&#13;
&#13;
    function memcpy(uint dest, uint src, uint len) private {&#13;
        // Copy word-length chunks while possible&#13;
        for(; len &gt;= 32; len -= 32) {&#13;
            assembly {&#13;
                mstore(dest, mload(src))&#13;
            }&#13;
            dest += 32;&#13;
            src += 32;&#13;
        }&#13;
&#13;
        // Copy remaining bytes&#13;
        uint mask = 256 ** (32 - len) - 1;&#13;
        assembly {&#13;
            let srcpart := and(mload(src), not(mask))&#13;
            let destpart := and(mload(dest), mask)&#13;
            mstore(dest, or(destpart, srcpart))&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns a slice containing the entire string.&#13;
     * @param self The string to make a slice from.&#13;
     * @return A newly allocated slice containing the entire string.&#13;
     */&#13;
    function toSlice(string self) internal returns (slice) {&#13;
        uint ptr;&#13;
        assembly {&#13;
            ptr := add(self, 0x20)&#13;
        }&#13;
        return slice(bytes(self).length, ptr);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the length of a null-terminated bytes32 string.&#13;
     * @param self The value to find the length of.&#13;
     * @return The length of the string, from 0 to 32.&#13;
     */&#13;
    function len(bytes32 self) internal returns (uint) {&#13;
        uint ret;&#13;
        if (self == 0)&#13;
            return 0;&#13;
        if (self &amp; 0xffffffffffffffffffffffffffffffff == 0) {&#13;
            ret += 16;&#13;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);&#13;
        }&#13;
        if (self &amp; 0xffffffffffffffff == 0) {&#13;
            ret += 8;&#13;
            self = bytes32(uint(self) / 0x10000000000000000);&#13;
        }&#13;
        if (self &amp; 0xffffffff == 0) {&#13;
            ret += 4;&#13;
            self = bytes32(uint(self) / 0x100000000);&#13;
        }&#13;
        if (self &amp; 0xffff == 0) {&#13;
            ret += 2;&#13;
            self = bytes32(uint(self) / 0x10000);&#13;
        }&#13;
        if (self &amp; 0xff == 0) {&#13;
            ret += 1;&#13;
        }&#13;
        return 32 - ret;&#13;
    }&#13;
&#13;
 &#13;
&#13;
&#13;
    /*&#13;
     * @dev Copies a slice to a new string.&#13;
     * @param self The slice to copy.&#13;
     * @return A newly allocated string containing the slice's text.&#13;
     */&#13;
    function toString(slice self) internal returns (string) {&#13;
        var ret = new string(self._len);&#13;
        uint retptr;&#13;
        assembly { retptr := add(ret, 32) }&#13;
&#13;
        memcpy(retptr, self._ptr, self._len);&#13;
        return ret;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the length in runes of the slice. Note that this operation&#13;
     *      takes time proportional to the length of the slice; avoid using it&#13;
     *      in loops, and call `slice.empty()` if you only need to know whether&#13;
     *      the slice is empty or not.&#13;
     * @param self The slice to operate on.&#13;
     * @return The length of the slice in runes.&#13;
     */&#13;
    function len(slice self) internal returns (uint l) {&#13;
        // Starting at ptr-31 means the LSB will be the byte we care about&#13;
        var ptr = self._ptr - 31;&#13;
        var end = ptr + self._len;&#13;
        for (l = 0; ptr &lt; end; l++) {&#13;
            uint8 b;&#13;
            assembly { b := and(mload(ptr), 0xFF) }&#13;
            if (b &lt; 0x80) {&#13;
                ptr += 1;&#13;
            } else if(b &lt; 0xE0) {&#13;
                ptr += 2;&#13;
            } else if(b &lt; 0xF0) {&#13;
                ptr += 3;&#13;
            } else if(b &lt; 0xF8) {&#13;
                ptr += 4;&#13;
            } else if(b &lt; 0xFC) {&#13;
                ptr += 5;&#13;
            } else {&#13;
                ptr += 6;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
      /*&#13;
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.&#13;
     * @param self The slice to search.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @return The number of occurrences of `needle` found in `self`.&#13;
     */&#13;
    function count(slice self, slice needle) internal returns (uint cnt) {&#13;
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;&#13;
        while (ptr &lt;= self._ptr + self._len) {&#13;
            cnt++;&#13;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;&#13;
        }&#13;
    }&#13;
     /*&#13;
     * @dev Returns a positive number if `other` comes lexicographically after&#13;
     *      `self`, a negative number if it comes before, or zero if the&#13;
     *      contents of the two slices are equal. Comparison is done per-rune,&#13;
     *      on unicode codepoints.&#13;
     * @param self The first slice to compare.&#13;
     * @param other The second slice to compare.&#13;
     * @return The result of the comparison.&#13;
     */&#13;
    function compare(slice self, slice other) internal returns (int) {&#13;
        uint shortest = self._len;&#13;
        if (other._len &lt; self._len)&#13;
            shortest = other._len;&#13;
&#13;
        var selfptr = self._ptr;&#13;
        var otherptr = other._ptr;&#13;
        for (uint idx = 0; idx &lt; shortest; idx += 32) {&#13;
            uint a;&#13;
            uint b;&#13;
            assembly {&#13;
                a := mload(selfptr)&#13;
                b := mload(otherptr)&#13;
            }&#13;
            if (a != b) {&#13;
                // Mask out irrelevant bytes and check again&#13;
                uint mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);&#13;
                var diff = (a &amp; mask) - (b &amp; mask);&#13;
                if (diff != 0)&#13;
                    return int(diff);&#13;
            }&#13;
            selfptr += 32;&#13;
            otherptr += 32;&#13;
        }&#13;
        return int(self._len) - int(other._len);&#13;
    }&#13;
&#13;
&#13;
    /*&#13;
     * @dev Returns true if the two slices contain the same text.&#13;
     * @param self The first slice to compare.&#13;
     * @param self The second slice to compare.&#13;
     * @return True if the slices are equal, false otherwise.&#13;
     */&#13;
    function equals(slice self, slice other) internal returns (bool) {&#13;
        return compare(self, other) == 0;&#13;
    }&#13;
&#13;
&#13;
    /*&#13;
     * @dev If `self` starts with `needle`, `needle` is removed from the&#13;
     *      beginning of `self`. Otherwise, `self` is unmodified.&#13;
     * @param self The slice to operate on.&#13;
     * @param needle The slice to search for.&#13;
     * @return `self`&#13;
     */&#13;
    function beyond(slice self, slice needle) internal returns (slice) {&#13;
        if (self._len &lt; needle._len) {&#13;
            return self;&#13;
        }&#13;
&#13;
        bool equal = true;&#13;
        if (self._ptr != needle._ptr) {&#13;
            assembly {&#13;
                let length := mload(needle)&#13;
                let selfptr := mload(add(self, 0x20))&#13;
                let needleptr := mload(add(needle, 0x20))&#13;
                equal := eq(sha3(selfptr, length), sha3(needleptr, length))&#13;
            }&#13;
        }&#13;
&#13;
        if (equal) {&#13;
            self._len -= needle._len;&#13;
            self._ptr += needle._len;&#13;
        }&#13;
&#13;
        return self;&#13;
    }&#13;
&#13;
&#13;
&#13;
    /*&#13;
     * @dev If `self` ends with `needle`, `needle` is removed from the&#13;
     *      end of `self`. Otherwise, `self` is unmodified.&#13;
     * @param self The slice to operate on.&#13;
     * @param needle The slice to search for.&#13;
     * @return `self`&#13;
     */&#13;
    function until(slice self, slice needle) internal returns (slice) {&#13;
        if (self._len &lt; needle._len) {&#13;
            return self;&#13;
        }&#13;
&#13;
        var selfptr = self._ptr + self._len - needle._len;&#13;
        bool equal = true;&#13;
        if (selfptr != needle._ptr) {&#13;
            assembly {&#13;
                let length := mload(needle)&#13;
                let needleptr := mload(add(needle, 0x20))&#13;
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))&#13;
            }&#13;
        }&#13;
&#13;
        if (equal) {&#13;
            self._len -= needle._len;&#13;
        }&#13;
&#13;
        return self;&#13;
    }&#13;
&#13;
    // Returns the memory address of the first byte of the first occurrence of&#13;
    // `needle` in `self`, or the first byte after `self` if not found.&#13;
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {&#13;
        uint ptr;&#13;
        uint idx;&#13;
&#13;
        if (needlelen &lt;= selflen) {&#13;
            if (needlelen &lt;= 32) {&#13;
                // Optimized assembly for 68 gas per byte on short strings&#13;
                assembly {&#13;
                    let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))&#13;
                    let needledata := and(mload(needleptr), mask)&#13;
                    let end := add(selfptr, sub(selflen, needlelen))&#13;
                    ptr := selfptr&#13;
                    loop:&#13;
                    jumpi(exit, eq(and(mload(ptr), mask), needledata))&#13;
                    ptr := add(ptr, 1)&#13;
                    jumpi(loop, lt(sub(ptr, 1), end))&#13;
                    ptr := add(selfptr, selflen)&#13;
                    exit:&#13;
                }&#13;
                return ptr;&#13;
            } else {&#13;
                // For long needles, use hashing&#13;
                bytes32 hash;&#13;
                assembly { hash := sha3(needleptr, needlelen) }&#13;
                ptr = selfptr;&#13;
                for (idx = 0; idx &lt;= selflen - needlelen; idx++) {&#13;
                    bytes32 testHash;&#13;
                    assembly { testHash := sha3(ptr, needlelen) }&#13;
                    if (hash == testHash)&#13;
                        return ptr;&#13;
                    ptr += 1;&#13;
                }&#13;
            }&#13;
        }&#13;
        return selfptr + selflen;&#13;
    }&#13;
&#13;
    // Returns the memory address of the first byte after the last occurrence of&#13;
    // `needle` in `self`, or the address of `self` if not found.&#13;
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {&#13;
        uint ptr;&#13;
&#13;
        if (needlelen &lt;= selflen) {&#13;
            if (needlelen &lt;= 32) {&#13;
                // Optimized assembly for 69 gas per byte on short strings&#13;
                assembly {&#13;
                    let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))&#13;
                    let needledata := and(mload(needleptr), mask)&#13;
                    ptr := add(selfptr, sub(selflen, needlelen))&#13;
                    loop:&#13;
                    jumpi(ret, eq(and(mload(ptr), mask), needledata))&#13;
                    ptr := sub(ptr, 1)&#13;
                    jumpi(loop, gt(add(ptr, 1), selfptr))&#13;
                    ptr := selfptr&#13;
                    jump(exit)&#13;
                    ret:&#13;
                    ptr := add(ptr, needlelen)&#13;
                    exit:&#13;
                }&#13;
                return ptr;&#13;
            } else {&#13;
                // For long needles, use hashing&#13;
                bytes32 hash;&#13;
                assembly { hash := sha3(needleptr, needlelen) }&#13;
                ptr = selfptr + (selflen - needlelen);&#13;
                while (ptr &gt;= selfptr) {&#13;
                    bytes32 testHash;&#13;
                    assembly { testHash := sha3(ptr, needlelen) }&#13;
                    if (hash == testHash)&#13;
                        return ptr + needlelen;&#13;
                    ptr -= 1;&#13;
                }&#13;
            }&#13;
        }&#13;
        return selfptr;&#13;
    }&#13;
&#13;
&#13;
&#13;
&#13;
    /*&#13;
     * @dev Splits the slice, setting `self` to everything after the first&#13;
     *      occurrence of `needle`, and `token` to everything before it. If&#13;
     *      `needle` does not occur in `self`, `self` is set to the empty slice,&#13;
     *      and `token` is set to the entirety of `self`.&#13;
     * @param self The slice to split.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @param token An output parameter to which the first token is written.&#13;
     * @return `token`.&#13;
     */&#13;
    function split(slice self, slice needle, slice token) internal returns (slice) {&#13;
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);&#13;
        token._ptr = self._ptr;&#13;
        token._len = ptr - self._ptr;&#13;
        if (ptr == self._ptr + self._len) {&#13;
            // Not found&#13;
            self._len = 0;&#13;
        } else {&#13;
            self._len -= token._len + needle._len;&#13;
            self._ptr = ptr + needle._len;&#13;
        }&#13;
        return token;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Splits the slice, setting `self` to everything after the first&#13;
     *      occurrence of `needle`, and returning everything before it. If&#13;
     *      `needle` does not occur in `self`, `self` is set to the empty slice,&#13;
     *      and the entirety of `self` is returned.&#13;
     * @param self The slice to split.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @return The part of `self` up to the first occurrence of `delim`.&#13;
     */&#13;
    function split(slice self, slice needle) internal returns (slice token) {&#13;
        split(self, needle, token);&#13;
    }&#13;
&#13;
&#13;
&#13;
&#13;
    /*&#13;
     * @dev Joins an array of slices, using `self` as a delimiter, returning a&#13;
     *      newly allocated string.&#13;
     * @param self The delimiter to use.&#13;
     * @param parts A list of slices to join.&#13;
     * @return A newly allocated string containing all the slices in `parts`,&#13;
     *         joined with `self`.&#13;
     */&#13;
    function join(slice self, slice[] parts) internal returns (string) {&#13;
        if (parts.length == 0)&#13;
            return "";&#13;
&#13;
        uint length = self._len * (parts.length - 1);&#13;
        for(uint i = 0; i &lt; parts.length; i++)&#13;
            length += parts[i]._len;&#13;
&#13;
        var ret = new string(length);&#13;
        uint retptr;&#13;
        assembly { retptr := add(ret, 32) }&#13;
&#13;
        for(i = 0; i &lt; parts.length; i++) {&#13;
            memcpy(retptr, parts[i]._ptr, parts[i]._len);&#13;
            retptr += parts[i]._len;&#13;
            if (i &lt; parts.length - 1) {&#13;
                memcpy(retptr, self._ptr, self._len);&#13;
                retptr += self._len;&#13;
            }&#13;
        }&#13;
&#13;
        return ret;&#13;
    }&#13;
}&#13;
&#13;
// start of satoshi futures contract&#13;
&#13;
contract SatoshiFutures is usingOraclize {&#13;
    using strings for *;&#13;
    using SafeMath for *;&#13;
&#13;
    &#13;
    address public owner = 0x047f606fd5b2baa5f5c6c4ab8958e45cb6b054b7;&#13;
    uint public allOpenTradesAmounts = 0;&#13;
    uint safeGas = 2300;&#13;
    uint constant ORACLIZE_GAS_LIMIT = 300000;&#13;
    bool public  isStopped = false;&#13;
    uint public ownerFee = 3;&#13;
    uint public currentProfitPct = 70;&#13;
    uint public minTrade = 10 finney;&#13;
    bool public emergencyWithdrawalActivated = false;&#13;
    uint public tradesCount = 0;&#13;
   &#13;
    &#13;
&#13;
    struct Trade {&#13;
        address investor;&#13;
        uint amountInvested;&#13;
        uint initialPrice;&#13;
        uint finalPrice;&#13;
        string coinSymbol;&#13;
        string putOrCall;&#13;
    }&#13;
&#13;
    struct TradeStats {&#13;
        uint initialTime;&#13;
        uint finalTime;&#13;
        bool resolved;&#13;
        uint tradePeriod;&#13;
        bool wonOrLost;&#13;
        string query;&#13;
    }&#13;
&#13;
    struct Investor {&#13;
        address investorAddress;&#13;
        uint balanceToPayout;&#13;
        bool withdrew;&#13;
    }&#13;
    &#13;
    mapping(address =&gt; uint) public investorIDs;&#13;
    mapping(uint =&gt; Investor) public investors;&#13;
    uint public numInvestors = 0;&#13;
&#13;
&#13;
    mapping(bytes32 =&gt; Trade) public trades;&#13;
    mapping(bytes32 =&gt; TradeStats) public tradesStats;&#13;
    mapping(uint =&gt; bytes32) public tradesIds; &#13;
    &#13;
    event LOG_MaxTradeAmountChanged(uint maxTradeAmount);&#13;
    event LOG_NewTradeCreated(bytes32 tradeId, address investor);&#13;
    event LOG_ContractStopped(string status);&#13;
    event LOG_OwnerAddressChanged(address oldAddr, address newOwnerAddress);&#13;
    event LOG_TradeWon (address investorAddress, uint amountInvested, bytes32 tradeId, uint _startTrade, uint _endTrade, uint _startPrice, uint _endPrice, string _coinSymbol, uint _pctToGain, string _queryUrl);&#13;
    event LOG_TradeLost(address investorAddress, uint amountInvested, bytes32 tradeId, uint _startTrade, uint _endTrade, uint _startPrice, uint _endPrice, string _coinSymbol, uint _pctToGain, string _queryUrl);&#13;
    event LOG_TradeDraw(address investorAddress, uint amountInvested, bytes32 tradeId, uint _startTrade, uint _endTrade, uint _startPrice, uint _endPrice, string _coinSymbol, uint _pctToGain, string _queryUrl);&#13;
    event LOG_GasLimitChanged(uint oldGasLimit, uint newGasLimit);&#13;
&#13;
&#13;
    //CONSTRUCTOR FUNCTION&#13;
    &#13;
&#13;
    //SECTION I: MODIFIERS AND HELPER FUNCTIONS&#13;
    &#13;
    modifier onlyOwner {&#13;
            require(msg.sender == owner);&#13;
            _;&#13;
    }&#13;
    &#13;
    modifier onlyOraclize {&#13;
        require(msg.sender == oraclize_cbAddress());&#13;
        _;&#13;
    }&#13;
    &#13;
    modifier onlyIfValidGas(uint newGasLimit) {&#13;
        require(ORACLIZE_GAS_LIMIT + newGasLimit &gt; ORACLIZE_GAS_LIMIT);&#13;
        require(newGasLimit &gt; 2500);&#13;
        _;&#13;
    }&#13;
    &#13;
    modifier onlyIfNotStopped {&#13;
      require(!isStopped);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyIfStopped {&#13;
      require(isStopped);&#13;
        _;&#13;
    }&#13;
    &#13;
    modifier onlyIfTradeExists(bytes32 myid) {&#13;
        require(trades[myid].investor != address(0x0));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyIfTradeUnresolved(bytes32 myid) {&#13;
        require(tradesStats[myid].resolved != true);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyIfEnoughBalanceToPayOut(uint _amountInvested) {&#13;
        require( _amountInvested &lt; getMaxTradeAmount());&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyInvestors {&#13;
        require(investorIDs[msg.sender] != 0);&#13;
        _;&#13;
    }&#13;
    &#13;
    modifier onlyNotInvestors {&#13;
        require(investorIDs[msg.sender] == 0);&#13;
        _;&#13;
    }&#13;
&#13;
    function addInvestorAtID(uint id)&#13;
    onlyNotInvestors&#13;
        private {&#13;
        investorIDs[msg.sender] = id;&#13;
        investors[id].investorAddress = msg.sender;&#13;
    }&#13;
    &#13;
    modifier onlyIfValidTradePeriod(uint tradePeriod) {&#13;
        require(tradePeriod &lt;= 30);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyIfTradeTimeEnded(uint _endTime) {&#13;
        require(block.timestamp &gt; _endTime);&#13;
        _;&#13;
    }&#13;
    &#13;
    modifier onlyMoreThanMinTrade() {&#13;
        require(msg.value &gt;= minTrade);&#13;
        _;&#13;
    }&#13;
    function getMaxTradeAmount() constant returns(uint) {&#13;
        LOG_MaxTradeAmountChanged((this.balance - allOpenTradesAmounts) * 100/currentProfitPct);&#13;
        require(this.balance &gt;= allOpenTradesAmounts);&#13;
        return ((this.balance - allOpenTradesAmounts) * 100/currentProfitPct);&#13;
    }&#13;
&#13;
    &#13;
    // SECTION II: TRADES &amp; TRADE PROCESSING&#13;
     &#13;
     /*&#13;
     * @dev Add money to the contract in case balance goes to 0.&#13;
     */&#13;
    &#13;
&#13;
    function addMoneyToContract() payable returns(uint) {&#13;
        //to add balance to the contract so trades are posible&#13;
        return msg.value;&#13;
        getMaxTradeAmount();&#13;
    }&#13;
&#13;
&#13;
     /*&#13;
     * @dev Initiate a trade by providing all the right params.&#13;
     */&#13;
&#13;
    function startTrade(string _coinSymbol, uint _tradePeriod, bool _putOrCall) &#13;
        payable &#13;
        onlyIfNotStopped&#13;
        // onlyIfRightCoinChoosen(_coinSymbol)&#13;
        onlyMoreThanMinTrade &#13;
        onlyIfValidTradePeriod(_tradePeriod)&#13;
        onlyIfEnoughBalanceToPayOut(msg.value) {&#13;
        string memory serializePutOrCall; &#13;
        if(_putOrCall == true) {&#13;
            serializePutOrCall = "put";&#13;
        } else  {&#13;
            serializePutOrCall = "call";&#13;
        }&#13;
        var finalTime = block.timestamp + ((_tradePeriod + 1) * 60);&#13;
        string memory queryUrl = generateUrl(_coinSymbol, block.timestamp,  _tradePeriod );&#13;
        bytes32 queryId = oraclize_query(block.timestamp + ((_tradePeriod + 5) * 60), "URL", queryUrl,ORACLIZE_GAS_LIMIT + safeGas);&#13;
        var thisTrade = trades[queryId];&#13;
        var thisTradeStats = tradesStats[queryId];&#13;
        thisTrade.investor = msg.sender;&#13;
        thisTrade.amountInvested = msg.value - (msg.value * ownerFee / 100 ); &#13;
        thisTrade.initialPrice = 0; &#13;
        thisTrade.finalPrice = 0; &#13;
        thisTrade.coinSymbol = _coinSymbol; &#13;
        thisTradeStats.tradePeriod = _tradePeriod; &#13;
        thisTrade.putOrCall = serializePutOrCall; &#13;
        thisTradeStats.wonOrLost = false; &#13;
        thisTradeStats.initialTime = block.timestamp; &#13;
        thisTradeStats.finalTime = finalTime - 60; &#13;
        thisTradeStats.resolved = false; &#13;
        thisTradeStats.query = queryUrl; &#13;
        allOpenTradesAmounts += thisTrade.amountInvested + ((thisTrade.amountInvested * currentProfitPct) / 100);&#13;
        tradesIds[tradesCount++] = queryId;&#13;
        owner.transfer(msg.value  * ownerFee / 100); &#13;
        getMaxTradeAmount();&#13;
        if (investorIDs[msg.sender] == 0) {&#13;
           numInvestors++;&#13;
           addInvestorAtID(numInvestors); &#13;
        } &#13;
        &#13;
        LOG_NewTradeCreated(queryId, thisTrade.investor);&#13;
&#13;
    }&#13;
&#13;
    // function __callback(bytes32 myid, string result, bytes proof) public {&#13;
    //     __callback(myid, result);&#13;
    // }&#13;
    &#13;
&#13;
     /*&#13;
     * @dev Callback function from oraclize after the trade period is over.&#13;
     * updates trade initial and final price and than calls the resolve trade function.&#13;
     */&#13;
    function __callback(bytes32 myid, string result, bytes proof)&#13;
        onlyOraclize &#13;
        onlyIfTradeExists(myid)&#13;
        onlyIfTradeUnresolved(myid) {&#13;
        var s = result.toSlice();&#13;
        var d = s.beyond("[".toSlice()).until("]".toSlice());&#13;
        var delim = ",".toSlice();&#13;
        var parts = new string[](d.count(delim) + 1 );&#13;
        for(uint i = 0; i &lt; parts.length; i++) {&#13;
          parts[i] = d.split(delim).toString();&#13;
        }&#13;
        &#13;
        trades[myid].initialPrice = parseInt(parts[0],4);&#13;
        trades[myid].finalPrice = parseInt(parts[tradesStats[myid].tradePeriod],4);&#13;
        resolveTrade(myid);         &#13;
    }&#13;
    &#13;
&#13;
     /*&#13;
     * @dev Resolves the trade based on the initial and final amount,&#13;
     * depending if put or call were chosen, if its a draw the money goes back&#13;
     * to investor.&#13;
     */&#13;
    function resolveTrade(bytes32 _myId) internal&#13;
    onlyIfTradeExists(_myId)&#13;
    onlyIfTradeUnresolved(_myId)&#13;
    onlyIfTradeTimeEnded(tradesStats[_myId].finalTime)&#13;
        {&#13;
    tradesStats[_myId].resolved = true;    &#13;
    if(trades[_myId].initialPrice == trades[_myId].finalPrice) {&#13;
        trades[_myId].investor.transfer(trades[_myId].amountInvested);&#13;
        LOG_TradeDraw(trades[_myId].investor, trades[_myId].amountInvested,_myId, tradesStats[_myId].initialTime, tradesStats[_myId].finalTime, trades[_myId].initialPrice, trades[_myId].finalPrice, trades[_myId].coinSymbol, currentProfitPct, tradesStats[_myId].query);&#13;
        }&#13;
     if(trades[_myId].putOrCall.toSlice().equals("put".toSlice())) { &#13;
         if(trades[_myId].initialPrice &gt; trades[_myId].finalPrice) {&#13;
            tradesStats[_myId].wonOrLost = true;&#13;
            trades[_myId].investor.transfer(trades[_myId].amountInvested + ((trades[_myId].amountInvested * currentProfitPct) / 100)); &#13;
            LOG_TradeWon(trades[_myId].investor, trades[_myId].amountInvested,_myId, tradesStats[_myId].initialTime, tradesStats[_myId].finalTime, trades[_myId].initialPrice, trades[_myId].finalPrice, trades[_myId].coinSymbol, currentProfitPct, tradesStats[_myId].query);&#13;
        }&#13;
        if(trades[_myId].initialPrice &lt; trades[_myId].finalPrice) {&#13;
            tradesStats[_myId].wonOrLost = false;&#13;
            trades[_myId].investor.transfer(1); &#13;
            LOG_TradeLost(trades[_myId].investor, trades[_myId].amountInvested,_myId, tradesStats[_myId].initialTime, tradesStats[_myId].finalTime, trades[_myId].initialPrice, trades[_myId].finalPrice, trades[_myId].coinSymbol, currentProfitPct, tradesStats[_myId].query);&#13;
        }    &#13;
     }&#13;
&#13;
     if(trades[_myId].putOrCall.toSlice().equals("call".toSlice())) { &#13;
         if(trades[_myId].initialPrice &lt; trades[_myId].finalPrice) {&#13;
            tradesStats[_myId].wonOrLost = true;&#13;
            trades[_myId].investor.transfer(trades[_myId].amountInvested + ((trades[_myId].amountInvested * currentProfitPct) / 100)); &#13;
            LOG_TradeWon(trades[_myId].investor, trades[_myId].amountInvested,_myId, tradesStats[_myId].initialTime, tradesStats[_myId].finalTime, trades[_myId].initialPrice, trades[_myId].finalPrice, trades[_myId].coinSymbol, currentProfitPct, tradesStats[_myId].query);&#13;
        }&#13;
        if(trades[_myId].initialPrice &gt; trades[_myId].finalPrice) {&#13;
            tradesStats[_myId].wonOrLost = false;&#13;
            trades[_myId].investor.transfer(1); &#13;
            LOG_TradeLost(trades[_myId].investor, trades[_myId].amountInvested,_myId, tradesStats[_myId].initialTime, tradesStats[_myId].finalTime, trades[_myId].initialPrice, trades[_myId].finalPrice, trades[_myId].coinSymbol, currentProfitPct, tradesStats[_myId].query);&#13;
        }&#13;
     }&#13;
    allOpenTradesAmounts -= trades[_myId].amountInvested + ((trades[_myId].amountInvested * currentProfitPct) / 100);&#13;
    getMaxTradeAmount();&#13;
&#13;
    }&#13;
  &#13;
   &#13;
&#13;
    /*&#13;
     * @dev Generate the url for the api call for oraclize.&#13;
     */&#13;
   function generateUrl(string _coinChosen, uint _timesStartTrade ,uint _tradePeriod) internal returns (string) {&#13;
        strings.slice[] memory parts = new strings.slice[](11);&#13;
        parts[0] = "json(https://api.cryptowat.ch/markets/bitfinex/".toSlice();&#13;
        parts[1] = _coinChosen.toSlice();&#13;
        parts[2] = "/ohlc?periods=60&amp;after=".toSlice();&#13;
        parts[3] = uint2str(_timesStartTrade).toSlice();&#13;
        // parts[4] = "&amp;before=".toSlice();&#13;
        // parts[5] = uint2str((_timesStartTrade + ( (_tradePeriod + 1 ) * 60))).toSlice();&#13;
        parts[4] = ").result.".toSlice();&#13;
        parts[5] = strConcat('"',uint2str(60),'"').toSlice();&#13;
        parts[6] = ".[0:".toSlice();&#13;
        parts[7] = uint2str(_tradePeriod + 1).toSlice();&#13;
        parts[8] = "].1".toSlice();&#13;
        return ''.toSlice().join(parts);&#13;
    }&#13;
 &#13;
   &#13;
    &#13;
    &#13;
    //SECTION IV: CONTRACT MANAGEMENT&#13;
&#13;
    &#13;
    &#13;
    function stopContract()&#13;
    onlyOwner {&#13;
    isStopped = true;&#13;
    LOG_ContractStopped("the contract is stopped");&#13;
    }&#13;
&#13;
    function resumeContract()&#13;
    onlyOwner {&#13;
    isStopped = false;&#13;
    LOG_ContractStopped("the contract is resumed");&#13;
    }&#13;
    &#13;
    function changeOwnerAddress(address newOwner)&#13;
    onlyOwner {&#13;
    require(newOwner != address(0x0)); //changed based on audit feedback&#13;
    owner = newOwner;&#13;
    LOG_OwnerAddressChanged(owner, newOwner);&#13;
    }&#13;
&#13;
    function changeOwnerFee(uint _newFee) &#13;
    onlyOwner {&#13;
        ownerFee = _newFee;&#13;
    }&#13;
&#13;
    function setProfitPcnt(uint _newPct) onlyOwner {&#13;
        currentProfitPct = _newPct;&#13;
    }&#13;
    &#13;
    function initialOraclizeSettings() public onlyOwner {&#13;
        oraclize_setCustomGasPrice(40000000000 wei);&#13;
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);&#13;
    }&#13;
 &#13;
    function changeOraclizeProofType(byte _proofType)&#13;
        onlyOwner {&#13;
        require(_proofType != 0x00);&#13;
        oraclize_setProof( _proofType |  proofStorage_IPFS );&#13;
    }&#13;
&#13;
    function changeMinTrade(uint _newMinTrade) onlyOwner {&#13;
        minTrade = _newMinTrade;&#13;
    }&#13;
    &#13;
    function changeGasLimitOfSafeSend(uint newGasLimit)&#13;
        onlyOwner&#13;
        onlyIfValidGas(newGasLimit) {&#13;
        safeGas = newGasLimit;&#13;
        LOG_GasLimitChanged(safeGas, newGasLimit);&#13;
&#13;
    }&#13;
&#13;
     function changeOraclizeGasPrize(uint _newGasPrice) onlyOwner{&#13;
        oraclize_setCustomGasPrice(_newGasPrice);&#13;
    }&#13;
&#13;
    function stopEmergencyWithdrawal() onlyOwner {&#13;
        emergencyWithdrawalActivated = false;&#13;
    }&#13;
&#13;
    modifier onlyIfEmergencyWithdrawalActivated() {&#13;
        require(emergencyWithdrawalActivated);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyIfnotWithdrew() {&#13;
        require(!investors[investorIDs[msg.sender]].withdrew);&#13;
        _;&#13;
    }&#13;
&#13;
&#13;
&#13;
    /*&#13;
     * @dev In the case of emergency stop trades and&#13;
        divide balance equally to all investors and allow&#13;
        them to withdraw it.&#13;
     */ &#13;
    function distributeBalanceToInvestors() &#13;
    onlyOwner&#13;
     {  &#13;
        isStopped = true;&#13;
        emergencyWithdrawalActivated = true;&#13;
        uint dividendsForInvestors = SafeMath.div(this.balance, numInvestors);&#13;
        for(uint i = 1; i &lt;=  numInvestors; i++) {&#13;
            investors[i].balanceToPayout = dividendsForInvestors;&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Withdraw your part from the total balance in case &#13;
        of emergency.&#13;
     */ &#13;
    function withdrawDividends() &#13;
    onlyIfEmergencyWithdrawalActivated &#13;
    onlyInvestors&#13;
    onlyIfnotWithdrew&#13;
    {   &#13;
       //send right balance to investor. &#13;
       investors[investorIDs[msg.sender]].withdrew = true; &#13;
       investors[investorIDs[msg.sender]].investorAddress.transfer(investors[investorIDs[msg.sender]].balanceToPayout); &#13;
        investors[investorIDs[msg.sender]].balanceToPayout = 0;&#13;
&#13;
    }&#13;
&#13;
 &#13;
}