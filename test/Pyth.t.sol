// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {PythScript} from "../src/Pyth.s.sol";
import {IPyth, Price, PriceFeed} from "../src/IPyth.sol";

contract PythScriptTest is Test, PythScript {
    string internal tickers = "ETH,BTC";
    bytes32[] internal ids = [
        bytes32(
            0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace // eth
        ),
        0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43 // btc
    ];

    uint256[] internal forks;

    function setUp() public {
        forks.push(vm.createFork("https://arb-pokt.nodies.app"));
        forks.push(vm.createFork("https://eth.llamarpc.com"));
    }

    function testGetPythDataWithTickers() public {
        (bytes[] memory payload, PriceFeed[] memory data) = getPythData(
            tickers
        );

        assertEq(payload.length, 1, "payload should have 1 item");
        assertGt(payload[0].length, 0, "payload should have length");

        assertEq(data.length, 2, "price data should have 2 items");

        assertEq(data[0].id, ids[0], "price-1-id");
        assertEq(data[1].id, ids[1], "price-2-id");

        assertGt(data[0].price.price, 0, "price-1-0");
        assertGt(data[0].emaPrice.price, 0, "ema-price-1-0");
        assertGt(data[1].price.price, 0, "price-2-0");
        assertGt(data[1].emaPrice.price, 0, "ema-price-2-0");
    }

    function testGetPythDataWithIds() public {
        (bytes[] memory payload, PriceFeed[] memory data) = getPythData(ids);

        assertEq(payload.length, 1, "payload should have 1 item");
        assertGt(payload[0].length, 0, "payload should have length");

        assertEq(data.length, 2, "price data should have 2 items");

        assertEq(data[0].id, ids[0], "price-1-id");
        assertEq(data[1].id, ids[1], "price-2-id");

        assertGt(data[0].price.price, 0, "price-1-0");
        assertGt(data[0].emaPrice.price, 0, "ema-price-1-0");
        assertGt(data[1].price.price, 0, "price-2-0");
        assertGt(data[1].emaPrice.price, 0, "ema-price-2-0");
    }

    function testUpdatePythPriceWithTickers() public {
        for (uint256 i; i < forks.length; i++) {
            vm.selectFork(forks[i]);
            IPyth ep = pyth.get[block.chainid];
            uint256 timeBefore1 = ep.getPriceUnsafe(ids[0]).publishTime;
            uint256 timeBefore2 = ep.getPriceUnsafe(ids[1]).publishTime;

            updatePythPrices(tickers);

            uint256 timeAfter1 = ep.getPrice(ids[0]).publishTime;
            uint256 timeAfter2 = ep.getPrice(ids[1]).publishTime;

            assertGt(timeAfter1, timeBefore1, "time-after-1");
            assertGt(timeAfter2, timeBefore2, "time-after-2");
        }
    }

    function testUpdatePythPriceWithIds() public {
        for (uint256 i; i < forks.length; i++) {
            vm.selectFork(forks[i]);
            IPyth ep = pyth.get[block.chainid];
            uint256 timeBefore1 = ep.getPriceUnsafe(ids[0]).publishTime;
            uint256 timeBefore2 = ep.getPriceUnsafe(ids[1]).publishTime;

            updatePythPrices(ids);

            uint256 timeAfter1 = ep.getPrice(ids[0]).publishTime;
            uint256 timeAfter2 = ep.getPrice(ids[1]).publishTime;

            assertGt(timeAfter1, timeBefore1, "time-after-1");
            assertGt(timeAfter2, timeBefore2, "time-after-2");
        }
    }

    function testPythUpdateWithTickers() public {
        for (uint256 i; i < forks.length; i++) {
            vm.selectFork(forks[i]);
            bytes[] memory payload = getPythPayload(tickers);

            pyth.get[block.chainid].updatePriceFeeds{
                value: pyth.get[block.chainid].getUpdateFee(payload)
            }(payload);
        }
    }

    function testPythUpdateWithIds() public {
        for (uint256 i; i < forks.length; i++) {
            vm.selectFork(forks[i]);
            bytes[] memory payload = getPythPayload(ids);

            pyth.get[block.chainid].updatePriceFeeds{
                value: pyth.get[block.chainid].getUpdateFee(payload)
            }(payload);
        }
    }

    function testGetPythnetPriceWithTicker() public {
        Price memory price = getTickerPrice("ETH");
        assertGt(price.price, 0, "price-eth");
    }

    function testGetPythnetPriceWithId() public {
        Price memory price = getPrice(ids[0]);
        assertGt(price.price, 0, "price-eth");
    }
}
