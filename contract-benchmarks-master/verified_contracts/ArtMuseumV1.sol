pragma solidity ^0.4.18;

// File: contracts/LikeCoinInterface.sol

//    Copyright (C) 2017 LikeCoin Foundation Limited
//
//    This file is part of LikeCoin Smart Contract.
//
//    LikeCoin Smart Contract is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    LikeCoin Smart Contract is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with LikeCoin Smart Contract.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.4.18;

contract LikeCoinInterface {
	function balanceOf(address _owner) public constant returns (uint256 balance);
	function transfer(address _to, uint256 _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
	function approve(address _spender, uint256 _value) public returns (bool success);
}

// File: contracts/Ownable.sol

contract Ownable {

	address public owner;
	address public pendingOwner;
	address public operator;

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
	 * @dev Modifier throws if called by any account other than the pendingOwner.
	 */
	modifier onlyPendingOwner() {
		require(msg.sender == pendingOwner);
		_;
	}

	modifier ownerOrOperator {
		require(msg.sender == owner || msg.sender == operator);
		_;
	}

	/**
	 * @dev Allows the current owner to set the pendingOwner address.
	 * @param newOwner The address to transfer ownership to.
	 */
	function transferOwnership(address newOwner) onlyOwner public {
		pendingOwner = newOwner;
	}

	/**
	 * @dev Allows the pendingOwner address to finalize the transfer.
	 */
	function claimOwnership() onlyPendingOwner public {
		emit OwnershipTransferred(owner, pendingOwner);
		owner = pendingOwner;
		pendingOwner = address(0);
	}

	function setOperator(address _operator) onlyOwner public {
		operator = _operator;
	}

}

// File: contracts/ArtMuseumBase.sol

contract ArtMuseumBase is Ownable {

	struct Artwork {
		uint8 artworkType;
		uint32 sequenceNumber;
		uint128 value;
		address player;
	}
	LikeCoinInterface public like;

	/** array holding ids mapping of the curret artworks*/
	uint32[] public ids;
	/** the last sequence id to be given to the link artwork **/
	uint32 public lastId;
	/** the id of the oldest artwork */
	uint32 public oldest;
	/** the artwork belonging to a given id */
	mapping(uint32 => Artwork) artworks;
	/** the user purchase sequence number per each artwork type */
	mapping(address=>mapping(uint8 => uint32)) userArtworkSequenceNumber;
	/** the cost of each artwork type */
	uint128[] public costs;
	/** the value of each artwork type (cost - fee), so it's not necessary to compute it each time*/
	uint128[] public values;
	/** the fee to be paid each time an artwork is bought in percent*/
	uint8 public fee;

	/** total number of artworks in the game (uint32 because of multiplication issues) */
	uint32 public numArtworks;
	/** The maximum of artworks allowed in the game */
	uint16 public maxArtworks;
	/** number of artworks per type */
	uint32[] numArtworksXType;

	/** initializes the contract parameters */
	function init(address _likeAddr) public onlyOwner {
		require(like==address(0));
		like = LikeCoinInterface(_likeAddr);
		costs = [800 ether, 2000 ether, 5000 ether, 12000 ether, 25000 ether];
		setFee(5);
		maxArtworks = 1000;
		lastId = 1;
		oldest = 0;
	}

	function deposit() payable public {

	}

	function withdrawBalance() public onlyOwner returns(bool res) {
		owner.transfer(address(this).balance);
		return true;
	}

	/**
	 * allows the owner to collect the accumulated fees
	 * sends the given amount to the owner's address if the amount does not exceed the
	 * fees (cannot touch the players' balances)
	 * */
	function collectFees(uint128 amount) public onlyOwner {
		uint collectedFees = getFees();
		if (amount <= collectedFees) {
			like.transfer(owner,amount);
		}
	}

	function getArtwork(uint32 artworkId) public constant returns(uint8 artworkType, uint32 sequenceNumber, uint128 value, address player) {
		return (artworks[artworkId].artworkType, artworks[artworkId].sequenceNumber, artworks[artworkId].value, artworks[artworkId].player);
	}

	function getAllArtworks() public constant returns(uint32[] artworkIds,uint8[] types,uint32[] sequenceNumbers, uint128[] artworkValues) {
		uint32 id;
		artworkIds = new uint32[](numArtworks);
		types = new uint8[](numArtworks);
		sequenceNumbers = new uint32[](numArtworks);
		artworkValues = new uint128[](numArtworks);
		for (uint16 i = 0; i < numArtworks; i++) {
			id = ids[i];
			artworkIds[i] = id;
			types[i] = artworks[id].artworkType;
			sequenceNumbers[i] = artworks[id].sequenceNumber;
			artworkValues[i] = artworks[id].value;
		}
	}

	function getAllArtworksByOwner() public constant returns(uint32[] artworkIds,uint8[] types,uint32[] sequenceNumbers, uint128[] artworkValues) {
		uint32 id;
		uint16 j = 0;
		uint16 howmany = 0;
		address player = address(msg.sender);
		for (uint16 k = 0; k < numArtworks; k++) {
			if (artworks[ids[k]].player == player)
				howmany++;
		}
		artworkIds = new uint32[](howmany);
		types = new uint8[](howmany);
		sequenceNumbers = new uint32[](howmany);
		artworkValues = new uint128[](howmany);
		for (uint16 i = 0; i < numArtworks; i++) {
			if (artworks[ids[i]].player == player) {
				id = ids[i];
				artworkIds[j] = id;
				types[j] = artworks[id].artworkType;
				sequenceNumbers[j] = artworks[id].sequenceNumber;
				artworkValues[j] = artworks[id].value;
				j++;
			}
		}
	}

	function setCosts(uint128[] _costs) public onlyOwner {
		require(_costs.length >= costs.length);
		costs = _costs;
		setFee(fee);
	}
	
	function setFee(uint8 _fee) public onlyOwner {
		fee = _fee;
		for (uint8 i = 0; i < costs.length; i++) {
			if (i < values.length)
				values[i] = costs[i] - costs[i] / 100 * fee;
			else {
				values.push(costs[i] - costs[i] / 100 * fee);
				numArtworksXType.push(0);
			}
		}
	}

	function getFees() public constant returns(uint) {
		uint reserved = 0;
		for (uint16 j = 0; j < numArtworks; j++)
			reserved += artworks[ids[j]].value;
		return like.balanceOf(this) - reserved;
	}


}

// File: contracts/oraclizeAPI.sol

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

pragma solidity ^0.4.20;//<=0.4.20;// Incompatible compiler version... please select one stated within pragma solidity or use different oraclizeAPI version

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

contract usingOraclize { // is ArtMuseumBase {
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
	string oraclize_network_name;
	OraclizeAddrResolverI OAR;
	OraclizeI oraclize;
	modifier oraclizeAPI {
		if((address(OAR)==0)||(getCodeSize(address(OAR))==0))
			oraclize_setNetwork(networkID_auto);

		if(address(oraclize) != OAR.getAddress())
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

	function oraclize_cbAddress() oraclizeAPI internal returns (address){
		return oraclize.cbAddress();
	}
	function oraclize_setCustomGasPrice(uint gasPrice) oraclizeAPI internal {
		return oraclize.setCustomGasPrice(gasPrice);
	}
	function getCodeSize(address _addr) constant internal returns(uint _size) {
		assembly {
			_size := extcodesize(_addr)
		}
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
	function oraclize_setNetworkName(string _network_name) internal {
		oraclize_network_name = _network_name;
	}
	function oraclize_getNetworkName() internal view returns (string) {
		return oraclize_network_name;
	}
}

// File: contracts/strings.sol

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6001120103080e0904200e0f14040f144e0e0514">[email protected]</a>&gt;&#13;
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
pragma solidity ^0.4.14;&#13;
&#13;
library strings {&#13;
	struct slice {&#13;
		uint _len;&#13;
		uint _ptr;&#13;
	}&#13;
&#13;
	function memcpy(uint dest, uint src, uint len) private pure {&#13;
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
	function toSlice(string self) internal pure returns (slice) {&#13;
		uint ptr;&#13;
		assembly {&#13;
			ptr := add(self, 0x20)&#13;
		}&#13;
		return slice(bytes(self).length, ptr);&#13;
	}&#13;
&#13;
	/*&#13;
	 * @dev Copies a slice to a new string.&#13;
	 * @param self The slice to copy.&#13;
	 * @return A newly allocated string containing the slice's text.&#13;
	 */&#13;
	function toString(slice self) internal pure returns (string) {&#13;
		string memory ret = new string(self._len);&#13;
		uint retptr;&#13;
		assembly { retptr := add(ret, 32) }&#13;
&#13;
		memcpy(retptr, self._ptr, self._len);&#13;
		return ret;&#13;
	}&#13;
&#13;
	// Returns the memory address of the first byte of the first occurrence of&#13;
	// `needle` in `self`, or the first byte after `self` if not found.&#13;
	function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {&#13;
		uint ptr = selfptr;&#13;
		uint idx;&#13;
&#13;
		if (needlelen &lt;= selflen) {&#13;
			if (needlelen &lt;= 32) {&#13;
				bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));&#13;
&#13;
				bytes32 needledata;&#13;
				assembly { needledata := and(mload(needleptr), mask) }&#13;
&#13;
				uint end = selfptr + selflen - needlelen;&#13;
				bytes32 ptrdata;&#13;
				assembly { ptrdata := and(mload(ptr), mask) }&#13;
&#13;
				while (ptrdata != needledata) {&#13;
					if (ptr &gt;= end)&#13;
						return selfptr + selflen;&#13;
					ptr++;&#13;
					assembly { ptrdata := and(mload(ptr), mask) }&#13;
				}&#13;
				return ptr;&#13;
			} else {&#13;
				// For long needles, use hashing&#13;
				bytes32 hash;&#13;
				assembly { hash := sha3(needleptr, needlelen) }&#13;
&#13;
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
	function split(slice self, slice needle, slice token) internal pure returns (slice) {&#13;
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
	function split(slice self, slice needle) internal pure returns (slice token) {&#13;
		split(self, needle, token);&#13;
	}&#13;
&#13;
	/*&#13;
	 * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.&#13;
	 * @param self The slice to search.&#13;
	 * @param needle The text to search for in `self`.&#13;
	 * @return The number of occurrences of `needle` found in `self`.&#13;
	 */&#13;
	function count(slice self, slice needle) internal pure returns (uint cnt) {&#13;
		uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;&#13;
		while (ptr &lt;= self._ptr + self._len) {&#13;
			cnt++;&#13;
			ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;&#13;
		}&#13;
	}&#13;
&#13;
}&#13;
&#13;
// File: contracts/ArtMuseumV1.sol&#13;
&#13;
contract ArtMuseumV1 is ArtMuseumBase, usingOraclize {&#13;
&#13;
	//using Strings for string;&#13;
	using strings for *;&#13;
&#13;
	/** num of times oldest artwork get bonus **/&#13;
	uint32 public lastcombo;&#13;
	/** last stolen at block number in blockchain **/&#13;
	uint public lastStealBlockNumber;&#13;
	/** oldest artwork extra steal probability **/&#13;
	uint8[] public oldestExtraStealProbability;&#13;
&#13;
	/** the query string getting the random numbers from oraclize**/&#13;
	string randomQuery;&#13;
	/** the type of the oraclize query**/&#13;
	string queryType;&#13;
	/** the timestamp of the next attack **/&#13;
	uint public nextStealTimestamp;&#13;
	/** gas provided for oraclize callback (attack)**/&#13;
	uint32 public oraclizeGas;&#13;
	/** gas provided for oraclize callback calculate by extra artworks fund likecoin (attack)**/&#13;
	uint32 public oraclizeGasExtraArtwork;&#13;
	/** the id of the next oraclize callback**/&#13;
	uint32 public etherExchangeLikeCoin;&#13;
	/** the id of oraclize callback**/&#13;
	bytes32 nextStealId;&#13;
	/** total number of times steal per day  **/&#13;
	uint8 public numOfTimesSteal;&#13;
	/** accumulate ether fee for trigger next steal include oraclize fee and trigger gas fee **/&#13;
	uint public oraclizeFee;&#13;
&#13;
	/** is fired when new artworks are purchased (who bought how many artworks of which type?) */&#13;
	event newPurchase(address player, uint32 startId, uint8[] artworkTypes, uint32[] startSequenceNumbers);&#13;
	/** is fired when an steal occures */&#13;
	event newSteal(uint timestamp,uint32[] stolenArtworks,uint8[] artworkTypes,uint32[] sequenceNumbers, uint256[] values,address[] players);&#13;
	/** is fired when an steal occures */&#13;
	event newStealRewards(uint128 total,uint128[] values);&#13;
	/** is fired when a single artwork is sold **/&#13;
	event newSell(uint32[] artworkId, address player, uint256 value);&#13;
	/** trigger oraclize **/&#13;
	event newTriggerOraclize(bytes32 nextStealId, uint waittime, uint gasAmount, uint price, uint balancebefore, uint balance);&#13;
	/** oraclize callback **/&#13;
	event newOraclizeCallback(bytes32 nextStealId, string result, uint32 killed, uint128 killedValue, uint128 distValue,uint oraclizeFee,uint gaslimit,uint exchange);&#13;
&#13;
&#13;
	function initOraclize() public onlyOwner {&#13;
		if((address(OAR)==0)||(getCodeSize(address(OAR))==0))&#13;
			oraclize_setNetwork();&#13;
	}&#13;
&#13;
	function init1() public onlyOwner {&#13;
		randomQuery = "10 random numbers between 1 and 100000";&#13;
		queryType = "WolframAlpha";&#13;
		oraclizeGas = 150000;&#13;
		oraclizeGasExtraArtwork = 14000;&#13;
		etherExchangeLikeCoin = 100000;&#13;
		oldestExtraStealProbability = [3,5,10,15,30,50];&#13;
		numOfTimesSteal = 1;&#13;
	}&#13;
&#13;
	/**&#13;
	 * buy artworks when likecoin transfer callback&#13;
	 * */&#13;
	function giveArtworks(uint8[] artworkTypes, address receiver, uint256 _value) internal {&#13;
		uint32 len = uint32(artworkTypes.length);&#13;
		require(numArtworks + len &lt; maxArtworks);&#13;
		uint256 amount = 0;&#13;
		for (uint16 i = 0; i &lt; len; i++) {&#13;
			require(artworkTypes[i] &lt; costs.length);&#13;
			amount += costs[artworkTypes[i]];&#13;
		}&#13;
		require(_value &gt;= amount);&#13;
		uint8 artworkType;&#13;
		uint32[] memory seqnolist = new uint32[](len);&#13;
		for (uint16 j = 0; j &lt; len; j++) {&#13;
			if (numArtworks &lt; ids.length)&#13;
				ids[numArtworks] = lastId;&#13;
			else&#13;
				ids.push(lastId);&#13;
			artworkType = artworkTypes[j];&#13;
			userArtworkSequenceNumber[receiver][artworkType]++;&#13;
			seqnolist[j] = userArtworkSequenceNumber[receiver][artworkType];&#13;
			artworks[lastId] = Artwork(artworkTypes[j], userArtworkSequenceNumber[receiver][artworkType], values[artworkType], receiver);&#13;
			numArtworks++;&#13;
			lastId++;&#13;
			numArtworksXType[artworkType]++;&#13;
		}&#13;
		// tryAutoTriggerSteal();&#13;
		emit newPurchase(receiver, lastId - len, artworkTypes, seqnolist);&#13;
	}&#13;
&#13;
	/**&#13;
	 * Replaces the artwork with the given id with the last artwork in the array&#13;
	 * */&#13;
	function replaceArtwork(uint16 index) internal {&#13;
		uint32 artworkId = ids[index];&#13;
		numArtworksXType[artworks[artworkId].artworkType]--;&#13;
		numArtworks--;&#13;
		if (artworkId == oldest) oldest = 0;&#13;
		delete artworks[artworkId];&#13;
		if (numArtworks&gt;0)&#13;
			ids[index] = ids[numArtworks];&#13;
		delete ids[numArtworks];&#13;
		ids.length = numArtworks;&#13;
	}&#13;
&#13;
&#13;
	/**&#13;
	 * get the oldest artwork&#13;
	 * */&#13;
	function getOldest() public constant returns(uint32 artworkId,uint8 artworkType, uint32 sequenceNumber, uint128 value, address player) {&#13;
		if (numArtworks==0) artworkId = 0;&#13;
		else {&#13;
			artworkId = oldest;&#13;
			if (artworkId==0) {&#13;
				artworkId = ids[0];&#13;
				for (uint16 i = 1; i &lt; numArtworks; i++) {&#13;
					if (ids[i] &lt; artworkId) //the oldest artwork has the lowest id&#13;
						artworkId = ids[i];&#13;
				}&#13;
			}&#13;
			artworkType = artworks[artworkId].artworkType;&#13;
			sequenceNumber = artworks[artworkId].sequenceNumber;&#13;
			value = artworks[artworkId].value;&#13;
			player = artworks[artworkId].player;&#13;
		}&#13;
	}&#13;
&#13;
	/**&#13;
	 * set the oldest artwork when steal&#13;
	 * */&#13;
	function setOldest() internal returns(uint32 artworkId,uint16 index) {&#13;
		if (numArtworks==0) artworkId = 0;&#13;
		else {&#13;
			if (oldest==0) {&#13;
				oldest = ids[0];&#13;
				index = 0;&#13;
				for (uint16 i = 1; i &lt; numArtworks; i++) {&#13;
					if (ids[i] &lt; oldest) { //the oldest artwork has the lowest id&#13;
						oldest = ids[i];&#13;
						index = i;&#13;
					}&#13;
				}&#13;
			} else {&#13;
				for (uint16 j = 0; j &lt; numArtworks; j++) {&#13;
					if (ids[j] == oldest) {&#13;
						index = j;&#13;
						break;&#13;
					}&#13;
				}				&#13;
			}&#13;
			artworkId = oldest;&#13;
		}&#13;
	}&#13;
&#13;
	/**&#13;
	 * sell the artwork of the given id&#13;
	 * */&#13;
	function sellArtwork(uint32 artworkId) public {&#13;
		require(msg.sender == artworks[artworkId].player);&#13;
		uint256 val = uint256(artworks[artworkId].value);// - sellfee;&#13;
		uint16 artworkIndex;&#13;
		bool found = false;&#13;
		for (uint16 i = 0; i &lt; numArtworks; i++) {&#13;
			if (ids[i] == artworkId) {&#13;
				artworkIndex = i;&#13;
				found = true;&#13;
				break;&#13;
			}&#13;
		}&#13;
		require(found == true);&#13;
		replaceArtwork(artworkIndex);&#13;
		if (val&gt;0)&#13;
			like.transfer(msg.sender,val);&#13;
		uint32[] memory artworkIds = new uint32[](1);&#13;
		artworkIds[0] = artworkId;&#13;
		// tryAutoTriggerSteal();&#13;
		// ids.length = numArtworks;&#13;
		emit newSell(artworkIds, msg.sender, val);&#13;
	}&#13;
	&#13;
	/**&#13;
	 * manually triggers the steal&#13;
	 * */&#13;
	function triggerStealManually(uint32 inseconds) public payable ownerOrOperator {&#13;
		require((nextStealTimestamp) &lt; now); // avoid two scheduled callback, asssume max 5mins wait to callback when trigger&#13;
		triggerSteal(inseconds, (oraclizeGas + oraclizeGasExtraArtwork * numArtworks));&#13;
	}&#13;
&#13;
&#13;
	/**&#13;
	 * the frequency of the thief steal depends on the number of artworks in the game. &#13;
	 * many artworks -&gt; many thief steal&#13;
	 * */&#13;
	function timeTillNextSteal() constant internal returns(uint32) {&#13;
		return (86400 / (1 + numArtworks / 100)) / ( numOfTimesSteal );&#13;
	}&#13;
&#13;
	/**&#13;
	 * sends a query to oraclize in order to get random numbers in 'inseconds' seconds&#13;
	 */&#13;
	function triggerSteal(uint32 inseconds, uint gasAmount) internal {&#13;
		// Check if we have enough remaining funds&#13;
		uint gaslimit = gasleft();&#13;
		uint price = oraclize_getPrice(queryType, gasAmount);&#13;
		uint balancebefore = address(this).balance;&#13;
		require(price &lt;= address(this).balance);&#13;
		if (numArtworks&lt;=1) {&#13;
			removeArtworksByString("",0);&#13;
			distribute(0);&#13;
			nextStealId = 0x0;&#13;
			price = 0;&#13;
		} else {&#13;
			nextStealId = oraclize_query(nextStealTimestamp, queryType, randomQuery, gasAmount);&#13;
		}&#13;
		emit newTriggerOraclize(nextStealId, inseconds, gasAmount, price, balancebefore, address(this).balance);&#13;
		oraclizeFee = price + (gaslimit-gasleft() + 200000 /*add gas overhead*/) * tx.gasprice;&#13;
	}&#13;
&#13;
	/**&#13;
	 * convert a random number to index of artworks list&#13;
	 * */&#13;
	function findIndexFromRandomNumber(uint32 randomNumbers) internal returns (uint32 artworkId, uint16 index) {&#13;
		uint16 indexOldest;&#13;
		uint maxNumber;&#13;
		uint8 extraProbability;&#13;
		if (oldest==0)&#13;
			lastcombo = 0;&#13;
		(artworkId,indexOldest) = setOldest();&#13;
		if (lastcombo&gt;oldestExtraStealProbability.length-1)&#13;
			extraProbability = oldestExtraStealProbability[oldestExtraStealProbability.length-1];&#13;
		else&#13;
			extraProbability = oldestExtraStealProbability[lastcombo];&#13;
		maxNumber = 100000 - extraProbability*1000;&#13;
		if (extraProbability&gt;0 &amp;&amp; randomNumbers&gt;maxNumber) {&#13;
			index = indexOldest;&#13;
			artworkId = oldest;&#13;
		} else {&#13;
			index = mapToNewRange(randomNumbers, numArtworks, maxNumber);&#13;
			artworkId = ids[index];&#13;
		}&#13;
	}&#13;
&#13;
	/**&#13;
	 * remove artwork by random number (a string, number list)&#13;
	 * */&#13;
	function removeArtworksByString(string result,uint32 howmany) internal returns (uint128 pot) {&#13;
		uint32[] memory stolenArtworks = new uint32[](howmany);&#13;
		uint8[] memory artworkTypes = new uint8[](howmany);&#13;
		uint32[] memory sequenceNumbers = new uint32[](howmany);&#13;
		uint256[] memory artworkValues = new uint256[](howmany);&#13;
		address[] memory players = new address[](howmany);&#13;
		if (howmany&gt;0) {&#13;
			uint32[] memory randomNumbers = getNumbersFromString(result, ",", howmany);&#13;
			uint16 index;&#13;
			uint32 artworkId;&#13;
			Artwork memory artworkData;&#13;
			pot = 0;&#13;
			if (oldest!=0)&#13;
				lastcombo++;&#13;
			for (uint32 i = 0; i &lt; howmany; i++) {&#13;
				(artworkId,index) = findIndexFromRandomNumber(randomNumbers[i]);&#13;
				artworkData = artworks[artworkId];&#13;
				pot += artworkData.value;&#13;
				stolenArtworks[i] = artworkId;&#13;
				artworkTypes[i] = artworkData.artworkType;&#13;
				sequenceNumbers[i] = artworkData.sequenceNumber;&#13;
				artworkValues[i] = artworkData.value;&#13;
				players[i] = artworkData.player;&#13;
				replaceArtwork(index);&#13;
			}&#13;
		} else {&#13;
			pot = 0;&#13;
		}&#13;
		emit newSteal(now,stolenArtworks,artworkTypes,sequenceNumbers,artworkValues,players);&#13;
	}&#13;
&#13;
	/**&#13;
	 * oraclize call back&#13;
	 * */&#13;
	function __callback(bytes32 myid, string result) public {&#13;
		uint gaslimit = gasleft();&#13;
		uint32 howmany;&#13;
		uint128 pot;&#13;
		uint gasCost;&#13;
		uint128 distpot;&#13;
		uint oraclizeFeeTmp = 0; // for event log&#13;
		if (msg.sender == oraclize_cbAddress() &amp;&amp; myid == nextStealId) {&#13;
			howmany = numArtworks &lt; 100 ? (numArtworks &lt; 10 ? (numArtworks &lt; 2 ? 0 : 1) : numArtworks / 10) : 10; //do not kill more than 10%, but at least one&#13;
			pot = removeArtworksByString(result,howmany);&#13;
			gasCost = ((oraclizeFee * etherExchangeLikeCoin) / 1 ether) * 1 ether + 1 ether/* not floor() */;&#13;
			if (pot &gt; gasCost)&#13;
				distpot = uint128(pot - gasCost);&#13;
			distribute(distpot); //distribute the pot minus the oraclize gas costs&#13;
			oraclizeFeeTmp = oraclizeFee;&#13;
			oraclizeFee = 0;&#13;
		}&#13;
		emit newOraclizeCallback(myid,result,howmany,pot,distpot,oraclizeFeeTmp,gaslimit,etherExchangeLikeCoin);&#13;
	}&#13;
&#13;
	/**&#13;
	 * change next steal time&#13;
	 * */&#13;
	function updateNextStealTime(uint32 inseconds) internal {&#13;
		nextStealTimestamp = now + inseconds;&#13;
	}&#13;
&#13;
	/** distributes the given amount among the surviving artworks*/&#13;
	function distribute(uint128 totalAmount) internal {&#13;
		uint32 artworkId;&#13;
		uint128 amount = ( totalAmount * 60 ) / 100;&#13;
		uint128 valueSum = 0;&#13;
		uint128 totalAmountRemain = totalAmount;&#13;
		uint128[] memory shares = new uint128[](values.length+1);&#13;
		if (totalAmount&gt;0) {&#13;
			//distribute the rest according to their type&#13;
			for (uint8 v = 0; v &lt; values.length; v++) {&#13;
				if (numArtworksXType[v] &gt; 0) valueSum += values[v];&#13;
			}&#13;
			for (uint8 m = 0; m &lt; values.length; m++) {&#13;
				if (numArtworksXType[m] &gt; 0)&#13;
					shares[m] = ((amount * (values[m] * 1000 / valueSum) / numArtworksXType[m]) / (1000 ether)) * (1 ether);&#13;
			}&#13;
			for (uint16 i = 0; i &lt; numArtworks; i++) {&#13;
				artworkId = ids[i];&#13;
				amount = shares[artworks[artworkId].artworkType];&#13;
				artworks[artworkId].value += amount;&#13;
				totalAmountRemain -= amount;&#13;
			}&#13;
			setOldest();&#13;
			artworks[oldest].value += totalAmountRemain;&#13;
			shares[shares.length-1] = totalAmountRemain;			&#13;
		}&#13;
		lastStealBlockNumber = block.number;&#13;
		updateNextStealTime(timeTillNextSteal());&#13;
		emit newStealRewards(totalAmount,shares);&#13;
	}&#13;
&#13;
&#13;
	&#13;
	/****************** GETTERS *************************/&#13;
&#13;
	function getNumArtworksXType() public constant returns(uint32[] _numArtworksXType) {&#13;
		_numArtworksXType = numArtworksXType;&#13;
	}&#13;
&#13;
	function get30Artworks(uint16 startIndex) public constant returns(uint32[] artworkIds,uint8[] types,uint32[] sequenceNumbers, uint128[] artworkValues,address[] players) {&#13;
		uint32 endIndex = startIndex + 30 &gt; numArtworks ? numArtworks : startIndex + 30;&#13;
		uint32 id;&#13;
		uint32 num = endIndex - startIndex;&#13;
		artworkIds = new uint32[](num);&#13;
		types = new uint8[](num);&#13;
		sequenceNumbers = new uint32[](num);&#13;
		artworkValues = new uint128[](num);&#13;
		players = new address[](num);&#13;
		uint16 j = 0;		&#13;
		for (uint16 i = startIndex; i &lt; endIndex; i++) {&#13;
			id = ids[i];&#13;
			artworkIds[j] = id;&#13;
			types[j] = artworks[id].artworkType;&#13;
			sequenceNumbers[j] = artworks[id].sequenceNumber;&#13;
			artworkValues[j] = artworks[id].value;&#13;
			players[j] = artworks[id].player;&#13;
			j++;&#13;
		}&#13;
	}&#13;
&#13;
	function getRemainTime() public constant returns(uint remainTime) {&#13;
		if (nextStealTimestamp&gt;now) remainTime = nextStealTimestamp - now;&#13;
	}&#13;
&#13;
	/****************** SETTERS *************************/&#13;
&#13;
	function setCustomGasPrice(uint gasPrice) public ownerOrOperator {&#13;
		oraclize_setCustomGasPrice(gasPrice);&#13;
	}&#13;
&#13;
	function setOraclizeGas(uint32 newGas) public ownerOrOperator {&#13;
		oraclizeGas = newGas;&#13;
	}&#13;
&#13;
	function setOraclizeGasExtraArtwork(uint32 newGas) public ownerOrOperator {&#13;
		oraclizeGasExtraArtwork = newGas;&#13;
	}&#13;
&#13;
	function setEtherExchangeLikeCoin(uint32 newValue) public ownerOrOperator {&#13;
		etherExchangeLikeCoin = newValue;&#13;
	}&#13;
&#13;
	function setMaxArtworks(uint16 number) public ownerOrOperator {&#13;
		maxArtworks = number;&#13;
	}&#13;
	&#13;
	function setNumOfTimesSteal(uint8 adjust) public ownerOrOperator {&#13;
		numOfTimesSteal = adjust;&#13;
	}&#13;
&#13;
	function updateNextStealTimeByOperator(uint32 inseconds) public ownerOrOperator {&#13;
		nextStealTimestamp = now + inseconds;&#13;
	}&#13;
&#13;
&#13;
	/************* HELPERS ****************/&#13;
&#13;
	/**&#13;
	 * maps a given number to the new range (old range 100000)&#13;
	 * */&#13;
	function mapToNewRange(uint number, uint range, uint max) pure internal returns(uint16 randomNumber) {&#13;
		return uint16(number * range / max);&#13;
	}&#13;
&#13;
	/**&#13;
	 * converts a string of numbers being separated by a given delimiter into an array of numbers (#howmany) &#13;
	 */&#13;
	function getNumbersFromString(string s, string delimiter, uint32 howmany) public pure returns(uint32[] numbers) {&#13;
		var s2 = s.toSlice();&#13;
		var delim = delimiter.toSlice();&#13;
		string[] memory parts = new string[](s2.count(delim) + 1);&#13;
		for(uint8 i = 0; i &lt; parts.length; i++) {&#13;
			parts[i] = s2.split(delim).toString();&#13;
		}&#13;
		numbers = new uint32[](howmany);&#13;
		if (howmany&gt;parts.length) howmany = uint32(parts.length);&#13;
		for (uint8 j = 0; j &lt; howmany; j++) {&#13;
			numbers[j] = uint32(parseInt(parts[j]));&#13;
		}&#13;
		return numbers;&#13;
	}&#13;
&#13;
	/**&#13;
	 * likecoin transfer callback &#13;
	 */&#13;
	function tokenCallback(address _from, uint256 _value, bytes _data) public {&#13;
		require(msg.sender == address(like));&#13;
		uint[] memory result;&#13;
		uint len;&#13;
		assembly {&#13;
			len := mload(_data)&#13;
			let c := 0&#13;
			result := mload(0x40)&#13;
			for { let i := 0 } lt(i, len) { i := add(i, 0x20) }&#13;
			{&#13;
				mstore(add(result, add(i, 0x20)), mload(add(_data, add(i, 0x20))))&#13;
				c := add(c, 1)&#13;
			}&#13;
			mstore(result, c)&#13;
			mstore(0x40, add(result , add(0x20, mul(c, 0x20))))&#13;
		}&#13;
		uint8[] memory result2 = new uint8[](result.length);&#13;
		for (uint16 j=0;j&lt;result.length; j++) {&#13;
			result2[j] = uint8(result[j]);&#13;
		}&#13;
		giveArtworks(result2, _from, _value);&#13;
	}&#13;
&#13;
}