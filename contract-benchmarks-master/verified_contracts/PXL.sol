pragma solidity ^0.4.24;

// File: contracts/token/ContractReceiver.sol

contract ContractReceiver {
    function receiveApproval(address _from, uint256 _value, address _token, bytes _data) public;
}

// File: contracts/token/CustomToken.sol

contract CustomToken {
    function approveAndCall(address _to, uint256 _value, bytes _data) public returns (bool);
    event ApproveAndCall(address indexed _from, address indexed _to, uint256 _value, bytes _data);
}

// File: contracts/utils/ExtendsOwnable.sol

contract ExtendsOwnable {

    mapping(address => bool) public owners;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipRevoked(address indexed revokedOwner);
    event OwnershipExtended(address indexed host, address indexed guest);

    modifier onlyOwner() {
        require(owners[msg.sender]);
        _;
    }

    constructor() public {
        owners[msg.sender] = true;
    }

    function isOwner(address owner) public view returns(bool) {
        return owners[owner];
    }

    function addOwner(address guest) public onlyOwner {
        require(guest != address(0));
        owners[guest] = true;
        emit OwnershipExtended(msg.sender, guest);
    }

    function removeOwner(address owner) public onlyOwner {
        require(owner != address(0));
        require(msg.sender != owner);
        owners[owner] = false;
        emit OwnershipRevoked(owner);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owners[newOwner] = true;
        delete owners[msg.sender];
        emit OwnershipTransferred(msg.sender, newOwner);
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

// File: contracts/token/PXL.sol

/**
 * @title PXL implementation based on StandardToken ERC-20 contract.
 *
 * @author Charls Kim - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4c2f3f622725210c2e2d38382029292238622f2321">[email protected]</a>&gt;&#13;
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md&#13;
 */&#13;
contract PXL is ERC20, CustomToken, ExtendsOwnable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    // PXL 토큰 기본 정보&#13;
    string public constant name = "Pixel";&#13;
    string public constant symbol = "PXL";&#13;
    uint256 public constant decimals = 18;&#13;
&#13;
    /**&#13;
     * @dev fallback 이더리움이 전송될 경우 Revert&#13;
     *&#13;
     */&#13;
    function() public payable {&#13;
        revert();&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev 토큰 대리 전송을 위한 함수&#13;
     *&#13;
     * @param _from 토큰을 가지고 있는 지갑 주소&#13;
     * @param _to 토큰을 전송받을 지갑 주소&#13;
     * @param _value 대리 전송할 토큰 수량&#13;
     * @return bool 타입의 토큰 대리 전송 권한 성공 여부&#13;
     */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev PXL 토큰 전송 함수&#13;
     *&#13;
     * @param _to 토큰을 받을 지갑 주소&#13;
     * @param _value 전송할 토큰 수량&#13;
     * @return bool 타입의 전송 결과&#13;
     */&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev PXL 전송과 데이터를 함께 사용하는 함수&#13;
     *&#13;
     * @notice CustomToken 인터페이스 활용&#13;
     * @notice _to 주소가 컨트랙트인 경우만 사용 가능&#13;
     * @notice 토큰과 데이터를 받으려면 해당 컨트랙트에 receiveApproval 함수 구현 필요&#13;
     * @param _to 토큰을 전송하고 함수를 실행할 컨트랙트 주소&#13;
     * @param _value 전송할 토큰 수량&#13;
     * @return bool 타입의 처리 결과&#13;
     */&#13;
    function approveAndCall(address _to, uint256 _value, bytes _data) public returns (bool) {&#13;
        require(_to != address(0) &amp;&amp; _to != address(this));&#13;
        require(balanceOf(msg.sender) &gt;= _value);&#13;
&#13;
        if(approve(_to, _value) &amp;&amp; isContract(_to)) {&#13;
            ContractReceiver receiver = ContractReceiver(_to);&#13;
            receiver.receiveApproval(msg.sender, _value, address(this), _data);&#13;
            emit ApproveAndCall(msg.sender, _to, _value, _data);&#13;
&#13;
            return true;&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev 토큰 발행 함수&#13;
     * @param _amount 발행할 토큰 수량&#13;
     */&#13;
    function mint(uint256 _amount) onlyOwner external {&#13;
        super._mint(msg.sender, _amount);&#13;
&#13;
        emit Mint(msg.sender, _amount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev 토큰 소멸 함수&#13;
     * @param _amount 소멸할 토큰 수량&#13;
     */&#13;
    function burn(uint256 _amount) onlyOwner external {&#13;
        super._burn(msg.sender, _amount);&#13;
&#13;
        emit Burn(msg.sender, _amount);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev 컨트랙트 확인 함수&#13;
     * @param _addr 컨트랙트 주소&#13;
     */&#13;
    function isContract(address _addr) private view returns (bool) {&#13;
        uint256 length;&#13;
        assembly {&#13;
            //retrieve the size of the code on target address, this needs assembly&#13;
            length := extcodesize(_addr)&#13;
        }&#13;
        return (length &gt; 0);&#13;
    }&#13;
&#13;
    event Mint(address indexed _to, uint256 _amount);&#13;
    event Burn(address indexed _from, uint256 _amount);&#13;
}