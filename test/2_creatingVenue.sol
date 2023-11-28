// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TicketingSystem} from "../src/ticketingSystem.sol";

contract VenueProfileTest is Test {
    TicketingSystem private ticketingSystem;

    bytes32 venue1Name = "Bercy";
    bytes32 venue2Name = "Olympia";

    uint256 venue1Capacity = 300;
    uint256 venue2Capacity = 4000;

    uint256 venue1Commission = 2000;
    uint256 venue2Commission = 1500;

    address payable private user1 = payable(address(0x1));
    address payable private user2 = payable(address(0x2));

    function setUp() public {
        ticketingSystem = new TicketingSystem();
    }

    function testCreateVenueProfile() public {
        // Creating venue profiles
        // function createVenue(bytes32 _name, uint256 _capacity, uint256 _standardComission) public {
        vm.prank(user1);
        ticketingSystem.createVenue(venue1Name, venue1Capacity, venue1Commission);
        vm.prank(user2);
        ticketingSystem.createVenue(venue2Name, venue2Capacity, venue2Commission);

        // Retrieving venue info
        (bytes32 retrievedName1, uint256 retrievedCapacity1, uint256 retrievedCommission1, address owner1) =
            ticketingSystem.venuesRegister(1);
        (bytes32 retrievedName2, uint256 retrievedCapacity2, uint256 retrievedCommission2, address owner2) =
            ticketingSystem.venuesRegister(2);

        // Checking that retrieved infos are correct
        assertEq(retrievedName1, venue1Name);
        assertEq(retrievedName2, venue2Name);
        assertEq(retrievedCapacity1, venue1Capacity);
        assertEq(retrievedCapacity2, venue2Capacity);
        assertEq(retrievedCommission1, venue1Commission);
        assertEq(retrievedCommission2, venue2Commission);
    }

    function testModifyVenueProfile() public {
        // Creating a new venue and checking it happened correctly
        vm.prank(user1);
        ticketingSystem.createVenue(venue1Name, venue1Capacity, venue1Commission);
        // Retrieving venue info
        (bytes32 retrievedName1, uint256 retrievedCapacity1, uint256 retrievedCommission1, address owner1) =
            ticketingSystem.venuesRegister(1);
        assertEq(retrievedName1, venue1Name);

        // Trying to modify venue profile with a wrong owner address
        // function modifyVenue(
        //     uint256 _venueId,
        //     bytes32 _name,
        //     uint256 _capacity,
        //     uint256 _standardComission,
        //     address payable _newOwner
        // ) public
        vm.prank(user2);
        vm.expectRevert("not the venue owner");
        ticketingSystem.modifyVenue(1, venue2Name, venue2Capacity, venue2Commission, user2);

        // Modifying venue profile
        vm.prank(user1);
        ticketingSystem.modifyVenue(1, venue2Name, venue2Capacity, venue2Commission, user2);

        // Checking modification were registered
        (bytes32 retrievedName2, uint256 retrievedCapacity2, uint256 retrievedCommission2, address owner2) =
            ticketingSystem.venuesRegister(1);
        assertEq(retrievedName2, venue2Name);
        assertEq(retrievedCapacity2, venue2Capacity);
        assertEq(retrievedCommission2, venue2Commission);
    }
}
