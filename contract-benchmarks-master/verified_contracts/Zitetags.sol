pragma solidity ^0.4.24;

/*******************************************************************************
 *
 * Copyright (c) 2018 Decentralization Authority MDAO.
 * Released under the MIT License.
 *
 * Zitetags - A Zeronet registrar, for managing Namecoin (.bit) addresses used 
 *            by Zeronet users/clients to simplify addressing of requested 
 *            zites (0net websites), by NOT having to enter the full 
 *            Bitcoin (address) public key.
 * 
 *            For example, D14na's zite has a Bitcoin public key of
 *            [ 1D14naQY4s65YR6xrJDBHk9ufj2eLbK49C ], but can be referenced 
 *            using any of the following zitetag variations:
 *                1. d14na
 *                2. #d14na
 *                3. d14na.bit
 * 
 *            NOTE: The following prefixes may sometimes be applied:
 *                      1. zero://
 *                      2. http://127.0.0.1:43110/
 *                      3. https://0net.io/
 *               
 *
 * Version 18.10.21
 *
 * Web    : https://d14na.org
 * Email  : <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="196a6c6969766b6d597d282d777837766b7e">[email protected]</a>&#13;
 */&#13;
&#13;
&#13;
/*******************************************************************************&#13;
 *&#13;
 * SafeMath&#13;
 */&#13;
library SafeMath {&#13;
    function add(uint a, uint b) internal pure returns (uint c) {&#13;
        c = a + b;&#13;
        require(c &gt;= a);&#13;
    }&#13;
    function sub(uint a, uint b) internal pure returns (uint c) {&#13;
        require(b &lt;= a);&#13;
        c = a - b;&#13;
    }&#13;
    function mul(uint a, uint b) internal pure returns (uint c) {&#13;
        c = a * b;&#13;
        require(a == 0 || c / a == b);&#13;
    }&#13;
    function div(uint a, uint b) internal pure returns (uint c) {&#13;
        require(b &gt; 0);&#13;
        c = a / b;&#13;
    }&#13;
}&#13;
&#13;
&#13;
/*******************************************************************************&#13;
 *&#13;
 * ERC Token Standard #20 Interface&#13;
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md&#13;
 */&#13;
contract ERC20Interface {&#13;
    function totalSupply() public constant returns (uint);&#13;
    function balanceOf(address tokenOwner) public constant returns (uint balance);&#13;
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);&#13;
    function transfer(address to, uint tokens) public returns (bool success);&#13;
    function approve(address spender, uint tokens) public returns (bool success);&#13;
    function transferFrom(address from, address to, uint tokens) public returns (bool success);&#13;
&#13;
    event Transfer(address indexed from, address indexed to, uint tokens);&#13;
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);&#13;
}&#13;
&#13;
&#13;
/*******************************************************************************&#13;
 * Zer0netDb Interface&#13;
 */&#13;
contract Zer0netDbInterface {&#13;
    /* Interface getters. */&#13;
    function getAddress(bytes32 _key) external view returns (address);&#13;
    function getBool(bytes32 _key)    external view returns (bool);&#13;
    function getBytes(bytes32 _key)   external view returns (bytes);&#13;
    function getInt(bytes32 _key)     external view returns (int);&#13;
    function getString(bytes32 _key)  external view returns (string);&#13;
    function getUint(bytes32 _key)    external view returns (uint);&#13;
&#13;
    /* Interface setters. */&#13;
    function setAddress(bytes32 _key, address _value) external;&#13;
    function setBool(bytes32 _key, bool _value) external;&#13;
    function setBytes(bytes32 _key, bytes _value) external;&#13;
    function setInt(bytes32 _key, int _value) external;&#13;
    function setString(bytes32 _key, string _value) external;&#13;
    function setUint(bytes32 _key, uint _value) external;&#13;
&#13;
    /* Interface deletes. */&#13;
    function deleteAddress(bytes32 _key) external;&#13;
    function deleteBool(bytes32 _key) external;&#13;
    function deleteBytes(bytes32 _key) external;&#13;
    function deleteInt(bytes32 _key) external;&#13;
    function deleteString(bytes32 _key) external;&#13;
    function deleteUint(bytes32 _key) external;&#13;
}&#13;
&#13;
&#13;
/*******************************************************************************&#13;
 * Owned contract&#13;
 */&#13;
contract Owned {&#13;
    address public owner;&#13;
    address public newOwner;&#13;
&#13;
    event OwnershipTransferred(address indexed _from, address indexed _to);&#13;
&#13;
    constructor() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    function transferOwnership(address _newOwner) public onlyOwner {&#13;
        newOwner = _newOwner;&#13;
    }&#13;
&#13;
    function acceptOwnership() public {&#13;
        require(msg.sender == newOwner);&#13;
&#13;
        emit OwnershipTransferred(owner, newOwner);&#13;
&#13;
        owner = newOwner;&#13;
&#13;
        newOwner = address(0);&#13;
    }&#13;
}&#13;
&#13;
&#13;
/*******************************************************************************&#13;
 *&#13;
 * @notice Zitetags Registrar Contract.&#13;
 *&#13;
 * @dev Zitetags are Namecoin (.bit) addresses that are used&#13;
 *      (similar to Twitter hashtags and traditional domain names) as a&#13;
 *      convenient alternative to users/clients when entering a &#13;
 *      zite's Bitcoin public key.&#13;
 */&#13;
contract Zitetags is Owned {&#13;
    using SafeMath for uint;&#13;
&#13;
    /* Initialize version number. */&#13;
    uint public version;&#13;
&#13;
    /* Initialize Zer0net Db contract. */&#13;
    Zer0netDbInterface public zer0netDb;&#13;
&#13;
    /* Initialize zitetag update notification/log event. */&#13;
    event ZitetagUpdate(&#13;
        bytes32 indexed zitetagId, &#13;
        string zitetag, &#13;
        string info&#13;
    );&#13;
&#13;
    /* Constructor. */&#13;
    constructor() public {&#13;
        /* Set the version number. */&#13;
        version = now;&#13;
&#13;
        /* Initialize Zer0netDb (eternal) storage database contract. */&#13;
        // NOTE We hard-code the address here, since it should never change.&#13;
        zer0netDb = Zer0netDbInterface(0xE865Fe1A1A3b342bF0E2fcB11fF4E3BCe58263af);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Only allow access to an authorized Zer0net administrator.&#13;
     */&#13;
    modifier onlyAuthBy0Admin() {&#13;
        /* Verify write access is only permitted to authorized accounts. */&#13;
        require(zer0netDb.getBool(keccak256(&#13;
            abi.encodePacked(msg.sender, '.has.auth.for.zitetags'))) == true);&#13;
&#13;
        _;      // function code is inserted here&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Retrieves the registration info for the given zitetag.&#13;
     * &#13;
     * @dev Use the calculated hash to query the eternal database &#13;
     *      for the `_zitetag` info.&#13;
     */&#13;
    function getInfo(string _zitetag) external view returns (string) {&#13;
        /* Calculate the zitetag's hash. */&#13;
        bytes32 hash = keccak256(abi.encodePacked('zitetag.', _zitetag));&#13;
        &#13;
        /* Retrieve the zitetag's info. */&#13;
        string memory info = zer0netDb.getString(hash);&#13;
&#13;
        /* Return info. */&#13;
        return (info);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Set the zitetag's registration info.&#13;
     * &#13;
     * @dev Calculate the `_zitetag` hash and use it to store the&#13;
     *      registration details in the eternal database.&#13;
     * &#13;
     *      NOTE: JSON will be the object type for registration details.&#13;
     */&#13;
    function setInfo(&#13;
        string _zitetag, &#13;
        string _info&#13;
    ) onlyAuthBy0Admin external returns (bool success) {&#13;
        /* Calculate the zitetag's hash. */&#13;
        bytes32 hash = keccak256(abi.encodePacked('zitetag.', _zitetag));&#13;
        &#13;
        /* Set the zitetag's info. */&#13;
        zer0netDb.setString(hash, _info);&#13;
&#13;
        /* Emit event notification. */&#13;
        emit ZitetagUpdate(hash, _zitetag, _info);&#13;
&#13;
        /* Return success. */&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * THIS CONTRACT DOES NOT ACCEPT DIRECT ETHER&#13;
     */&#13;
    function () public payable {&#13;
        /* Cancel this transaction. */&#13;
        revert('Oops! Direct payments are NOT permitted here.');&#13;
    }&#13;
&#13;
    /**&#13;
     * Transfer Any ERC20 Token&#13;
     *&#13;
     * @notice Owner can transfer out any accidentally sent ERC20 tokens.&#13;
     *&#13;
     * @dev Provides an ERC20 interface, which allows for the recover&#13;
     *      of any accidentally sent ERC20 tokens.&#13;
     */&#13;
    function transferAnyERC20Token(&#13;
        address tokenAddress, uint tokens&#13;
    ) public onlyOwner returns (bool success) {&#13;
        return ERC20Interface(tokenAddress).transfer(owner, tokens);&#13;
    }&#13;
}