// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TicketingSystem} from "../src/ticketingSystem.sol";

contract TicketManagementTest is Test {
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

    uint256 concertPrice = 1000;

    function setUp() public {
        ticketingSystem = new TicketingSystem();
        // Create a venue with user1 as owner
        vm.prank(user0);
        ticketingSystem.createVenue(venue1Name, venue1Capacity, venue1Commission);
        // Create an artist with user2 as owner
        uint256 artistCategory = 1;
        vm.prank(user1);
        ticketingSystem.createArtist(artist1Name, artistCategory);
        // Create a concert
        uint256 oneDay = 60 * 60 * 24;
        uint256 concertDate2 = block.timestamp + oneDay - 1;
        vm.prank(user1);
        ticketingSystem.createConcert(1, 1, concertDate2, concertPrice);
        vm.prank(user0);
        ticketingSystem.validateConcert(1);
    }

    function testBuyingTicket() public {
        // Buying 2 tickets
        // function buyTicket(uint _concertId) public payable
        vm.deal(user3, concertPrice * 2);
        vm.deal(user4, concertPrice * 2);
        vm.prank(user3);
        ticketingSystem.buyTicket{value: concertPrice}(1);
        vm.prank(user4);
        ticketingSystem.buyTicket{value: concertPrice}(1);

        // Verifying concert infos
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
        assertEq(totalTicketSold1, 2);
        assertEq(totalMoneyCollected1, 2 * concertPrice);

        // Verifying ticket info
        (uint256 concertId1, address payable owner1, bool isAvailable1, bool isAvailableForSale, uint256 amountPaid1) =
            ticketingSystem.ticketsRegister(1);
        assertEq(concertId1, 1);
        assertEq(owner1, user3);
        assertEq(isAvailable1, true);
        assertEq(amountPaid1, concertPrice);
        assertEq(isAvailableForSale, false);
    }

    function testUsingBoughtTickets() public {
        // Buying ticket
        vm.deal(user3, concertPrice * 2);
        vm.prank(user3);
        ticketingSystem.buyTicket{value: concertPrice}(1);
        // Trying to use ticket I do not own
        vm.prank(user5);
        vm.expectRevert("sender should be the owner");
        ticketingSystem.useTicket(1);

        // Using a ticket on the day of the event
        vm.prank(user3);
        ticketingSystem.useTicket(1);

        // Verifying ticket info
        (uint256 concertId1, address payable owner1, bool isAvailable1, bool isAvailableForSale, uint256 amountPaid1) =
            ticketingSystem.ticketsRegister(1);
        assertEq(isAvailable1, false);
        assertEq(owner1, payable(address(0)));
    }

    function testTransferringTickets() public {
        // Buying ticket
        vm.deal(user3, concertPrice * 2);
        vm.prank(user3);
        ticketingSystem.buyTicket{value: concertPrice}(1);

        // Trying to transfer ticket I do not own
        // function transferTicket(uint _ticketId, address payable _newOwner) public
        vm.prank(user5);
        vm.expectRevert("not the ticket owner");
        ticketingSystem.transferTicket(1, user5);

        // Transferring a ticket
        vm.prank(user3);
        ticketingSystem.transferTicket(1, user5);

        // Verifying ticket info
        (uint256 concertId1, address payable owner1, bool isAvailable1, bool isAvailableForSale, uint256 amountPaid1) =
            ticketingSystem.ticketsRegister(1);
        assertEq(owner1, user5);
    }
}
