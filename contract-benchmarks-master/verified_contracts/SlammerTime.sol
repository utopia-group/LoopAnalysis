pragma solidity ^0.4.15;

/*
  https://cryptogs.io
  --Austin Thomas Griffith for ETHDenver
  ( this is unaudited )
*/



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract SlammerTime is Ownable{

  string public constant purpose = "ETHDenver";
  string public constant contact = "https://cryptogs.io";
  string public constant author = "Austin Thomas Griffith | <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="72130701061b1c32111d1c11070000171c11175c1b1d">[email protected]</a>";&#13;
&#13;
  address public cryptogs;&#13;
&#13;
  function SlammerTime(address _cryptogs) public {&#13;
    //deploy slammertime with cryptogs address coded in so&#13;
    // only the cryptogs address can mess with it&#13;
    cryptogs=_cryptogs;&#13;
  }&#13;
&#13;
  function startSlammerTime(address _player1,uint256[5] _id1,address _player2,uint256[5] _id2) public returns (bool) {&#13;
    //only the cryptogs contract should be able to hit it&#13;
    require(msg.sender==cryptogs);&#13;
&#13;
    Cryptogs cryptogsContract = Cryptogs(cryptogs);&#13;
&#13;
    for(uint8 i=0;i&lt;5;i++){&#13;
      //make sure player1 owns _id1&#13;
      require(cryptogsContract.tokenIndexToOwner(_id1[i])==_player1);&#13;
      //transfer id1 in&#13;
      cryptogsContract.transferFrom(_player1,address(this),_id1[i]);&#13;
      //make this contract is the owner&#13;
      require(cryptogsContract.tokenIndexToOwner(_id1[i])==address(this));&#13;
    }&#13;
&#13;
&#13;
    for(uint8 j=0;j&lt;5;j++){&#13;
      //make sure player2 owns _id1&#13;
      require(cryptogsContract.tokenIndexToOwner(_id2[j])==_player2);&#13;
      //transfer id1 in&#13;
      cryptogsContract.transferFrom(_player2,address(this),_id2[j]);&#13;
      //make this contract is the owner&#13;
      require(cryptogsContract.tokenIndexToOwner(_id2[j])==address(this));&#13;
    }&#13;
&#13;
&#13;
    return true;&#13;
  }&#13;
&#13;
  function transferBack(address _toWhom, uint256 _id) public returns (bool) {&#13;
    //only the cryptogs contract should be able to hit it&#13;
    require(msg.sender==cryptogs);&#13;
&#13;
    Cryptogs cryptogsContract = Cryptogs(cryptogs);&#13;
&#13;
    require(cryptogsContract.tokenIndexToOwner(_id)==address(this));&#13;
    cryptogsContract.transfer(_toWhom,_id);&#13;
    require(cryptogsContract.tokenIndexToOwner(_id)==_toWhom);&#13;
    return true;&#13;
  }&#13;
&#13;
  function withdraw(uint256 _amount) public onlyOwner returns (bool) {&#13;
    require(this.balance &gt;= _amount);&#13;
    assert(owner.send(_amount));&#13;
    return true;&#13;
  }&#13;
&#13;
  function withdrawToken(address _token,uint256 _amount) public onlyOwner returns (bool) {&#13;
    StandardToken token = StandardToken(_token);&#13;
    token.transfer(msg.sender,_amount);&#13;
    return true;&#13;
  }&#13;
}&#13;
&#13;
contract StandardToken {&#13;
  function transfer(address _to, uint256 _value) public returns (bool) { }&#13;
}&#13;
&#13;
&#13;
contract Cryptogs {&#13;
  mapping (uint256 =&gt; address) public tokenIndexToOwner;&#13;
  function transfer(address _to,uint256 _tokenId) external { }&#13;
  function transferFrom(address _from,address _to,uint256 _tokenId) external { }&#13;
}