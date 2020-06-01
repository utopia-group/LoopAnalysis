pragma solidity ^0.4.18;

contract ZastrinPay {

  /*
   * Author: Mahesh Murthy
   * Company: Zastrin, Inc
   * Contact: <span class="__cf_email__" data-cfemail="761b171e13051e360c170502041f185815191b">[email protected]</span>&#13;
   */&#13;
&#13;
  address public owner;&#13;
&#13;
  struct paymentInfo {&#13;
    uint userId;&#13;
    uint amount;&#13;
    uint purchasedAt;&#13;
    bool refunded;&#13;
    bool cashedOut;&#13;
  }&#13;
&#13;
  mapping(uint =&gt; bool) coursesOffered;&#13;
  mapping(address =&gt; mapping(uint =&gt; paymentInfo)) customers;&#13;
&#13;
  uint fallbackAmount;&#13;
&#13;
  event NewPayment(uint indexed _courseId, uint indexed _userId, address indexed _customer, uint _amount);&#13;
  event RefundPayment(uint indexed _courseId, uint indexed _userId, address indexed _customer);&#13;
&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  function ZastrinPay() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
  function addCourse(uint _courseId) public onlyOwner {&#13;
    coursesOffered[_courseId] = true;&#13;
  }&#13;
&#13;
  function buyCourse(uint _courseId, uint _userId) public payable {&#13;
    require(coursesOffered[_courseId]);&#13;
    customers[msg.sender][_courseId].amount += msg.value;&#13;
    customers[msg.sender][_courseId].purchasedAt = now;&#13;
    customers[msg.sender][_courseId].userId = _userId;&#13;
    NewPayment(_courseId, _userId, msg.sender, msg.value);&#13;
  }&#13;
&#13;
  function getRefund(uint _courseId) public {&#13;
    require(customers[msg.sender][_courseId].userId &gt; 0);&#13;
    require(customers[msg.sender][_courseId].refunded == false);&#13;
    require(customers[msg.sender][_courseId].purchasedAt + (3 hours) &gt; now);&#13;
    customers[msg.sender][_courseId].refunded = true;&#13;
    msg.sender.transfer(customers[msg.sender][_courseId].amount);&#13;
    RefundPayment(_courseId, customers[msg.sender][_courseId].userId, msg.sender);&#13;
  }&#13;
&#13;
  function cashOut(address _customer, uint _courseId) public onlyOwner {&#13;
    require(customers[_customer][_courseId].refunded == false);&#13;
    require(customers[_customer][_courseId].cashedOut == false);&#13;
    require(customers[_customer][_courseId].purchasedAt + (3 hours) &lt; now);&#13;
    customers[_customer][_courseId].cashedOut = true;&#13;
    owner.transfer(customers[_customer][_courseId].amount);&#13;
  }&#13;
&#13;
  function cashOutFallbackAmount() public onlyOwner {&#13;
    owner.transfer(fallbackAmount);&#13;
  }&#13;
&#13;
  function() public payable {&#13;
    fallbackAmount += msg.value;&#13;
  }&#13;
}