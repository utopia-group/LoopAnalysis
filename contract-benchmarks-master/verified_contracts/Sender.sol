pragma solidity ^0.4.11;
/*
Token Contract with batch assignments

ERC-20 Token Standar Compliant

Contract developer: Fares A. Akel C.
<span class="__cf_email__" data-cfemail="a8ce86c9c6dcc7c6c1c786c9c3cdc4e8cfc5c9c1c486cbc7c5">[email protected]</span>&#13;
MIT PGP KEY ID: 078E41CB&#13;
*/&#13;
&#13;
 contract token {&#13;
&#13;
 	function transfer(address _to, uint256 _value) returns (bool); &#13;
 &#13;
 }&#13;
&#13;
&#13;
/**&#13;
 * This contract is administered&#13;
 */&#13;
&#13;
contract admined {&#13;
    address public admin; //Admin address is public&#13;
    /**&#13;
    * @dev This constructor set the initial admin of the contract&#13;
    */&#13;
    function admined() internal {&#13;
        admin = msg.sender; //Set initial admin to contract creator&#13;
        Admined(admin);&#13;
    }&#13;
&#13;
    modifier onlyAdmin() { //A modifier to define admin-only functions&#13;
        require(msg.sender == admin);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfer the adminship of the contract&#13;
    * @param _newAdmin The address of the new admin.&#13;
    */&#13;
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered&#13;
        require(_newAdmin != address(0));&#13;
        admin = _newAdmin;&#13;
        TransferAdminship(admin);&#13;
    }&#13;
&#13;
    //All admin actions have a log for public review&#13;
    event TransferAdminship(address newAdmin);&#13;
    event Admined(address administrador);&#13;
}&#13;
&#13;
contract Sender is admined {&#13;
    &#13;
    token public DEEM;&#13;
    &#13;
	function Sender (token _addressOfToken) public {&#13;
		DEEM = _addressOfToken; &#13;
	}&#13;
&#13;
    function batch(address[] _data, uint256 _amount) onlyAdmin public { //It takes an array of addresses and an amount&#13;
        for (uint i=0; i&lt;_data.length; i++) { //It moves over the array&#13;
            require(DEEM.transfer(_data[i], _amount));&#13;
        }&#13;
    }&#13;
&#13;
    function() public {&#13;
        revert();&#13;
    }&#13;
}