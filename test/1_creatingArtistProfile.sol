// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TicketingSystem} from "../src/ticketingSystem.sol";

contract ArtistProfileTest is Test {
    TicketingSystem private ticketingSystem;

    bytes32 artist1Name = "Electric Octopus";
    bytes32 artist2Name = "David Bowie";

    address payable private user1 = payable(address(0x1));
    address payable private user2 = payable(address(0x2));

    function setUp() public {
        ticketingSystem = new TicketingSystem();
    }

    function testCreateArtistProfile() public {
        uint256 artistCategory = 1;

        // Creating artist profiles
        vm.prank(user1);
        ticketingSystem.createArtist(artist1Name, artistCategory);
        vm.prank(user2);
        ticketingSystem.createArtist(artist2Name, artistCategory);

        // Retrieving artist info
        (bytes32 name1, uint256 artistCategory1, address owner1, uint256 totalTicketSold1) =
            ticketingSystem.artistsRegister(1);
        (bytes32 name2, uint256 artistCategory2, address owner2, uint256 totalTicketSold2) =
            ticketingSystem.artistsRegister(2);

        // Asserts
        assertEq(name1, artist1Name);
        assertEq(name2, artist2Name);
        assertEq(owner1, user1);
        assertEq(owner2, user2);
    }

    function testModifyArtistProfile() public {
        uint256 artistCategory = 1;
        uint256 newArtistCategory = 2;

        // Creating a new artist and checking it happened correctly
        // function createArtist(bytes32 _name, uint256 _artistCategory) public
        vm.prank(user1);
        ticketingSystem.createArtist(artist1Name, artistCategory);
        (bytes32 name1, uint256 artistCategory1, address owner1, uint256 totalTicketSold1) =
            ticketingSystem.artistsRegister(1);
        assertEq(name1, artist1Name);

        // Trying to modify artist profile with a wrong owner address
        //function modifyArtist(uint _artistId, bytes32 _name, uint _artistCategory, address payable _newOwner)

        vm.prank(user2);
        vm.expectRevert("not the owner");
        ticketingSystem.modifyArtist(1, artist2Name, newArtistCategory, user2);

        // Modifying artist profile
        vm.prank(user1);
        ticketingSystem.modifyArtist(1, artist2Name, newArtistCategory, user2);

        // Checking modification were registered
        (bytes32 name2, uint256 artistCategory2, address owner2, uint256 totalTicketSold2) =
            ticketingSystem.artistsRegister(1);
        assertEq(name2, artist2Name);
        assertEq(artistCategory2, newArtistCategory);
        assertEq(owner2, user2);
    }
}
