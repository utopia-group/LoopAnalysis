// <ORACLIZE_API_LIB>
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

pragma solidity ^0.4.21;

contract OraclizeI {
    address public cbAddress;
    function query(uint _timestamp, string _datasource, string _arg) external payable returns (bytes32 _id);
    function query_withGasLimit(uint _timestamp, string _datasource, string _arg, uint _gaslimit) external payable returns (bytes32 _id);
    function query2(uint _timestamp, string _datasource, string _arg1, string _arg2) public payable returns (bytes32 _id);
    function query2_withGasLimit(uint _timestamp, string _datasource, string _arg1, string _arg2, uint _gaslimit) external payable returns (bytes32 _id);
    function queryN(uint _timestamp, string _datasource, bytes _argN) public payable returns (bytes32 _id);
    function queryN_withGasLimit(uint _timestamp, string _datasource, bytes _argN, uint _gaslimit) external payable returns (bytes32 _id);
    function getPrice(string _datasource) public view returns (uint _dsprice);
    function getPrice(string _datasource, uint gaslimit) public view returns (uint _dsprice);
    function setProofType(byte _proofType) external;
    function setCustomGasPrice(uint _gasPrice) external;
    function randomDS_getSessionPubKeyHash() external view returns(bytes32);
}
contract OraclizeAddrResolverI {
    function getAddress() public view returns (address _addr);
}
library oraclizeLib {

    function proofType_NONE()
    public
    pure
    returns (byte) {
        return 0x00;
    }

    function proofType_TLSNotary()
    public
    pure
    returns (byte) {
        return 0x10;
    }

    function proofType_Android()
    public
    pure
    returns (byte) {
        return 0x20;
    }

    function proofType_Ledger()
    public
    pure
    returns (byte) {
        return 0x30;
    }

    function proofType_Native()
    public
    pure
    returns (byte) {
        return 0xF0;
    }

    function proofStorage_IPFS()
    public
    pure
    returns (byte) {
        return 0x01;
    }

    //OraclizeAddrResolverI constant public OAR = oraclize_setNetwork();

    function OAR()
    public
    view
    returns (OraclizeAddrResolverI) {
        return oraclize_setNetwork();
    }

    //OraclizeI constant public oraclize = OraclizeI(OAR.getAddress());

    function oraclize()
    public
    view
    returns (OraclizeI) {
        return OraclizeI(OAR().getAddress());
    }

    function oraclize_setNetwork()
    public
    view
    returns(OraclizeAddrResolverI){
        if (getCodeSize(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed)>0){ //mainnet
            return OraclizeAddrResolverI(0x1d3B2638a7cC9f2CB3D298A3DA7a90B67E5506ed);
        }
        if (getCodeSize(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1)>0){ //ropsten testnet
            return OraclizeAddrResolverI(0xc03A2615D5efaf5F49F60B7BB6583eaec212fdf1);
        }
        if (getCodeSize(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e)>0){ //kovan testnet
            return OraclizeAddrResolverI(0xB7A07BcF2Ba2f2703b24C0691b5278999C59AC7e);
        }
        if (getCodeSize(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48)>0){ //rinkeby testnet
            return OraclizeAddrResolverI(0x146500cfd35B22E4A392Fe0aDc06De1a1368Ed48);
        }
        if (getCodeSize(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475)>0){ //ethereum-bridge
            return OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        }
        if (getCodeSize(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF)>0){ //ether.camp ide
            return OraclizeAddrResolverI(0x20e12A1F859B3FeaE5Fb2A0A32C18F5a65555bBF);
        }
        if (getCodeSize(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA)>0){ //browser-solidity
            return OraclizeAddrResolverI(0x51efaF4c8B3C9AfBD5aB9F4bbC82784Ab6ef8fAA);
        }
    }

    function oraclize_getPrice(string datasource)
    public
    view
    returns (uint){
        return oraclize().getPrice(datasource);
    }

    function oraclize_getPrice(string datasource, uint gaslimit)
    public
    view
    returns (uint){
        return oraclize().getPrice(datasource, gaslimit);
    }

    function oraclize_query(string datasource, string arg)
    public
    returns (bytes32 id){
        return oraclize_query(0, datasource, arg);
    }

    function oraclize_query(uint timestamp, string datasource, string arg)
    public
    returns (bytes32 id){
        OraclizeI oracle = oraclize();
        uint price = oracle.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oracle.query.value(price)(timestamp, datasource, arg);
    }

    function oraclize_query(string datasource, string arg, uint gaslimit)
    public
    returns (bytes32 id){
        return oraclize_query(0, datasource, arg, gaslimit);
    }

    function oraclize_query(uint timestamp, string datasource, string arg, uint gaslimit)
    public
    returns (bytes32 id){
        OraclizeI oracle = oraclize();
        uint price = oracle.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oracle.query_withGasLimit.value(price)(timestamp, datasource, arg, gaslimit);
    }

    function oraclize_query(string datasource, string arg1, string arg2)
    public
    returns (bytes32 id){
        return oraclize_query(0, datasource, arg1, arg2);
    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2)
    public
    returns (bytes32 id){
        OraclizeI oracle = oraclize();
        uint price = oracle.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        return oracle.query2.value(price)(timestamp, datasource, arg1, arg2);
    }

    function oraclize_query(string datasource, string arg1, string arg2, uint gaslimit)
    public
    returns (bytes32 id){
        return oraclize_query(0, datasource, arg1, arg2, gaslimit);
    }

    function oraclize_query(uint timestamp, string datasource, string arg1, string arg2, uint gaslimit)
    public
    returns (bytes32 id){
        OraclizeI oracle = oraclize();
        uint price = oracle.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        return oracle.query2_withGasLimit.value(price)(timestamp, datasource, arg1, arg2, gaslimit);
    }

    // internalize w/o experimental
    function oraclize_query(string datasource, string[] argN)
    internal
    returns (bytes32 id){
        return oraclize_query(0, datasource, argN);
    }

    // internalize w/o experimental
    function oraclize_query(uint timestamp, string datasource, string[] argN)
    internal
    returns (bytes32 id){
        OraclizeI oracle = oraclize();
        uint price = oracle.getPrice(datasource);
        if (price > 1 ether + tx.gasprice*200000) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oracle.queryN.value(price)(timestamp, datasource, args);
    }

    // internalize w/o experimental
    function oraclize_query(string datasource, string[] argN, uint gaslimit)
    internal
    returns (bytes32 id){
        return oraclize_query(0, datasource, argN, gaslimit);
    }

    // internalize w/o experimental
    function oraclize_query(uint timestamp, string datasource, string[] argN, uint gaslimit)
    internal
    returns (bytes32 id){
        OraclizeI oracle = oraclize();
        uint price = oracle.getPrice(datasource, gaslimit);
        if (price > 1 ether + tx.gasprice*gaslimit) return 0; // unexpectedly high price
        bytes memory args = stra2cbor(argN);
        return oracle.queryN_withGasLimit.value(price)(timestamp, datasource, args, gaslimit);
    }

    function oraclize_cbAddress()
    public
    view
    returns (address){
        return oraclize().cbAddress();
    }

    function oraclize_setProof(byte proofP)
    public {
        return oraclize().setProofType(proofP);
    }

    function oraclize_setCustomGasPrice(uint gasPrice)
    public {
        return oraclize().setCustomGasPrice(gasPrice);
    }

    // setting to internal doesn't cause major increase in deployment and saves gas
    // per use, for this tiny function
    function getCodeSize(address _addr)
    public
    view
    returns(uint _size) {
        assembly {
            _size := extcodesize(_addr)
        }
    }

    // expects 0x prefix
    function parseAddr(string _a)
    public
    pure
    returns (address){
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

    function strCompare(string _a, string _b)
    public
    pure
    returns (int) {
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

    function indexOf(string _haystack, string _needle)
    public
    pure
    returns (int) {
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

    function strConcat(string _a, string _b, string _c, string _d, string _e)
    internal
    pure
    returns (string) {
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

    function strConcat(string _a, string _b, string _c, string _d)
    internal
    pure
    returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c)
    internal
    pure
    returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b)
    internal
    pure
    returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    // parseInt
    function parseInt(string _a)
    public
    pure
    returns (uint) {
        return parseInt(_a, 0);
    }

    // parseInt(parseFloat*10^_b)
    function parseInt(string _a, uint _b)
    public
    pure
    returns (uint) {
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

    function uint2str(uint i)
    internal
    pure
    returns (string){
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

    function stra2cbor(string[] arr)
    internal
    pure
    returns (bytes) {
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
}
// </ORACLIZE_API_LIB>


/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c7a6b5a6a4afa9aea387a9a8b3a3a8b3e9a9a2b3">[email protected]</a>&gt;&#13;
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
     * @dev Returns the length of a null-terminated bytes32 string.&#13;
     * @param self The value to find the length of.&#13;
     * @return The length of the string, from 0 to 32.&#13;
     */&#13;
    function len(bytes32 self) internal pure returns (uint) {&#13;
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
    /*&#13;
     * @dev Returns a slice containing the entire bytes32, interpreted as a&#13;
     *      null-terminated utf-8 string.&#13;
     * @param self The bytes32 value to convert to a slice.&#13;
     * @return A new slice containing the value of the input argument up to the&#13;
     *         first null.&#13;
     */&#13;
    function toSliceB32(bytes32 self) internal pure returns (slice ret) {&#13;
        // Allocate space for `self` in memory, copy it there, and point ret at it&#13;
        assembly {&#13;
            let ptr := mload(0x40)&#13;
            mstore(0x40, add(ptr, 0x20))&#13;
            mstore(ptr, self)&#13;
            mstore(add(ret, 0x20), ptr)&#13;
        }&#13;
        ret._len = len(self);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns a new slice containing the same data as the current slice.&#13;
     * @param self The slice to copy.&#13;
     * @return A new slice containing the same data as `self`.&#13;
     */&#13;
    function copy(slice self) internal pure returns (slice) {&#13;
        return slice(self._len, self._ptr);&#13;
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
    /*&#13;
     * @dev Returns the length in runes of the slice. Note that this operation&#13;
     *      takes time proportional to the length of the slice; avoid using it&#13;
     *      in loops, and call `slice.empty()` if you only need to know whether&#13;
     *      the slice is empty or not.&#13;
     * @param self The slice to operate on.&#13;
     * @return The length of the slice in runes.&#13;
     */&#13;
    function len(slice self) internal pure returns (uint l) {&#13;
        // Starting at ptr-31 means the LSB will be the byte we care about&#13;
        uint ptr = self._ptr - 31;&#13;
        uint end = ptr + self._len;&#13;
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
     * @dev Returns true if the slice is empty (has a length of 0).&#13;
     * @param self The slice to operate on.&#13;
     * @return True if the slice is empty, False otherwise.&#13;
     */&#13;
    function empty(slice self) internal pure returns (bool) {&#13;
        return self._len == 0;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns a positive number if `other` comes lexicographically after&#13;
     *      `self`, a negative number if it comes before, or zero if the&#13;
     *      contents of the two slices are equal. Comparison is done per-rune,&#13;
     *      on unicode codepoints.&#13;
     * @param self The first slice to compare.&#13;
     * @param other The second slice to compare.&#13;
     * @return The result of the comparison.&#13;
     */&#13;
    function compare(slice self, slice other) internal pure returns (int) {&#13;
        uint shortest = self._len;&#13;
        if (other._len &lt; self._len)&#13;
            shortest = other._len;&#13;
&#13;
        uint selfptr = self._ptr;&#13;
        uint otherptr = other._ptr;&#13;
        for (uint idx = 0; idx &lt; shortest; idx += 32) {&#13;
            uint a;&#13;
            uint b;&#13;
            assembly {&#13;
                a := mload(selfptr)&#13;
                b := mload(otherptr)&#13;
            }&#13;
            if (a != b) {&#13;
                // Mask out irrelevant bytes and check again&#13;
                uint256 mask = uint256(-1); // 0xffff...&#13;
                if(shortest &lt; 32) {&#13;
                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);&#13;
                }&#13;
                uint256 diff = (a &amp; mask) - (b &amp; mask);&#13;
                if (diff != 0)&#13;
                    return int(diff);&#13;
            }&#13;
            selfptr += 32;&#13;
            otherptr += 32;&#13;
        }&#13;
        return int(self._len) - int(other._len);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns true if the two slices contain the same text.&#13;
     * @param self The first slice to compare.&#13;
     * @param self The second slice to compare.&#13;
     * @return True if the slices are equal, false otherwise.&#13;
     */&#13;
    function equals(slice self, slice other) internal pure returns (bool) {&#13;
        return compare(self, other) == 0;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Extracts the first rune in the slice into `rune`, advancing the&#13;
     *      slice to point to the next rune and returning `self`.&#13;
     * @param self The slice to operate on.&#13;
     * @param rune The slice that will contain the first rune.&#13;
     * @return `rune`.&#13;
     */&#13;
    function nextRune(slice self, slice rune) internal pure returns (slice) {&#13;
        rune._ptr = self._ptr;&#13;
&#13;
        if (self._len == 0) {&#13;
            rune._len = 0;&#13;
            return rune;&#13;
        }&#13;
&#13;
        uint l;&#13;
        uint b;&#13;
        // Load the first byte of the rune into the LSBs of b&#13;
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }&#13;
        if (b &lt; 0x80) {&#13;
            l = 1;&#13;
        } else if(b &lt; 0xE0) {&#13;
            l = 2;&#13;
        } else if(b &lt; 0xF0) {&#13;
            l = 3;&#13;
        } else {&#13;
            l = 4;&#13;
        }&#13;
&#13;
        // Check for truncated codepoints&#13;
        if (l &gt; self._len) {&#13;
            rune._len = self._len;&#13;
            self._ptr += self._len;&#13;
            self._len = 0;&#13;
            return rune;&#13;
        }&#13;
&#13;
        self._ptr += l;&#13;
        self._len -= l;&#13;
        rune._len = l;&#13;
        return rune;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the first rune in the slice, advancing the slice to point&#13;
     *      to the next rune.&#13;
     * @param self The slice to operate on.&#13;
     * @return A slice containing only the first rune from `self`.&#13;
     */&#13;
    function nextRune(slice self) internal pure returns (slice ret) {&#13;
        nextRune(self, ret);&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the number of the first codepoint in the slice.&#13;
     * @param self The slice to operate on.&#13;
     * @return The number of the first codepoint in the slice.&#13;
     */&#13;
    function ord(slice self) internal pure returns (uint ret) {&#13;
        if (self._len == 0) {&#13;
            return 0;&#13;
        }&#13;
&#13;
        uint word;&#13;
        uint length;&#13;
        uint divisor = 2 ** 248;&#13;
&#13;
        // Load the rune into the MSBs of b&#13;
        assembly { word:= mload(mload(add(self, 32))) }&#13;
        uint b = word / divisor;&#13;
        if (b &lt; 0x80) {&#13;
            ret = b;&#13;
            length = 1;&#13;
        } else if(b &lt; 0xE0) {&#13;
            ret = b &amp; 0x1F;&#13;
            length = 2;&#13;
        } else if(b &lt; 0xF0) {&#13;
            ret = b &amp; 0x0F;&#13;
            length = 3;&#13;
        } else {&#13;
            ret = b &amp; 0x07;&#13;
            length = 4;&#13;
        }&#13;
&#13;
        // Check for truncated codepoints&#13;
        if (length &gt; self._len) {&#13;
            return 0;&#13;
        }&#13;
&#13;
        for (uint i = 1; i &lt; length; i++) {&#13;
            divisor = divisor / 256;&#13;
            b = (word / divisor) &amp; 0xFF;&#13;
            if (b &amp; 0xC0 != 0x80) {&#13;
                // Invalid UTF-8 sequence&#13;
                return 0;&#13;
            }&#13;
            ret = (ret * 64) | (b &amp; 0x3F);&#13;
        }&#13;
&#13;
        return ret;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns the keccak-256 hash of the slice.&#13;
     * @param self The slice to hash.&#13;
     * @return The hash of the slice.&#13;
     */&#13;
    function keccak(slice self) internal pure returns (bytes32 ret) {&#13;
        assembly {&#13;
            ret := keccak256(mload(add(self, 32)), mload(self))&#13;
        }&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns true if `self` starts with `needle`.&#13;
     * @param self The slice to operate on.&#13;
     * @param needle The slice to search for.&#13;
     * @return True if the slice starts with the provided text, false otherwise.&#13;
     */&#13;
    function startsWith(slice self, slice needle) internal pure returns (bool) {&#13;
        if (self._len &lt; needle._len) {&#13;
            return false;&#13;
        }&#13;
&#13;
        if (self._ptr == needle._ptr) {&#13;
            return true;&#13;
        }&#13;
&#13;
        bool equal;&#13;
        assembly {&#13;
            let length := mload(needle)&#13;
            let selfptr := mload(add(self, 0x20))&#13;
            let needleptr := mload(add(needle, 0x20))&#13;
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))&#13;
        }&#13;
        return equal;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev If `self` starts with `needle`, `needle` is removed from the&#13;
     *      beginning of `self`. Otherwise, `self` is unmodified.&#13;
     * @param self The slice to operate on.&#13;
     * @param needle The slice to search for.&#13;
     * @return `self`&#13;
     */&#13;
    function beyond(slice self, slice needle) internal pure returns (slice) {&#13;
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
    /*&#13;
     * @dev Returns true if the slice ends with `needle`.&#13;
     * @param self The slice to operate on.&#13;
     * @param needle The slice to search for.&#13;
     * @return True if the slice starts with the provided text, false otherwise.&#13;
     */&#13;
    function endsWith(slice self, slice needle) internal pure returns (bool) {&#13;
        if (self._len &lt; needle._len) {&#13;
            return false;&#13;
        }&#13;
&#13;
        uint selfptr = self._ptr + self._len - needle._len;&#13;
&#13;
        if (selfptr == needle._ptr) {&#13;
            return true;&#13;
        }&#13;
&#13;
        bool equal;&#13;
        assembly {&#13;
            let length := mload(needle)&#13;
            let needleptr := mload(add(needle, 0x20))&#13;
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))&#13;
        }&#13;
&#13;
        return equal;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev If `self` ends with `needle`, `needle` is removed from the&#13;
     *      end of `self`. Otherwise, `self` is unmodified.&#13;
     * @param self The slice to operate on.&#13;
     * @param needle The slice to search for.&#13;
     * @return `self`&#13;
     */&#13;
    function until(slice self, slice needle) internal pure returns (slice) {&#13;
        if (self._len &lt; needle._len) {&#13;
            return self;&#13;
        }&#13;
&#13;
        uint selfptr = self._ptr + self._len - needle._len;&#13;
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
    event log_bytemask(bytes32 mask);&#13;
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
    // Returns the memory address of the first byte after the last occurrence of&#13;
    // `needle` in `self`, or the address of `self` if not found.&#13;
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {&#13;
        uint ptr;&#13;
&#13;
        if (needlelen &lt;= selflen) {&#13;
            if (needlelen &lt;= 32) {&#13;
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));&#13;
&#13;
                bytes32 needledata;&#13;
                assembly { needledata := and(mload(needleptr), mask) }&#13;
&#13;
                ptr = selfptr + selflen - needlelen;&#13;
                bytes32 ptrdata;&#13;
                assembly { ptrdata := and(mload(ptr), mask) }&#13;
&#13;
                while (ptrdata != needledata) {&#13;
                    if (ptr &lt;= selfptr)&#13;
                        return selfptr;&#13;
                    ptr--;&#13;
                    assembly { ptrdata := and(mload(ptr), mask) }&#13;
                }&#13;
                return ptr + needlelen;&#13;
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
    /*&#13;
     * @dev Modifies `self` to contain everything from the first occurrence of&#13;
     *      `needle` to the end of the slice. `self` is set to the empty slice&#13;
     *      if `needle` is not found.&#13;
     * @param self The slice to search and modify.&#13;
     * @param needle The text to search for.&#13;
     * @return `self`.&#13;
     */&#13;
    function find(slice self, slice needle) internal pure returns (slice) {&#13;
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);&#13;
        self._len -= ptr - self._ptr;&#13;
        self._ptr = ptr;&#13;
        return self;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Modifies `self` to contain the part of the string from the start of&#13;
     *      `self` to the end of the first occurrence of `needle`. If `needle`&#13;
     *      is not found, `self` is set to the empty slice.&#13;
     * @param self The slice to search and modify.&#13;
     * @param needle The text to search for.&#13;
     * @return `self`.&#13;
     */&#13;
    function rfind(slice self, slice needle) internal pure returns (slice) {&#13;
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);&#13;
        self._len = ptr - self._ptr;&#13;
        return self;&#13;
    }&#13;
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
     * @dev Splits the slice, setting `self` to everything before the last&#13;
     *      occurrence of `needle`, and `token` to everything after it. If&#13;
     *      `needle` does not occur in `self`, `self` is set to the empty slice,&#13;
     *      and `token` is set to the entirety of `self`.&#13;
     * @param self The slice to split.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @param token An output parameter to which the first token is written.&#13;
     * @return `token`.&#13;
     */&#13;
    function rsplit(slice self, slice needle, slice token) internal pure returns (slice) {&#13;
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);&#13;
        token._ptr = ptr;&#13;
        token._len = self._len - (ptr - self._ptr);&#13;
        if (ptr == self._ptr) {&#13;
            // Not found&#13;
            self._len = 0;&#13;
        } else {&#13;
            self._len -= token._len + needle._len;&#13;
        }&#13;
        return token;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Splits the slice, setting `self` to everything before the last&#13;
     *      occurrence of `needle`, and returning everything after it. If&#13;
     *      `needle` does not occur in `self`, `self` is set to the empty slice,&#13;
     *      and the entirety of `self` is returned.&#13;
     * @param self The slice to split.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @return The part of `self` after the last occurrence of `delim`.&#13;
     */&#13;
    function rsplit(slice self, slice needle) internal pure returns (slice token) {&#13;
        rsplit(self, needle, token);&#13;
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
    /*&#13;
     * @dev Returns True if `self` contains `needle`.&#13;
     * @param self The slice to search.&#13;
     * @param needle The text to search for in `self`.&#13;
     * @return True if `needle` is found in `self`, false otherwise.&#13;
     */&#13;
    function contains(slice self, slice needle) internal pure returns (bool) {&#13;
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Returns a newly allocated string containing the concatenation of&#13;
     *      `self` and `other`.&#13;
     * @param self The first slice to concatenate.&#13;
     * @param other The second slice to concatenate.&#13;
     * @return The concatenation of the two strings.&#13;
     */&#13;
    function concat(slice self, slice other) internal pure returns (string) {&#13;
        string memory ret = new string(self._len + other._len);&#13;
        uint retptr;&#13;
        assembly { retptr := add(ret, 32) }&#13;
        memcpy(retptr, self._ptr, self._len);&#13;
        memcpy(retptr + self._len, other._ptr, other._len);&#13;
        return ret;&#13;
    }&#13;
&#13;
    /*&#13;
     * @dev Joins an array of slices, using `self` as a delimiter, returning a&#13;
     *      newly allocated string.&#13;
     * @param self The delimiter to use.&#13;
     * @param parts A list of slices to join.&#13;
     * @return A newly allocated string containing all the slices in `parts`,&#13;
     *         joined with `self`.&#13;
     */&#13;
    function join(slice self, slice[] parts) internal pure returns (string) {&#13;
        if (parts.length == 0)&#13;
            return "";&#13;
&#13;
        uint length = self._len * (parts.length - 1);&#13;
        for(uint i = 0; i &lt; parts.length; i++)&#13;
            length += parts[i]._len;&#13;
&#13;
        string memory ret = new string(length);&#13;
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
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
    uint256 c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
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
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  function Ownable() public{&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) onlyOwner public{&#13;
    if (newOwner != address(0)) {&#13;
      owner = newOwner;&#13;
    }&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 */&#13;
contract Pausable is Ownable {&#13;
  event Pause();&#13;
  event Unpause();&#13;
&#13;
  bool public paused = false;&#13;
&#13;
&#13;
  /**&#13;
   * @dev modifier to allow actions only when the contract IS paused&#13;
   */&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev modifier to allow actions only when the contract IS NOT paused&#13;
   */&#13;
  modifier whenPaused {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to pause, triggers stopped state&#13;
   */&#13;
  function pause() onlyOwner whenNotPaused public returns (bool) {&#13;
    paused = true;&#13;
    emit Pause();&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyOwner whenPaused public returns (bool) {&#13;
    paused = false;&#13;
    emit Unpause();&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Config is Pausable {&#13;
    // 配置信息&#13;
    uint public taxRate;     &#13;
    uint gasForOraclize;&#13;
    uint systemGasForOraclize; &#13;
    uint256 public minStake;&#13;
    uint256 public maxStake;&#13;
    uint256 public maxWin;&#13;
    uint256 public normalRoomMin;&#13;
    uint256 public normalRoomMax;&#13;
    uint256 public tripleRoomMin;&#13;
    uint256 public tripleRoomMax;&#13;
    uint referrelFund;&#13;
    string random_api_key;&#13;
    uint public minSet;&#13;
    uint public maxSet;&#13;
&#13;
    function Config() public{&#13;
        setOraGasLimit(235000);         &#13;
        setSystemOraGasLimit(120000);   &#13;
        setMinStake(0.1 ether);&#13;
        setMaxStake(10 ether);&#13;
        setMaxWin(10 ether); &#13;
        taxRate = 20;&#13;
        setNormalRoomMin(0.1 ether);&#13;
        setNormalRoomMax(1 ether);&#13;
        setTripleRoomMin(1 ether);&#13;
        setTripleRoomMax(10 ether);&#13;
        setRandomApiKey("50faa373-68a1-40ce-8da8-4523db62d42a");&#13;
        setMinSet(3);&#13;
        setMaxSet(10);&#13;
        referrelFund = 10;&#13;
    }&#13;
&#13;
    function setRandomApiKey(string value) public onlyOwner {        &#13;
        random_api_key = value;&#13;
    }           &#13;
&#13;
    function setOraGasLimit(uint gasLimit) public onlyOwner {&#13;
        if(gasLimit == 0){&#13;
            return;&#13;
        }&#13;
        gasForOraclize = gasLimit;&#13;
    }&#13;
&#13;
    function setSystemOraGasLimit(uint gasLimit) public onlyOwner {&#13;
        if(gasLimit == 0){&#13;
            return;&#13;
        }&#13;
        systemGasForOraclize = gasLimit;&#13;
    }       &#13;
    &#13;
&#13;
    function setMinStake(uint256 value) public onlyOwner{&#13;
        if(value == 0){&#13;
            return;&#13;
        }&#13;
        minStake = value;&#13;
    }&#13;
&#13;
    function setMaxStake(uint256 value) public onlyOwner{&#13;
        if(value == 0){&#13;
            return;&#13;
        }&#13;
        maxStake = value;&#13;
    }&#13;
&#13;
    function setMinSet(uint value) public onlyOwner{&#13;
        if(value == 0){&#13;
            return;&#13;
        }&#13;
        minSet = value;&#13;
    }&#13;
&#13;
    function setMaxSet(uint value) public onlyOwner{&#13;
        if(value == 0){&#13;
            return;&#13;
        }&#13;
        maxSet = value;&#13;
    }&#13;
&#13;
    function setMaxWin(uint256 value) public onlyOwner{&#13;
        if(value == 0){&#13;
            return;&#13;
        }&#13;
        maxWin = value;&#13;
    }&#13;
&#13;
    function setNormalRoomMax(uint256 value) public onlyOwner{&#13;
        if(value == 0){&#13;
            return;&#13;
        }&#13;
        normalRoomMax = value;&#13;
    }&#13;
&#13;
    function setNormalRoomMin(uint256 value) public onlyOwner{&#13;
        if(value == 0){&#13;
            return;&#13;
        }&#13;
        normalRoomMin = value;&#13;
    }&#13;
&#13;
    function setTripleRoomMax(uint256 value) public onlyOwner{&#13;
        if(value == 0){&#13;
            return;&#13;
        }&#13;
        tripleRoomMax = value;&#13;
    }&#13;
&#13;
    function setTripleRoomMin(uint256 value) public onlyOwner{&#13;
        if(value == 0){&#13;
            return;&#13;
        }&#13;
        tripleRoomMin = value;&#13;
    }&#13;
&#13;
    function setTaxRate(uint value) public onlyOwner{&#13;
        if(value == 0 || value &gt;= 1000){&#13;
            return;&#13;
        }&#13;
        taxRate = value;&#13;
    }&#13;
&#13;
    function setReferralFund(uint value) public onlyOwner{&#13;
        if(value == 0 || value &gt;= 1000){&#13;
            return;&#13;
        }&#13;
        referrelFund = value;&#13;
    }  &#13;
}&#13;
&#13;
contract UserManager {    &#13;
    struct UserInfo {         &#13;
        uint256 playAmount;&#13;
        uint playCount;&#13;
        uint openRoomCount;&#13;
        uint256 winAmount;&#13;
        address referral;       &#13;
    }&#13;
   &#13;
    mapping (address =&gt; UserInfo) allUsers;&#13;
    &#13;
    &#13;
    function UserManager() public{        &#13;
    }    &#13;
&#13;
    function addBet (address player,uint256 value) internal {        &#13;
        allUsers[player].playCount++;&#13;
        allUsers[player].playAmount += value;&#13;
    }&#13;
&#13;
    function addWin (address player,uint256 value) internal {            &#13;
        allUsers[player].winAmount += value;&#13;
    }&#13;
    &#13;
    function addOpenRoomCount (address player) internal {&#13;
       allUsers[player].openRoomCount ++;&#13;
    }&#13;
&#13;
    function subOpenRoomCount (address player) internal {          &#13;
        if(allUsers[player].openRoomCount &gt; 0){&#13;
            allUsers[player].openRoomCount--;&#13;
        }&#13;
    }&#13;
&#13;
    function setReferral (address player,address referral) internal { &#13;
        if(referral == 0)&#13;
            return;&#13;
        if(allUsers[player].referral == 0 &amp;&amp; referral != player){&#13;
            allUsers[player].referral = referral;&#13;
        }&#13;
    }&#13;
    &#13;
    function getPlayedInfo (address player) public view returns(uint playedCount,uint openRoomCount,&#13;
        uint256 playAmount,uint256 winAmount) {&#13;
        playedCount = allUsers[player].playCount;&#13;
        openRoomCount = allUsers[player].openRoomCount;&#13;
        playAmount = allUsers[player].playAmount;&#13;
        winAmount = allUsers[player].winAmount;&#13;
    }&#13;
    &#13;
&#13;
    function fundReferrel(address player,uint256 value) internal {&#13;
        if(allUsers[player].referral != 0){&#13;
            allUsers[player].referral.transfer(value);&#13;
        }&#13;
    }    &#13;
}&#13;
&#13;
/**&#13;
 * The contractName contract does this and that...&#13;
 */&#13;
contract RoomManager {  &#13;
    uint constant roomFree = 0;&#13;
    uint constant roomPending = 1;&#13;
    uint constant roomEnded = 2;&#13;
&#13;
    struct RoomInfo{&#13;
        uint roomid;&#13;
        address owner;&#13;
        uint setCount;  // 0 if not a tripple room&#13;
        uint256 balance;&#13;
        uint status;&#13;
        uint currentSet;&#13;
        uint256 initBalance;&#13;
        uint roomData;  // owner choose big(1) ozr small(0)&#13;
        address lastPlayer;&#13;
        uint256 lastBet;&#13;
    }&#13;
&#13;
    uint[] roomIDList;&#13;
&#13;
    mapping (uint =&gt; RoomInfo) roomMapping;   &#13;
&#13;
    uint _roomindex;&#13;
&#13;
    event evt_calculate(address indexed player,address owner,uint num123,int256 winAmount,uint roomid,uint256 playTime,bytes32 serialNumber);&#13;
    event evt_gameRecord(address indexed player,uint256 betAmount,int256 winAmount,uint playTypeAndData,uint256 time,uint num123,address owner,uint setCountAndEndSet,uint256 roomInitBalance);&#13;
    &#13;
&#13;
    function RoomManager ()  public {       &#13;
        _roomindex = 1; // 0 is invalid roomid       &#13;
    }&#13;
    &#13;
    function getResult(uint num123) internal pure returns(uint){&#13;
        uint num1 = num123 / 100;&#13;
        uint num2 = (num123 % 100) / 10;&#13;
        uint num3 = num123 % 10;&#13;
        if(num1 + num2 + num3 &gt; 10){&#13;
            return 1;&#13;
        }&#13;
        return 0;&#13;
    }&#13;
    &#13;
    function isTripleNumber(uint num123) internal pure returns(bool){&#13;
        uint num1 = num123 / 100;&#13;
        uint num2 = (num123 % 100) / 10;&#13;
        uint num3 = num123 % 10;&#13;
        return (num1 == num2 &amp;&amp; num1 == num3);&#13;
    }&#13;
&#13;
    &#13;
    function tryOpenRoom(address owner,uint256 value,uint setCount,uint roomData) internal returns(uint roomID){&#13;
        roomID = _roomindex;&#13;
        roomMapping[_roomindex].owner = owner;&#13;
        roomMapping[_roomindex].initBalance = value;&#13;
        roomMapping[_roomindex].balance = value;&#13;
        roomMapping[_roomindex].setCount = setCount;&#13;
        roomMapping[_roomindex].roomData = roomData;&#13;
        roomMapping[_roomindex].roomid = _roomindex;&#13;
        roomMapping[_roomindex].status = roomFree;&#13;
        roomIDList.push(_roomindex);&#13;
        _roomindex++;&#13;
        if(_roomindex == 0){&#13;
            _roomindex = 1;&#13;
        }      &#13;
    }&#13;
&#13;
    function tryCloseRoom(address owner,uint roomid,uint taxrate) internal returns(bool ret,bool taxPayed)  {&#13;
        // find the room        &#13;
        ret = false;&#13;
        taxPayed = false;&#13;
        if(roomMapping[roomid].roomid == 0){&#13;
            return;&#13;
        }       &#13;
        RoomInfo memory room = roomMapping[roomid];&#13;
        // is the owner?&#13;
        if(room.owner != owner){&#13;
            return;&#13;
        }&#13;
        // 能不能解散&#13;
        if(room.status == roomPending){&#13;
            return;&#13;
        }&#13;
        ret = true;&#13;
        // return &#13;
        // need to pay tax?&#13;
        if(room.balance &gt; room.initBalance){&#13;
            uint256 tax = SafeMath.div(SafeMath.mul(room.balance,taxrate),1000);            &#13;
            room.balance -= tax;&#13;
            taxPayed = true;&#13;
        }&#13;
        room.owner.transfer(room.balance);&#13;
        deleteRoomByRoomID(roomid);&#13;
        return;&#13;
    }&#13;
&#13;
    function tryDismissRoom(uint roomid) internal {&#13;
        // find the room        &#13;
        if(roomMapping[roomid].roomid == 0){&#13;
            return;&#13;
        }    &#13;
&#13;
        RoomInfo memory room = roomMapping[roomid];&#13;
        &#13;
        if(room.lastPlayer == 0){&#13;
            room.owner.transfer(room.balance);&#13;
            deleteRoomByRoomID(roomid);&#13;
            return;&#13;
        }&#13;
        room.lastPlayer.transfer(room.lastBet);&#13;
        room.owner.transfer(SafeMath.sub(room.balance,room.lastBet));&#13;
        deleteRoomByRoomID(roomid);&#13;
    }   &#13;
&#13;
    // just check if can be rolled and update balance,not calculate here&#13;
    function tryRollRoom(address user,uint256 value,uint roomid) internal returns(bool)  {&#13;
        if(value &lt;= 0){&#13;
            return false;&#13;
        }&#13;
&#13;
        if(roomMapping[roomid].roomid == 0){&#13;
            return false;&#13;
        }&#13;
&#13;
        RoomInfo storage room = roomMapping[roomid];&#13;
&#13;
        if(room.status != roomFree || room.balance == 0){&#13;
            return false;&#13;
        }&#13;
&#13;
        uint256 betValue = getBetValue(room.initBalance,room.balance,room.setCount);&#13;
&#13;
        // if value less&#13;
        if (value &lt; betValue){&#13;
            return false;&#13;
        }&#13;
        if(value &gt; betValue){&#13;
            user.transfer(value - betValue);&#13;
            value = betValue;&#13;
        }&#13;
        // add to room balance&#13;
        room.balance += value;&#13;
        room.lastPlayer = user;&#13;
        room.lastBet = value;&#13;
        room.status = roomPending;&#13;
        return true;&#13;
    }&#13;
&#13;
    // do the calculation&#13;
    // returns : success,isend,winer,tax&#13;
    function calculateRoom(uint roomid,uint num123,uint taxrate,bytes32 myid) internal returns(bool success,&#13;
        bool isend,address winer,uint256 tax) {&#13;
        success = false;        &#13;
        tax = 0;&#13;
        if(roomMapping[roomid].roomid == 0){&#13;
            return;&#13;
        }&#13;
&#13;
        RoomInfo memory room = roomMapping[roomid];&#13;
        if(room.status != roomPending || room.balance == 0){            &#13;
            return;&#13;
        }&#13;
&#13;
        // ok&#13;
        success = true;        &#13;
        // simple room&#13;
        if(room.setCount == 0){&#13;
            isend = true;&#13;
            (winer,tax) = calSimpleRoom(roomid,taxrate,num123,myid);            &#13;
            return;&#13;
        }&#13;
&#13;
        (winer,tax,isend) = calTripleRoom(roomid,taxrate,num123,myid);&#13;
    }&#13;
&#13;
    function calSimpleRoom(uint roomid,uint taxrate,uint num123,bytes32 myid) internal returns(address winer,uint256 tax) { &#13;
        RoomInfo storage room = roomMapping[roomid];&#13;
        uint result = getResult(num123);&#13;
        tax = SafeMath.div(SafeMath.mul(room.balance,taxrate),1000);&#13;
        room.balance -= tax; &#13;
        int256 winamount = -int256(room.lastBet);&#13;
        if(room.roomData == result){&#13;
            // owner win                &#13;
            winer = room.owner;&#13;
            winamount += int256(tax);&#13;
        } else {&#13;
            // player win               &#13;
            winer = room.lastPlayer;&#13;
            winamount = int256(room.balance - room.initBalance);&#13;
        }&#13;
        room.status = roomEnded;            &#13;
        winer.transfer(room.balance);       &#13;
        &#13;
        emit evt_calculate(room.lastPlayer,room.owner,num123,winamount,room.roomid,now,myid);&#13;
        emit evt_gameRecord(room.lastPlayer,room.lastBet,winamount,10 + room.roomData,now,num123,room.owner,0,room.initBalance);&#13;
        deleteRoomByRoomID(roomid);&#13;
    }&#13;
&#13;
    function calTripleRoom(uint roomid,uint taxrate,uint num123,bytes32 myid) internal &#13;
        returns(address winer,uint256 tax,bool isend) { &#13;
        RoomInfo storage room = roomMapping[roomid];       &#13;
        // triple room&#13;
        room.currentSet++;&#13;
        int256 winamount = -int256(room.lastBet);&#13;
        bool isTriple = isTripleNumber(num123);&#13;
        isend = room.currentSet &gt;= room.setCount || isTriple;&#13;
        if(isend){&#13;
            tax = SafeMath.div(SafeMath.mul(room.balance,taxrate),1000);&#13;
            room.balance -= tax; &#13;
            if(isTriple){   &#13;
                // player win&#13;
                winer = room.lastPlayer;&#13;
                winamount = int256(room.balance - room.lastBet);&#13;
            } else {&#13;
                // owner win&#13;
                winer = room.owner;&#13;
            }&#13;
            room.status = roomEnded;&#13;
            winer.transfer(room.balance);       &#13;
            &#13;
            room.balance = 0;            &#13;
            emit evt_calculate(room.lastPlayer,room.owner,num123,winamount,room.roomid,now,myid);&#13;
            emit evt_gameRecord(room.lastPlayer,room.lastBet,winamount,10,now,num123,room.owner,room.setCount * 100 + room.currentSet,room.initBalance);&#13;
            deleteRoomByRoomID(roomid);&#13;
        } else {&#13;
            room.status = roomFree;&#13;
            emit evt_gameRecord(room.lastPlayer,room.lastBet,winamount,10,now,num123,room.owner,room.setCount * 100 + room.currentSet,room.initBalance);&#13;
            emit evt_calculate(room.lastPlayer,room.owner,num123,winamount,room.roomid,now,myid);&#13;
        }&#13;
    }&#13;
    &#13;
&#13;
    function getBetValue(uint256 initBalance,uint256 curBalance,uint setCount) public pure returns(uint256) {&#13;
        // normal&#13;
        if(setCount == 0){&#13;
            return initBalance;&#13;
        }&#13;
&#13;
        // tripple&#13;
        return SafeMath.div(curBalance,setCount);&#13;
    }   &#13;
&#13;
    function deleteRoomByRoomID (uint roomID) internal {&#13;
        delete roomMapping[roomID];&#13;
        uint len = roomIDList.length;&#13;
        for(uint i = 0;i &lt; len;i++){&#13;
            if(roomIDList[i] == roomID){&#13;
                roomIDList[i] = roomIDList[len - 1];&#13;
                roomIDList.length--;&#13;
                return;&#13;
            }&#13;
        }        &#13;
    }&#13;
&#13;
    function deleteRoomByIndex (uint index) internal {    &#13;
        uint len = roomIDList.length;&#13;
        if(index &gt; len - 1){&#13;
            return;&#13;
        }&#13;
        delete roomMapping[roomIDList[index]];&#13;
        roomIDList[index] = roomIDList[len - 1];   &#13;
        roomIDList.length--;&#13;
    }&#13;
&#13;
    function getAllBalance() public view returns(uint256) {&#13;
        uint256 ret = 0;&#13;
        for(uint i = 0;i &lt; roomIDList.length;i++){&#13;
            ret += roomMapping[roomIDList[i]].balance;&#13;
        }&#13;
        return ret;&#13;
    }&#13;
    &#13;
    function returnAllRoomsBalance() internal {&#13;
        for(uint i = 0;i &lt; roomIDList.length;i++){            &#13;
            if(roomMapping[roomIDList[i]].balance &gt; 0){&#13;
                roomMapping[roomIDList[i]].owner.transfer(roomMapping[roomIDList[i]].balance);&#13;
                roomMapping[roomIDList[i]].balance = 0;&#13;
                roomMapping[roomIDList[i]].status = roomEnded;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function removeFreeRoom() internal {&#13;
        for(uint i = 0;i &lt; roomIDList.length;i++){&#13;
            if(roomMapping[roomIDList[i]].balance ==0 &amp;&amp; roomMapping[roomIDList[i]].status == roomEnded){&#13;
                deleteRoomByIndex(i);&#13;
                removeFreeRoom();&#13;
                return;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function getRoomCount() public view returns(uint) {&#13;
        return roomIDList.length;&#13;
    }&#13;
&#13;
    function getRoomID(uint index) public view returns(uint)  {&#13;
        if(index &gt; roomIDList.length){&#13;
            return 0;&#13;
        }&#13;
        return roomIDList[index];&#13;
    } &#13;
&#13;
    function getRoomInfo(uint index) public view &#13;
        returns(uint roomID,address owner,uint setCount,&#13;
            uint256 balance,uint status,uint curSet,uint data) {&#13;
        if(index &gt; roomIDList.length){&#13;
            return;&#13;
        }&#13;
        roomID = roomMapping[roomIDList[index]].roomid;&#13;
        owner = roomMapping[roomIDList[index]].owner;&#13;
        setCount = roomMapping[roomIDList[index]].setCount;&#13;
        balance = roomMapping[roomIDList[index]].balance;&#13;
        status = roomMapping[roomIDList[index]].status;&#13;
        curSet = roomMapping[roomIDList[index]].currentSet;&#13;
        data = roomMapping[roomIDList[index]].roomData;&#13;
    }    &#13;
}&#13;
&#13;
contract DiceOffline is Config,RoomManager,UserManager {&#13;
    // 事件&#13;
    event withdraw_failed();&#13;
    event withdraw_succeeded(address toUser,uint256 value);    &#13;
    event bet_failed(address indexed player,uint256 value,uint result,uint roomid,uint errorcode);&#13;
    event bet_succeeded(address indexed player,uint256 value,uint result,uint roomid,bytes32 serialNumber);    &#13;
    event evt_createRoomFailed(address indexed player);&#13;
    event evt_createRoomSucceeded(address indexed player,uint roomid);&#13;
    event evt_closeRoomFailed(address indexed player,uint roomid);&#13;
    event evt_closeRoomSucceeded(address indexed player,uint roomid);&#13;
&#13;
    // 下注信息&#13;
    struct BetInfo{&#13;
        address player;&#13;
        uint result;&#13;
        uint256 value;  &#13;
        uint roomid;       &#13;
    }&#13;
&#13;
    mapping (bytes32 =&gt; BetInfo) rollingBet;&#13;
    uint256 public allWagered;&#13;
    uint256 public allWon;&#13;
    uint    public allPlayCount;&#13;
&#13;
    function DiceOffline() public{        &#13;
    }  &#13;
   &#13;
    &#13;
    // 销毁合约&#13;
    function destroy() onlyOwner public{     &#13;
        returnAllRoomsBalance();&#13;
        selfdestruct(owner);&#13;
    }&#13;
&#13;
    // 充值&#13;
    function () public payable {        &#13;
    }&#13;
&#13;
    // 提现&#13;
    function withdraw(uint256 value) public onlyOwner{&#13;
        if(getAvailableBalance() &lt; value){&#13;
            emit withdraw_failed();&#13;
            return;&#13;
        }&#13;
        owner.transfer(value);  &#13;
        emit withdraw_succeeded(owner,value);&#13;
    }&#13;
&#13;
    // 获取可提现额度&#13;
    function getAvailableBalance() public view returns (uint256){&#13;
        return SafeMath.sub(getBalance(),getAllBalance());&#13;
    }&#13;
&#13;
    function rollSystem (uint result,address referral) public payable returns(bool) {&#13;
        if(msg.value == 0){&#13;
            return;&#13;
        }&#13;
        BetInfo memory bet = BetInfo(msg.sender,result,msg.value,0);&#13;
       &#13;
        if(bet.value &lt; minStake){&#13;
            bet.player.transfer(bet.value);&#13;
            emit bet_failed(bet.player,bet.value,result,0,0);&#13;
            return false;&#13;
        }&#13;
&#13;
        uint256 maxBet = getAvailableBalance() / 10;&#13;
        if(maxBet &gt; maxStake){&#13;
            maxBet = maxStake;&#13;
        }&#13;
&#13;
        if(bet.value &gt; maxBet){&#13;
            bet.player.transfer(SafeMath.sub(bet.value,maxBet));&#13;
            bet.value = maxBet;&#13;
        }&#13;
      &#13;
        allWagered += bet.value;&#13;
        allPlayCount++;&#13;
&#13;
        addBet(msg.sender,bet.value);&#13;
        setReferral(msg.sender,referral);        &#13;
        // 生成随机数&#13;
        bytes32 serialNumber = doOraclize(true);&#13;
        rollingBet[serialNumber] = bet;&#13;
        emit bet_succeeded(bet.player,bet.value,result,0,serialNumber);        &#13;
        return true;&#13;
    }   &#13;
&#13;
    // 如果setCount为0，表示大小&#13;
    function openRoom(uint setCount,uint roomData,address referral) public payable returns(bool) {&#13;
        if(setCount &gt; 0 &amp;&amp; (setCount &gt; maxSet || setCount &lt; minSet)){&#13;
            emit evt_createRoomFailed(msg.sender);&#13;
            msg.sender.transfer(msg.value);&#13;
            return false;&#13;
        }&#13;
        uint256 minValue = normalRoomMin;&#13;
        uint256 maxValue = normalRoomMax;&#13;
        if(setCount &gt; 0){&#13;
            minValue = tripleRoomMin;&#13;
            maxValue = tripleRoomMax;&#13;
        }&#13;
&#13;
        if(msg.value &lt; minValue || msg.value &gt; maxValue){&#13;
            emit evt_createRoomFailed(msg.sender);&#13;
            msg.sender.transfer(msg.value);&#13;
            return false;&#13;
        }&#13;
&#13;
        allWagered += msg.value;&#13;
&#13;
        uint roomid = tryOpenRoom(msg.sender,msg.value,setCount,roomData);&#13;
        setReferral(msg.sender,referral);&#13;
        addOpenRoomCount(msg.sender);&#13;
&#13;
        emit evt_createRoomSucceeded(msg.sender,roomid); &#13;
    }&#13;
&#13;
    function closeRoom(uint roomid) public returns(bool) {        &#13;
        bool ret = false;&#13;
        bool taxPayed = false;        &#13;
        (ret,taxPayed) = tryCloseRoom(msg.sender,roomid,taxRate);&#13;
        if(!ret){&#13;
            emit evt_closeRoomFailed(msg.sender,roomid);&#13;
            return false;&#13;
        }&#13;
        &#13;
        emit evt_closeRoomSucceeded(msg.sender,roomid);&#13;
&#13;
        if(!taxPayed){&#13;
            subOpenRoomCount(msg.sender);&#13;
        }&#13;
        &#13;
        return true;&#13;
    }    &#13;
&#13;
    function rollRoom(uint roomid,address referral) public payable returns(bool) {&#13;
        bool ret = tryRollRoom(msg.sender,msg.value,roomid);&#13;
        if(!ret){&#13;
            emit bet_failed(msg.sender,msg.value,0,roomid,0);&#13;
            msg.sender.transfer(msg.value);&#13;
            return false;&#13;
        }        &#13;
        &#13;
        BetInfo memory bet = BetInfo(msg.sender,0,msg.value,roomid);&#13;
&#13;
        allWagered += bet.value;&#13;
        allPlayCount++;&#13;
       &#13;
        setReferral(msg.sender,referral);&#13;
        addBet(msg.sender,bet.value);&#13;
        // 生成随机数&#13;
        bytes32 serialNumber = doOraclize(false);&#13;
        rollingBet[serialNumber] = bet;&#13;
        emit bet_succeeded(msg.sender,msg.value,0,roomid,serialNumber);       &#13;
        return true;&#13;
    }&#13;
&#13;
    function dismissRoom(uint roomid) public onlyOwner {&#13;
        tryDismissRoom(roomid);&#13;
    } &#13;
&#13;
    function doOraclize(bool isSystem) internal returns(bytes32) {        &#13;
        uint256 random = uint256(keccak256(block.difficulty,now));&#13;
        return bytes32(random);       &#13;
    }&#13;
&#13;
    /*TLSNotary for oraclize call &#13;
    function offlineCallback(bytes32 myid) internal {&#13;
        uint num = uint256(keccak256(block.difficulty,now)) &amp; 216;&#13;
        uint num1 = num % 6 + 1;&#13;
        uint num2 = (num / 6) % 6 + 1;&#13;
        uint num3 = (num / 36) % 6 + 1;&#13;
        doCalculate(num1 * 100 + num2 * 10 + num3,myid);  &#13;
    }*/&#13;
&#13;
    function doCalculate(uint num123,bytes32 myid) internal {&#13;
        BetInfo memory bet = rollingBet[myid];   &#13;
        if(bet.player == 0){            &#13;
            return;&#13;
        }       &#13;
        &#13;
        if(bet.roomid == 0){    // 普通房间&#13;
            // 进行结算&#13;
            int256 winAmount = -int256(bet.value);&#13;
            if(bet.result == getResult(num123)){&#13;
                uint256 tax = (bet.value + bet.value) * taxRate / 1000;                &#13;
                winAmount = int256(bet.value - tax);&#13;
                addWin(bet.player,uint256(winAmount));&#13;
                bet.player.transfer(bet.value + uint256(winAmount));&#13;
                fundReferrel(bet.player,tax * referrelFund / 1000);&#13;
                allWon += uint256(winAmount);&#13;
            }&#13;
            //addGameRecord(bet.player,bet.value,winAmount,bet.result,num123,0x0,0,0);&#13;
            emit evt_calculate(bet.player,0x0,num123,winAmount,0,now,myid);&#13;
            emit evt_gameRecord(bet.player,bet.value,winAmount,bet.result,now,num123,0x0,0,0);&#13;
            delete rollingBet[myid];&#13;
            return;&#13;
        }&#13;
        &#13;
        doCalculateRoom(num123,myid);&#13;
    }&#13;
&#13;
    function doCalculateRoom(uint num123,bytes32 myid) internal {&#13;
        // 多人房间&#13;
        BetInfo memory bet = rollingBet[myid];         &#13;
       &#13;
        bool success;&#13;
        bool isend;&#13;
        address winer;&#13;
        uint256 tax;     &#13;
&#13;
        (success,isend,winer,tax) = calculateRoom(bet.roomid,num123,taxRate,myid);&#13;
        delete rollingBet[myid];&#13;
        if(!success){            &#13;
            return;&#13;
        }&#13;
&#13;
        if(isend){&#13;
            addWin(winer,tax * 1000 / taxRate);&#13;
            fundReferrel(winer,SafeMath.div(SafeMath.mul(tax,referrelFund),1000));            &#13;
        }        &#13;
    }&#13;
  &#13;
    function getBalance() public view returns(uint256){&#13;
        return address(this).balance;&#13;
    }&#13;
}&#13;
&#13;
contract DiceOnline is DiceOffline {    &#13;
    using strings for *;     &#13;
    // 随机序列号&#13;
    uint randomQueryID;   &#13;
    &#13;
    function DiceOnline() public{   &#13;
        oraclizeLib.oraclize_setProof(oraclizeLib.proofType_TLSNotary() | oraclizeLib.proofStorage_IPFS());     &#13;
        oraclizeLib.oraclize_setCustomGasPrice(20000000000 wei);        &#13;
        randomQueryID = 0;&#13;
    }    &#13;
&#13;
    /*&#13;
     * checks only Oraclize address is calling&#13;
    */&#13;
    modifier onlyOraclize {&#13;
        require(msg.sender == oraclizeLib.oraclize_cbAddress());&#13;
        _;&#13;
    }    &#13;
    &#13;
    function doOraclize(bool isSystem) internal returns(bytes32) {&#13;
        randomQueryID += 1;&#13;
        string memory queryString1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":\"";&#13;
        string memory queryString2 = random_api_key;&#13;
        string memory queryString3 = "\",\"n\":3,\"min\":1,\"max\":6},\"id\":";&#13;
        string memory queryString4 = oraclizeLib.uint2str(randomQueryID);&#13;
        string memory queryString5 = "}']";&#13;
&#13;
        string memory queryString1_2 = queryString1.toSlice().concat(queryString2.toSlice());&#13;
        string memory queryString1_2_3 = queryString1_2.toSlice().concat(queryString3.toSlice());&#13;
        string memory queryString1_2_3_4 = queryString1_2_3.toSlice().concat(queryString4.toSlice());&#13;
        string memory queryString1_2_3_4_5 = queryString1_2_3_4.toSlice().concat(queryString5.toSlice());&#13;
        //emit logString(queryString1_2_3_4_5,"queryString");&#13;
        if(isSystem)&#13;
            return oraclizeLib.oraclize_query("nested", queryString1_2_3_4_5,systemGasForOraclize);&#13;
        else&#13;
            return oraclizeLib.oraclize_query("nested", queryString1_2_3_4_5,gasForOraclize);&#13;
    }&#13;
&#13;
    /*TLSNotary for oraclize call */&#13;
    function __callback(bytes32 myid, string result, bytes proof) public onlyOraclize {&#13;
        /* keep oraclize honest by retrieving the serialNumber from random.org result */&#13;
        proof;&#13;
        //emit logString(result,"result");       &#13;
        strings.slice memory sl_result = result.toSlice();&#13;
        sl_result = sl_result.beyond("[".toSlice()).until("]".toSlice());        &#13;
      &#13;
        string memory numString = sl_result.split(', '.toSlice()).toString();&#13;
        uint num1 = oraclizeLib.parseInt(numString);&#13;
        numString = sl_result.split(', '.toSlice()).toString();&#13;
        uint num2 = oraclizeLib.parseInt(numString);&#13;
        numString = sl_result.split(', '.toSlice()).toString();&#13;
        uint num3 = oraclizeLib.parseInt(numString);&#13;
        if(num1 &lt; 1 || num1 &gt; 6){            &#13;
            return;&#13;
        }&#13;
        if(num2 &lt; 1 || num2 &gt; 6){            &#13;
            return;&#13;
        }&#13;
        if(num3 &lt; 1 || num3 &gt; 6){            &#13;
            return;&#13;
        }        &#13;
        doCalculate(num1  * 100 + num2 * 10 + num3,myid);        &#13;
    }    &#13;
}