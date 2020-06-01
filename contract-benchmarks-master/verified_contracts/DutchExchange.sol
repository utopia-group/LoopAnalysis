pragma solidity ^0.4.21;

// File: contracts/Oracle/DSAuth.sol

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() public {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}

// File: contracts/Oracle/DSMath.sol

contract DSMath {
    
    /*
    standard uint256 functions
     */

    function add(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x * y) >= x);
    }

    function div(uint256 x, uint256 y) constant internal returns (uint256 z) {
        z = x / y;
    }

    function min(uint256 x, uint256 y) constant internal returns (uint256 z) {
        return x <= y ? x : y;
    }
    function max(uint256 x, uint256 y) constant internal returns (uint256 z) {
        return x >= y ? x : y;
    }

    /*
    uint128 functions (h is for half)
     */


    function hadd(uint128 x, uint128 y) constant internal returns (uint128 z) {
        assert((z = x + y) >= x);
    }

    function hsub(uint128 x, uint128 y) constant internal returns (uint128 z) {
        assert((z = x - y) <= x);
    }

    function hmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        assert((z = x * y) >= x);
    }

    function hdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = x / y;
    }

    function hmin(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x <= y ? x : y;
    }
    function hmax(uint128 x, uint128 y) constant internal returns (uint128 z) {
        return x >= y ? x : y;
    }


    /*
    int256 functions
     */

    function imin(int256 x, int256 y) constant internal returns (int256 z) {
        return x <= y ? x : y;
    }
    function imax(int256 x, int256 y) constant internal returns (int256 z) {
        return x >= y ? x : y;
    }

    /*
    WAD math
     */

    uint128 constant WAD = 10 ** 18;

    function wadd(uint128 x, uint128 y) constant internal returns (uint128) {
        return hadd(x, y);
    }

    function wsub(uint128 x, uint128 y) constant internal returns (uint128) {
        return hsub(x, y);
    }

    function wmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * y + WAD / 2) / WAD);
    }

    function wdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * WAD + y / 2) / y);
    }

    function wmin(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmin(x, y);
    }
    function wmax(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmax(x, y);
    }

    /*
    RAY math
     */

    uint128 constant RAY = 10 ** 27;

    function radd(uint128 x, uint128 y) constant internal returns (uint128) {
        return hadd(x, y);
    }

    function rsub(uint128 x, uint128 y) constant internal returns (uint128) {
        return hsub(x, y);
    }

    function rmul(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * y + RAY / 2) / RAY);
    }

    function rdiv(uint128 x, uint128 y) constant internal returns (uint128 z) {
        z = cast((uint256(x) * RAY + y / 2) / y);
    }

    function rpow(uint128 x, uint64 n) constant internal returns (uint128 z) {
        // This famous algorithm is called "exponentiation by squaring"
        // and calculates x^n with x as fixed-point and n as regular unsigned.
        //
        // It's O(log n), instead of O(n) for naive repeated multiplication.
        //
        // These facts are why it works:
        //
        //  If n is even, then x^n = (x^2)^(n/2).
        //  If n is odd,  then x^n = x * x^(n-1),
        //   and applying the equation for even x gives
        //    x^n = x * (x^2)^((n-1) / 2).
        //
        //  Also, EVM division is flooring and
        //    floor[(n-1) / 2] = floor[n / 2].

        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }

    function rmin(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmin(x, y);
    }
    function rmax(uint128 x, uint128 y) constant internal returns (uint128) {
        return hmax(x, y);
    }

    function cast(uint256 x) constant internal returns (uint128 z) {
        assert((z = uint128(x)) == x);
    }

}

// File: contracts/Oracle/DSNote.sol

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

// File: contracts/Oracle/DSThing.sol

contract DSThing is DSAuth, DSNote, DSMath {
}

// File: contracts/Oracle/DSValue.sol

contract DSValue is DSThing {
    bool    has;
    bytes32 val;
    function peek() constant returns (bytes32, bool) {
        return (val,has);
    }
    function read() constant returns (bytes32) {
        var (wut, has) = peek();
        assert(has);
        return wut;
    }
    function poke(bytes32 wut) note auth {
        val = wut;
        has = true;
    }
    function void() note auth { // unset the value
        has = false;
    }
}

// File: contracts/Oracle/Medianizer.sol

contract Medianizer is DSValue {
    mapping (bytes12 => address) public values;
    mapping (address => bytes12) public indexes;
    bytes12 public next = 0x1;

    uint96 public min = 0x1;

    function set(address wat) auth {
        bytes12 nextId = bytes12(uint96(next) + 1);
        assert(nextId != 0x0);
        set(next, wat);
        next = nextId;
    }

    function set(bytes12 pos, address wat) note auth {
        if (pos == 0x0) throw;

        if (wat != 0 && indexes[wat] != 0) throw;

        indexes[values[pos]] = 0; // Making sure to remove a possible existing address in that position

        if (wat != 0) {
            indexes[wat] = pos;
        }

        values[pos] = wat;
    }

    function setMin(uint96 min_) note auth {
        if (min_ == 0x0) throw;
        min = min_;
    }

    function setNext(bytes12 next_) note auth {
        if (next_ == 0x0) throw;
        next = next_;
    }

    function unset(bytes12 pos) {
        set(pos, 0);
    }

    function unset(address wat) {
        set(indexes[wat], 0);
    }

    function poke() {
        poke(0);
    }

    function poke(bytes32) note {
        (val, has) = compute();
    }

    function compute() constant returns (bytes32, bool) {
        bytes32[] memory wuts = new bytes32[](uint96(next) - 1);
        uint96 ctr = 0;
        for (uint96 i = 1; i < uint96(next); i++) {
            if (values[bytes12(i)] != 0) {
                var (wut, wuz) = DSValue(values[bytes12(i)]).peek();
                if (wuz) {
                    if (ctr == 0 || wut >= wuts[ctr - 1]) {
                        wuts[ctr] = wut;
                    } else {
                        uint96 j = 0;
                        while (wut >= wuts[j]) {
                            j++;
                        }
                        for (uint96 k = ctr; k > j; k--) {
                            wuts[k] = wuts[k - 1];
                        }
                        wuts[j] = wut;
                    }
                    ctr++;
                }
            }
        }

        if (ctr < min) return (val, false);

        bytes32 value;
        if (ctr % 2 == 0) {
            uint128 val1 = uint128(wuts[(ctr / 2) - 1]);
            uint128 val2 = uint128(wuts[ctr / 2]);
            value = bytes32(wdiv(hadd(val1, val2), 2 ether));
        } else {
            value = wuts[(ctr - 1) / 2];
        }

        return (value, true);
    }
}

// File: contracts/Oracle/PriceFeed.sol

/// price-feed.sol

// Copyright (C) 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).



contract PriceFeed is DSThing {

    uint128 val;
    uint32 public zzz;

    function peek() public view
        returns (bytes32, bool)
    {
        return (bytes32(val), now < zzz);
    }

    function read() public view
        returns (bytes32)
    {
        assert(now < zzz);
        return bytes32(val);
    }

    function post(uint128 val_, uint32 zzz_, address med_) public note auth
    {
        val = val_;
        zzz = zzz_;
        bool ret = med_.call(bytes4(keccak256("poke()")));
        ret;
    }

    function void() public note auth
    {
        zzz = 0;
    }

}

// File: contracts/Oracle/PriceOracleInterface.sol

/*
This contract is the interface between the MakerDAO priceFeed and our DX platform.
*/



contract PriceOracleInterface {

    address public priceFeedSource;
    address public owner;
    bool public emergencyMode;

    event NonValidPriceFeed(address priceFeedSource);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @dev constructor of the contract
    /// @param _priceFeedSource address of price Feed Source -> should be maker feeds Medianizer contract
    function PriceOracleInterface(
        address _owner,
        address _priceFeedSource
    )
        public
    {
        owner = _owner;
        priceFeedSource = _priceFeedSource;
    }
    /// @dev gives the owner the possibility to put the Interface into an emergencyMode, which will 
    /// output always a price of 600 USD. This gives everyone time to set up a new pricefeed.
    function raiseEmergency(bool _emergencyMode)
        public
        onlyOwner()
    {
        emergencyMode = _emergencyMode;
    }

    /// @dev updates the priceFeedSource
    /// @param _owner address of owner
    function updateCurator(
        address _owner
    )
        public
        onlyOwner()
    {
        owner = _owner;
    }

    /// @dev returns the USDETH price, ie gets the USD price from Maker feed with 18 digits, but last 18 digits are cut off
    function getUSDETHPrice() 
        public
        returns (uint256)
    {
        // if the contract is in the emergencyMode, because there is an issue with the oracle, we will simply return a price of 600 USD
        if(emergencyMode){
            return 600;
        }

        bytes32 price;
        bool valid=true;
        (price, valid) = Medianizer(priceFeedSource).peek();
        if (!valid) {
            NonValidPriceFeed(priceFeedSource);
        }
        // ensuring that there is no underflow or overflow possible,
        // even if the price is compromised
        uint priceUint = uint256(price)/(1 ether);
        if (priceUint == 0) return 1;
        if (priceUint > 1000000) return 1000000; 
        return priceUint;
    }  
}

// File: @gnosis.pm/util-contracts/contracts/Math.sol

/// @title Math library - Allows calculation of logarithmic and exponential functions
/// @author Alan Lu - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a2c3cec3cc8cced7e2c5cccdd1cbd18cd2cf">[email protected]</a>&gt;&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="7e0d0a1b181f103e1910110d170d500e13">[email protected]</a>&gt;&#13;
library Math {&#13;
&#13;
    /*&#13;
     *  Constants&#13;
     */&#13;
    // This is equal to 1 in our calculations&#13;
    uint public constant ONE =  0x10000000000000000;&#13;
    uint public constant LN2 = 0xb17217f7d1cf79ac;&#13;
    uint public constant LOG2_E = 0x171547652b82fe177;&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Returns natural exponential function value of given x&#13;
    /// @param x x&#13;
    /// @return e**x&#13;
    function exp(int x)&#13;
        public&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        // revert if x is &gt; MAX_POWER, where&#13;
        // MAX_POWER = int(mp.floor(mp.log(mpf(2**256 - 1) / ONE) * ONE))&#13;
        require(x &lt;= 2454971259878909886679);&#13;
        // return 0 if exp(x) is tiny, using&#13;
        // MIN_POWER = int(mp.floor(mp.log(mpf(1) / ONE) * ONE))&#13;
        if (x &lt; -818323753292969962227)&#13;
            return 0;&#13;
        // Transform so that e^x -&gt; 2^x&#13;
        x = x * int(ONE) / int(LN2);&#13;
        // 2^x = 2^whole(x) * 2^frac(x)&#13;
        //       ^^^^^^^^^^ is a bit shift&#13;
        // so Taylor expand on z = frac(x)&#13;
        int shift;&#13;
        uint z;&#13;
        if (x &gt;= 0) {&#13;
            shift = x / int(ONE);&#13;
            z = uint(x % int(ONE));&#13;
        }&#13;
        else {&#13;
            shift = x / int(ONE) - 1;&#13;
            z = ONE - uint(-x % int(ONE));&#13;
        }&#13;
        // 2^x = 1 + (ln 2) x + (ln 2)^2/2! x^2 + ...&#13;
        //&#13;
        // Can generate the z coefficients using mpmath and the following lines&#13;
        // &gt;&gt;&gt; from mpmath import mp&#13;
        // &gt;&gt;&gt; mp.dps = 100&#13;
        // &gt;&gt;&gt; ONE =  0x10000000000000000&#13;
        // &gt;&gt;&gt; print('\n'.join(hex(int(mp.log(2)**i / mp.factorial(i) * ONE)) for i in range(1, 7)))&#13;
        // 0xb17217f7d1cf79ab&#13;
        // 0x3d7f7bff058b1d50&#13;
        // 0xe35846b82505fc5&#13;
        // 0x276556df749cee5&#13;
        // 0x5761ff9e299cc4&#13;
        // 0xa184897c363c3&#13;
        uint zpow = z;&#13;
        uint result = ONE;&#13;
        result += 0xb17217f7d1cf79ab * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x3d7f7bff058b1d50 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0xe35846b82505fc5 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x276556df749cee5 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x5761ff9e299cc4 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0xa184897c363c3 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0xffe5fe2c4586 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x162c0223a5c8 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x1b5253d395e * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x1e4cf5158b * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x1e8cac735 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x1c3bd650 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x1816193 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x131496 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0xe1b7 * zpow / ONE;&#13;
        zpow = zpow * z / ONE;&#13;
        result += 0x9c7 * zpow / ONE;&#13;
        if (shift &gt;= 0) {&#13;
            if (result &gt;&gt; (256-shift) &gt; 0)&#13;
                return (2**256-1);&#13;
            return result &lt;&lt; shift;&#13;
        }&#13;
        else&#13;
            return result &gt;&gt; (-shift);&#13;
    }&#13;
&#13;
    /// @dev Returns natural logarithm value of given x&#13;
    /// @param x x&#13;
    /// @return ln(x)&#13;
    function ln(uint x)&#13;
        public&#13;
        pure&#13;
        returns (int)&#13;
    {&#13;
        require(x &gt; 0);&#13;
        // binary search for floor(log2(x))&#13;
        int ilog2 = floorLog2(x);&#13;
        int z;&#13;
        if (ilog2 &lt; 0)&#13;
            z = int(x &lt;&lt; uint(-ilog2));&#13;
        else&#13;
            z = int(x &gt;&gt; uint(ilog2));&#13;
        // z = x * 2^-⌊log₂x⌋&#13;
        // so 1 &lt;= z &lt; 2&#13;
        // and ln z = ln x - ⌊log₂x⌋/log₂e&#13;
        // so just compute ln z using artanh series&#13;
        // and calculate ln x from that&#13;
        int term = (z - int(ONE)) * int(ONE) / (z + int(ONE));&#13;
        int halflnz = term;&#13;
        int termpow = term * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 3;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 5;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 7;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 9;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 11;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 13;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 15;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 17;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 19;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 21;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 23;&#13;
        termpow = termpow * term / int(ONE) * term / int(ONE);&#13;
        halflnz += termpow / 25;&#13;
        return (ilog2 * int(ONE)) * int(ONE) / int(LOG2_E) + 2 * halflnz;&#13;
    }&#13;
&#13;
    /// @dev Returns base 2 logarithm value of given x&#13;
    /// @param x x&#13;
    /// @return logarithmic value&#13;
    function floorLog2(uint x)&#13;
        public&#13;
        pure&#13;
        returns (int lo)&#13;
    {&#13;
        lo = -64;&#13;
        int hi = 193;&#13;
        // I use a shift here instead of / 2 because it floors instead of rounding towards 0&#13;
        int mid = (hi + lo) &gt;&gt; 1;&#13;
        while((lo + 1) &lt; hi) {&#13;
            if (mid &lt; 0 &amp;&amp; x &lt;&lt; uint(-mid) &lt; ONE || mid &gt;= 0 &amp;&amp; x &gt;&gt; uint(mid) &lt; ONE)&#13;
                hi = mid;&#13;
            else&#13;
                lo = mid;&#13;
            mid = (hi + lo) &gt;&gt; 1;&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Returns maximum of an array&#13;
    /// @param nums Numbers to look through&#13;
    /// @return Maximum number&#13;
    function max(int[] nums)&#13;
        public&#13;
        pure&#13;
        returns (int maxNum)&#13;
    {&#13;
        require(nums.length &gt; 0);&#13;
        maxNum = -2**255;&#13;
        for (uint i = 0; i &lt; nums.length; i++)&#13;
            if (nums[i] &gt; maxNum)&#13;
                maxNum = nums[i];&#13;
    }&#13;
&#13;
    /// @dev Returns whether an add operation causes an overflow&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Did no overflow occur?&#13;
    function safeToAdd(uint a, uint b)&#13;
        internal&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        return a + b &gt;= a;&#13;
    }&#13;
&#13;
    /// @dev Returns whether a subtraction operation causes an underflow&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Did no underflow occur?&#13;
    function safeToSub(uint a, uint b)&#13;
        internal&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        return a &gt;= b;&#13;
    }&#13;
&#13;
    /// @dev Returns whether a multiply operation causes an overflow&#13;
    /// @param a First factor&#13;
    /// @param b Second factor&#13;
    /// @return Did no overflow occur?&#13;
    function safeToMul(uint a, uint b)&#13;
        internal&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        return b == 0 || a * b / b == a;&#13;
    }&#13;
&#13;
    /// @dev Returns sum if no overflow occurred&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Sum&#13;
    function add(uint a, uint b)&#13;
        internal&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToAdd(a, b));&#13;
        return a + b;&#13;
    }&#13;
&#13;
    /// @dev Returns difference if no overflow occurred&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Difference&#13;
    function sub(uint a, uint b)&#13;
        internal&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToSub(a, b));&#13;
        return a - b;&#13;
    }&#13;
&#13;
    /// @dev Returns product if no overflow occurred&#13;
    /// @param a First factor&#13;
    /// @param b Second factor&#13;
    /// @return Product&#13;
    function mul(uint a, uint b)&#13;
        internal&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToMul(a, b));&#13;
        return a * b;&#13;
    }&#13;
&#13;
    /// @dev Returns whether an add operation causes an overflow&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Did no overflow occur?&#13;
    function safeToAdd(int a, int b)&#13;
        internal&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        return (b &gt;= 0 &amp;&amp; a + b &gt;= a) || (b &lt; 0 &amp;&amp; a + b &lt; a);&#13;
    }&#13;
&#13;
    /// @dev Returns whether a subtraction operation causes an underflow&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Did no underflow occur?&#13;
    function safeToSub(int a, int b)&#13;
        internal&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        return (b &gt;= 0 &amp;&amp; a - b &lt;= a) || (b &lt; 0 &amp;&amp; a - b &gt; a);&#13;
    }&#13;
&#13;
    /// @dev Returns whether a multiply operation causes an overflow&#13;
    /// @param a First factor&#13;
    /// @param b Second factor&#13;
    /// @return Did no overflow occur?&#13;
    function safeToMul(int a, int b)&#13;
        internal&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        return (b == 0) || (a * b / b == a);&#13;
    }&#13;
&#13;
    /// @dev Returns sum if no overflow occurred&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Sum&#13;
    function add(int a, int b)&#13;
        internal&#13;
        pure&#13;
        returns (int)&#13;
    {&#13;
        require(safeToAdd(a, b));&#13;
        return a + b;&#13;
    }&#13;
&#13;
    /// @dev Returns difference if no overflow occurred&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Difference&#13;
    function sub(int a, int b)&#13;
        internal&#13;
        pure&#13;
        returns (int)&#13;
    {&#13;
        require(safeToSub(a, b));&#13;
        return a - b;&#13;
    }&#13;
&#13;
    /// @dev Returns product if no overflow occurred&#13;
    /// @param a First factor&#13;
    /// @param b Second factor&#13;
    /// @return Product&#13;
    function mul(int a, int b)&#13;
        internal&#13;
        pure&#13;
        returns (int)&#13;
    {&#13;
        require(safeToMul(a, b));&#13;
        return a * b;&#13;
    }&#13;
}&#13;
&#13;
// File: @gnosis.pm/util-contracts/contracts/Proxy.sol&#13;
&#13;
/// @title Proxied - indicates that a contract will be proxied. Also defines storage requirements for Proxy.&#13;
/// @author Alan Lu - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="553439343b15323b3a263c267b2538">[email protected]</a>&gt;&#13;
contract Proxied {&#13;
    address public masterCopy;&#13;
}&#13;
&#13;
/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c3b0b7a6a5a2ad83a4adacb0aab0edb3ae">[email protected]</a>&gt;&#13;
contract Proxy is Proxied {&#13;
    /// @dev Constructor function sets address of master copy contract.&#13;
    /// @param _masterCopy Master copy address.&#13;
    function Proxy(address _masterCopy)&#13;
        public&#13;
    {&#13;
        require(_masterCopy != 0);&#13;
        masterCopy = _masterCopy;&#13;
    }&#13;
&#13;
    /// @dev Fallback function forwards all transactions and returns all received return data.&#13;
    function ()&#13;
        external&#13;
        payable&#13;
    {&#13;
        address _masterCopy = masterCopy;&#13;
        assembly {&#13;
            calldatacopy(0, 0, calldatasize())&#13;
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)&#13;
            returndatacopy(0, 0, returndatasize())&#13;
            switch success&#13;
            case 0 { revert(0, returndatasize()) }&#13;
            default { return(0, returndatasize()) }&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
// File: @gnosis.pm/util-contracts/contracts/Token.sol&#13;
&#13;
/// Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md&#13;
pragma solidity ^0.4.21;&#13;
&#13;
&#13;
/// @title Abstract token contract - Functions to be implemented by token contracts&#13;
contract Token {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event Transfer(address indexed from, address indexed to, uint value);&#13;
    event Approval(address indexed owner, address indexed spender, uint value);&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    function transfer(address to, uint value) public returns (bool);&#13;
    function transferFrom(address from, address to, uint value) public returns (bool);&#13;
    function approve(address spender, uint value) public returns (bool);&#13;
    function balanceOf(address owner) public view returns (uint);&#13;
    function allowance(address owner, address spender) public view returns (uint);&#13;
    function totalSupply() public view returns (uint);&#13;
}&#13;
&#13;
// File: @gnosis.pm/util-contracts/contracts/StandardToken.sol&#13;
&#13;
contract StandardTokenData {&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    mapping (address =&gt; uint) balances;&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) allowances;&#13;
    uint totalTokens;&#13;
}&#13;
&#13;
/// @title Standard token contract with overflow protection&#13;
contract StandardToken is Token, StandardTokenData {&#13;
    using Math for *;&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Transfers sender's tokens to a given address. Returns success&#13;
    /// @param to Address of token receiver&#13;
    /// @param value Number of tokens to transfer&#13;
    /// @return Was transfer successful?&#13;
    function transfer(address to, uint value)&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        if (   !balances[msg.sender].safeToSub(value)&#13;
            || !balances[to].safeToAdd(value))&#13;
            return false;&#13;
        balances[msg.sender] -= value;&#13;
        balances[to] += value;&#13;
        emit Transfer(msg.sender, to, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success&#13;
    /// @param from Address from where tokens are withdrawn&#13;
    /// @param to Address to where tokens are sent&#13;
    /// @param value Number of tokens to transfer&#13;
    /// @return Was transfer successful?&#13;
    function transferFrom(address from, address to, uint value)&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        if (   !balances[from].safeToSub(value)&#13;
            || !allowances[from][msg.sender].safeToSub(value)&#13;
            || !balances[to].safeToAdd(value))&#13;
            return false;&#13;
        balances[from] -= value;&#13;
        allowances[from][msg.sender] -= value;&#13;
        balances[to] += value;&#13;
        emit Transfer(from, to, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Sets approved amount of tokens for spender. Returns success&#13;
    /// @param spender Address of allowed account&#13;
    /// @param value Number of approved tokens&#13;
    /// @return Was approval successful?&#13;
    function approve(address spender, uint value)&#13;
        public&#13;
        returns (bool)&#13;
    {&#13;
        allowances[msg.sender][spender] = value;&#13;
        emit Approval(msg.sender, spender, value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev Returns number of allowed tokens for given address&#13;
    /// @param owner Address of token owner&#13;
    /// @param spender Address of token spender&#13;
    /// @return Remaining allowance for spender&#13;
    function allowance(address owner, address spender)&#13;
        public&#13;
        view&#13;
        returns (uint)&#13;
    {&#13;
        return allowances[owner][spender];&#13;
    }&#13;
&#13;
    /// @dev Returns number of tokens owned by given address&#13;
    /// @param owner Address of token owner&#13;
    /// @return Balance of owner&#13;
    function balanceOf(address owner)&#13;
        public&#13;
        view&#13;
        returns (uint)&#13;
    {&#13;
        return balances[owner];&#13;
    }&#13;
&#13;
    /// @dev Returns total supply of tokens&#13;
    /// @return Total supply&#13;
    function totalSupply()&#13;
        public&#13;
        view&#13;
        returns (uint)&#13;
    {&#13;
        return totalTokens;&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/TokenFRT.sol&#13;
&#13;
/// @title Standard token contract with overflow protection&#13;
contract TokenFRT is StandardToken {&#13;
    string public constant symbol = "MGN";&#13;
    string public constant name = "Magnolia Token";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    struct unlockedToken {&#13;
        uint amountUnlocked;&#13;
        uint withdrawalTime;&#13;
    }&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
&#13;
    address public owner;&#13;
    address public minter;&#13;
&#13;
    // user =&gt; unlockedToken&#13;
    mapping (address =&gt; unlockedToken) public unlockedTokens;&#13;
&#13;
    // user =&gt; amount&#13;
    mapping (address =&gt; uint) public lockedTokenBalances;&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
&#13;
    function TokenFRT(&#13;
        address _owner&#13;
    )&#13;
        public&#13;
    {&#13;
        require(_owner != address(0));&#13;
        owner = _owner;&#13;
    }&#13;
&#13;
    // @dev allows to set the minter of Magnolia tokens once.&#13;
    // @param   _minter the minter of the Magnolia tokens, should be the DX-proxy&#13;
    function updateMinter(&#13;
        address _minter&#13;
    )&#13;
        public&#13;
    {&#13;
        require(msg.sender == owner);&#13;
        require(_minter != address(0));&#13;
&#13;
        minter = _minter;&#13;
    }&#13;
&#13;
    // @dev the intention is to set the owner as the DX-proxy, once it is deployed&#13;
    // Then only an update of the DX-proxy contract after a 30 days delay could change the minter again.&#13;
    function updateOwner(   &#13;
        address _owner&#13;
    )&#13;
        public&#13;
    {&#13;
        require(msg.sender == owner);&#13;
        require(_owner != address(0));&#13;
        owner = _owner;&#13;
    }&#13;
&#13;
    function mintTokens(&#13;
        address user,&#13;
        uint amount&#13;
    )&#13;
        public&#13;
    {&#13;
        require(msg.sender == minter);&#13;
&#13;
        lockedTokenBalances[user] = add(lockedTokenBalances[user], amount);&#13;
        totalTokens = add(totalTokens, amount);&#13;
    }&#13;
&#13;
    /// @dev Lock Token&#13;
    function lockTokens(&#13;
        uint amount&#13;
    )&#13;
        public&#13;
        returns (uint totalAmountLocked)&#13;
    {&#13;
        // Adjust amount by balance&#13;
        amount = min(amount, balances[msg.sender]);&#13;
        &#13;
        // Update state variables&#13;
        balances[msg.sender] = sub(balances[msg.sender], amount);&#13;
        lockedTokenBalances[msg.sender] = add(lockedTokenBalances[msg.sender], amount);&#13;
&#13;
        // Get return variable&#13;
        totalAmountLocked = lockedTokenBalances[msg.sender];&#13;
    }&#13;
&#13;
    function unlockTokens(&#13;
        uint amount&#13;
    )&#13;
        public&#13;
        returns (uint totalAmountUnlocked, uint withdrawalTime)&#13;
    {&#13;
        // Adjust amount by locked balances&#13;
        amount = min(amount, lockedTokenBalances[msg.sender]);&#13;
&#13;
        if (amount &gt; 0) {&#13;
            // Update state variables&#13;
            lockedTokenBalances[msg.sender] = sub(lockedTokenBalances[msg.sender], amount);&#13;
            unlockedTokens[msg.sender].amountUnlocked =  add(unlockedTokens[msg.sender].amountUnlocked, amount);&#13;
            unlockedTokens[msg.sender].withdrawalTime = now + 24 hours;&#13;
        }&#13;
&#13;
        // Get return variables&#13;
        totalAmountUnlocked = unlockedTokens[msg.sender].amountUnlocked;&#13;
        withdrawalTime = unlockedTokens[msg.sender].withdrawalTime;&#13;
    }&#13;
&#13;
    function withdrawUnlockedTokens()&#13;
        public&#13;
    {&#13;
        require(unlockedTokens[msg.sender].withdrawalTime &lt; now);&#13;
        balances[msg.sender] = add(balances[msg.sender], unlockedTokens[msg.sender].amountUnlocked);&#13;
        unlockedTokens[msg.sender].amountUnlocked = 0;&#13;
    }&#13;
&#13;
    function min(uint a, uint b) &#13;
        public&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        if (a &lt; b) {&#13;
            return a;&#13;
        } else {&#13;
            return b;&#13;
        }&#13;
    }&#13;
        /// @dev Returns whether an add operation causes an overflow&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Did no overflow occur?&#13;
    function safeToAdd(uint a, uint b)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        return a + b &gt;= a;&#13;
    }&#13;
&#13;
    /// @dev Returns whether a subtraction operation causes an underflow&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Did no underflow occur?&#13;
    function safeToSub(uint a, uint b)&#13;
        public&#13;
        constant&#13;
        returns (bool)&#13;
    {&#13;
        return a &gt;= b;&#13;
    }&#13;
&#13;
&#13;
    /// @dev Returns sum if no overflow occurred&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Sum&#13;
    function add(uint a, uint b)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToAdd(a, b));&#13;
        return a + b;&#13;
    }&#13;
&#13;
    /// @dev Returns difference if no overflow occurred&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Difference&#13;
    function sub(uint a, uint b)&#13;
        public&#13;
        constant&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToSub(a, b));&#13;
        return a - b;&#13;
    }&#13;
}&#13;
&#13;
// File: @gnosis.pm/owl-token/contracts/TokenOWL.sol&#13;
&#13;
contract TokenOWL is Proxied, StandardToken {&#13;
    using Math for *;&#13;
&#13;
    string public constant name = "OWL Token";&#13;
    string public constant symbol = "OWL";&#13;
    uint8 public constant decimals = 18;&#13;
&#13;
    struct masterCopyCountdownType {&#13;
        address masterCopy;&#13;
        uint timeWhenAvailable;&#13;
    }&#13;
&#13;
    masterCopyCountdownType masterCopyCountdown;&#13;
&#13;
    address public creator;&#13;
    address public minter;&#13;
&#13;
    event Minted(address indexed to, uint256 amount);&#13;
    event Burnt(address indexed from, address indexed user, uint256 amount);&#13;
&#13;
    modifier onlyCreator() {&#13;
        // R1&#13;
        require(msg.sender == creator);&#13;
        _;&#13;
    }&#13;
    /// @dev trickers the update process via the proxyMaster for a new address _masterCopy &#13;
    /// updating is only possible after 30 days&#13;
    function startMasterCopyCountdown (&#13;
        address _masterCopy&#13;
     )&#13;
        public&#13;
        onlyCreator()&#13;
    {&#13;
        require(address(_masterCopy) != 0);&#13;
&#13;
        // Update masterCopyCountdown&#13;
        masterCopyCountdown.masterCopy = _masterCopy;&#13;
        masterCopyCountdown.timeWhenAvailable = now + 30 days;&#13;
    }&#13;
&#13;
     /// @dev executes the update process via the proxyMaster for a new address _masterCopy&#13;
    function updateMasterCopy()&#13;
        public&#13;
        onlyCreator()&#13;
    {   &#13;
        require(address(masterCopyCountdown.masterCopy) != 0);&#13;
        require(now &gt;= masterCopyCountdown.timeWhenAvailable);&#13;
&#13;
        // Update masterCopy&#13;
        masterCopy = masterCopyCountdown.masterCopy;&#13;
    }&#13;
&#13;
    function getMasterCopy()&#13;
        public&#13;
        view&#13;
        returns (address)&#13;
    {&#13;
        return masterCopy;&#13;
    }&#13;
&#13;
    /// @dev Set minter. Only the creator of this contract can call this.&#13;
    /// @param newMinter The new address authorized to mint this token&#13;
    function setMinter(address newMinter)&#13;
        public&#13;
        onlyCreator()&#13;
    {&#13;
        minter = newMinter;&#13;
    }&#13;
&#13;
&#13;
    /// @dev change owner/creator of the contract. Only the creator/owner of this contract can call this.&#13;
    /// @param newOwner The new address, which should become the owner&#13;
    function setNewOwner(address newOwner)&#13;
        public&#13;
        onlyCreator()&#13;
    {&#13;
        creator = newOwner;&#13;
    }&#13;
&#13;
    /// @dev Mints OWL.&#13;
    /// @param to Address to which the minted token will be given&#13;
    /// @param amount Amount of OWL to be minted&#13;
    function mintOWL(address to, uint amount)&#13;
        public&#13;
    {&#13;
        require(minter != 0 &amp;&amp; msg.sender == minter);&#13;
        balances[to] = balances[to].add(amount);&#13;
        totalTokens = totalTokens.add(amount);&#13;
        emit Minted(to, amount);&#13;
    }&#13;
&#13;
    /// @dev Burns OWL.&#13;
    /// @param user Address of OWL owner&#13;
    /// @param amount Amount of OWL to be burnt&#13;
    function burnOWL(address user, uint amount)&#13;
        public&#13;
    {&#13;
        allowances[user][msg.sender] = allowances[user][msg.sender].sub(amount);&#13;
        balances[user] = balances[user].sub(amount);&#13;
        totalTokens = totalTokens.sub(amount);&#13;
        emit Burnt(msg.sender, user, amount);&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/DutchExchange.sol&#13;
&#13;
/// @title Dutch Exchange - exchange token pairs with the clever mechanism of the dutch auction&#13;
/// @author Alex Herrmann - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="63020f061b23040d0c100a104d130e">[email protected]</a>&gt;&#13;
/// @author Dominik Teiml - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="14707b797d7a7d7f54737a7b677d673a6479">[email protected]</a>&gt;&#13;
&#13;
contract DutchExchange is Proxied {&#13;
    address masterCopy;&#13;
    // The price is a rational number, so we need a concept of a fraction&#13;
    struct fraction {&#13;
        uint num;&#13;
        uint den;&#13;
    }&#13;
&#13;
    uint constant WAITING_PERIOD_NEW_TOKEN_PAIR = 6 hours;&#13;
    uint constant WAITING_PERIOD_NEW_AUCTION = 10 minutes;&#13;
    uint constant WAITING_PERIOD_CHANGE_MASTERCOPY_OR_ORACLE = 30 days;&#13;
    uint constant AUCTION_START_WAITING_FOR_FUNDING = 1;&#13;
&#13;
    address public newMasterCopy;&#13;
    // Time when new masterCopy is updatabale&#13;
    uint public masterCopyCountdown;&#13;
&#13;
    // &gt; Storage&#13;
    // auctioneer has the power to manage some variables&#13;
    address public auctioneer;&#13;
    // Ether ERC-20 token&#13;
    address public ethToken;&#13;
    // Price Oracle interface &#13;
    PriceOracleInterface public ethUSDOracle;&#13;
    // Price Oracle interface proposals during update process&#13;
    PriceOracleInterface public newProposalEthUSDOracle;&#13;
    uint public oracleInterfaceCountdown;&#13;
    // Minimum required sell funding for adding a new token pair, in USD&#13;
    uint public thresholdNewTokenPair;&#13;
    // Minimum required sell funding for starting antoher auction, in USD&#13;
    uint public thresholdNewAuction;&#13;
    // Fee reduction token (magnolia, ERC-20 token)&#13;
    TokenFRT public frtToken;&#13;
    // Token for paying fees&#13;
    TokenOWL public owlToken;&#13;
&#13;
    // mapping that stores the tokens, which are approved&#13;
    // Token =&gt; approved&#13;
    // Only tokens approved by auctioneer generate frtToken tokens&#13;
    mapping (address =&gt; bool) public approvedTokens;&#13;
&#13;
    // For the following two mappings, there is one mapping for each token pair&#13;
    // The order which the tokens should be called is smaller, larger&#13;
    // These variables should never be called directly! They have getters below&#13;
    // Token =&gt; Token =&gt; index&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) public latestAuctionIndices;&#13;
    // Token =&gt; Token =&gt; time&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) public auctionStarts;&#13;
&#13;
    // Token =&gt; Token =&gt; auctionIndex =&gt; price&#13;
    mapping (address =&gt; mapping (address =&gt; mapping (uint =&gt; fraction))) public closingPrices;&#13;
&#13;
    // Token =&gt; Token =&gt; amount&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) public sellVolumesCurrent;&#13;
    // Token =&gt; Token =&gt; amount&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) public sellVolumesNext;&#13;
    // Token =&gt; Token =&gt; amount&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) public buyVolumes;&#13;
&#13;
    // Token =&gt; user =&gt; amount&#13;
    // balances stores a user's balance in the DutchX&#13;
    mapping (address =&gt; mapping (address =&gt; uint)) public balances;&#13;
&#13;
    // Token =&gt; Token =&gt; auctionIndex =&gt; amount&#13;
    mapping (address =&gt; mapping (address =&gt; mapping (uint =&gt; uint))) public extraTokens;&#13;
&#13;
    // Token =&gt; Token =&gt;  auctionIndex =&gt; user =&gt; amount&#13;
    mapping (address =&gt; mapping (address =&gt; mapping (uint =&gt; mapping (address =&gt; uint)))) public sellerBalances;&#13;
    mapping (address =&gt; mapping (address =&gt; mapping (uint =&gt; mapping (address =&gt; uint)))) public buyerBalances;&#13;
    mapping (address =&gt; mapping (address =&gt; mapping (uint =&gt; mapping (address =&gt; uint)))) public claimedAmounts;&#13;
&#13;
    // &gt; Modifiers&#13;
    modifier onlyAuctioneer() {&#13;
        // Only allows auctioneer to proceed&#13;
        // R1&#13;
        require(msg.sender == auctioneer);&#13;
        _;&#13;
    }&#13;
&#13;
    /// @dev Constructor-Function creates exchange&#13;
    /// @param _frtToken - address of frtToken ERC-20 token&#13;
    /// @param _owlToken - address of owlToken ERC-20 token&#13;
    /// @param _auctioneer - auctioneer for managing interfaces&#13;
    /// @param _ethToken - address of ETH ERC-20 token&#13;
    /// @param _ethUSDOracle - address of the oracle contract for fetching feeds&#13;
    /// @param _thresholdNewTokenPair - Minimum required sell funding for adding a new token pair, in USD&#13;
    function setupDutchExchange(&#13;
        TokenFRT _frtToken,&#13;
        TokenOWL _owlToken,&#13;
        address _auctioneer, &#13;
        address _ethToken,&#13;
        PriceOracleInterface _ethUSDOracle,&#13;
        uint _thresholdNewTokenPair,&#13;
        uint _thresholdNewAuction&#13;
    )&#13;
        public&#13;
    {&#13;
        // Make sure contract hasn't been initialised&#13;
        require(ethToken == 0);&#13;
&#13;
        // Validates inputs&#13;
        require(address(_owlToken) != address(0));&#13;
        require(address(_frtToken) != address(0));&#13;
        require(_auctioneer != 0);&#13;
        require(_ethToken != 0);&#13;
        require(address(_ethUSDOracle) != address(0));&#13;
&#13;
        frtToken = _frtToken;&#13;
        owlToken = _owlToken;&#13;
        auctioneer = _auctioneer;&#13;
        ethToken = _ethToken;&#13;
        ethUSDOracle = _ethUSDOracle;&#13;
        thresholdNewTokenPair = _thresholdNewTokenPair;&#13;
        thresholdNewAuction = _thresholdNewAuction;&#13;
    }&#13;
&#13;
    function updateAuctioneer(&#13;
        address _auctioneer&#13;
    )&#13;
        public&#13;
        onlyAuctioneer&#13;
    {&#13;
        require(_auctioneer != address(0));&#13;
        auctioneer = _auctioneer;&#13;
    }&#13;
&#13;
    function initiateEthUsdOracleUpdate(&#13;
        PriceOracleInterface _ethUSDOracle&#13;
    )&#13;
        public&#13;
        onlyAuctioneer&#13;
    {         &#13;
        require(address(_ethUSDOracle) != address(0));&#13;
        newProposalEthUSDOracle = _ethUSDOracle;&#13;
        oracleInterfaceCountdown = add(now, WAITING_PERIOD_CHANGE_MASTERCOPY_OR_ORACLE);&#13;
        NewOracleProposal(_ethUSDOracle);&#13;
    }&#13;
&#13;
    function updateEthUSDOracle()&#13;
        public&#13;
        onlyAuctioneer&#13;
    {&#13;
        require(address(newProposalEthUSDOracle) != address(0));&#13;
        require(oracleInterfaceCountdown &lt; now);&#13;
        ethUSDOracle = newProposalEthUSDOracle;&#13;
        newProposalEthUSDOracle = PriceOracleInterface(0);&#13;
    }&#13;
&#13;
    function updateThresholdNewTokenPair(&#13;
        uint _thresholdNewTokenPair&#13;
    )&#13;
        public&#13;
        onlyAuctioneer&#13;
    {&#13;
        thresholdNewTokenPair = _thresholdNewTokenPair;&#13;
    }&#13;
&#13;
    function updateThresholdNewAuction(&#13;
        uint _thresholdNewAuction&#13;
    )&#13;
        public&#13;
        onlyAuctioneer&#13;
    {&#13;
        thresholdNewAuction = _thresholdNewAuction;&#13;
    }&#13;
&#13;
    function updateApprovalOfToken(&#13;
        address[] token,&#13;
        bool approved&#13;
    )&#13;
        public&#13;
        onlyAuctioneer&#13;
     {  &#13;
        for(uint i = 0; i &lt; token.length; i++) {&#13;
            approvedTokens[token[i]] = approved;&#13;
            Approval(token[i], approved);&#13;
        }&#13;
     }&#13;
&#13;
     function startMasterCopyCountdown (&#13;
        address _masterCopy&#13;
     )&#13;
        public&#13;
        onlyAuctioneer&#13;
    {&#13;
        require(_masterCopy != address(0));&#13;
&#13;
        // Update masterCopyCountdown&#13;
        newMasterCopy = _masterCopy;&#13;
        masterCopyCountdown = add(now, WAITING_PERIOD_CHANGE_MASTERCOPY_OR_ORACLE);&#13;
        NewMasterCopyProposal(_masterCopy);&#13;
    }&#13;
&#13;
    function updateMasterCopy()&#13;
        public&#13;
        onlyAuctioneer&#13;
    {&#13;
        require(newMasterCopy != address(0));&#13;
        require(now &gt;= masterCopyCountdown);&#13;
&#13;
        // Update masterCopy&#13;
        masterCopy = newMasterCopy;&#13;
        newMasterCopy = address(0);&#13;
    }&#13;
&#13;
    /// @param initialClosingPriceNum initial price will be 2 * initialClosingPrice. This is its numerator&#13;
    /// @param initialClosingPriceDen initial price will be 2 * initialClosingPrice. This is its denominator&#13;
    function addTokenPair(&#13;
        address token1,&#13;
        address token2,&#13;
        uint token1Funding,&#13;
        uint token2Funding,&#13;
        uint initialClosingPriceNum,&#13;
        uint initialClosingPriceDen &#13;
    )&#13;
        public&#13;
    {&#13;
        // R1&#13;
        require(token1 != token2);&#13;
&#13;
        // R2&#13;
        require(initialClosingPriceNum != 0);&#13;
&#13;
        // R3&#13;
        require(initialClosingPriceDen != 0);&#13;
&#13;
        // R4&#13;
        require(getAuctionIndex(token1, token2) == 0);&#13;
&#13;
        // R5: to prevent overflow&#13;
        require(initialClosingPriceNum &lt; 10 ** 18);&#13;
&#13;
        // R6&#13;
        require(initialClosingPriceDen &lt; 10 ** 18);&#13;
&#13;
        setAuctionIndex(token1, token2);&#13;
&#13;
        token1Funding = min(token1Funding, balances[token1][msg.sender]);&#13;
        token2Funding = min(token2Funding, balances[token2][msg.sender]);&#13;
&#13;
        // R7&#13;
        require(token1Funding &lt; 10 ** 30);&#13;
&#13;
        // R8&#13;
        require(token2Funding &lt; 10 ** 30);&#13;
&#13;
        uint fundedValueUSD;&#13;
        uint ethUSDPrice = ethUSDOracle.getUSDETHPrice();&#13;
&#13;
        // Compute fundedValueUSD&#13;
        address ethTokenMem = ethToken;&#13;
        if (token1 == ethTokenMem) {&#13;
            // C1&#13;
            // MUL: 10^30 * 10^6 = 10^36&#13;
            fundedValueUSD = mul(token1Funding, ethUSDPrice);&#13;
        } else if (token2 == ethTokenMem) {&#13;
            // C2&#13;
            // MUL: 10^30 * 10^6 = 10^36&#13;
            fundedValueUSD = mul(token2Funding, ethUSDPrice);&#13;
        } else {&#13;
            // C3: Neither token is ethToken&#13;
            fundedValueUSD = calculateFundedValueTokenToken(token1, token2, &#13;
                token1Funding, token2Funding, ethTokenMem, ethUSDPrice);&#13;
        }&#13;
&#13;
        // R5&#13;
        require(fundedValueUSD &gt;= thresholdNewTokenPair);&#13;
&#13;
        // Save prices of opposite auctions&#13;
        closingPrices[token1][token2][0] = fraction(initialClosingPriceNum, initialClosingPriceDen);&#13;
        closingPrices[token2][token1][0] = fraction(initialClosingPriceDen, initialClosingPriceNum);&#13;
&#13;
        // Split into two fns because of 16 local-var cap&#13;
        addTokenPairSecondPart(token1, token2, token1Funding, token2Funding);&#13;
    }&#13;
&#13;
    function calculateFundedValueTokenToken(&#13;
        address token1,&#13;
        address token2,&#13;
        uint token1Funding,&#13;
        uint token2Funding,&#13;
        address ethTokenMem,&#13;
        uint ethUSDPrice&#13;
    )&#13;
        internal&#13;
        view&#13;
        returns (uint fundedValueUSD)&#13;
    {&#13;
        // We require there to exist ethToken-Token auctions&#13;
        // R3.1&#13;
        require(getAuctionIndex(token1, ethTokenMem) &gt; 0);&#13;
&#13;
        // R3.2&#13;
        require(getAuctionIndex(token2, ethTokenMem) &gt; 0);&#13;
&#13;
        // Price of Token 1&#13;
        uint priceToken1Num;&#13;
        uint priceToken1Den;&#13;
        (priceToken1Num, priceToken1Den) = getPriceOfTokenInLastAuction(token1);&#13;
&#13;
        // Price of Token 2&#13;
        uint priceToken2Num;&#13;
        uint priceToken2Den;&#13;
        (priceToken2Num, priceToken2Den) = getPriceOfTokenInLastAuction(token2);&#13;
&#13;
        // Compute funded value in ethToken and USD&#13;
        // 10^30 * 10^30 = 10^60&#13;
        uint fundedValueETH = add(mul(token1Funding, priceToken1Num) / priceToken1Den,&#13;
            token2Funding * priceToken2Num / priceToken2Den);&#13;
&#13;
        fundedValueUSD = mul(fundedValueETH, ethUSDPrice);&#13;
    }&#13;
&#13;
    function addTokenPairSecondPart(&#13;
        address token1,&#13;
        address token2,&#13;
        uint token1Funding,&#13;
        uint token2Funding&#13;
    )&#13;
        internal&#13;
    {&#13;
        balances[token1][msg.sender] = sub(balances[token1][msg.sender], token1Funding);&#13;
        balances[token2][msg.sender] = sub(balances[token2][msg.sender], token2Funding);&#13;
&#13;
        // Fee mechanism, fees are added to extraTokens&#13;
        uint token1FundingAfterFee = settleFee(token1, token2, 1, token1Funding);&#13;
        uint token2FundingAfterFee = settleFee(token2, token1, 1, token2Funding);&#13;
&#13;
        // Update other variables&#13;
        sellVolumesCurrent[token1][token2] = token1FundingAfterFee;&#13;
        sellVolumesCurrent[token2][token1] = token2FundingAfterFee;&#13;
        sellerBalances[token1][token2][1][msg.sender] = token1FundingAfterFee;&#13;
        sellerBalances[token2][token1][1][msg.sender] = token2FundingAfterFee;&#13;
        &#13;
        setAuctionStart(token1, token2, WAITING_PERIOD_NEW_TOKEN_PAIR);&#13;
        NewTokenPair(token1, token2);&#13;
    }&#13;
&#13;
    function deposit(&#13;
        address tokenAddress,&#13;
        uint amount&#13;
    )&#13;
        public&#13;
        returns (uint)&#13;
    {&#13;
        // R1&#13;
        require(Token(tokenAddress).transferFrom(msg.sender, this, amount));&#13;
&#13;
        uint newBal = add(balances[tokenAddress][msg.sender], amount);&#13;
&#13;
        balances[tokenAddress][msg.sender] = newBal;&#13;
&#13;
        NewDeposit(tokenAddress, amount);&#13;
&#13;
        return newBal;&#13;
    }&#13;
&#13;
    function withdraw(&#13;
        address tokenAddress,&#13;
        uint amount&#13;
    )&#13;
        public&#13;
        returns (uint)&#13;
    {&#13;
        uint usersBalance = balances[tokenAddress][msg.sender];&#13;
        amount = min(amount, usersBalance);&#13;
&#13;
        // R1&#13;
        require(amount &gt; 0);&#13;
&#13;
        // R2&#13;
        require(Token(tokenAddress).transfer(msg.sender, amount));&#13;
&#13;
        uint newBal = sub(usersBalance, amount);&#13;
        balances[tokenAddress][msg.sender] = newBal;&#13;
&#13;
        NewWithdrawal(tokenAddress, amount);&#13;
&#13;
        return newBal;&#13;
    }&#13;
&#13;
    function postSellOrder(&#13;
        address sellToken,&#13;
        address buyToken,&#13;
        uint auctionIndex,&#13;
        uint amount&#13;
    )&#13;
        public&#13;
        returns (uint, uint)&#13;
    {&#13;
        // Note: if a user specifies auctionIndex of 0, it&#13;
        // means he is agnostic which auction his sell order goes into&#13;
&#13;
        amount = min(amount, balances[sellToken][msg.sender]);&#13;
&#13;
        // R1&#13;
        require(amount &gt; 0);&#13;
        &#13;
        // R2&#13;
        uint latestAuctionIndex = getAuctionIndex(sellToken, buyToken);&#13;
        require(latestAuctionIndex &gt; 0);&#13;
      &#13;
        // R3&#13;
        uint auctionStart = getAuctionStart(sellToken, buyToken);&#13;
        if (auctionStart == AUCTION_START_WAITING_FOR_FUNDING || auctionStart &gt; now) {&#13;
            // C1: We are in the 10 minute buffer period&#13;
            // OR waiting for an auction to receive sufficient sellVolume&#13;
            // Auction has already cleared, and index has been incremented&#13;
            // sell order must use that auction index&#13;
            // R1.1&#13;
            if (auctionIndex == 0) {&#13;
                auctionIndex = latestAuctionIndex;&#13;
            } else {&#13;
                require(auctionIndex == latestAuctionIndex);&#13;
            }&#13;
&#13;
            // R1.2&#13;
            require(add(sellVolumesCurrent[sellToken][buyToken], amount) &lt; 10 ** 30);&#13;
        } else {&#13;
            // C2&#13;
            // R2.1: Sell orders must go to next auction&#13;
            if (auctionIndex == 0) {&#13;
                auctionIndex = latestAuctionIndex + 1;&#13;
            } else {&#13;
                require(auctionIndex == latestAuctionIndex + 1);&#13;
            }&#13;
&#13;
            // R2.2&#13;
            require(add(sellVolumesNext[sellToken][buyToken], amount) &lt; 10 ** 30);&#13;
        }&#13;
&#13;
        // Fee mechanism, fees are added to extraTokens&#13;
        uint amountAfterFee = settleFee(sellToken, buyToken, auctionIndex, amount);&#13;
&#13;
        // Update variables&#13;
        balances[sellToken][msg.sender] = sub(balances[sellToken][msg.sender], amount);&#13;
        uint newSellerBal = add(sellerBalances[sellToken][buyToken][auctionIndex][msg.sender], amountAfterFee);&#13;
        sellerBalances[sellToken][buyToken][auctionIndex][msg.sender] = newSellerBal;&#13;
&#13;
        if (auctionStart == AUCTION_START_WAITING_FOR_FUNDING || auctionStart &gt; now) {&#13;
            // C1&#13;
            uint sellVolumeCurrent = sellVolumesCurrent[sellToken][buyToken];&#13;
            sellVolumesCurrent[sellToken][buyToken] = add(sellVolumeCurrent, amountAfterFee);&#13;
        } else {&#13;
            // C2&#13;
            uint sellVolumeNext = sellVolumesNext[sellToken][buyToken];&#13;
            sellVolumesNext[sellToken][buyToken] = add(sellVolumeNext, amountAfterFee);&#13;
        }&#13;
&#13;
        if (auctionStart == AUCTION_START_WAITING_FOR_FUNDING) {&#13;
            scheduleNextAuction(sellToken, buyToken);&#13;
        }&#13;
&#13;
        NewSellOrder(sellToken, buyToken, msg.sender, auctionIndex, amountAfterFee);&#13;
&#13;
        return (auctionIndex, newSellerBal);&#13;
    }&#13;
&#13;
    function postBuyOrder(&#13;
        address sellToken,&#13;
        address buyToken,&#13;
        uint auctionIndex,&#13;
        uint amount&#13;
    )&#13;
        public&#13;
        returns (uint)&#13;
    {&#13;
        // R1: auction must not have cleared&#13;
        require(closingPrices[sellToken][buyToken][auctionIndex].den == 0);&#13;
&#13;
        uint auctionStart = getAuctionStart(sellToken, buyToken);&#13;
&#13;
        // R2&#13;
        require(auctionStart &lt;= now);&#13;
&#13;
        // R4&#13;
        require(auctionIndex == getAuctionIndex(sellToken, buyToken));&#13;
        &#13;
        // R5: auction must not be in waiting period&#13;
        require(auctionStart &gt; AUCTION_START_WAITING_FOR_FUNDING);&#13;
        &#13;
        // R6: auction must be funded&#13;
        require(sellVolumesCurrent[sellToken][buyToken] &gt; 0);&#13;
        &#13;
        uint buyVolume = buyVolumes[sellToken][buyToken];&#13;
        amount = min(amount, balances[buyToken][msg.sender]);&#13;
&#13;
        // R7&#13;
        require(add(buyVolume, amount) &lt; 10 ** 30);&#13;
        &#13;
        // Overbuy is when a part of a buy order clears an auction&#13;
        // In that case we only process the part before the overbuy&#13;
        // To calculate overbuy, we first get current price&#13;
        uint sellVolume = sellVolumesCurrent[sellToken][buyToken];&#13;
&#13;
        uint num;&#13;
        uint den;&#13;
        (num, den) = getCurrentAuctionPrice(sellToken, buyToken, auctionIndex);&#13;
        // 10^30 * 10^37 = 10^67&#13;
        uint outstandingVolume = atleastZero(int(mul(sellVolume, num) / den - buyVolume));&#13;
&#13;
        uint amountAfterFee;&#13;
        if (amount &lt; outstandingVolume) {&#13;
            if (amount &gt; 0) {&#13;
                amountAfterFee = settleFee(buyToken, sellToken, auctionIndex, amount);&#13;
            }&#13;
        } else {&#13;
            amount = outstandingVolume;&#13;
            amountAfterFee = outstandingVolume;&#13;
        }&#13;
&#13;
        // Here we could also use outstandingVolume or amountAfterFee, it doesn't matter&#13;
        if (amount &gt; 0) {&#13;
            // Update variables&#13;
            balances[buyToken][msg.sender] = sub(balances[buyToken][msg.sender], amount);&#13;
            uint newBuyerBal = add(buyerBalances[sellToken][buyToken][auctionIndex][msg.sender], amountAfterFee);&#13;
            buyerBalances[sellToken][buyToken][auctionIndex][msg.sender] = newBuyerBal;&#13;
            buyVolumes[sellToken][buyToken] = add(buyVolumes[sellToken][buyToken], amountAfterFee);&#13;
            NewBuyOrder(sellToken, buyToken, msg.sender, auctionIndex, amountAfterFee);&#13;
        }&#13;
&#13;
        // Checking for equality would suffice here. nevertheless:&#13;
        if (amount &gt;= outstandingVolume) {&#13;
            // Clear auction&#13;
            clearAuction(sellToken, buyToken, auctionIndex, sellVolume);&#13;
        }&#13;
&#13;
        return (newBuyerBal);&#13;
    }&#13;
    &#13;
    function claimSellerFunds(&#13;
        address sellToken,&#13;
        address buyToken,&#13;
        address user,&#13;
        uint auctionIndex&#13;
    )&#13;
        public&#13;
        // &lt; (10^60, 10^61)&#13;
        returns (uint returned, uint frtsIssued)&#13;
    {&#13;
        closeTheoreticalClosedAuction(sellToken, buyToken, auctionIndex);&#13;
        uint sellerBalance = sellerBalances[sellToken][buyToken][auctionIndex][user];&#13;
&#13;
        // R1&#13;
        require(sellerBalance &gt; 0);&#13;
&#13;
        // Get closing price for said auction&#13;
        fraction memory closingPrice = closingPrices[sellToken][buyToken][auctionIndex];&#13;
        uint num = closingPrice.num;&#13;
        uint den = closingPrice.den;&#13;
&#13;
        // R2: require auction to have cleared&#13;
        require(den &gt; 0);&#13;
&#13;
        // Calculate return&#13;
        // &lt; 10^30 * 10^30 = 10^60&#13;
        returned = mul(sellerBalance, num) / den;&#13;
&#13;
        frtsIssued = issueFrts(sellToken, buyToken, returned, auctionIndex, sellerBalance, user);&#13;
&#13;
        // Claim tokens&#13;
        sellerBalances[sellToken][buyToken][auctionIndex][user] = 0;&#13;
        if (returned &gt; 0) {&#13;
            balances[buyToken][user] = add(balances[buyToken][user], returned);&#13;
        }&#13;
        NewSellerFundsClaim(sellToken, buyToken, user, auctionIndex, returned, frtsIssued);&#13;
    }&#13;
&#13;
    function claimBuyerFunds(&#13;
        address sellToken,&#13;
        address buyToken,&#13;
        address user,&#13;
        uint auctionIndex&#13;
    )&#13;
        public&#13;
        returns (uint returned, uint frtsIssued)&#13;
    {&#13;
        closeTheoreticalClosedAuction(sellToken, buyToken, auctionIndex);&#13;
        &#13;
        uint num;&#13;
        uint den;&#13;
        (returned, num, den) = getUnclaimedBuyerFunds(sellToken, buyToken, user, auctionIndex);&#13;
&#13;
        if (closingPrices[sellToken][buyToken][auctionIndex].den == 0) {&#13;
            // Auction is running&#13;
            claimedAmounts[sellToken][buyToken][auctionIndex][user] = add(claimedAmounts[sellToken][buyToken][auctionIndex][user], returned);&#13;
        } else {&#13;
            // Auction has closed&#13;
            // We DON'T want to check for returned &gt; 0, because that would fail if a user claims&#13;
            // intermediate funds &amp; auction clears in same block (he/she would not be able to claim extraTokens)&#13;
&#13;
            // Assign extra sell tokens (this is possible only after auction has cleared,&#13;
            // because buyVolume could still increase before that)&#13;
            uint extraTokensTotal = extraTokens[sellToken][buyToken][auctionIndex];&#13;
            uint buyerBalance = buyerBalances[sellToken][buyToken][auctionIndex][user];&#13;
&#13;
            // closingPrices.num represents buyVolume&#13;
            // &lt; 10^30 * 10^30 = 10^60&#13;
            uint tokensExtra = mul(buyerBalance, extraTokensTotal) / closingPrices[sellToken][buyToken][auctionIndex].num;&#13;
            returned = add(returned, tokensExtra);&#13;
&#13;
            frtsIssued = issueFrts(buyToken, sellToken, mul(buyerBalance, den) / num, auctionIndex, buyerBalance, user);&#13;
&#13;
            // Auction has closed&#13;
            // Reset buyerBalances and claimedAmounts&#13;
            buyerBalances[sellToken][buyToken][auctionIndex][user] = 0;&#13;
            claimedAmounts[sellToken][buyToken][auctionIndex][user] = 0; &#13;
        }&#13;
&#13;
        // Claim tokens&#13;
        if (returned &gt; 0) {&#13;
            balances[sellToken][user] = add(balances[sellToken][user], returned);&#13;
        }&#13;
        &#13;
        NewBuyerFundsClaim(sellToken, buyToken, user, auctionIndex, returned, frtsIssued);&#13;
    }&#13;
&#13;
    function issueFrts(&#13;
        address primaryToken,&#13;
        address secondaryToken,&#13;
        uint x,&#13;
        uint auctionIndex,&#13;
        uint bal,&#13;
        address user&#13;
    )&#13;
        internal&#13;
        returns (uint frtsIssued)&#13;
    {&#13;
        if (approvedTokens[primaryToken] &amp;&amp; approvedTokens[secondaryToken]) {&#13;
            address ethTokenMem = ethToken;&#13;
            // Get frts issued based on ETH price of returned tokens&#13;
            if (primaryToken == ethTokenMem) {&#13;
                frtsIssued = bal;&#13;
            } else if (secondaryToken == ethTokenMem) {&#13;
                // 10^30 * 10^39 = 10^66&#13;
                frtsIssued = x;&#13;
            } else {&#13;
                // Neither token is ethToken, so we use getHhistoricalPriceOracle()&#13;
                uint pastNum;&#13;
                uint pastDen;&#13;
                (pastNum, pastDen) = getPriceInPastAuction(primaryToken, ethTokenMem, auctionIndex - 1);&#13;
                // 10^30 * 10^35 = 10^65&#13;
                frtsIssued = mul(bal, pastNum) / pastDen;&#13;
            }&#13;
&#13;
            if (frtsIssued &gt; 0) {&#13;
                // Issue frtToken&#13;
                frtToken.mintTokens(user, frtsIssued);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    //@dev allows to close possible theoretical closed markets&#13;
    //@param sellToken sellToken of an auction&#13;
    //@param buyToken buyToken of an auction &#13;
    //@param index is the auctionIndex of the auction&#13;
    function closeTheoreticalClosedAuction(&#13;
        address sellToken,&#13;
        address buyToken,&#13;
        uint auctionIndex&#13;
    )&#13;
        public&#13;
    {&#13;
        if(auctionIndex == getAuctionIndex(buyToken, sellToken) &amp;&amp; closingPrices[sellToken][buyToken][auctionIndex].num == 0) {&#13;
            uint buyVolume = buyVolumes[sellToken][buyToken];&#13;
            uint sellVolume = sellVolumesCurrent[sellToken][buyToken];&#13;
            uint num;&#13;
            uint den;&#13;
            (num, den) = getCurrentAuctionPrice(sellToken, buyToken, auctionIndex);&#13;
            // 10^30 * 10^37 = 10^67&#13;
            uint outstandingVolume = atleastZero(int(mul(sellVolume, num) / den - buyVolume));&#13;
            &#13;
            if(outstandingVolume == 0) {&#13;
                postBuyOrder(sellToken, buyToken, auctionIndex, 0);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev Claim buyer funds for one auction&#13;
    function getUnclaimedBuyerFunds(&#13;
        address sellToken,&#13;
        address buyToken,&#13;
        address user,&#13;
        uint auctionIndex&#13;
    )&#13;
        public&#13;
        view&#13;
        // &lt; (10^67, 10^37)&#13;
        returns (uint unclaimedBuyerFunds, uint num, uint den)&#13;
    {&#13;
        // R1: checks if particular auction has ever run&#13;
        require(auctionIndex &lt;= getAuctionIndex(sellToken, buyToken));&#13;
&#13;
        (num, den) = getCurrentAuctionPrice(sellToken, buyToken, auctionIndex);&#13;
&#13;
        if (num == 0) {&#13;
            // This should rarely happen - as long as there is &gt;= 1 buy order,&#13;
            // auction will clear before price = 0. So this is just fail-safe&#13;
            unclaimedBuyerFunds = 0;&#13;
        } else {&#13;
            uint buyerBalance = buyerBalances[sellToken][buyToken][auctionIndex][user];&#13;
            // &lt; 10^30 * 10^37 = 10^67&#13;
            unclaimedBuyerFunds = atleastZero(int(&#13;
                mul(buyerBalance, den) / num - &#13;
                claimedAmounts[sellToken][buyToken][auctionIndex][user]&#13;
            ));&#13;
        }&#13;
    }&#13;
&#13;
    function settleFee(&#13;
        address primaryToken,&#13;
        address secondaryToken,&#13;
        uint auctionIndex,&#13;
        uint amount&#13;
    )&#13;
        internal&#13;
        // &lt; 10^30&#13;
        returns (uint amountAfterFee)&#13;
    {&#13;
        uint feeNum;&#13;
        uint feeDen;&#13;
        (feeNum, feeDen) = getFeeRatio(msg.sender);&#13;
        // 10^30 * 10^3 / 10^4 = 10^29&#13;
        uint fee = mul(amount, feeNum) / feeDen;&#13;
&#13;
        if (fee &gt; 0) {&#13;
            fee = settleFeeSecondPart(primaryToken, fee);&#13;
            &#13;
            uint usersExtraTokens = extraTokens[primaryToken][secondaryToken][auctionIndex + 1];&#13;
            extraTokens[primaryToken][secondaryToken][auctionIndex + 1] = add(usersExtraTokens, fee);&#13;
&#13;
            Fee(primaryToken, secondaryToken, msg.sender, auctionIndex, fee);&#13;
        }&#13;
        &#13;
        amountAfterFee = sub(amount, fee);&#13;
    }&#13;
&#13;
    function settleFeeSecondPart(&#13;
        address primaryToken,&#13;
        uint fee&#13;
    )&#13;
        internal&#13;
        returns (uint newFee)&#13;
    {&#13;
        // Allow user to reduce up to half of the fee with owlToken&#13;
        uint num;&#13;
        uint den;&#13;
        (num, den) = getPriceOfTokenInLastAuction(primaryToken);&#13;
&#13;
        // Convert fee to ETH, then USD&#13;
        // 10^29 * 10^30 / 10^30 = 10^29&#13;
        uint feeInETH = mul(fee, num) / den;&#13;
&#13;
        uint ethUSDPrice = ethUSDOracle.getUSDETHPrice();&#13;
        // 10^29 * 10^6 = 10^35&#13;
        // Uses 18 decimal places &lt;&gt; exactly as owlToken tokens: 10**18 owlToken == 1 USD &#13;
        uint feeInUSD = mul(feeInETH, ethUSDPrice);&#13;
        uint amountOfowlTokenBurned = min(owlToken.allowance(msg.sender, this), feeInUSD / 2);&#13;
        amountOfowlTokenBurned = min(owlToken.balanceOf(msg.sender), amountOfowlTokenBurned);&#13;
&#13;
&#13;
        if (amountOfowlTokenBurned &gt; 0) {&#13;
            owlToken.burnOWL(msg.sender, amountOfowlTokenBurned);&#13;
            // Adjust fee&#13;
            // 10^35 * 10^29 = 10^64&#13;
            uint adjustment = mul(amountOfowlTokenBurned, fee) / feeInUSD;&#13;
            newFee = sub(fee, adjustment);&#13;
        } else {&#13;
            newFee = fee;&#13;
        }&#13;
    }&#13;
    &#13;
    function getFeeRatio(&#13;
        address user&#13;
    )&#13;
        public&#13;
        view&#13;
        // feeRatio &lt; 10^4&#13;
        returns (uint num, uint den)&#13;
    {&#13;
        uint t = frtToken.totalSupply();&#13;
        uint b = frtToken.lockedTokenBalances(user);&#13;
&#13;
        if (b * 100000 &lt; t || t == 0) {&#13;
            // 0.5%&#13;
            num = 1;&#13;
            den = 200;&#13;
        } else if (b * 10000 &lt; t) {&#13;
            // 0.4%&#13;
            num = 1;&#13;
            den = 250;&#13;
        } else if (b * 1000 &lt; t) {&#13;
            // 0.3%&#13;
            num = 3;&#13;
            den = 1000;&#13;
        } else if (b * 100 &lt; t) {&#13;
            // 0.2%&#13;
            num = 1;&#13;
            den = 500;&#13;
        } else if (b * 10 &lt; t) {&#13;
            // 0.1%&#13;
            num = 1;&#13;
            den = 1000;&#13;
        } else {&#13;
            // 0% &#13;
            num = 0; &#13;
            den = 1;&#13;
        }&#13;
    }&#13;
&#13;
    /// @dev clears an Auction&#13;
    /// @param sellToken sellToken of the auction&#13;
    /// @param buyToken  buyToken of the auction&#13;
    /// @param auctionIndex of the auction to be cleared.&#13;
    function clearAuction(&#13;
        address sellToken,&#13;
        address buyToken,&#13;
        uint auctionIndex,&#13;
        uint sellVolume&#13;
    )&#13;
        internal&#13;
    {&#13;
        // Get variables&#13;
        uint buyVolume = buyVolumes[sellToken][buyToken];&#13;
        uint sellVolumeOpp = sellVolumesCurrent[buyToken][sellToken];&#13;
        uint closingPriceOppDen = closingPrices[buyToken][sellToken][auctionIndex].den;&#13;
        uint auctionStart = getAuctionStart(sellToken, buyToken);&#13;
&#13;
        // Update closing price&#13;
        if (sellVolume &gt; 0) {&#13;
            closingPrices[sellToken][buyToken][auctionIndex] = fraction(buyVolume, sellVolume);&#13;
        }&#13;
&#13;
        // if (opposite is 0 auction OR price = 0 OR opposite auction cleared)&#13;
        // price = 0 happens if auction pair has been running for &gt;= 24 hrs = 86400&#13;
        if (sellVolumeOpp == 0 || now &gt;= auctionStart + 86400 || closingPriceOppDen &gt; 0) {&#13;
            // Close auction pair&#13;
            uint buyVolumeOpp = buyVolumes[buyToken][sellToken];&#13;
            if (closingPriceOppDen == 0 &amp;&amp; sellVolumeOpp &gt; 0) {&#13;
                // Save opposite price&#13;
                closingPrices[buyToken][sellToken][auctionIndex] = fraction(buyVolumeOpp, sellVolumeOpp);&#13;
            }&#13;
&#13;
            uint sellVolumeNext = sellVolumesNext[sellToken][buyToken];&#13;
            uint sellVolumeNextOpp = sellVolumesNext[buyToken][sellToken];&#13;
&#13;
            // Update state variables for both auctions&#13;
            sellVolumesCurrent[sellToken][buyToken] = sellVolumeNext;&#13;
            if (sellVolumeNext &gt; 0) {&#13;
                sellVolumesNext[sellToken][buyToken] = 0;&#13;
            }&#13;
            if (buyVolume &gt; 0) {&#13;
                buyVolumes[sellToken][buyToken] = 0;&#13;
            }&#13;
&#13;
            sellVolumesCurrent[buyToken][sellToken] = sellVolumeNextOpp;&#13;
            if (sellVolumeNextOpp &gt; 0) {&#13;
                sellVolumesNext[buyToken][sellToken] = 0;&#13;
            }&#13;
            if (buyVolumeOpp &gt; 0) {&#13;
                buyVolumes[buyToken][sellToken] = 0;&#13;
            }&#13;
&#13;
            // Increment auction index&#13;
            setAuctionIndex(sellToken, buyToken);&#13;
            // Check if next auction can be scheduled&#13;
            scheduleNextAuction(sellToken, buyToken);&#13;
        }&#13;
&#13;
        AuctionCleared(sellToken, buyToken, sellVolume, buyVolume, auctionIndex);&#13;
    }&#13;
&#13;
    function scheduleNextAuction(&#13;
        address sellToken,&#13;
        address buyToken&#13;
    )&#13;
        internal&#13;
    {&#13;
        // Check if auctions received enough sell orders&#13;
        uint ethUSDPrice = ethUSDOracle.getUSDETHPrice();&#13;
&#13;
        uint sellNum;&#13;
        uint sellDen;&#13;
        (sellNum, sellDen) = getPriceOfTokenInLastAuction(sellToken);&#13;
&#13;
        uint buyNum;&#13;
        uint buyDen;&#13;
        (buyNum, buyDen) = getPriceOfTokenInLastAuction(buyToken);&#13;
&#13;
        // We use current sell volume, because in clearAuction() we set&#13;
        // sellVolumesCurrent = sellVolumesNext before calling this function&#13;
        // (this is so that we don't need case work,&#13;
        // since it might also be called from postSellOrder())&#13;
&#13;
        // &lt; 10^30 * 10^31 * 10^6 = 10^67&#13;
        uint sellVolume = mul(mul(sellVolumesCurrent[sellToken][buyToken], sellNum), ethUSDPrice) / sellDen;&#13;
        uint sellVolumeOpp = mul(mul(sellVolumesCurrent[buyToken][sellToken], buyNum), ethUSDPrice) / buyDen;&#13;
        if (sellVolume &gt;= thresholdNewAuction || sellVolumeOpp &gt;= thresholdNewAuction) {&#13;
            // Schedule next auction&#13;
            setAuctionStart(sellToken, buyToken, WAITING_PERIOD_NEW_AUCTION);&#13;
        } else {&#13;
            resetAuctionStart(sellToken, buyToken);&#13;
        }&#13;
    }&#13;
&#13;
    //@ dev returns price in units [token2]/[token1]&#13;
    //@ param token1 first token for price calculation&#13;
    //@ param token2 second token for price calculation&#13;
    //@ param auctionIndex index for the auction to get the averaged price from&#13;
    function getPriceInPastAuction(&#13;
        address token1,&#13;
        address token2,&#13;
        uint auctionIndex&#13;
    )&#13;
        public&#13;
        view&#13;
        // price &lt; 10^31&#13;
        returns (uint num, uint den)&#13;
    {&#13;
        if (token1 == token2) {&#13;
            // C1&#13;
            num = 1;&#13;
            den = 1;&#13;
        } else {&#13;
            // C2&#13;
            // R2.1&#13;
            require(auctionIndex &gt;= 0);&#13;
&#13;
&#13;
            // C3&#13;
            // R3.1&#13;
            require(auctionIndex &lt;= getAuctionIndex(token1, token2));&#13;
            // auction still running&#13;
&#13;
            uint i = 0;&#13;
            bool correctPair = false;&#13;
            fraction memory closingPriceToken1;&#13;
            fraction memory closingPriceToken2;&#13;
&#13;
            while (!correctPair) {&#13;
                closingPriceToken2 = closingPrices[token2][token1][auctionIndex - i];&#13;
                closingPriceToken1 = closingPrices[token1][token2][auctionIndex - i];&#13;
                &#13;
                if (closingPriceToken1.num &gt; 0 &amp;&amp; closingPriceToken1.den &gt; 0 || &#13;
                    closingPriceToken2.num &gt; 0 &amp;&amp; closingPriceToken2.den &gt; 0)&#13;
                {&#13;
                    correctPair = true;&#13;
                }&#13;
                i++;&#13;
            }&#13;
&#13;
            // At this point at least one closing price is strictly positive&#13;
            // If only one is positive, we want to output that&#13;
            if (closingPriceToken1.num == 0 || closingPriceToken1.den == 0) {&#13;
                num = closingPriceToken2.den;&#13;
                den = closingPriceToken2.num;&#13;
            } else if (closingPriceToken2.num == 0 || closingPriceToken2.den == 0) {&#13;
                num = closingPriceToken1.num;&#13;
                den = closingPriceToken1.den;&#13;
            } else {&#13;
                // If both prices are positive, output weighted average&#13;
                num = closingPriceToken2.den + closingPriceToken1.num;&#13;
                den = closingPriceToken2.num + closingPriceToken1.den;&#13;
            }&#13;
        } &#13;
    }&#13;
&#13;
    /// @dev Gives best estimate for market price of a token in ETH of any price oracle on the Ethereum network&#13;
    /// @param token address of ERC-20 token&#13;
    /// @return Weighted average of closing prices of opposite Token-ethToken auctions, based on their sellVolume  &#13;
    function getPriceOfTokenInLastAuction(&#13;
        address token&#13;
    )&#13;
        public&#13;
        view&#13;
        // price &lt; 10^31&#13;
        returns (uint num, uint den)&#13;
    {&#13;
        uint latestAuctionIndex = getAuctionIndex(token, ethToken);&#13;
        // getPriceInPastAuction &lt; 10^30&#13;
        (num, den) = getPriceInPastAuction(token, ethToken, latestAuctionIndex - 1);&#13;
    }&#13;
&#13;
    function getCurrentAuctionPrice(&#13;
        address sellToken,&#13;
        address buyToken,&#13;
        uint auctionIndex&#13;
    )&#13;
        public&#13;
        view&#13;
        // price &lt; 10^37&#13;
        returns (uint num, uint den)&#13;
    {&#13;
        fraction memory closingPrice = closingPrices[sellToken][buyToken][auctionIndex];&#13;
&#13;
        if (closingPrice.den != 0) {&#13;
            // Auction has closed&#13;
            (num, den) = (closingPrice.num, closingPrice.den);&#13;
        } else if (auctionIndex &gt; getAuctionIndex(sellToken, buyToken)) {&#13;
            (num, den) = (0, 0);&#13;
        } else {&#13;
            // Auction is running&#13;
            uint pastNum;&#13;
            uint pastDen;&#13;
            (pastNum, pastDen) = getPriceInPastAuction(sellToken, buyToken, auctionIndex - 1);&#13;
&#13;
            // If we're calling the function into an unstarted auction,&#13;
            // it will return the starting price of that auction&#13;
            uint timeElapsed = atleastZero(int(now - getAuctionStart(sellToken, buyToken)));&#13;
&#13;
            // The numbers below are chosen such that&#13;
            // P(0 hrs) = 2 * lastClosingPrice, P(6 hrs) = lastClosingPrice, P(&gt;=24 hrs) = 0&#13;
&#13;
            // 10^5 * 10^31 = 10^36&#13;
            num = atleastZero(int((86400 - timeElapsed) * pastNum));&#13;
            // 10^6 * 10^31 = 10^37&#13;
            den = mul((timeElapsed + 43200), pastDen);&#13;
&#13;
            if (mul(num, sellVolumesCurrent[sellToken][buyToken]) &lt;= mul(den, buyVolumes[sellToken][buyToken])) {&#13;
                num = buyVolumes[sellToken][buyToken];&#13;
                den = sellVolumesCurrent[sellToken][buyToken];&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function depositAndSell(&#13;
        address sellToken,&#13;
        address buyToken,&#13;
        uint amount&#13;
    )&#13;
        external&#13;
        returns (uint newBal, uint auctionIndex, uint newSellerBal)&#13;
    {&#13;
        newBal = deposit(sellToken, amount);&#13;
        (auctionIndex, newSellerBal) = postSellOrder(sellToken, buyToken, 0, amount);&#13;
    }&#13;
&#13;
    function claimAndWithdraw(&#13;
        address sellToken,&#13;
        address buyToken,&#13;
        address user,&#13;
        uint auctionIndex,&#13;
        uint amount&#13;
    )&#13;
        external&#13;
        returns (uint returned, uint frtsIssued, uint newBal)&#13;
    {&#13;
        (returned, frtsIssued) = claimSellerFunds(sellToken, buyToken, user, auctionIndex);&#13;
        newBal = withdraw(buyToken, amount);&#13;
    }&#13;
&#13;
    // &gt; Helper fns&#13;
    function getTokenOrder(&#13;
        address token1,&#13;
        address token2&#13;
    )&#13;
        public&#13;
        pure&#13;
        returns (address, address)&#13;
    {&#13;
        if (token2 &lt; token1) {&#13;
            (token1, token2) = (token2, token1);&#13;
        }&#13;
&#13;
        return (token1, token2);&#13;
    }&#13;
&#13;
    function setAuctionStart(&#13;
        address token1,&#13;
        address token2,&#13;
        uint value&#13;
    )&#13;
        internal&#13;
    {&#13;
        (token1, token2) = getTokenOrder(token1, token2);        &#13;
        uint auctionStart = now + value;&#13;
        uint auctionIndex = latestAuctionIndices[token1][token2];&#13;
        auctionStarts[token1][token2] = auctionStart;&#13;
        AuctionStartScheduled(token1, token2, auctionIndex, auctionStart);&#13;
    }&#13;
&#13;
    function resetAuctionStart(&#13;
        address token1,&#13;
        address token2&#13;
    )&#13;
        internal&#13;
    {&#13;
        (token1, token2) = getTokenOrder(token1, token2);&#13;
        if (auctionStarts[token1][token2] != AUCTION_START_WAITING_FOR_FUNDING) {&#13;
            auctionStarts[token1][token2] = AUCTION_START_WAITING_FOR_FUNDING;&#13;
        }&#13;
    }&#13;
&#13;
    function getAuctionStart(&#13;
        address token1,&#13;
        address token2&#13;
    )&#13;
        public&#13;
        view&#13;
        returns (uint auctionStart)&#13;
    {&#13;
        (token1, token2) = getTokenOrder(token1, token2);&#13;
        auctionStart = auctionStarts[token1][token2];&#13;
    }&#13;
&#13;
    function setAuctionIndex(&#13;
        address token1,&#13;
        address token2&#13;
    )&#13;
        internal&#13;
    {&#13;
        (token1, token2) = getTokenOrder(token1, token2);&#13;
        latestAuctionIndices[token1][token2] += 1;&#13;
    }&#13;
&#13;
&#13;
    function getAuctionIndex(&#13;
        address token1,&#13;
        address token2&#13;
    )&#13;
        public&#13;
        view&#13;
        returns (uint auctionIndex) &#13;
    {&#13;
        (token1, token2) = getTokenOrder(token1, token2);&#13;
        auctionIndex = latestAuctionIndices[token1][token2];&#13;
    }&#13;
&#13;
    // &gt; Math fns&#13;
    function min(uint a, uint b) &#13;
        public&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        if (a &lt; b) {&#13;
            return a;&#13;
        } else {&#13;
            return b;&#13;
        }&#13;
    }&#13;
&#13;
    function atleastZero(int a)&#13;
        public&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        if (a &lt; 0) {&#13;
            return 0;&#13;
        } else {&#13;
            return uint(a);&#13;
        }&#13;
    }&#13;
    /// @dev Returns whether an add operation causes an overflow&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Did no overflow occur?&#13;
    function safeToAdd(uint a, uint b)&#13;
        public&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        return a + b &gt;= a;&#13;
    }&#13;
&#13;
    /// @dev Returns whether a subtraction operation causes an underflow&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Did no underflow occur?&#13;
    function safeToSub(uint a, uint b)&#13;
        public&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        return a &gt;= b;&#13;
    }&#13;
&#13;
    /// @dev Returns whether a multiply operation causes an overflow&#13;
    /// @param a First factor&#13;
    /// @param b Second factor&#13;
    /// @return Did no overflow occur?&#13;
    function safeToMul(uint a, uint b)&#13;
        public&#13;
        pure&#13;
        returns (bool)&#13;
    {&#13;
        return b == 0 || a * b / b == a;&#13;
    }&#13;
&#13;
    /// @dev Returns sum if no overflow occurred&#13;
    /// @param a First addend&#13;
    /// @param b Second addend&#13;
    /// @return Sum&#13;
    function add(uint a, uint b)&#13;
        public&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToAdd(a, b));&#13;
        return a + b;&#13;
    }&#13;
&#13;
    /// @dev Returns difference if no overflow occurred&#13;
    /// @param a Minuend&#13;
    /// @param b Subtrahend&#13;
    /// @return Difference&#13;
    function sub(uint a, uint b)&#13;
        public&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToSub(a, b));&#13;
        return a - b;&#13;
    }&#13;
&#13;
    /// @dev Returns product if no overflow occurred&#13;
    /// @param a First factor&#13;
    /// @param b Second factor&#13;
    /// @return Product&#13;
    function mul(uint a, uint b)&#13;
        public&#13;
        pure&#13;
        returns (uint)&#13;
    {&#13;
        require(safeToMul(a, b));&#13;
        return a * b;&#13;
    }&#13;
&#13;
    function getRunningTokenPairs(&#13;
        address[] tokens&#13;
    )&#13;
        external&#13;
        view&#13;
        returns (address[] tokens1, address[] tokens2)&#13;
    {&#13;
        uint arrayLength;&#13;
&#13;
        for (uint k = 0; k &lt; tokens.length - 1; k++) {&#13;
            for (uint l = k + 1; l &lt; tokens.length; l++) {&#13;
                if (getAuctionIndex(tokens[k], tokens[l]) &gt; 0) {&#13;
                    arrayLength++;&#13;
                }&#13;
            }&#13;
        }&#13;
&#13;
        tokens1 = new address[](arrayLength);&#13;
        tokens2 = new address[](arrayLength);&#13;
&#13;
        uint h;&#13;
&#13;
        for (uint i = 0; i &lt; tokens.length - 1; i++) {&#13;
            for (uint j = i + 1; j &lt; tokens.length; j++) {&#13;
                if (getAuctionIndex(tokens[i], tokens[j]) &gt; 0) {&#13;
                    tokens1[h] = tokens[i];&#13;
                    tokens2[h] = tokens[j];&#13;
                    h++;&#13;
                }&#13;
            }&#13;
        }&#13;
    }&#13;
    &#13;
    //@dev for quick overview of possible sellerBalances to calculate the possible withdraw tokens&#13;
    //@param auctionSellToken is the sellToken defining an auctionPair&#13;
    //@param auctionBuyToken is the buyToken defining an auctionPair&#13;
    //@param user is the user who wants to his tokens&#13;
    //@param lastNAuctions how many auctions will be checked. 0 means all&#13;
    //@returns returns sellbal for all indices for all tokenpairs &#13;
    function getIndicesWithClaimableTokensForSellers(&#13;
        address auctionSellToken,&#13;
        address auctionBuyToken,&#13;
        address user,&#13;
        uint lastNAuctions&#13;
    )&#13;
        external&#13;
        view&#13;
        returns(uint[] indices, uint[] usersBalances)&#13;
    {&#13;
        uint runningAuctionIndex = getAuctionIndex(auctionSellToken, auctionBuyToken);&#13;
&#13;
        uint arrayLength;&#13;
        &#13;
        uint startingIndex = lastNAuctions == 0 ? 1 : runningAuctionIndex - lastNAuctions + 1;&#13;
&#13;
        for (uint j = startingIndex; j &lt;= runningAuctionIndex; j++) {&#13;
            if (sellerBalances[auctionSellToken][auctionBuyToken][j][user] &gt; 0) {&#13;
                arrayLength++;&#13;
            }&#13;
        }&#13;
&#13;
        indices = new uint[](arrayLength);&#13;
        usersBalances = new uint[](arrayLength);&#13;
&#13;
        uint k;&#13;
&#13;
        for (uint i = startingIndex; i &lt;= runningAuctionIndex; i++) {&#13;
            if (sellerBalances[auctionSellToken][auctionBuyToken][i][user] &gt; 0) {&#13;
                indices[k] = i;&#13;
                usersBalances[k] = sellerBalances[auctionSellToken][auctionBuyToken][i][user];&#13;
                k++;&#13;
            }&#13;
        }&#13;
    }    &#13;
&#13;
    //@dev for quick overview of current sellerBalances for a user&#13;
    //@param auctionSellTokens are the sellTokens defining an auctionPair&#13;
    //@param auctionBuyTokens are the buyTokens defining an auctionPair&#13;
    //@param user is the user who wants to his tokens&#13;
    function getSellerBalancesOfCurrentAuctions(&#13;
        address[] auctionSellTokens,&#13;
        address[] auctionBuyTokens,&#13;
        address user&#13;
    )&#13;
        external&#13;
        view&#13;
        returns (uint[])&#13;
    {&#13;
        uint length = auctionSellTokens.length;&#13;
        uint length2 = auctionBuyTokens.length;&#13;
        require(length == length2);&#13;
&#13;
        uint[] memory sellersBalances = new uint[](length);&#13;
&#13;
        for (uint i = 0; i &lt; length; i++) {&#13;
            uint runningAuctionIndex = getAuctionIndex(auctionSellTokens[i], auctionBuyTokens[i]);&#13;
            sellersBalances[i] = sellerBalances[auctionSellTokens[i]][auctionBuyTokens[i]][runningAuctionIndex][user];&#13;
        }&#13;
&#13;
        return sellersBalances;&#13;
    }&#13;
&#13;
    //@dev for quick overview of possible buyerBalances to calculate the possible withdraw tokens&#13;
    //@param auctionSellToken is the sellToken defining an auctionPair&#13;
    //@param auctionBuyToken is the buyToken defining an auctionPair&#13;
    //@param user is the user who wants to his tokens&#13;
    //@param lastNAuctions how many auctions will be checked. 0 means all&#13;
    //@returns returns sellbal for all indices for all tokenpairs &#13;
    function getIndicesWithClaimableTokensForBuyers(&#13;
        address auctionSellToken,&#13;
        address auctionBuyToken,&#13;
        address user,&#13;
        uint lastNAuctions&#13;
    )&#13;
        external&#13;
        view&#13;
        returns(uint[] indices, uint[] usersBalances)&#13;
    {&#13;
        uint runningAuctionIndex = getAuctionIndex(auctionSellToken, auctionBuyToken);&#13;
&#13;
        uint arrayLength;&#13;
        &#13;
        uint startingIndex = lastNAuctions == 0 ? 1 : runningAuctionIndex - lastNAuctions + 1;&#13;
&#13;
        for (uint j = startingIndex; j &lt;= runningAuctionIndex; j++) {&#13;
            if (buyerBalances[auctionSellToken][auctionBuyToken][j][user] &gt; 0) {&#13;
                arrayLength++;&#13;
            }&#13;
        }&#13;
&#13;
        indices = new uint[](arrayLength);&#13;
        usersBalances = new uint[](arrayLength);&#13;
&#13;
        uint k;&#13;
&#13;
        for (uint i = startingIndex; i &lt;= runningAuctionIndex; i++) {&#13;
            if (buyerBalances[auctionSellToken][auctionBuyToken][i][user] &gt; 0) {&#13;
                indices[k] = i;&#13;
                usersBalances[k] = buyerBalances[auctionSellToken][auctionBuyToken][i][user];&#13;
                k++;&#13;
            }&#13;
        }&#13;
    }    &#13;
&#13;
    //@dev for quick overview of current sellerBalances for a user&#13;
    //@param auctionSellTokens are the sellTokens defining an auctionPair&#13;
    //@param auctionBuyTokens are the buyTokens defining an auctionPair&#13;
    //@param user is the user who wants to his tokens&#13;
    function getBuyerBalancesOfCurrentAuctions(&#13;
        address[] auctionSellTokens,&#13;
        address[] auctionBuyTokens,&#13;
        address user&#13;
    )&#13;
        external&#13;
        view&#13;
        returns (uint[])&#13;
    {&#13;
        uint length = auctionSellTokens.length;&#13;
        uint length2 = auctionBuyTokens.length;&#13;
        require(length == length2);&#13;
&#13;
        uint[] memory buyersBalances = new uint[](length);&#13;
&#13;
        for (uint i = 0; i &lt; length; i++) {&#13;
            uint runningAuctionIndex = getAuctionIndex(auctionSellTokens[i], auctionBuyTokens[i]);&#13;
            buyersBalances[i] = buyerBalances[auctionSellTokens[i]][auctionBuyTokens[i]][runningAuctionIndex][user];&#13;
        }&#13;
&#13;
        return buyersBalances;&#13;
    }&#13;
&#13;
    //@dev for quick overview of approved Tokens&#13;
    //@param addressesToCheck are the ERC-20 token addresses to be checked whether they are approved&#13;
    function getApprovedAddressesOfList(&#13;
        address[] addressToCheck&#13;
    )&#13;
        external&#13;
        view&#13;
        returns (bool[])&#13;
    {&#13;
        uint length = addressToCheck.length;&#13;
&#13;
        bool[] memory isApproved = new bool[](length);&#13;
&#13;
        for (uint i = 0; i &lt; length; i++) {&#13;
            isApproved[i] = approvedTokens[addressToCheck[i]];&#13;
        }&#13;
&#13;
        return isApproved;&#13;
    }&#13;
&#13;
    //@dev for multiple withdraws&#13;
    //@param auctionSellTokens are the sellTokens defining an auctionPair&#13;
    //@param auctionBuyTokens are the buyTokens defining an auctionPair&#13;
    //@param auctionIndices are the auction indices on which an token should be claimedAmounts&#13;
    //@param user is the user who wants to his tokens&#13;
    function claimTokensFromSeveralAuctionsAsSeller(&#13;
        address[] auctionSellTokens,&#13;
        address[] auctionBuyTokens,&#13;
        uint[] auctionIndices,&#13;
        address user&#13;
    )&#13;
        external&#13;
    {&#13;
        uint length = auctionSellTokens.length;&#13;
        uint length2 = auctionBuyTokens.length;&#13;
        require(length == length2);&#13;
&#13;
        uint length3 = auctionIndices.length;&#13;
        require(length2 == length3);&#13;
&#13;
        for (uint i = 0; i &lt; length; i++)&#13;
            claimSellerFunds(auctionSellTokens[i], auctionBuyTokens[i], user, auctionIndices[i]);&#13;
    }&#13;
    //@dev for multiple withdraws&#13;
    //@param auctionSellTokens are the sellTokens defining an auctionPair&#13;
    //@param auctionBuyTokens are the buyTokens defining an auctionPair&#13;
    //@param auctionIndices are the auction indices on which an token should be claimedAmounts&#13;
    //@param user is the user who wants to his tokens&#13;
    function claimTokensFromSeveralAuctionsAsBuyer(&#13;
        address[] auctionSellTokens,&#13;
        address[] auctionBuyTokens,&#13;
        uint[] auctionIndices,&#13;
        address user&#13;
    )&#13;
        external&#13;
    {&#13;
        uint length = auctionSellTokens.length;&#13;
        uint length2 = auctionBuyTokens.length;&#13;
        require(length == length2);&#13;
&#13;
        uint length3 = auctionIndices.length;&#13;
        require(length2 == length3);&#13;
&#13;
        for (uint i = 0; i &lt; length; i++)&#13;
            claimBuyerFunds(auctionSellTokens[i], auctionBuyTokens[i], user, auctionIndices[i]);&#13;
    }&#13;
&#13;
    function getMasterCopy()&#13;
        external&#13;
        view &#13;
        returns (address)&#13;
    {&#13;
        return masterCopy;&#13;
    }&#13;
&#13;
    // &gt; Events&#13;
    event NewDeposit(&#13;
         address indexed token,&#13;
         uint amount&#13;
    );&#13;
&#13;
    event NewOracleProposal(&#13;
         PriceOracleInterface priceOracleInterface&#13;
    );&#13;
&#13;
&#13;
    event NewMasterCopyProposal(&#13;
         address newMasterCopy&#13;
    );&#13;
&#13;
    event NewWithdrawal(&#13;
        address indexed token,&#13;
        uint amount&#13;
    );&#13;
    &#13;
    event NewSellOrder(&#13;
        address indexed sellToken,&#13;
        address indexed buyToken,&#13;
        address indexed user,&#13;
        uint auctionIndex,&#13;
        uint amount&#13;
    );&#13;
&#13;
    event NewBuyOrder(&#13;
        address indexed sellToken,&#13;
        address indexed buyToken,&#13;
        address indexed user,&#13;
        uint auctionIndex,&#13;
        uint amount&#13;
    );&#13;
&#13;
    event NewSellerFundsClaim(&#13;
        address indexed sellToken,&#13;
        address indexed buyToken,&#13;
        address indexed user,&#13;
        uint auctionIndex,&#13;
        uint amount,&#13;
        uint frtsIssued&#13;
    );&#13;
&#13;
    event NewBuyerFundsClaim(&#13;
        address indexed sellToken,&#13;
        address indexed buyToken,&#13;
        address indexed user,&#13;
        uint auctionIndex,&#13;
        uint amount,&#13;
        uint frtsIssued&#13;
    );&#13;
&#13;
    event NewTokenPair(&#13;
        address indexed sellToken,&#13;
        address indexed buyToken&#13;
    );&#13;
&#13;
    event AuctionCleared(&#13;
        address indexed sellToken,&#13;
        address indexed buyToken,&#13;
        uint sellVolume,&#13;
        uint buyVolume,&#13;
        uint indexed auctionIndex&#13;
    );&#13;
&#13;
    event Approval(&#13;
        address indexed token,&#13;
        bool approved&#13;
    );&#13;
&#13;
    event AuctionStartScheduled(&#13;
        address indexed sellToken,&#13;
        address indexed buyToken,&#13;
        uint indexed auctionIndex,&#13;
        uint auctionStart&#13;
    );&#13;
&#13;
    event Fee(&#13;
        address indexed primaryToken,&#13;
        address indexed secondarToken,&#13;
        address indexed user,&#13;
        uint auctionIndex,&#13;
        uint fee&#13;
    );&#13;
}