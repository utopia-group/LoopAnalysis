pragma solidity 0.4.21;

library SafeMath {
    //internals
    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c>=a && c>=b);
        return c;
    }
}

contract Owned {
    address public owner;
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function Owned() public {
        owner = msg.sender;
    }
}

/// @title Simple Tokens
/// Simple Tokens that can be minted by their owner
contract SimpleToken is Owned {
    using SafeMath for uint256;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This creates a mapping with all balances
    mapping (address => uint256) public balanceOf;
    // Another array with spending allowances
    mapping (address => mapping (address => uint256)) public allowance;
    // The total supply of the token
    uint256 public totalSupply;

    // Some variables for nice wallet integration
    string public name = "CryptoGold";          // Set the name for display purposes
    string public symbol = "CGC" ;             // Set the symbol for display purposes
    uint8 public decimals = 6;                // Amount of decimals for display purposes

    // Send coins
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != 0x0);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != 0x0);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    // Approve that others can transfer _value tokens for the msg.sender
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowance[msg.sender][_spender] = allowance[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }
    
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowance[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowance[msg.sender][_spender] = 0;
        } else {
            allowance[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }

}

/// @title Multisignature Mintable Token - Allows minting of Tokens by a 2-2-Multisignature
/// @author Henning Kopp - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8ce7e3fcfccceee0e3efe7efe4ede5e2a1eee9feedf8f9e2eba2e8e9">[email protected]</a>&gt;&#13;
contract MultiSigMint is SimpleToken {&#13;
&#13;
    // Address change event&#13;
    event newOwner(address indexed oldAddress, address indexed newAddress);&#13;
    event newNotary(address indexed oldAddress, address indexed newAddress);    &#13;
    event Mint(address indexed minter, uint256 value);&#13;
    event Burn(address indexed burner, uint256 value);&#13;
&#13;
    // The address of the notary&#13;
    address public notary;&#13;
&#13;
    uint256 proposedMintAmnt = 0;&#13;
    uint256 proposedBurnAmnt = 0;&#13;
&#13;
    address proposeOwner = 0x0;&#13;
    address proposeNotary = 0x0;&#13;
&#13;
    function MultiSigMint(address _notary) public {&#13;
        require(_notary != 0x0);&#13;
        require(msg.sender != _notary);&#13;
        notary = _notary;&#13;
    }&#13;
&#13;
    modifier onlyNotary {&#13;
        require(msg.sender == notary);&#13;
        _;&#13;
    }&#13;
&#13;
    /* Allows the owner to propose the minting of tokens.&#13;
     * tokenamount is the amount of tokens to be minted.&#13;
     */&#13;
    function proposeMinting(uint256 _tokenamount) external onlyOwner returns (bool) {&#13;
        require(_tokenamount &gt; 0);&#13;
        proposedMintAmnt = _tokenamount;&#13;
        return true;&#13;
    }&#13;
&#13;
    /* Allows the notary to confirm the minting of tokens.&#13;
     * tokenamount is the amount of tokens to be minted.&#13;
     */&#13;
    function confirmMinting(uint256 _tokenamount) external onlyNotary returns (bool) {&#13;
        if (_tokenamount == proposedMintAmnt) {&#13;
            proposedMintAmnt = 0; // reset the amount&#13;
            balanceOf[owner] = balanceOf[owner].add(_tokenamount);&#13;
            totalSupply = totalSupply.add(_tokenamount);&#13;
            emit Mint(owner, _tokenamount);&#13;
            emit Transfer(0x0, owner, _tokenamount);&#13;
            return true;&#13;
        } else {&#13;
            proposedMintAmnt = 0; // reset the amount&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    /* Allows the owner to propose the burning of tokens.&#13;
     * tokenamount is the amount of tokens to be burned.&#13;
     */&#13;
    function proposeBurning(uint256 _tokenamount) external onlyOwner returns (bool) {&#13;
        require(_tokenamount &gt; 0);&#13;
        proposedBurnAmnt = _tokenamount;&#13;
        return true;&#13;
    }&#13;
&#13;
    /* Allows the notary to confirm the burning of tokens.&#13;
     * tokenamount is the amount of tokens to be burning.&#13;
     */&#13;
    function confirmBurning(uint256 _tokenamount) external onlyNotary returns (bool) {&#13;
        if (_tokenamount == proposedBurnAmnt) {&#13;
            proposedBurnAmnt = 0; // reset the amount&#13;
            balanceOf[owner] = balanceOf[owner].sub(_tokenamount);&#13;
            totalSupply = totalSupply.sub(_tokenamount);&#13;
            emit Burn(owner, _tokenamount);&#13;
            emit Transfer(owner, 0x0, _tokenamount);&#13;
            return true;&#13;
        } else {&#13;
            proposedBurnAmnt = 0; // reset the amount&#13;
            return false;&#13;
        }&#13;
    }&#13;
&#13;
    /* Owner can propose an address change for owner&#13;
    The notary has to confirm that address&#13;
    */&#13;
    function proposeNewOwner(address _newAddress) external onlyOwner {&#13;
        proposeOwner = _newAddress;&#13;
    }&#13;
    function confirmNewOwner(address _newAddress) external onlyNotary returns (bool) {&#13;
        if (proposeOwner == _newAddress &amp;&amp; _newAddress != 0x0 &amp;&amp; _newAddress != notary) {&#13;
            proposeOwner = 0x0;&#13;
            emit newOwner(owner, _newAddress);&#13;
            owner = _newAddress;&#13;
            return true;&#13;
        } else {&#13;
            proposeOwner = 0x0;&#13;
            return false;&#13;
        }&#13;
    }&#13;
    &#13;
    /* Owner can propose an address change for notary&#13;
    The notary has to confirm that address&#13;
    */&#13;
    function proposeNewNotary(address _newAddress) external onlyOwner {&#13;
        proposeNotary = _newAddress;&#13;
    }&#13;
    function confirmNewNotary(address _newAddress) external onlyNotary returns (bool) {&#13;
        if (proposeNotary == _newAddress &amp;&amp; _newAddress != 0x0 &amp;&amp; _newAddress != owner) {&#13;
            proposeNotary = 0x0;&#13;
            emit newNotary(notary, _newAddress);&#13;
            notary = _newAddress;&#13;
            return true;&#13;
        } else {&#13;
            proposeNotary = 0x0;&#13;
            return false;&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
/// @title Contract with fixed parameters for deployment&#13;
/// @author Henning Kopp - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a2c9cdd2d2e2c0cecdc1c9c1cac3cbcc8fc0c7d0c3d6d7ccc58cc6c7">[email protected]</a>&gt;&#13;
contract GoldToken is MultiSigMint {&#13;
    function GoldToken(address _notary) public MultiSigMint(_notary) {}&#13;
}