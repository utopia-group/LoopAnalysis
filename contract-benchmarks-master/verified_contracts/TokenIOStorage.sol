pragma solidity 0.4.24;


/**

COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title Ownable
@dev The Ownable contract has an owner address, and provides basic authorization control
functions, this simplifies the implementation of "user permissions".


 */
contract Ownable {

  mapping(address => bool) public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event AllowOwnership(address indexed allowedAddress);
  event RevokeOwnership(address indexed allowedAddress);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner[msg.sender] = true;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(owner[msg.sender], "Error: Transaction sender is not allowed by the contract.");
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   * @return {"success" : "Returns true when successfully transferred ownership"}
   */
  function transferOwnership(address newOwner) public onlyOwner returns (bool success) {
    require(newOwner != address(0), "Error: newOwner cannot be null!");
    emit OwnershipTransferred(msg.sender, newOwner);
    owner[newOwner] = true;
    owner[msg.sender] = false;
    return true;
  }

  /**
   * @dev Allows interface contracts and accounts to access contract methods (e.g. Storage contract)
   * @param allowedAddress The address of new owner
   * @return {"success" : "Returns true when successfully allowed ownership"}
   */
  function allowOwnership(address allowedAddress) public onlyOwner returns (bool success) {
    owner[allowedAddress] = true;
    emit AllowOwnership(allowedAddress);
    return true;
  }

  /**
   * @dev Disallows interface contracts and accounts to access contract methods (e.g. Storage contract)
   * @param allowedAddress The address to disallow ownership
   * @return {"success" : "Returns true when successfully allowed ownership"}
   */
  function removeOwnership(address allowedAddress) public onlyOwner returns (bool success) {
    owner[allowedAddress] = false;
    emit RevokeOwnership(allowedAddress);
    return true;
  }

}


/**

COPYRIGHT 2018 Token, Inc.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


@title TokenIOStorage - Serves as derived contract for TokenIO contract and
is used to upgrade interfaces in the event of deprecating the main contract.

@author Ryan Tate <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="0d7f746c6323796c79684d7962666863236462">[email protected]</a>&gt;, Sean Pollock &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c6b5a3a7a8e8b6a9aaaaa9a5ad86b2a9ada3a8e8afa9">[email protected]</a>&gt;&#13;
&#13;
@notice Storage contract&#13;
&#13;
@dev In the event that the main contract becomes deprecated, the upgraded contract&#13;
will be set as the owner of this contract, and use this contract's storage to&#13;
maintain data consistency between contract.&#13;
&#13;
@notice NOTE: This contract is based on the RocketPool Storage Contract,&#13;
found here: https://github.com/rocket-pool/rocketpool/blob/master/contracts/RocketStorage.sol&#13;
And this medium article: https://medium.com/rocket-pool/upgradable-solidity-contract-design-54789205276d&#13;
&#13;
Changes:&#13;
 - setting primitive mapping view to internal;&#13;
 - setting method views to public;&#13;
&#13;
 @dev NOTE: When deprecating the main TokenIO contract, the upgraded contract&#13;
 must take ownership of the TokenIO contract, it will require using the public methods&#13;
 to update changes to the underlying data. The updated contract must use a&#13;
 standard call to original TokenIO contract such that the  request is made from&#13;
 the upgraded contract and not the transaction origin (tx.origin) of the signing&#13;
 account.&#13;
&#13;
&#13;
 @dev NOTE: The reasoning for using the storage contract is to abstract the interface&#13;
 from the data of the contract on chain, limiting the need to migrate data to&#13;
 new contracts.&#13;
&#13;
*/&#13;
contract TokenIOStorage is Ownable {&#13;
&#13;
&#13;
    /// @dev mapping for Primitive Data Types;&#13;
		/// @notice primitive data mappings have `internal` view;&#13;
		/// @dev only the derived contract can use the internal methods;&#13;
		/// @dev key == `keccak256(param1, param2...)`&#13;
		/// @dev Nested mapping can be achieved using multiple params in keccak256 hash;&#13;
    mapping(bytes32 =&gt; uint256)    internal uIntStorage;&#13;
    mapping(bytes32 =&gt; string)     internal stringStorage;&#13;
    mapping(bytes32 =&gt; address)    internal addressStorage;&#13;
    mapping(bytes32 =&gt; bytes)      internal bytesStorage;&#13;
    mapping(bytes32 =&gt; bool)       internal boolStorage;&#13;
    mapping(bytes32 =&gt; int256)     internal intStorage;&#13;
&#13;
    constructor() public {&#13;
				/// @notice owner is set to msg.sender by default&#13;
				/// @dev consider removing in favor of setting ownership in inherited&#13;
				/// contract&#13;
        owner[msg.sender] = true;&#13;
    }&#13;
&#13;
    /// @dev Set Key Methods&#13;
&#13;
    /**&#13;
     * @notice Set value for Address associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @param _value The Address value to be set&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function setAddress(bytes32 _key, address _value) public onlyOwner returns (bool success) {&#13;
        addressStorage[_key] = _value;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Set value for Uint associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @param _value The Uint value to be set&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function setUint(bytes32 _key, uint _value) public onlyOwner returns (bool success) {&#13;
        uIntStorage[_key] = _value;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Set value for String associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @param _value The String value to be set&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function setString(bytes32 _key, string _value) public onlyOwner returns (bool success) {&#13;
        stringStorage[_key] = _value;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Set value for Bytes associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @param _value The Bytes value to be set&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function setBytes(bytes32 _key, bytes _value) public onlyOwner returns (bool success) {&#13;
        bytesStorage[_key] = _value;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Set value for Bool associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @param _value The Bool value to be set&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function setBool(bytes32 _key, bool _value) public onlyOwner returns (bool success) {&#13;
        boolStorage[_key] = _value;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Set value for Int associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @param _value The Int value to be set&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function setInt(bytes32 _key, int _value) public onlyOwner returns (bool success) {&#13;
        intStorage[_key] = _value;&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Delete Key Methods&#13;
		/// @dev delete methods may be unnecessary; Use set methods to set values&#13;
		/// to default?&#13;
&#13;
    /**&#13;
     * @notice Delete value for Address associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function deleteAddress(bytes32 _key) public onlyOwner returns (bool success) {&#13;
        delete addressStorage[_key];&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Delete value for Uint associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function deleteUint(bytes32 _key) public onlyOwner returns (bool success) {&#13;
        delete uIntStorage[_key];&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Delete value for String associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function deleteString(bytes32 _key) public onlyOwner returns (bool success) {&#13;
        delete stringStorage[_key];&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Delete value for Bytes associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function deleteBytes(bytes32 _key) public onlyOwner returns (bool success) {&#13;
        delete bytesStorage[_key];&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Delete value for Bool associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function deleteBool(bytes32 _key) public onlyOwner returns (bool success) {&#13;
        delete boolStorage[_key];&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Delete value for Int associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "success" : "Returns true when successfully called from another contract" }&#13;
     */&#13;
    function deleteInt(bytes32 _key) public onlyOwner returns (bool success) {&#13;
        delete intStorage[_key];&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Get Key Methods&#13;
&#13;
    /**&#13;
     * @notice Get value for Address associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "_value" : "Returns the Address value associated with the id key" }&#13;
     */&#13;
    function getAddress(bytes32 _key) public view returns (address _value) {&#13;
        return addressStorage[_key];&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Get value for Uint associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "_value" : "Returns the Uint value associated with the id key" }&#13;
     */&#13;
    function getUint(bytes32 _key) public view returns (uint _value) {&#13;
        return uIntStorage[_key];&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Get value for String associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "_value" : "Returns the String value associated with the id key" }&#13;
     */&#13;
    function getString(bytes32 _key) public view returns (string _value) {&#13;
        return stringStorage[_key];&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Get value for Bytes associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "_value" : "Returns the Bytes value associated with the id key" }&#13;
     */&#13;
    function getBytes(bytes32 _key) public view returns (bytes _value) {&#13;
        return bytesStorage[_key];&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Get value for Bool associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "_value" : "Returns the Bool value associated with the id key" }&#13;
     */&#13;
    function getBool(bytes32 _key) public view returns (bool _value) {&#13;
        return boolStorage[_key];&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Get value for Int associated with bytes32 id key&#13;
     * @param _key Pointer identifier for value in storage&#13;
     * @return { "_value" : "Returns the Int value associated with the id key" }&#13;
     */&#13;
    function getInt(bytes32 _key) public view returns (int _value) {&#13;
        return intStorage[_key];&#13;
    }&#13;
&#13;
}