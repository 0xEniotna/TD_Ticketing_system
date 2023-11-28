// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TicketingSystem} from "../src/ticketingSystem.sol";

contract ConcertManagmentTest is Test {
    TicketingSystem private ticketingSystem;

    bytes32 venue1Name = "Bercy";
    bytes32 venue2Name = "Olympia";

    uint256 venue1Capacity = 300;
    uint256 venue2Capacity = 4000;

    uint256 venue1Commission = 2000;
    uint256 venue2Commission = 1500;

    address payable private user0 = payable(address(0x1));
    address payable private user1 = payable(address(0x2));
    address payable private user2 = payable(address(0x3));
    address payable private user3 = payable(address(4));
    address payable private user4 = payable(address(5));
    address payable private user5 = payable(address(6));
    address payable private user6 = payable(address(7));

    bytes32 artist1Name = "Electric Octopus";
    bytes32 artist2Name = "David Bowie";

    uint256 oneWeek = 60 * 60 * 24 * 7;
    uint256 concertDate = block.timestamp + oneWeek;

    function setUp() public {
        vm.prank(user0);
        ticketingSystem = new TicketingSystem();
        // Create a venue with user1 as owner
        vm.prank(user0);
        ticketingSystem.createVenue(venue1Name, venue1Capacity, venue1Commission);
        // Create an artist with user2 as owner
        uint256 artistCategory = 1;
        vm.prank(user1);
        ticketingSystem.createArtist(artist1Name, artistCategory);
    }

    function testCreateConcert() public {
        // AnyoneCan declare a concert for any artist they want.
        // Tickets can be sold before the venue or the artits validated their participation. This is to incentivize the artists
        // and venue to look at potential opportunities, with actual funds licked in waiting for them.
        // function createConcert(uint _artistId, uint _venueId, uint _concertDate, uint _ticketPrice)

        // Creating concerts
        vm.prank(user1);
        ticketingSystem.createConcert(1, 1, concertDate, 1000);
        vm.prank(user2);
        ticketingSystem.createConcert(1, 1, concertDate, 1000);

        // Retrieve concert info
        (
            uint256 artistId1,
            uint256 venueId1,
            uint256 concertDate1,
            uint256 ticketPrice1,
            bool validatedByArtist1,
            bool validatedByVenue1,
            uint256 totalTicketSold1,
            uint256 totalMoneyCollected1
        ) = ticketingSystem.concertsRegister(1);
        (
            uint256 artistId2,
            uint256 venueId2,
            uint256 concertDate2,
            uint256 ticketPrice2,
            bool validatedByArtist2,
            bool validatedByVenue2,
            uint256 totalTicketSold2,
            uint256 totalMoneyCollected2
        ) = ticketingSystem.concertsRegister(2);

        // Checking that retrieved infos are correct
        assertEq(artistId1, 1);
        assertEq(artistId2, 1);

        assertEq(concertDate1, concertDate);
        assertEq(concertDate2, concertDate);

        assertEq(validatedByArtist1, true);
        assertEq(validatedByArtist2, false);

        assertEq(validatedByVenue1, false);
        assertEq(validatedByVenue2, false);

        // Artist accepts concert 2 and venue accepts concert 1 and 2
        // function validateConcert(uint _concertId)
        vm.prank(user0);
        ticketingSystem.validateConcert(1);
        vm.prank(user0);
        ticketingSystem.validateConcert(2);
        vm.prank(user1);
        ticketingSystem.validateConcert(2);

        // Retrieve concert info
        (
            artistId1,
            venueId1,
            concertDate1,
            ticketPrice1,
            validatedByArtist1,
            validatedByVenue1,
            totalTicketSold1,
            totalMoneyCollected1
        ) = ticketingSystem.concertsRegister(1);
        (
            artistId2,
            venueId2,
            concertDate2,
            ticketPrice2,
            validatedByArtist2,
            validatedByVenue2,
            totalTicketSold2,
            totalMoneyCollected2
        ) = ticketingSystem.concertsRegister(2);

        // Checking validation
        assertEq(validatedByArtist1, true);
        assertEq(validatedByArtist2, true);
        assertEq(validatedByVenue1, true);
        assertEq(validatedByVenue2, true);
    }

    function testEmitTickets() public {
        uint256 concertPrice = 1000;
        // Creating concerts
        vm.prank(user1);
        ticketingSystem.createConcert(1, 1, concertDate, concertPrice);
        vm.prank(user0);
        ticketingSystem.validateConcert(1);
        // Retrieve concert info
        (
            uint256 artistId1,
            uint256 venueId1,
            uint256 concertDate1,
            uint256 ticketPrice1,
            bool validatedByArtist1,
            bool validatedByVenue1,
            uint256 totalTicketSold1,
            uint256 totalMoneyCollected1
        ) = ticketingSystem.concertsRegister(1);
        assertEq(totalTicketSold1, 0);
        assertEq(totalMoneyCollected1, 0);

        // Emitting 5 tickets. Only artists can emit tickets.
        // function emitTicket(uint _concertId, address payable _ticketOwner)
        vm.prank(user1);
        ticketingSystem.emitTicket(1, user2);
        vm.prank(user1);
        ticketingSystem.emitTicket(1, user3);
        vm.prank(user1);
        ticketingSystem.emitTicket(1, user4);
        vm.prank(user1);
        ticketingSystem.emitTicket(1, user5);
        vm.prank(user1);
        ticketingSystem.emitTicket(1, user6);
        // Trying to emit ticket with wrong account, expect revert
        vm.prank(user2);
        vm.expectRevert("not the owner");
        ticketingSystem.emitTicket(1, user5);

        // Verifying concert info
        (
            artistId1,
            venueId1,
            concertDate1,
            ticketPrice1,
            validatedByArtist1,
            validatedByVenue1,
            totalTicketSold1,
            totalMoneyCollected1
        ) = ticketingSystem.concertsRegister(1);
        assertEq(totalTicketSold1, 5);
        assertEq(totalMoneyCollected1, 0);

        // Verifying ticket infos
        (uint256 concertId1, address payable owner1, bool isAvailable1, bool isAvailableForSale, uint256 amountPaid1) =
            ticketingSystem.ticketsRegister(3);
        assertEq(owner1, user4);
        assertEq(isAvailable1, true);
    }

    function testUseTicket() public {
        uint256 oneDay = 60 * 60 * 24;
        uint256 concertPrice = 1000;

        uint256 concertDate2 = block.timestamp + oneDay - 1;
        // Creating concerts
        vm.prank(user1);
        ticketingSystem.createConcert(1, 1, concertDate, concertPrice);
        vm.prank(user0);
        ticketingSystem.validateConcert(1);
        vm.prank(user1);
        ticketingSystem.createConcert(1, 1, concertDate2, concertPrice);
        // Retrieve concert info
        (
            uint256 artistId1,
            uint256 venueId1,
            uint256 concertDate1,
            uint256 ticketPrice1,
            bool validatedByArtist1,
            bool validatedByVenue1,
            uint256 totalTicketSold1,
            uint256 totalMoneyCollected1
        ) = ticketingSystem.concertsRegister(1);
        assertEq(totalTicketSold1, 0);
        assertEq(totalMoneyCollected1, 0);

        // Buying 2 tickets for concert 1 and 2
        vm.prank(user1);
        ticketingSystem.emitTicket(1, user3);
        vm.prank(user1);
        ticketingSystem.emitTicket(2, user4);

        // Trying to use ticket I do not own
        // function useTicket(uint _ticketId)
        vm.prank(user5);
        vm.expectRevert("sender should be the owner");
        ticketingSystem.useTicket(1);
        // Trying to use ticket before the day of the event
        vm.prank(user3);
        vm.expectRevert("should be used the d-day");
        ticketingSystem.useTicket(1);
        // Trying to use ticket before the venue validated the event
        vm.prank(user4);
        vm.expectRevert("should be validated by the venue");
        ticketingSystem.useTicket(2);

        // Validating the concert
        vm.prank(user0);
        ticketingSystem.validateConcert(2);

        // Using a ticket on the day of the event
        vm.prank(user4);
        ticketingSystem.useTicket(2);

        // Verifying ticket info
        (uint256 concertId1, address payable owner1, bool isAvailable1, bool isAvailableForSale, uint256 amountPaid1) =
            ticketingSystem.ticketsRegister(3);
        assertEq(isAvailable1, false);
        assertEq(owner1, address(0));
    }
}
