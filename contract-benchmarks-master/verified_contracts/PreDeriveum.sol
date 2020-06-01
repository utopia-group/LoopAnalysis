pragma solidity 0.4.25;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title ERC664Balances interface
 * @dev see https://github.com/ethereum/EIPs/issues/644
 */
interface IERC664Balances {
    function getBalance(address _acct) external view returns(uint balance);

    function incBalance(address _acct, uint _val) external returns(bool success);

    function decBalance(address _acct, uint _val) external returns(bool success);

    function getAllowance(address _owner, address _spender) external view returns(uint remaining);

    function setApprove(address _sender, address _spender, uint256 _value) external returns(bool success);

    function decApprove(address _from, address _spender, uint _value) external returns(bool success);

    function getModule(address _acct) external view returns (bool success);

    function setModule(address _acct, bool _set) external returns(bool success);

    function getTotalSupply() external view returns(uint);

    function incTotalSupply(uint _val) external returns(bool success);

    function decTotalSupply(uint _val) external returns(bool success);

    function transferRoot(address _new) external returns(bool success);

    event BalanceAdj(address indexed Module, address indexed Account, uint Amount, string Polarity);

    event ModuleSet(address indexed Module, bool indexed Set);
}

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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
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


/**
 * @title Owned
 * @author Adria Massanet <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="50313422393110333f3435333f3e243528247e393f">[email protected]</a>&gt;&#13;
 * @notice The Owned contract has an owner address, and provides basic&#13;
 *  authorization control functions, this simplifies &amp; the implementation of&#13;
 *  user permissions; this contract has three work flows for a change in&#13;
 *  ownership, the first requires the new owner to validate that they have the&#13;
 *  ability to accept ownership, the second allows the ownership to be&#13;
 *  directly transferred without requiring acceptance, and the third allows for&#13;
 *  the ownership to be removed to allow for decentralization&#13;
 */&#13;
contract Owned {&#13;
&#13;
    address public owner;&#13;
    address public newOwnerCandidate;&#13;
&#13;
    event OwnershipRequested(address indexed by, address indexed to);&#13;
    event OwnershipTransferred(address indexed from, address indexed to);&#13;
    event OwnershipRemoved();&#13;
&#13;
    /**&#13;
     * @dev The constructor sets the `msg.sender` as the`owner` of the contract&#13;
     */&#13;
    constructor() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev `owner` is the only address that can call a function with this&#13;
     * modifier&#13;
     */&#13;
    modifier onlyOwner() {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev In this 1st option for ownership transfer `proposeOwnership()` must&#13;
     *  be called first by the current `owner` then `acceptOwnership()` must be&#13;
     *  called by the `newOwnerCandidate`&#13;
     * @notice `onlyOwner` Proposes to transfer control of the contract to a&#13;
     *  new owner&#13;
     * @param _newOwnerCandidate The address being proposed as the new owner&#13;
     */&#13;
    function proposeOwnership(address _newOwnerCandidate) external onlyOwner {&#13;
        newOwnerCandidate = _newOwnerCandidate;&#13;
        emit OwnershipRequested(msg.sender, newOwnerCandidate);&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Can only be called by the `newOwnerCandidate`, accepts the&#13;
     *  transfer of ownership&#13;
     */&#13;
    function acceptOwnership() external {&#13;
        require(msg.sender == newOwnerCandidate);&#13;
&#13;
        address oldOwner = owner;&#13;
        owner = newOwnerCandidate;&#13;
        newOwnerCandidate = 0x0;&#13;
&#13;
        emit OwnershipTransferred(oldOwner, owner);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev In this 2nd option for ownership transfer `changeOwnership()` can&#13;
     *  be called and it will immediately assign ownership to the `newOwner`&#13;
     * @notice `owner` can step down and assign some other address to this role&#13;
     * @param _newOwner The address of the new owner&#13;
     */&#13;
    function changeOwnership(address _newOwner) external onlyOwner {&#13;
        require(_newOwner != 0x0);&#13;
&#13;
        address oldOwner = owner;&#13;
        owner = _newOwner;&#13;
        newOwnerCandidate = 0x0;&#13;
&#13;
        emit OwnershipTransferred(oldOwner, owner);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev In this 3rd option for ownership transfer `removeOwnership()` can&#13;
     *  be called and it will immediately assign ownership to the 0x0 address;&#13;
     *  it requires a 0xdece be input as a parameter to prevent accidental use&#13;
     * @notice Decentralizes the contract, this operation cannot be undone&#13;
     * @param _dac `0xdac` has to be entered for this function to work&#13;
     */&#13;
    function removeOwnership(address _dac) external onlyOwner {&#13;
        require(_dac == 0xdac);&#13;
        owner = 0x0;&#13;
        newOwnerCandidate = 0x0;&#13;
        emit OwnershipRemoved();&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title Safe Guard Contract&#13;
 * @author Panos&#13;
 */&#13;
contract SafeGuard is Owned {&#13;
&#13;
    event Transaction(address indexed destination, uint value, bytes data);&#13;
&#13;
    /**&#13;
     * @dev Allows owner to execute a transaction.&#13;
     */&#13;
    function executeTransaction(address destination, uint value, bytes data)&#13;
    public&#13;
    onlyOwner&#13;
    {&#13;
        require(externalCall(destination, value, data.length, data));&#13;
        emit Transaction(destination, value, data);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev call has been separated into its own function in order to take advantage&#13;
     *  of the Solidity's code generator to produce a loop that copies tx.data into memory.&#13;
     */&#13;
    function externalCall(address destination, uint value, uint dataLength, bytes data)&#13;
    private&#13;
    returns (bool) {&#13;
        bool result;&#13;
        assembly { // solhint-disable-line no-inline-assembly&#13;
            let x := mload(0x40)   // "Allocate" memory for output&#13;
            // (0x40 is where "free memory" pointer is stored by convention)&#13;
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that&#13;
            result := call(&#13;
            sub(gas, 34710), // 34710 is the value that solidity is currently emitting&#13;
            // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +&#13;
            // callNewAccountGas (25000, in case the destination address does not exist and needs creating)&#13;
            destination,&#13;
            value,&#13;
            d,&#13;
            dataLength, // Size of the input (in bytes) - this is what fixes the padding problem&#13;
            x,&#13;
            0                  // Output is ignored, therefore the output size is zero&#13;
            )&#13;
        }&#13;
        return result;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20Detailed token&#13;
 * @dev The decimals are only for visualization purposes.&#13;
 * All the operations are done using the smallest and indivisible token unit,&#13;
 * just as on Ethereum all the operations are done in wei.&#13;
 */&#13;
contract ERC20Detailed is IERC20 {&#13;
    string private _name;&#13;
    string private _symbol;&#13;
    uint8 private _decimals;&#13;
&#13;
    constructor (string name, string symbol, uint8 decimals) public {&#13;
        _name = name;&#13;
        _symbol = symbol;&#13;
        _decimals = decimals;&#13;
    }&#13;
&#13;
    /**&#13;
     * @return the name of the token.&#13;
     */&#13;
    function name() public view returns (string) {&#13;
        return _name;&#13;
    }&#13;
&#13;
    /**&#13;
     * @return the symbol of the token.&#13;
     */&#13;
    function symbol() public view returns (string) {&#13;
        return _symbol;&#13;
    }&#13;
&#13;
    /**&#13;
     * @return the number of decimals of the token.&#13;
     */&#13;
    function decimals() public view returns (uint8) {&#13;
        return _decimals;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 *&#13;
 * @dev Implementation of the basic standard token.&#13;
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md&#13;
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
contract ERC20 is IERC20 {&#13;
    using SafeMath for uint256;&#13;
&#13;
    mapping (address =&gt; uint256) private _balances;&#13;
&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) private _allowed;&#13;
&#13;
    uint256 private _totalSupply;&#13;
&#13;
    /**&#13;
    * @dev Total number of tokens in existence&#13;
    */&#13;
    function totalSupply() public view returns (uint256) {&#13;
        return _totalSupply;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Gets the balance of the specified address.&#13;
    * @param owner The address to query the balance of.&#13;
    * @return An uint256 representing the amount owned by the passed address.&#13;
    */&#13;
    function balanceOf(address owner) public view returns (uint256) {&#13;
        return _balances[owner];&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
     * @param owner address The address which owns the funds.&#13;
     * @param spender address The address which will spend the funds.&#13;
     * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
     */&#13;
    function allowance(address owner, address spender) public view returns (uint256) {&#13;
        return _allowed[owner][spender];&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfer token for a specified address&#13;
    * @param to The address to transfer to.&#13;
    * @param value The amount to be transferred.&#13;
    */&#13;
    function transfer(address to, uint256 value) public returns (bool) {&#13;
        _transfer(msg.sender, to, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
     * Beware that changing an allowance with this method brings the risk that someone may use both the old&#13;
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this&#13;
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:&#13;
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
     * @param spender The address which will spend the funds.&#13;
     * @param value The amount of tokens to be spent.&#13;
     */&#13;
    function approve(address spender, uint256 value) public returns (bool) {&#13;
        require(spender != address(0));&#13;
&#13;
        _allowed[msg.sender][spender] = value;&#13;
        emit Approval(msg.sender, spender, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Transfer tokens from one address to another&#13;
     * @param from address The address which you want to send tokens from&#13;
     * @param to address The address which you want to transfer to&#13;
     * @param value uint256 the amount of tokens to be transferred&#13;
     */&#13;
    function transferFrom(address from, address to, uint256 value) public returns (bool) {&#13;
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);&#13;
        _transfer(from, to, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
     * approve should be called when allowed_[_spender] == 0. To increment&#13;
     * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
     * the first transaction is mined)&#13;
     * From MonolithDAO Token.sol&#13;
     * @param spender The address which will spend the funds.&#13;
     * @param addedValue The amount of tokens to increase the allowance by.&#13;
     */&#13;
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {&#13;
        require(spender != address(0));&#13;
&#13;
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);&#13;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
     * approve should be called when allowed_[_spender] == 0. To decrement&#13;
     * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
     * the first transaction is mined)&#13;
     * From MonolithDAO Token.sol&#13;
     * @param spender The address which will spend the funds.&#13;
     * @param subtractedValue The amount of tokens to decrease the allowance by.&#13;
     */&#13;
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {&#13;
        require(spender != address(0));&#13;
&#13;
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);&#13;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Transfer token for a specified addresses&#13;
    * @param from The address to transfer from.&#13;
    * @param to The address to transfer to.&#13;
    * @param value The amount to be transferred.&#13;
    */&#13;
    function _transfer(address from, address to, uint256 value) internal {&#13;
        require(to != address(0));&#13;
&#13;
        _balances[from] = _balances[from].sub(value);&#13;
        _balances[to] = _balances[to].add(value);&#13;
        emit Transfer(from, to, value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Internal function that mints an amount of the token and assigns it to&#13;
     * an account. This encapsulates the modification of balances such that the&#13;
     * proper events are emitted.&#13;
     * @param account The account that will receive the created tokens.&#13;
     * @param value The amount that will be created.&#13;
     */&#13;
    function _mint(address account, uint256 value) internal {&#13;
        require(account != address(0));&#13;
&#13;
        _totalSupply = _totalSupply.add(value);&#13;
        _balances[account] = _balances[account].add(value);&#13;
        emit Transfer(address(0), account, value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Internal function that burns an amount of the token of a given&#13;
     * account.&#13;
     * @param account The account whose tokens will be burnt.&#13;
     * @param value The amount that will be burnt.&#13;
     */&#13;
    function _burn(address account, uint256 value) internal {&#13;
        require(account != address(0));&#13;
&#13;
        _totalSupply = _totalSupply.sub(value);&#13;
        _balances[account] = _balances[account].sub(value);&#13;
        emit Transfer(account, address(0), value);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Internal function that burns an amount of the token of a given&#13;
     * account, deducting from the sender's allowance for said account. Uses the&#13;
     * internal burn function.&#13;
     * @param account The account whose tokens will be burnt.&#13;
     * @param value The amount that will be burnt.&#13;
     */&#13;
    function _burnFrom(address account, uint256 value) internal {&#13;
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,&#13;
        // this function needs to emit an event with the updated approval.&#13;
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);&#13;
        _burn(account, value);&#13;
    }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title ERC664 Standard Balances Contract&#13;
 * @author chrisfranko&#13;
 */&#13;
contract ERC664Balances is IERC664Balances, SafeGuard {&#13;
    using SafeMath for uint256;&#13;
&#13;
    uint256 public totalSupply;&#13;
&#13;
    event BalanceAdj(address indexed module, address indexed account, uint amount, string polarity);&#13;
    event ModuleSet(address indexed module, bool indexed set);&#13;
&#13;
    mapping(address =&gt; bool) public modules;&#13;
    mapping(address =&gt; uint256) public balances;&#13;
    mapping(address =&gt; mapping(address =&gt; uint256)) public allowed;&#13;
&#13;
    modifier onlyModule() {&#13;
        require(modules[msg.sender]);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Constructor to create ERC664Balances&#13;
     * @param _initialAmount Database initial amount&#13;
     */&#13;
    constructor(uint256 _initialAmount) public {&#13;
        balances[msg.sender] = _initialAmount;&#13;
        totalSupply = _initialAmount;&#13;
        emit BalanceAdj(address(0), msg.sender, _initialAmount, "+");&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Set allowance of `_spender` in behalf of `_sender` at `_value`&#13;
     * @param _sender Owner account&#13;
     * @param _spender Spender account&#13;
     * @param _value Value to approve&#13;
     * @return Operation status&#13;
     */&#13;
    function setApprove(address _sender, address _spender, uint256 _value) external onlyModule returns (bool) {&#13;
        allowed[_sender][_spender] = _value;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Decrease allowance of `_spender` in behalf of `_from` at `_value`&#13;
     * @param _from Owner account&#13;
     * @param _spender Spender account&#13;
     * @param _value Value to decrease&#13;
     * @return Operation status&#13;
     */&#13;
    function decApprove(address _from, address _spender, uint _value) external onlyModule returns (bool) {&#13;
        allowed[_from][_spender] = allowed[_from][_spender].sub(_value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Increase total supply by `_val`&#13;
    * @param _val Value to increase&#13;
    * @return Operation status&#13;
    */&#13;
    function incTotalSupply(uint _val) external onlyOwner returns (bool) {&#13;
        totalSupply = totalSupply.add(_val);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Decrease total supply by `_val`&#13;
     * @param _val Value to decrease&#13;
     * @return Operation status&#13;
     */&#13;
    function decTotalSupply(uint _val) external onlyOwner returns (bool) {&#13;
        totalSupply = totalSupply.sub(_val);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Set/Unset `_acct` as an authorized module&#13;
     * @param _acct Module address&#13;
     * @param _set Module set status&#13;
     * @return Operation status&#13;
     */&#13;
    function setModule(address _acct, bool _set) external onlyOwner returns (bool) {&#13;
        modules[_acct] = _set;&#13;
        emit ModuleSet(_acct, _set);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Change database owner&#13;
     * @param _newOwner The new owner address&#13;
     */&#13;
    function transferRoot(address _newOwner) external onlyOwner returns(bool) {&#13;
        owner = _newOwner;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**getBalance&#13;
     * @notice Get `_acct` balance&#13;
     * @param _acct Target account to get balance.&#13;
     * @return The account balance&#13;
     */&#13;
    function getBalance(address _acct) external view returns (uint256) {&#13;
        return balances[_acct];&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Get allowance of `_spender` in behalf of `_owner`&#13;
     * @param _owner Owner account&#13;
     * @param _spender Spender account&#13;
     * @return Allowance&#13;
     */&#13;
    function getAllowance(address _owner, address _spender) external view returns (uint256) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Get if `_acct` is an authorized module&#13;
     * @param _acct Module address&#13;
     * @return Operation status&#13;
     */&#13;
    function getModule(address _acct) external view returns (bool) {&#13;
        return modules[_acct];&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Get total supply&#13;
     * @return Total supply&#13;
     */&#13;
    function getTotalSupply() external view returns (uint256) {&#13;
        return totalSupply;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Increment `_acct` balance by `_val`&#13;
     * @param _acct Target account to increment balance.&#13;
     * @param _val Value to increment&#13;
     * @return Operation status&#13;
     */&#13;
    function incBalance(address _acct, uint _val) public onlyModule returns (bool) {&#13;
        balances[_acct] = balances[_acct].add(_val);&#13;
        emit BalanceAdj(msg.sender, _acct, _val, "+");&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Decrement `_acct` balance by `_val`&#13;
     * @param _acct Target account to decrement balance.&#13;
     * @param _val Value to decrement&#13;
     * @return Operation status&#13;
     */&#13;
    function decBalance(address _acct, uint _val) public onlyModule returns (bool) {&#13;
        balances[_acct] = balances[_acct].sub(_val);&#13;
        emit BalanceAdj(msg.sender, _acct, _val, "-");&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC664 Database Contract&#13;
 * @author Panos&#13;
 */&#13;
contract DStore is ERC664Balances {&#13;
&#13;
    /**&#13;
     * @notice Database construction&#13;
     * @param _totalSupply The total supply of the token&#13;
     */&#13;
    constructor(uint256 _totalSupply) public&#13;
    ERC664Balances(_totalSupply) {&#13;
&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Increase total supply by `_val`&#13;
     * @param _val Value to increase&#13;
     * @return Operation status&#13;
     */&#13;
    // solhint-disable-next-line no-unused-vars&#13;
    function incTotalSupply(uint _val) external onlyOwner returns (bool) {&#13;
        return false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Decrease total supply by `_val`&#13;
     * @param _val Value to decrease&#13;
     * @return Operation status&#13;
     */&#13;
    // solhint-disable-next-line no-unused-vars&#13;
    function decTotalSupply(uint _val) external onlyOwner returns (bool) {&#13;
        return false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice moving `_amount` from `_from` to `_to`&#13;
     * @param _from The sender address&#13;
     * @param _to The receiving address&#13;
     * @param _amount The moving amount&#13;
     * @return bool The move result&#13;
     */&#13;
    function move(address _from, address _to, uint256 _amount) external&#13;
    onlyModule&#13;
    returns (bool) {&#13;
        balances[_from] = balances[_from].sub(_amount);&#13;
        emit BalanceAdj(msg.sender, _from, _amount, "-");&#13;
        balances[_to] = balances[_to].add(_amount);&#13;
        emit BalanceAdj(msg.sender, _to, _amount, "+");&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Increase allowance of `_spender` in behalf of `_from` at `_value`&#13;
     * @param _from Owner account&#13;
     * @param _spender Spender account&#13;
     * @param _value Value to increase&#13;
     * @return Operation status&#13;
     */&#13;
    function incApprove(address _from, address _spender, uint _value) external onlyModule returns (bool) {&#13;
        allowed[_from][_spender] = allowed[_from][_spender].add(_value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Increment `_acct` balance by `_val`&#13;
     * @param _acct Target account to increment balance.&#13;
     * @param _val Value to increment&#13;
     * @return Operation status&#13;
     */&#13;
    // solhint-disable-next-line no-unused-vars&#13;
    function incBalance(address _acct, uint _val) public&#13;
    onlyModule&#13;
    returns (bool) {&#13;
        return false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @notice Decrement `_acct` balance by `_val`&#13;
     * @param _acct Target account to decrement balance.&#13;
     * @param _val Value to decrement&#13;
     * @return Operation status&#13;
     */&#13;
    // solhint-disable-next-line no-unused-vars&#13;
    function decBalance(address _acct, uint _val) public&#13;
    onlyModule&#13;
    returns (bool) {&#13;
        return false;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title PreDeriveum&#13;
 * @dev The Deriveum pre token.&#13;
 *&#13;
 */&#13;
contract PreDeriveum is ERC20, ERC20Detailed, SafeGuard {&#13;
    uint256 public constant INITIAL_SUPPLY = 10000000000 * (10 ** uint256(decimals()));&#13;
    DStore public tokenDB;&#13;
&#13;
    /**&#13;
     * @dev Constructor that gives msg.sender all of existing tokens.&#13;
     */&#13;
    constructor () public ERC20Detailed("Pre-Deriveum", "PDER", 18) {&#13;
        tokenDB = new DStore(INITIAL_SUPPLY);&#13;
        require(tokenDB.setModule(address(this), true));&#13;
        require(tokenDB.move(address(this), msg.sender, INITIAL_SUPPLY));&#13;
        require(tokenDB.transferRoot(msg.sender));&#13;
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Total number of tokens in existence&#13;
    */&#13;
    function totalSupply() public view returns (uint256) {&#13;
        return tokenDB.getTotalSupply();&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Gets the balance of the specified address.&#13;
    * @param owner The address to query the balance of.&#13;
    * @return An uint256 representing the amount owned by the passed address.&#13;
    */&#13;
    function balanceOf(address owner) public view returns (uint256) {&#13;
        return tokenDB.getBalance(owner);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
     * @param owner address The address which owns the funds.&#13;
     * @param spender address The address which will spend the funds.&#13;
     * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
     */&#13;
    function allowance(address owner, address spender) public view returns (uint256) {&#13;
        return tokenDB.getAllowance(owner, spender);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
     * Beware that changing an allowance with this method brings the risk that someone may use both the old&#13;
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this&#13;
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:&#13;
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
     * @param spender The address which will spend the funds.&#13;
     * @param value The amount of tokens to be spent.&#13;
     */&#13;
    function approve(address spender, uint256 value) public returns (bool) {&#13;
        require(spender != address(0));&#13;
&#13;
        require(tokenDB.setApprove(msg.sender, spender, value));&#13;
        emit Approval(msg.sender, spender, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Transfer tokens from one address to another&#13;
     * @param from address The address which you want to send tokens from&#13;
     * @param to address The address which you want to transfer to&#13;
     * @param value uint256 the amount of tokens to be transferred&#13;
     */&#13;
    function transferFrom(address from, address to, uint256 value) public returns (bool) {&#13;
        uint256 allow = tokenDB.getAllowance(from, msg.sender);&#13;
        allow = allow.sub(value);&#13;
        require(tokenDB.setApprove(from, msg.sender, allow));&#13;
        _transfer(from, to, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
     * approve should be called when allowed_[_spender] == 0. To increment&#13;
     * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
     * the first transaction is mined)&#13;
     * From MonolithDAO Token.sol&#13;
     * @param spender The address which will spend the funds.&#13;
     * @param addedValue The amount of tokens to increase the allowance by.&#13;
     */&#13;
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {&#13;
        require(spender != address(0));&#13;
&#13;
        uint256 allow = tokenDB.getAllowance(msg.sender, spender);&#13;
        allow = allow.add(addedValue);&#13;
        require(tokenDB.setApprove(msg.sender, spender, allow));&#13;
        emit Approval(msg.sender, spender, allow);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
     * approve should be called when allowed_[_spender] == 0. To decrement&#13;
     * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
     * the first transaction is mined)&#13;
     * From MonolithDAO Token.sol&#13;
     * @param spender The address which will spend the funds.&#13;
     * @param subtractedValue The amount of tokens to decrease the allowance by.&#13;
     */&#13;
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {&#13;
        require(spender != address(0));&#13;
&#13;
        uint256 allow = tokenDB.getAllowance(msg.sender, spender);&#13;
        allow = allow.sub(subtractedValue);&#13;
        require(tokenDB.setApprove(msg.sender, spender, allow));&#13;
        emit Approval(msg.sender, spender, allow);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Transfer token for a specified addresses&#13;
     * @param from The address to transfer from.&#13;
     * @param to The address to transfer to.&#13;
     * @param value The amount to be transferred.&#13;
     */&#13;
    function _transfer(address from, address to, uint256 value) internal {&#13;
        require(to != address(0));&#13;
&#13;
        require(tokenDB.move(from, to, value));&#13;
        emit Transfer(from, to, value);&#13;
    }&#13;
}