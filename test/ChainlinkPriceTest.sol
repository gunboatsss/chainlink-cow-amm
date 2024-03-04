// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "forge-std/Test.sol";
// the contract
import {ChainlinkPrice, Data} from "../src/ChainlinkPrice.sol";
// the mock contract
import {AggregatorMock} from "./mocks/AggregatorMock.sol";

contract ChainlinkPriceTest is Test {
    
    ChainlinkPrice oracle;
    AggregatorMock ETHUSD;
    AggregatorMock BTCUSD;
    AggregatorMock AMPLUSD;
    function setUp() public {
        ETHUSD = new AggregatorMock(8, "ETH/USD");
        BTCUSD = new AggregatorMock(8, "BTC/USD");
        AMPLUSD = new AggregatorMock(18, "AMPL/USD");
        oracle = new ChainlinkPrice();
        vm.warp(1709549746);
    }

    function test_happy_path() public {
        ETHUSD.setAnswer(69, 3500e8, block.timestamp - 3600);
        BTCUSD.setAnswer(69, 65000e8, block.timestamp - 2400);
        Data memory ETHBTC = Data(address(ETHUSD), address(BTCUSD));
        (uint256 token0, uint256 token1) = oracle.getPrice(address(100), address(200), abi.encode(ETHBTC));
        assert(token0 == 3500e8);
        assert(token1 == 65000e8);
    }

    function test_ampl_scaling() public {
        ETHUSD.setAnswer(69, 3500e8, block.timestamp - 3600);
        AMPLUSD.setAnswer(69, 1e18, block.timestamp - 2400);
        Data memory ETHAMPL = Data(address(ETHUSD), address(AMPLUSD));
        (uint256 token0, uint256 token1) = oracle.getPrice(address(100), address(200), abi.encode(ETHAMPL));
        console2.log("token0 price", token0);
        console2.log("token1 price", token1);
        assert(token0 == 3500e18);
        assert(token1 == 1e18);
    }
    function test_stale_oracle() public {
        ETHUSD.setAnswer(69, 3500e8, block.timestamp - 86400);
        BTCUSD.setAnswer(69, 65000e8, block.timestamp - 2400);
        Data memory ETHBTC = Data(address(ETHUSD), address(BTCUSD));
        vm.expectRevert();
        (uint256 unused,) = oracle.getPrice(address(100), address(200), abi.encode(ETHBTC));
    }

    function testFuzz_lessThanUint128(int256 _ethPrice, int256 _amplPrice) public {
        _ethPrice = bound(_ethPrice, 1e8, 1000000e8);
        _amplPrice = bound(_amplPrice, 0.1e18, 5e18);
        ETHUSD.setAnswer(69, _ethPrice, block.timestamp - 1);
        AMPLUSD.setAnswer(69, _amplPrice, block.timestamp - 1);
        Data memory ETHAMPL = Data(address(ETHUSD), address(AMPLUSD));
        (uint256 eth, uint256 ampl) = oracle.getPrice(address(100), address(200), abi.encode(ETHAMPL));
        assertLe(eth, type(uint128).max);
    }
}