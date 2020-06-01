pragma solidity ^0.4.15;

contract owned {
    function owned() public { owner = msg.sender; }
    address public owner;

    // This contract only defines a modifier but does not use
    // it - it will be used in derived contracts.
    // The function body is inserted where the special symbol
    // "_;" in the definition of a modifier appears.
    // This means that if the owner calls this function, the
    // function is executed and otherwise, an exception is
    // thrown.
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract ERC20 {
    function balanceOf(address _owner) public constant returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="274342534267465f4e484a5d4249094448">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
    // Required methods&#13;
    function totalSupply() public returns (uint256 total);&#13;
    function balanceOf(address _owner) public returns (uint256 balance);&#13;
    function ownerOf(uint256 _tokenId) external returns (address owner);&#13;
    function approve(address _to, uint256 _tokenId) external;&#13;
    function transfer(address _to, uint256 _tokenId) external;&#13;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;&#13;
&#13;
    // Events&#13;
    event Transfer(address from, address to, uint256 tokenId);&#13;
    event Approval(address owner, address approved, uint256 tokenId);&#13;
&#13;
    // Optional&#13;
    // function name() public view returns (string name);&#13;
    // function symbol() public view returns (string symbol);&#13;
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);&#13;
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);&#13;
&#13;
    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)&#13;
    function supportsInterface(bytes4 _interfaceID) external returns (bool);&#13;
}&#13;
&#13;
contract AutoWallet is owned {&#13;
    function changeOwner(address _newOwner) external onlyOwner {&#13;
        owner = _newOwner;&#13;
    }&#13;
    &#13;
    function () external payable {&#13;
        // this is the fallback function; it is called whenever the contract receives ether&#13;
        // forward that ether onto the contract owner immediately&#13;
        owner.transfer(msg.value);&#13;
        // and emit the EtherReceived event in case anyone is watching it&#13;
        EtherReceived(msg.sender, msg.value);&#13;
    }&#13;
    &#13;
    function sweep() external returns (bool success) {&#13;
        // this can be called by anyone (who wants to pay for gas), but that's safe because it will only sweep&#13;
        // funds to the owner's account. it sweeps the entire ether balance&#13;
        require(this.balance &gt; 0);&#13;
        return owner.send(this.balance);&#13;
    }&#13;
    &#13;
    function transferToken(address _tokenContractAddress, address _to, uint256 _amount) external onlyOwner returns (bool success) {&#13;
        // this can only be called by the owner. it sends some amount of an ERC-20 token to some address&#13;
        ERC20 token = ERC20(_tokenContractAddress);&#13;
        return token.transfer(_to, _amount);&#13;
    }&#13;
    &#13;
    function sweepToken(address _tokenContractAddress) external returns (bool success) {&#13;
        // like sweep(), this can be called by anyone. it sweeps the full balance of an ERC-20 token to the owner's account&#13;
        ERC20 token = ERC20(_tokenContractAddress);&#13;
        uint bal = token.balanceOf(this);&#13;
        require(bal &gt; 0);&#13;
        return token.transfer(owner, bal);&#13;
    }&#13;
    &#13;
    function transferTokenFrom(address _tokenContractAddress, address _from, address _to, uint256 _amount) external onlyOwner returns (bool success) {&#13;
        ERC20 token = ERC20(_tokenContractAddress);&#13;
        return token.transferFrom(_from, _to, _amount);&#13;
    }&#13;
    &#13;
    function approveTokenTransfer(address _tokenContractAddress, address _spender, uint256 _amount) external onlyOwner returns (bool success) {&#13;
        ERC20 token = ERC20(_tokenContractAddress);&#13;
        return token.approve(_spender, _amount);&#13;
    }&#13;
    &#13;
    function transferNonFungibleToken(address _tokenContractAddress, address _to, uint256 _tokenId) external onlyOwner {&#13;
        // for cryptokitties etc&#13;
        ERC721 token = ERC721(_tokenContractAddress);&#13;
        token.transfer(_to, _tokenId);&#13;
    }&#13;
    &#13;
    function transferNonFungibleTokenFrom(address _tokenContractAddress, address _from, address _to, uint256 _tokenId) external onlyOwner {&#13;
        ERC721 token = ERC721(_tokenContractAddress);&#13;
        token.transferFrom(_from, _to, _tokenId);&#13;
    }&#13;
    &#13;
    function transferNonFungibleTokenMulti(address _tokenContractAddress, address _to, uint256[] _tokenIds) external onlyOwner {&#13;
        ERC721 token = ERC721(_tokenContractAddress);&#13;
        for (uint i = 0; i &lt; _tokenIds.length; i++) {&#13;
            token.transfer(_to, _tokenIds[i]);&#13;
        }&#13;
    }&#13;
    &#13;
    event EtherReceived(address _sender, uint256 _value);&#13;
}