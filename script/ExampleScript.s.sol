// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {PythScript} from "../src/Pyth.s.sol";
import {IPyth, PriceFeed} from "../src/IPyth.sol";

// Inherit the base contract
contract ExampleScript is PythScript {
    // Use Pyth IDs
    bytes32[] internal ids = [
        bytes32(
            0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace // eth
        ),
        0xe62df6c8b4a85fe1a67db44dc12de5db330f7ac66b72dc658afedf0f4a415b43 // btc
    ];
    // Use tickers, eg. "ETH,BTC". add additional tickers into ts/config.ts
    string internal tickers = "ETH,BTC";

    address internal sender =
        address(0xB38e8c17e38363aF6EbdCb3dAE12e0243582891D);

    function setUp() public {
        vm.createSelectFork("https://arb-pokt.nodies.app");
    }

    // Plain updates
    function updateAndRun() public {
        vm.startBroadcast(sender);

        // Updates the prices for the tickers in Arbitrum
        updatePythPrices(tickers);

        // Updates the prices for the IDs in Arbitrum
        updatePythPrices(ids);

        // ... do the thing with the prices

        vm.stopBroadcast();
    }

    // Use `getPythPayload` to get just the payload
    function getPayloadAndRun() external {
        bytes[] memory payload = getPythPayload(
            tickers // or ids
        );

        vm.startBroadcast(sender);

        // get the ep from chainid
        IPyth ep = pyth.get[block.chainid];
        ep.updatePriceFeeds{value: ep.getUpdateFee(payload)}(payload);

        vm.stopBroadcast();
    }

    // Use the `getPythData` function to get prices and the payload
    function getDataAndRun() external {
        (bytes[] memory payload, PriceFeed[] memory data) = getPythData(
            tickers // or ids
        );

        vm.startBroadcast(sender);

        int64 ethPrice = data[0].price.price;
        int64 btcPrice = data[1].price.price;

        // do something with the data
        if (ethPrice > btcPrice) {
            pyth.arbitrum.updatePriceFeeds{
                value: pyth.arbitrum.getUpdateFee(payload)
            }(payload);

            // ...
        }

        vm.stopBroadcast();
    }

    // Use the `getPrice` or `getTickerPrice` to inspect a single price
    function getPriceAndRun() external {
        vm.startBroadcast(sender);

        int64 ethPrice = getPrice(ids[0]).price;
        int64 btcPrice = getTickerPrice("BTC").price;

        // do something with the data
        if (ethPrice > btcPrice) {
            bytes[] memory payload = getPythPayload(
                "ETH,BTC,ARB,USDC,USDT,DAI,UNI,XAU"
            );
            IPyth ep = pyth.get[block.chainid];
            ep.updatePriceFeeds{value: ep.getUpdateFee(payload)}(payload);
            // ...
        }

        vm.stopBroadcast();
    }
}
