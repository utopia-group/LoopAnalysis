pragma solidity 0.4.23;

// File: contracts/oraclize/usingOraclize.sol

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
pragma solidity ^0.4.18;

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
        // Convert from seconds to ledger timer ticks
        _delay *= 10; 
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
        bytes memory delay = new bytes(32);
        assembly { 
            mstore(add(delay, 0x20), _delay) 
        }
        
        bytes memory delay_bytes8 = new bytes(8);
        copyBytes(delay, 24, 8, delay_bytes8, 0);

        bytes[4] memory args = [unonce, nbytes, sessionKeyHash, delay];
        bytes32 queryId = oraclize_query("random", args, _customGasLimit);
        
        bytes memory delay_bytes8_left = new bytes(8);
        
        assembly {
            let x := mload(add(delay_bytes8, 0x20))
            mstore8(add(delay_bytes8_left, 0x27), div(x, 0x100000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x26), div(x, 0x1000000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x25), div(x, 0x10000000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x24), div(x, 0x100000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x23), div(x, 0x1000000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x22), div(x, 0x10000000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x21), div(x, 0x100000000000000000000000000000000000000000000000000))
            mstore8(add(delay_bytes8_left, 0x20), div(x, 0x1000000000000000000000000000000000000000000000000))

        }
        
        oraclize_randomDS_setCommitment(queryId, keccak256(delay_bytes8_left, args[1], sha256(args[0]), args[2]));
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
        
        require(prefix.length == n_random_bytes);

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

// File: mixbytes-solidity/contracts/ownership/multiowned.sol

// Copyright (C) 2017  MixBytes, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).

// Code taken from https://github.com/ethereum/dapp-bin/blob/master/wallet/wallet.sol
// Audit, refactoring and improvements by github.com/Eenae

// @authors:
// Gav Wood <<span class="__cf_email__" data-cfemail="1d7a5d78697579786b337e7270">[email protected]</span>&gt;&#13;
// inheritable "property" contract that enables methods to be protected by requiring the acquiescence of either a&#13;
// single, or, crucially, each of a number of, designated owners.&#13;
// usage:&#13;
// use modifiers onlyowner (just own owned) or onlymanyowners(hash), whereby the same hash must be provided by&#13;
// some number (specified in constructor) of the set of owners (specified in the constructor, modifiable) before the&#13;
// interior is executed.&#13;
&#13;
pragma solidity ^0.4.15;&#13;
&#13;
&#13;
/// note: during any ownership changes all pending operations (waiting for more signatures) are cancelled&#13;
// TODO acceptOwnership&#13;
contract multiowned {&#13;
&#13;
	// TYPES&#13;
&#13;
    // struct for the status of a pending operation.&#13;
    struct MultiOwnedOperationPendingState {&#13;
        // count of confirmations needed&#13;
        uint yetNeeded;&#13;
&#13;
        // bitmap of confirmations where owner #ownerIndex's decision corresponds to 2**ownerIndex bit&#13;
        uint ownersDone;&#13;
&#13;
        // position of this operation key in m_multiOwnedPendingIndex&#13;
        uint index;&#13;
    }&#13;
&#13;
	// EVENTS&#13;
&#13;
    event Confirmation(address owner, bytes32 operation);&#13;
    event Revoke(address owner, bytes32 operation);&#13;
    event FinalConfirmation(address owner, bytes32 operation);&#13;
&#13;
    // some others are in the case of an owner changing.&#13;
    event OwnerChanged(address oldOwner, address newOwner);&#13;
    event OwnerAdded(address newOwner);&#13;
    event OwnerRemoved(address oldOwner);&#13;
&#13;
    // the last one is emitted if the required signatures change&#13;
    event RequirementChanged(uint newRequirement);&#13;
&#13;
	// MODIFIERS&#13;
&#13;
    // simple single-sig function modifier.&#13;
    modifier onlyowner {&#13;
        require(isOwner(msg.sender));&#13;
        _;&#13;
    }&#13;
    // multi-sig function modifier: the operation must have an intrinsic hash in order&#13;
    // that later attempts can be realised as the same underlying operation and&#13;
    // thus count as confirmations.&#13;
    modifier onlymanyowners(bytes32 _operation) {&#13;
        if (confirmAndCheck(_operation)) {&#13;
            _;&#13;
        }&#13;
        // Even if required number of confirmations has't been collected yet,&#13;
        // we can't throw here - because changes to the state have to be preserved.&#13;
        // But, confirmAndCheck itself will throw in case sender is not an owner.&#13;
    }&#13;
&#13;
    modifier validNumOwners(uint _numOwners) {&#13;
        require(_numOwners &gt; 0 &amp;&amp; _numOwners &lt;= c_maxOwners);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier multiOwnedValidRequirement(uint _required, uint _numOwners) {&#13;
        require(_required &gt; 0 &amp;&amp; _required &lt;= _numOwners);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerExists(address _address) {&#13;
        require(isOwner(_address));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier ownerDoesNotExist(address _address) {&#13;
        require(!isOwner(_address));&#13;
        _;&#13;
    }&#13;
&#13;
    modifier multiOwnedOperationIsActive(bytes32 _operation) {&#13;
        require(isOperationActive(_operation));&#13;
        _;&#13;
    }&#13;
&#13;
	// METHODS&#13;
&#13;
    // constructor is given number of sigs required to do protected "onlymanyowners" transactions&#13;
    // as well as the selection of addresses capable of confirming them (msg.sender is not added to the owners!).&#13;
    function multiowned(address[] _owners, uint _required)&#13;
        public&#13;
        validNumOwners(_owners.length)&#13;
        multiOwnedValidRequirement(_required, _owners.length)&#13;
    {&#13;
        assert(c_maxOwners &lt;= 255);&#13;
&#13;
        m_numOwners = _owners.length;&#13;
        m_multiOwnedRequired = _required;&#13;
&#13;
        for (uint i = 0; i &lt; _owners.length; ++i)&#13;
        {&#13;
            address owner = _owners[i];&#13;
            // invalid and duplicate addresses are not allowed&#13;
            require(0 != owner &amp;&amp; !isOwner(owner) /* not isOwner yet! */);&#13;
&#13;
            uint currentOwnerIndex = checkOwnerIndex(i + 1 /* first slot is unused */);&#13;
            m_owners[currentOwnerIndex] = owner;&#13;
            m_ownerIndex[owner] = currentOwnerIndex;&#13;
        }&#13;
&#13;
        assertOwnersAreConsistent();&#13;
    }&#13;
&#13;
    /// @notice replaces an owner `_from` with another `_to`.&#13;
    /// @param _from address of owner to replace&#13;
    /// @param _to address of new owner&#13;
    // All pending operations will be canceled!&#13;
    function changeOwner(address _from, address _to)&#13;
        external&#13;
        ownerExists(_from)&#13;
        ownerDoesNotExist(_to)&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        assertOwnersAreConsistent();&#13;
&#13;
        clearPending();&#13;
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_from]);&#13;
        m_owners[ownerIndex] = _to;&#13;
        m_ownerIndex[_from] = 0;&#13;
        m_ownerIndex[_to] = ownerIndex;&#13;
&#13;
        assertOwnersAreConsistent();&#13;
        OwnerChanged(_from, _to);&#13;
    }&#13;
&#13;
    /// @notice adds an owner&#13;
    /// @param _owner address of new owner&#13;
    // All pending operations will be canceled!&#13;
    function addOwner(address _owner)&#13;
        external&#13;
        ownerDoesNotExist(_owner)&#13;
        validNumOwners(m_numOwners + 1)&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        assertOwnersAreConsistent();&#13;
&#13;
        clearPending();&#13;
        m_numOwners++;&#13;
        m_owners[m_numOwners] = _owner;&#13;
        m_ownerIndex[_owner] = checkOwnerIndex(m_numOwners);&#13;
&#13;
        assertOwnersAreConsistent();&#13;
        OwnerAdded(_owner);&#13;
    }&#13;
&#13;
    /// @notice removes an owner&#13;
    /// @param _owner address of owner to remove&#13;
    // All pending operations will be canceled!&#13;
    function removeOwner(address _owner)&#13;
        external&#13;
        ownerExists(_owner)&#13;
        validNumOwners(m_numOwners - 1)&#13;
        multiOwnedValidRequirement(m_multiOwnedRequired, m_numOwners - 1)&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        assertOwnersAreConsistent();&#13;
&#13;
        clearPending();&#13;
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_owner]);&#13;
        m_owners[ownerIndex] = 0;&#13;
        m_ownerIndex[_owner] = 0;&#13;
        //make sure m_numOwners is equal to the number of owners and always points to the last owner&#13;
        reorganizeOwners();&#13;
&#13;
        assertOwnersAreConsistent();&#13;
        OwnerRemoved(_owner);&#13;
    }&#13;
&#13;
    /// @notice changes the required number of owner signatures&#13;
    /// @param _newRequired new number of signatures required&#13;
    // All pending operations will be canceled!&#13;
    function changeRequirement(uint _newRequired)&#13;
        external&#13;
        multiOwnedValidRequirement(_newRequired, m_numOwners)&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        m_multiOwnedRequired = _newRequired;&#13;
        clearPending();&#13;
        RequirementChanged(_newRequired);&#13;
    }&#13;
&#13;
    /// @notice Gets an owner by 0-indexed position&#13;
    /// @param ownerIndex 0-indexed owner position&#13;
    function getOwner(uint ownerIndex) public constant returns (address) {&#13;
        return m_owners[ownerIndex + 1];&#13;
    }&#13;
&#13;
    /// @notice Gets owners&#13;
    /// @return memory array of owners&#13;
    function getOwners() public constant returns (address[]) {&#13;
        address[] memory result = new address[](m_numOwners);&#13;
        for (uint i = 0; i &lt; m_numOwners; i++)&#13;
            result[i] = getOwner(i);&#13;
&#13;
        return result;&#13;
    }&#13;
&#13;
    /// @notice checks if provided address is an owner address&#13;
    /// @param _addr address to check&#13;
    /// @return true if it's an owner&#13;
    function isOwner(address _addr) public constant returns (bool) {&#13;
        return m_ownerIndex[_addr] &gt; 0;&#13;
    }&#13;
&#13;
    /// @notice Tests ownership of the current caller.&#13;
    /// @return true if it's an owner&#13;
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to&#13;
    // addOwner/changeOwner and to isOwner.&#13;
    function amIOwner() external constant onlyowner returns (bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @notice Revokes a prior confirmation of the given operation&#13;
    /// @param _operation operation value, typically keccak256(msg.data)&#13;
    function revoke(bytes32 _operation)&#13;
        external&#13;
        multiOwnedOperationIsActive(_operation)&#13;
        onlyowner&#13;
    {&#13;
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);&#13;
        var pending = m_multiOwnedPending[_operation];&#13;
        require(pending.ownersDone &amp; ownerIndexBit &gt; 0);&#13;
&#13;
        assertOperationIsConsistent(_operation);&#13;
&#13;
        pending.yetNeeded++;&#13;
        pending.ownersDone -= ownerIndexBit;&#13;
&#13;
        assertOperationIsConsistent(_operation);&#13;
        Revoke(msg.sender, _operation);&#13;
    }&#13;
&#13;
    /// @notice Checks if owner confirmed given operation&#13;
    /// @param _operation operation value, typically keccak256(msg.data)&#13;
    /// @param _owner an owner address&#13;
    function hasConfirmed(bytes32 _operation, address _owner)&#13;
        external&#13;
        constant&#13;
        multiOwnedOperationIsActive(_operation)&#13;
        ownerExists(_owner)&#13;
        returns (bool)&#13;
    {&#13;
        return !(m_multiOwnedPending[_operation].ownersDone &amp; makeOwnerBitmapBit(_owner) == 0);&#13;
    }&#13;
&#13;
    // INTERNAL METHODS&#13;
&#13;
    function confirmAndCheck(bytes32 _operation)&#13;
        private&#13;
        onlyowner&#13;
        returns (bool)&#13;
    {&#13;
        if (512 == m_multiOwnedPendingIndex.length)&#13;
            // In case m_multiOwnedPendingIndex grows too much we have to shrink it: otherwise at some point&#13;
            // we won't be able to do it because of block gas limit.&#13;
            // Yes, pending confirmations will be lost. Dont see any security or stability implications.&#13;
            // TODO use more graceful approach like compact or removal of clearPending completely&#13;
            clearPending();&#13;
&#13;
        var pending = m_multiOwnedPending[_operation];&#13;
&#13;
        // if we're not yet working on this operation, switch over and reset the confirmation status.&#13;
        if (! isOperationActive(_operation)) {&#13;
            // reset count of confirmations needed.&#13;
            pending.yetNeeded = m_multiOwnedRequired;&#13;
            // reset which owners have confirmed (none) - set our bitmap to 0.&#13;
            pending.ownersDone = 0;&#13;
            pending.index = m_multiOwnedPendingIndex.length++;&#13;
            m_multiOwnedPendingIndex[pending.index] = _operation;&#13;
            assertOperationIsConsistent(_operation);&#13;
        }&#13;
&#13;
        // determine the bit to set for this owner.&#13;
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);&#13;
        // make sure we (the message sender) haven't confirmed this operation previously.&#13;
        if (pending.ownersDone &amp; ownerIndexBit == 0) {&#13;
            // ok - check if count is enough to go ahead.&#13;
            assert(pending.yetNeeded &gt; 0);&#13;
            if (pending.yetNeeded == 1) {&#13;
                // enough confirmations: reset and run interior.&#13;
                delete m_multiOwnedPendingIndex[m_multiOwnedPending[_operation].index];&#13;
                delete m_multiOwnedPending[_operation];&#13;
                FinalConfirmation(msg.sender, _operation);&#13;
                return true;&#13;
            }&#13;
            else&#13;
            {&#13;
                // not enough: record that this owner in particular confirmed.&#13;
                pending.yetNeeded--;&#13;
                pending.ownersDone |= ownerIndexBit;&#13;
                assertOperationIsConsistent(_operation);&#13;
                Confirmation(msg.sender, _operation);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    // Reclaims free slots between valid owners in m_owners.&#13;
    // TODO given that its called after each removal, it could be simplified.&#13;
    function reorganizeOwners() private {&#13;
        uint free = 1;&#13;
        while (free &lt; m_numOwners)&#13;
        {&#13;
            // iterating to the first free slot from the beginning&#13;
            while (free &lt; m_numOwners &amp;&amp; m_owners[free] != 0) free++;&#13;
&#13;
            // iterating to the first occupied slot from the end&#13;
            while (m_numOwners &gt; 1 &amp;&amp; m_owners[m_numOwners] == 0) m_numOwners--;&#13;
&#13;
            // swap, if possible, so free slot is located at the end after the swap&#13;
            if (free &lt; m_numOwners &amp;&amp; m_owners[m_numOwners] != 0 &amp;&amp; m_owners[free] == 0)&#13;
            {&#13;
                // owners between swapped slots should't be renumbered - that saves a lot of gas&#13;
                m_owners[free] = m_owners[m_numOwners];&#13;
                m_ownerIndex[m_owners[free]] = free;&#13;
                m_owners[m_numOwners] = 0;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function clearPending() private onlyowner {&#13;
        uint length = m_multiOwnedPendingIndex.length;&#13;
        // TODO block gas limit&#13;
        for (uint i = 0; i &lt; length; ++i) {&#13;
            if (m_multiOwnedPendingIndex[i] != 0)&#13;
                delete m_multiOwnedPending[m_multiOwnedPendingIndex[i]];&#13;
        }&#13;
        delete m_multiOwnedPendingIndex;&#13;
    }&#13;
&#13;
    function checkOwnerIndex(uint ownerIndex) private pure returns (uint) {&#13;
        assert(0 != ownerIndex &amp;&amp; ownerIndex &lt;= c_maxOwners);&#13;
        return ownerIndex;&#13;
    }&#13;
&#13;
    function makeOwnerBitmapBit(address owner) private constant returns (uint) {&#13;
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[owner]);&#13;
        return 2 ** ownerIndex;&#13;
    }&#13;
&#13;
    function isOperationActive(bytes32 _operation) private constant returns (bool) {&#13;
        return 0 != m_multiOwnedPending[_operation].yetNeeded;&#13;
    }&#13;
&#13;
&#13;
    function assertOwnersAreConsistent() private constant {&#13;
        assert(m_numOwners &gt; 0);&#13;
        assert(m_numOwners &lt;= c_maxOwners);&#13;
        assert(m_owners[0] == 0);&#13;
        assert(0 != m_multiOwnedRequired &amp;&amp; m_multiOwnedRequired &lt;= m_numOwners);&#13;
    }&#13;
&#13;
    function assertOperationIsConsistent(bytes32 _operation) private constant {&#13;
        var pending = m_multiOwnedPending[_operation];&#13;
        assert(0 != pending.yetNeeded);&#13;
        assert(m_multiOwnedPendingIndex[pending.index] == _operation);&#13;
        assert(pending.yetNeeded &lt;= m_multiOwnedRequired);&#13;
    }&#13;
&#13;
&#13;
   	// FIELDS&#13;
&#13;
    uint constant c_maxOwners = 250;&#13;
&#13;
    // the number of owners that must confirm the same operation before it is run.&#13;
    uint public m_multiOwnedRequired;&#13;
&#13;
&#13;
    // pointer used to find a free slot in m_owners&#13;
    uint public m_numOwners;&#13;
&#13;
    // list of owners (addresses),&#13;
    // slot 0 is unused so there are no owner which index is 0.&#13;
    // TODO could we save space at the end of the array for the common case of &lt;10 owners? and should we?&#13;
    address[256] internal m_owners;&#13;
&#13;
    // index on the list of owners to allow reverse lookup: owner address =&gt; index in m_owners&#13;
    mapping(address =&gt; uint) internal m_ownerIndex;&#13;
&#13;
&#13;
    // the ongoing operations.&#13;
    mapping(bytes32 =&gt; MultiOwnedOperationPendingState) internal m_multiOwnedPending;&#13;
    bytes32[] internal m_multiOwnedPendingIndex;&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/math/SafeMath.sol&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    uint256 c = a * b;&#13;
    assert(a == 0 || c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  function div(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  function add(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/EthPriceDependent.sol&#13;
&#13;
contract EthPriceDependent is usingOraclize, multiowned {&#13;
&#13;
    using SafeMath for uint256;&#13;
&#13;
    event NewOraclizeQuery(string description);&#13;
    event NewETHPrice(uint price);&#13;
    event ETHPriceOutOfBounds(uint price);&#13;
&#13;
    /// @notice Constructor&#13;
    /// @param _initialOwners set owners, which can control bounds and things&#13;
    ///        described in the actual sale contract, inherited from this one&#13;
    /// @param _consensus Number of votes enough to make a decision&#13;
    /// @param _production True if on mainnet and testnet&#13;
    function EthPriceDependent(address[] _initialOwners,  uint _consensus, bool _production)&#13;
        public&#13;
        multiowned(_initialOwners, _consensus)&#13;
    {&#13;
        oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);&#13;
        if (!_production) {&#13;
            // Use it when testing with testrpc and etherium bridge. Don't forget to change address&#13;
            OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);&#13;
        } else {&#13;
            // Don't call this while testing as it's too long and gets in the way&#13;
            updateETHPriceInCents();&#13;
        }&#13;
    }&#13;
&#13;
    /// @notice Send oraclize query.&#13;
    /// if price is received successfully - update scheduled automatically,&#13;
    /// if at any point the contract runs out of ether - updating stops and further&#13;
    /// updating will require running this function again.&#13;
    /// if price is out of bounds - updating attempts continue&#13;
    function updateETHPriceInCents() public payable {&#13;
        // prohibit running multiple instances of update&#13;
        // however don't throw any error, because it's called from __callback as well&#13;
        // and we need to let it update the price anyway, otherwise there is an attack possibility&#13;
        if ( !updateRequestExpired() ) {&#13;
            NewOraclizeQuery("Oraclize request fail. Previous one still pending");&#13;
        } else if (oraclize_getPrice("URL") &gt; this.balance) {&#13;
            NewOraclizeQuery("Oraclize request fail. Not enough ether");&#13;
        } else {&#13;
            oraclize_query(&#13;
                m_ETHPriceUpdateInterval,&#13;
                "URL",&#13;
                "json(https://api.coinmarketcap.com/v1/ticker/ethereum/?convert=USD).0.price_usd",&#13;
                m_callbackGas&#13;
            );&#13;
            m_ETHPriceLastUpdateRequest = getTime();&#13;
            NewOraclizeQuery("Oraclize query was sent");&#13;
        }&#13;
    }&#13;
&#13;
    /// @notice Called on ETH price update by Oraclize&#13;
    function __callback(bytes32 myid, string result, bytes proof) public {&#13;
        require(msg.sender == oraclize_cbAddress());&#13;
&#13;
        uint newPrice = parseInt(result).mul(100);&#13;
&#13;
        if (newPrice &gt;= m_ETHPriceLowerBound &amp;&amp; newPrice &lt;= m_ETHPriceUpperBound) {&#13;
            m_ETHPriceInCents = newPrice;&#13;
            m_ETHPriceLastUpdate = getTime();&#13;
            NewETHPrice(m_ETHPriceInCents);&#13;
        } else {&#13;
            ETHPriceOutOfBounds(newPrice);&#13;
        }&#13;
        // continue updating anyway (if current price was out of bounds, the price might recover in the next cycle)&#13;
        updateETHPriceInCents();&#13;
    }&#13;
&#13;
    /// @notice set the limit of ETH in cents, oraclize data greater than this is not accepted&#13;
    /// @param _price Price in US cents&#13;
    function setETHPriceUpperBound(uint _price)&#13;
        external&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        m_ETHPriceUpperBound = _price;&#13;
    }&#13;
&#13;
    /// @notice set the limit of ETH in cents, oraclize data smaller than this is not accepted&#13;
    /// @param _price Price in US cents&#13;
    function setETHPriceLowerBound(uint _price)&#13;
        external&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        m_ETHPriceLowerBound = _price;&#13;
    }&#13;
&#13;
    /// @notice set the price of ETH in cents, called in case we don't get oraclize data&#13;
    ///         for more than double the update interval&#13;
    /// @param _price Price in US cents&#13;
    function setETHPriceManually(uint _price)&#13;
        external&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        // allow for owners to change the price anytime if update is not running&#13;
        // but if it is, then only in case the price has expired&#13;
        require( priceExpired() || updateRequestExpired() );&#13;
        m_ETHPriceInCents = _price;&#13;
        m_ETHPriceLastUpdate = getTime();&#13;
        NewETHPrice(m_ETHPriceInCents);&#13;
    }&#13;
&#13;
    /// @notice add more ether to use in oraclize queries&#13;
    function topUp() external payable {&#13;
    }&#13;
&#13;
    /// @dev change gas price for oraclize calls,&#13;
    ///      should be a compromise between speed and price according to market&#13;
    /// @param _gasPrice gas price in wei&#13;
    function setOraclizeGasPrice(uint _gasPrice)&#13;
        external&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        oraclize_setCustomGasPrice(_gasPrice);&#13;
    }&#13;
&#13;
    /// @dev change gas limit for oraclize callback&#13;
    ///      note: should be changed only in case of emergency&#13;
    /// @param _callbackGas amount of gas&#13;
    function setOraclizeGasLimit(uint _callbackGas)&#13;
        external&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        m_callbackGas = _callbackGas;&#13;
    }&#13;
&#13;
    /// @dev Check that double the update interval has passed&#13;
    ///      since last successful price update&#13;
    function priceExpired() public view returns (bool) {&#13;
        return (getTime() &gt; m_ETHPriceLastUpdate + 2 * m_ETHPriceUpdateInterval);&#13;
    }&#13;
&#13;
    /// @dev Check that price update was requested&#13;
    ///      more than 1 update interval ago&#13;
    ///      NOTE: m_leeway seconds added to offset possible timestamp inaccuracy&#13;
    function updateRequestExpired() public view returns (bool) {&#13;
        return ( (getTime() + m_leeway) &gt;= (m_ETHPriceLastUpdateRequest + m_ETHPriceUpdateInterval) );&#13;
    }&#13;
&#13;
    /// @dev to be overridden in tests&#13;
    function getTime() internal view returns (uint) {&#13;
        return now;&#13;
    }&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @notice usd price of ETH in cents, retrieved using oraclize&#13;
    uint public m_ETHPriceInCents = 0;&#13;
    /// @notice unix timestamp of last update&#13;
    uint public m_ETHPriceLastUpdate;&#13;
    /// @notice unix timestamp of last update request,&#13;
    ///         don't allow requesting more than once per update interval&#13;
    uint public m_ETHPriceLastUpdateRequest;&#13;
&#13;
    /// @notice lower bound of the ETH price in cents&#13;
    uint public m_ETHPriceLowerBound = 100;&#13;
    /// @notice upper bound of the ETH price in cents&#13;
    uint public m_ETHPriceUpperBound = 100000000;&#13;
&#13;
    /// @dev Update ETH price in cents every 12 hours&#13;
    uint public m_ETHPriceUpdateInterval = 60*60*12;&#13;
&#13;
    /// @dev offset time inaccuracy when checking update expiration date&#13;
    uint public m_leeway = 30; // 30 seconds&#13;
&#13;
    /// @dev set just enough gas because the rest is not refunded&#13;
    ///      (should be ~105000, additional 5000 just in case)&#13;
    uint public m_callbackGas = 110000;&#13;
}&#13;
&#13;
// File: contracts/IBoomstarterToken.sol&#13;
&#13;
/// @title Interface of the BoomstarterToken.&#13;
interface IBoomstarterToken {&#13;
    // multiowned&#13;
    function changeOwner(address _from, address _to) external;&#13;
    function addOwner(address _owner) external;&#13;
    function removeOwner(address _owner) external;&#13;
    function changeRequirement(uint _newRequired) external;&#13;
    function getOwner(uint ownerIndex) public view returns (address);&#13;
    function getOwners() public view returns (address[]);&#13;
    function isOwner(address _addr) public view returns (bool);&#13;
    function amIOwner() external view returns (bool);&#13;
    function revoke(bytes32 _operation) external;&#13;
    function hasConfirmed(bytes32 _operation, address _owner) external view returns (bool);&#13;
&#13;
    // ERC20Basic&#13;
    function totalSupply() public view returns (uint256);&#13;
    function balanceOf(address who) public view returns (uint256);&#13;
    function transfer(address to, uint256 value) public returns (bool);&#13;
&#13;
    // ERC20&#13;
    function allowance(address owner, address spender) public view returns (uint256);&#13;
    function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
    function approve(address spender, uint256 value) public returns (bool);&#13;
&#13;
    function name() public view returns (string);&#13;
    function symbol() public view returns (string);&#13;
    function decimals() public view returns (uint8);&#13;
&#13;
    // BurnableToken&#13;
    function burn(uint256 _amount) public returns (bool);&#13;
&#13;
    // TokenWithApproveAndCallMethod&#13;
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public;&#13;
&#13;
    // BoomstarterToken&#13;
    function setSale(address account, bool isSale) external;&#13;
    function switchToNextSale(address _newSale) external;&#13;
    function thaw() external;&#13;
    function disablePrivileged() external;&#13;
&#13;
}&#13;
&#13;
// File: mixbytes-solidity/contracts/security/ArgumentsChecker.sol&#13;
&#13;
// Copyright (C) 2017  MixBytes, LLC&#13;
&#13;
// Licensed under the Apache License, Version 2.0 (the "License").&#13;
// You may not use this file except in compliance with the License.&#13;
&#13;
// Unless required by applicable law or agreed to in writing, software&#13;
// distributed under the License is distributed on an "AS IS" BASIS,&#13;
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).&#13;
&#13;
pragma solidity ^0.4.15;&#13;
&#13;
&#13;
/// @title utility methods and modifiers of arguments validation&#13;
contract ArgumentsChecker {&#13;
&#13;
    /// @dev check which prevents short address attack&#13;
    modifier payloadSizeIs(uint size) {&#13;
       require(msg.data.length == size + 4 /* function selector */);&#13;
       _;&#13;
    }&#13;
&#13;
    /// @dev check that address is valid&#13;
    modifier validAddress(address addr) {&#13;
        require(addr != address(0));&#13;
        _;&#13;
    }&#13;
}&#13;
&#13;
// File: zeppelin-solidity/contracts/ReentrancyGuard.sol&#13;
&#13;
/**&#13;
 * @title Helps contracts guard agains rentrancy attacks.&#13;
 * @author Remco Bloemen &lt;<span class="__cf_email__" data-cfemail="14667179777b5426">[email protected]</span>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private rentrancy_lock = false;&#13;
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
    require(!rentrancy_lock);&#13;
    rentrancy_lock = true;&#13;
    _;&#13;
    rentrancy_lock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/BoomstarterPresale.sol&#13;
&#13;
/// @title Boomstarter pre-sale contract&#13;
contract BoomstarterPresale is ArgumentsChecker, ReentrancyGuard, EthPriceDependent {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event FundTransfer(address backer, uint amount, bool isContribution);&#13;
&#13;
    /// @dev checks that owners didn't finish the sale yet&#13;
    modifier onlyIfSaleIsActive() {&#13;
        require(m_active == true);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     *  @dev checks that finish date is not reached yet&#13;
     *       (and potentially start date, but not needed for presale)&#13;
     *       AND also that the limits for the sale are not met&#13;
     *       AND that current price is non-zero (updated)&#13;
     */&#13;
    modifier checkLimitsAndDates() {&#13;
        require((c_dateTo &gt;= getTime()) &amp;&amp;&#13;
                (m_currentTokensSold &lt; c_maximumTokensSold) &amp;&amp;&#13;
                (m_ETHPriceInCents &gt; 0));&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev constructor, payable to fund oraclize calls&#13;
     * @param _owners Addresses to do administrative actions&#13;
     * @param _token Address of token being sold in this presale&#13;
     * @param _beneficiary Address of the wallet, receiving all the collected ether&#13;
     * @param _production False if you use testrpc, true if mainnet and most testnets&#13;
     */&#13;
    function BoomstarterPresale(address[] _owners, address _token,&#13;
                                address _beneficiary, bool _production)&#13;
        public&#13;
        payable&#13;
        EthPriceDependent(_owners, 2, _production)&#13;
        validAddress(_token)&#13;
        validAddress(_beneficiary)&#13;
    {&#13;
        m_token = IBoomstarterToken(_token);&#13;
        m_beneficiary = _beneficiary;&#13;
        m_active = true;&#13;
    }&#13;
&#13;
&#13;
    // PUBLIC interface: payments&#13;
&#13;
    // fallback function as a shortcut&#13;
    function() payable {&#13;
        require(0 == msg.data.length);&#13;
        buy();  // only internal call here!&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice presale participation. Can buy tokens only in batches by one price&#13;
     *         if price changes mid-transaction, you'll get only the amount for initial price&#13;
     *         and the rest will be refunded&#13;
     */&#13;
    function buy()&#13;
        public&#13;
        payable&#13;
        nonReentrant&#13;
        onlyIfSaleIsActive&#13;
        checkLimitsAndDates&#13;
    {&#13;
        // don't allow to buy anything if price change was too long ago&#13;
        // effectively enforcing a sale pause&#13;
        require( !priceExpired() );&#13;
        address investor = msg.sender;&#13;
        uint256 payment = msg.value;&#13;
        require((payment.mul(m_ETHPriceInCents)).div(1 ether) &gt;= c_MinInvestmentInCents);&#13;
&#13;
        /**&#13;
         * calculate amount based on ETH/USD rate&#13;
         * for example 2e17 * 36900 / 30 = 246 * 1e18&#13;
         * 0.2 eth buys 246 tokens if Ether price is $369 and token price is 30 cents&#13;
         */&#13;
        uint tokenAmount;&#13;
        // either hard cap or the amount where prices change&#13;
        uint cap;&#13;
        // price of the batch of token bought&#13;
        uint centsPerToken;&#13;
        if (m_currentTokensSold &lt; c_priceRiseTokenAmount) {&#13;
            centsPerToken = c_centsPerTokenFirst;&#13;
            // don't let price rise happen during this transaction - cap at price change value&#13;
            cap = c_priceRiseTokenAmount;&#13;
        } else {&#13;
            centsPerToken = c_centsPerTokenSecond;&#13;
            // capped by the presale cap itself&#13;
            cap = c_maximumTokensSold;&#13;
        }&#13;
&#13;
        // amount that can be bought depending on the price&#13;
        tokenAmount = payment.mul(m_ETHPriceInCents).div(centsPerToken);&#13;
&#13;
        // number of tokens available before the cap is reached&#13;
        uint maxTokensAllowed = cap.sub(m_currentTokensSold);&#13;
&#13;
        // if amount of tokens we can buy is more than the amount available&#13;
        if (tokenAmount &gt; maxTokensAllowed) {&#13;
            // price of 1 full token in ether-wei&#13;
            // example 30 * 1e18 / 36900 = 0.081 * 1e18 = 0.081 eth&#13;
            uint ethPerToken = centsPerToken.mul(1 ether).div(m_ETHPriceInCents);&#13;
            // change amount to maximum allowed&#13;
            tokenAmount = maxTokensAllowed;&#13;
            payment = ethPerToken.mul(tokenAmount).div(1 ether);&#13;
        }&#13;
&#13;
        m_currentTokensSold = m_currentTokensSold.add(tokenAmount);&#13;
&#13;
        // send ether to external wallet&#13;
        m_beneficiary.transfer(payment);&#13;
&#13;
        m_token.transfer(investor, tokenAmount);&#13;
&#13;
        uint change = msg.value.sub(payment);&#13;
        if (change &gt; 0)&#13;
            investor.transfer(change);&#13;
&#13;
        FundTransfer(investor, payment, true);&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
     * @notice stop accepting ether, transfer remaining tokens to the next sale and&#13;
     *         give new sale permissions to transfer frozen funds and revoke own ones&#13;
     *         Can be called anytime, even before the set finish date&#13;
     */&#13;
    function finishSale()&#13;
        external&#13;
        onlyIfSaleIsActive&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        // next sale should be set using setNextSale&#13;
        require( m_nextSale != address(0) );&#13;
        // cannot accept ether anymore&#13;
        m_active = false;&#13;
        // send remaining oraclize ether to the next sale - we don't need oraclize anymore&#13;
        EthPriceDependent next = EthPriceDependent(m_nextSale);&#13;
        next.topUp.value(this.balance)();&#13;
        // transfer all remaining tokens to the next sale account&#13;
        m_token.transfer(m_nextSale, m_token.balanceOf(this));&#13;
        // mark next sale as a valid sale account, unmark self as valid sale account&#13;
        m_token.switchToNextSale(m_nextSale);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice set address of a sale that will be next one after the current sale is finished&#13;
     * @param _sale address of the sale contract&#13;
     */&#13;
    function setNextSale(address _sale)&#13;
        external&#13;
        validAddress(_sale)&#13;
        onlymanyowners(keccak256(msg.data))&#13;
    {&#13;
        m_nextSale = _sale;&#13;
    }&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @notice minimum investment in cents&#13;
    uint public c_MinInvestmentInCents = 3000000; // $30k&#13;
&#13;
    /// @dev contract responsible for token accounting&#13;
    IBoomstarterToken public m_token;&#13;
&#13;
    /// @dev address receiving all the ether, no intentions to refund&#13;
    address public m_beneficiary;&#13;
&#13;
    /// @dev next sale to receive remaining tokens after this one finishes&#13;
    address public m_nextSale;&#13;
&#13;
    /// @dev active sale can accept ether, inactive - cannot&#13;
    bool public m_active;&#13;
&#13;
    /**&#13;
     *  @dev unix timestamp that sets presale finish date, which means that after that date&#13;
     *       you cannot buy anything, but finish can happen before, if owners decide to do so&#13;
     */&#13;
    uint public c_dateTo = 1529064000; // 15-Jun-18 12:00:00 UTC&#13;
&#13;
    /// @dev current amount of tokens sold&#13;
    uint public m_currentTokensSold = 0;&#13;
    /// @dev limit of tokens to be sold during presale&#13;
    uint public c_maximumTokensSold = uint(1500000) * uint(10) ** uint(18); // 1.5 million tokens&#13;
&#13;
    /// @notice first step, usd price of BoomstarterToken in cents &#13;
    uint public c_centsPerTokenFirst = 30; // $0.3&#13;
    /// @notice second step, usd price of BoomstarterToken in cents&#13;
    uint public c_centsPerTokenSecond = 40; // $0.4&#13;
    /// @notice amount of tokens sold at which price switch should happen&#13;
    uint public c_priceRiseTokenAmount = uint(666668) * uint(10) ** uint(18);&#13;
}