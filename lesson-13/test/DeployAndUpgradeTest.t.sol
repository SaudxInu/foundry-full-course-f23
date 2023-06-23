// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployBox} from "../script/DepolyBox.s.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract DeployAndUpgradeTest is Test {
    DeployBox public deployBox;
    UpgradeBox public upgradeBox;

    address public OWNER = address(1);

    function setUp() public {
        deployBox = new DeployBox();
        upgradeBox = new UpgradeBox();
    }

    function testBoxWorks() public {
        address proxyAddress = deployBox.deployBox();

        uint256 expectedValue = 0;

        assertEq(expectedValue, BoxV1(proxyAddress).getValue());
    }

    function testDeploymentIsV1() public {
        address proxyAddress = deployBox.deployBox();

        uint256 expectedValue = 1;

        assertEq(expectedValue, BoxV1(proxyAddress).version());
    }

    function testUpgradeWorks() public {
        address proxyAddress = deployBox.deployBox();

        BoxV2 box2 = new BoxV2();

        vm.prank(BoxV1(proxyAddress).owner());
        BoxV1(proxyAddress).transferOwnership(msg.sender);

        address proxy = upgradeBox.upgradeBox(proxyAddress, address(box2));

        uint256 expectedValue = 2;

        assertEq(expectedValue, BoxV2(proxy).version());

        BoxV2(proxy).setValue(expectedValue);

        assertEq(expectedValue, BoxV2(proxy).getValue());
    }
}
