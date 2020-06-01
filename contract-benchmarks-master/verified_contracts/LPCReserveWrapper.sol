pragma solidity ^0.4.21;

////// lib/ds-roles/lib/ds-auth/src/auth.sol
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

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
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

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

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

contract DSStop is DSNote, DSAuth {

    bool public stopped;

    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}

// See <https://github.com/ethereum/EIPs/issues/20>.

// This file likely does not meet the threshold of originality
// required for copyright to apply.  As a result, this is free and
// unencumbered software belonging to the public domain.

contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);
}

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    function DSTokenBase(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        Approval(msg.sender, guy, wad);

        return true;
    }
}

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

contract DSToken is DSTokenBase(0), DSStop {

    bytes32  public  symbol;
    uint256  public  decimals = 18; // standard token precision. override to customize

    function DSToken(bytes32 symbol_) public {
        symbol = symbol_;
    }

    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);

    function approve(address guy) public stoppable returns (bool) {
        return super.approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        return super.approve(guy, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }

    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }

    function mint(uint wad) public {
        mint(msg.sender, wad);
    }
    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        Mint(guy, wad);
    }
    function burn(address guy, uint wad) public auth stoppable {
        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }

        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        Burn(guy, wad);
    }

    // Optional token name
    bytes32   public  name = "";

    function setName(bytes32 name_) public auth {
        name = name_;
    }
}

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

contract DSThing is DSAuth, DSNote, DSMath {

    function S(string s) internal pure returns (bytes4) {
        return bytes4(keccak256(s));
    }

}

// Copyright (C) 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

contract DSValue is DSThing {
    bool    has;
    bytes32 val;
    function peek() public view returns (bytes32, bool) {
        return (val,has);
    }
    function read() public view returns (bytes32) {
        bytes32 wut; bool haz;
        (wut, haz) = peek();
        assert(haz);
        return wut;
    }
    function poke(bytes32 wut) public note auth {
        val = wut;
        has = true;
    }
    function void() public note auth {  // unset the value
        has = false;
    }
}

// Copyright (C) 2017, 2018 Rain <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="790b1810171b0b1c1812390b100a1c0c0957171c0d">[email protected]</a>&gt;&#13;
&#13;
// This program is free software: you can redistribute it and/or modify&#13;
// it under the terms of the GNU Affero General Public License as published by&#13;
// the Free Software Foundation, either version 3 of the License, or&#13;
// (at your option) any later version.&#13;
&#13;
// This program is distributed in the hope that it will be useful,&#13;
// but WITHOUT ANY WARRANTY; without even the implied warranty of&#13;
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the&#13;
// GNU Affero General Public License for more details.&#13;
&#13;
// You should have received a copy of the GNU Affero General Public License&#13;
// along with this program.  If not, see &lt;http://www.gnu.org/licenses/&gt;.&#13;
&#13;
contract SaiLPC is DSThing {&#13;
    // This is a simple two token liquidity pool that uses an external&#13;
    // price feed.&#13;
&#13;
    // Makers&#13;
    // - `pool` their gems and receive LPS tokens, which are a claim&#13;
    //    on the pool.&#13;
    // - `exit` and trade their LPS tokens for a share of the gems in&#13;
    //    the pool&#13;
&#13;
    // Takers&#13;
    // - `take` and exchange one gem for another, whilst paying a&#13;
    //   fee (the `gap`). The collected fee goes into the pool.&#13;
&#13;
    // To avoid `pool`, `exit` being used to circumvent the taker fee,&#13;
    // makers must pay the same fee on `exit`.&#13;
&#13;
    // provide liquidity for this gem pair&#13;
    ERC20    public  ref;&#13;
    ERC20    public  alt;&#13;
&#13;
    DSValue  public  pip;  // price feed, giving refs per alt&#13;
    uint256  public  gap;  // spread, charged on `take`&#13;
    DSToken  public  lps;  // 'liquidity provider shares', earns spread&#13;
&#13;
    function SaiLPC(ERC20 ref_, ERC20 alt_, DSValue pip_, DSToken lps_) public {&#13;
        ref = ref_;&#13;
        alt = alt_;&#13;
        pip = pip_;&#13;
&#13;
        lps = lps_;&#13;
        gap = WAD;&#13;
    }&#13;
&#13;
    function jump(uint wad) public note auth {&#13;
        assert(wad != 0);&#13;
        gap = wad;&#13;
    }&#13;
&#13;
    // ref per alt&#13;
    function tag() public view returns (uint) {&#13;
        return uint(pip.read());&#13;
    }&#13;
&#13;
    // total pool value&#13;
    function pie() public view returns (uint) {&#13;
        return add(ref.balanceOf(this), wmul(alt.balanceOf(this), tag()));&#13;
    }&#13;
&#13;
    // lps per ref&#13;
    function per() public view returns (uint) {&#13;
        return lps.totalSupply() == 0&#13;
             ? RAY&#13;
             : rdiv(lps.totalSupply(), pie());&#13;
    }&#13;
&#13;
    // {ref,alt} -&gt; lps&#13;
    function pool(ERC20 gem, uint wad) public note auth {&#13;
        require(gem == alt || gem == ref);&#13;
&#13;
        uint jam = (gem == ref) ? wad : wmul(wad, tag());&#13;
        uint ink = rmul(jam, per());&#13;
        lps.mint(ink);&#13;
        lps.push(msg.sender, ink);&#13;
&#13;
        gem.transferFrom(msg.sender, this, wad);&#13;
    }&#13;
&#13;
    // lps -&gt; {ref,alt}&#13;
    function exit(ERC20 gem, uint wad) public note auth {&#13;
        require(gem == alt || gem == ref);&#13;
&#13;
        uint jam = (gem == ref) ? wad : wmul(wad, tag());&#13;
        uint ink = rmul(jam, per());&#13;
        // pay fee to exit, unless you're the last out&#13;
        ink = (jam == pie())? ink : wmul(gap, ink);&#13;
        lps.pull(msg.sender, ink);&#13;
        lps.burn(ink);&#13;
&#13;
        gem.transfer(msg.sender, wad);&#13;
    }&#13;
&#13;
    // ref &lt;-&gt; alt&#13;
    // TODO: meme 'swap'?&#13;
    // TODO: mem 'yen' means to desire. pair with 'pay'? or 'ney'&#13;
    function take(ERC20 gem, uint wad) public note auth {&#13;
        require(gem == alt || gem == ref);&#13;
&#13;
        uint jam = (gem == ref) ? wdiv(wad, tag()) : wmul(wad, tag());&#13;
        jam = wmul(gap, jam);&#13;
&#13;
        ERC20 pay = (gem == ref) ? alt : ref;&#13;
        pay.transferFrom(msg.sender, this, jam);&#13;
        gem.transfer(msg.sender, wad);&#13;
    }&#13;
}&#13;
&#13;
/// @title Kyber Reserve contract&#13;
interface KyberReserveInterface {&#13;
    function() payable;&#13;
    function getConversionRate(ERC20 src, ERC20 dest, uint srcQty, uint blockNumber) external view returns(uint);&#13;
    function withdraw(ERC20 token, uint amount, address destination) external returns(bool);&#13;
    function getBalance(ERC20 token) external view returns(uint);&#13;
}&#13;
&#13;
interface WETHInterface {&#13;
  function() external payable;&#13;
  function deposit() external payable;&#13;
  function withdraw(uint wad) external;&#13;
}&#13;
&#13;
contract WETH is WETHInterface, ERC20 { }&#13;
&#13;
contract LPCReserveWrapper is DSThing {&#13;
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);&#13;
&#13;
    KyberReserveInterface public reserve;&#13;
    WETH public weth;&#13;
    ERC20 public dai;&#13;
    SaiLPC public lpc;&#13;
&#13;
    function LPCReserveWrapper(KyberReserveInterface reserve_, WETH weth_, ERC20 dai_, SaiLPC lpc_) public {&#13;
        assert(address(reserve_) != 0);&#13;
        assert(address(weth_) != 0);&#13;
        assert(address(dai_) != 0);&#13;
        assert(address(lpc_) != 0);&#13;
&#13;
        reserve = reserve_;&#13;
        weth = weth_;&#13;
        lpc = lpc_;&#13;
        dai = dai_;&#13;
    }&#13;
&#13;
    function switchLPC(SaiLPC lpc_) public note auth {&#13;
        assert(address(lpc_) != 0);&#13;
        lpc = lpc_;&#13;
    }&#13;
&#13;
    function switchReserve(KyberReserveInterface reserve_) public note auth {&#13;
        assert(address(reserve_) != 0);&#13;
        reserve = reserve_;&#13;
    }&#13;
&#13;
    function() public payable { }&#13;
&#13;
    function withdrawFromReserve(ERC20 token, uint amount) internal returns (bool success) {&#13;
        if (token == weth) {&#13;
            require(reserve.withdraw(ETH_TOKEN_ADDRESS, amount, this));&#13;
            weth.deposit.value(amount)();&#13;
        } else {&#13;
            require(reserve.withdraw(token, amount, this));&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    function transferToReserve(ERC20 token, uint amount) internal returns (bool success) {&#13;
        if (token == weth) {&#13;
            weth.withdraw(amount);&#13;
            reserve.transfer(amount);&#13;
        } else {&#13;
            require(token.transfer(reserve, amount));&#13;
        }&#13;
        return true;&#13;
    }&#13;
&#13;
    function approveToken(ERC20 token, address who, uint wad) public note auth {&#13;
        require(token.approve(who, wad));&#13;
    }&#13;
&#13;
    function take(ERC20 token, uint wad) public note auth {&#13;
        require(token == weth || token == dai);&#13;
        // Handle only ref == DAI and alt == WETH in this contract&#13;
        require(lpc.ref() == dai);&#13;
        require(lpc.alt() == weth);&#13;
        // Get from LPC the amount that we need to have&#13;
        uint amountToWithdraw = (token == dai) ? wdiv(wad, lpc.tag()) : wmul(wad, lpc.tag());&#13;
        // Get the amount from the reserve&#13;
        require(withdrawFromReserve((token == dai) ? weth : dai, amountToWithdraw));&#13;
        // Magic&#13;
        lpc.take(token, wad);&#13;
        // Transfer DAI/WETH to reserve&#13;
        require(transferToReserve(token, wad));&#13;
    }&#13;
&#13;
    function withdraw(ERC20 token, uint amount, address destination) public note auth {&#13;
        if (token == ETH_TOKEN_ADDRESS) {&#13;
            destination.transfer(amount);&#13;
        } else {&#13;
            require(token.transfer(destination, amount));&#13;
        }&#13;
    }&#13;
}