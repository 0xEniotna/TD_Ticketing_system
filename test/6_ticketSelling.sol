// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TicketingSystem} from "../src/ticketingSystem.sol";

contract TicketSellingTest is Test {
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
    uint256 oneDay = 60 * 60 * 24;

    uint256 concertPrice = 1000;

    function setUp() public {
        vm.prank(user0);
        ticketingSystem = new TicketingSystem();
        // Create a venue with user1 as owner
        vm.prank(user0);
        ticketingSystem.createVenue(venue1Name, venue1Capacity, venue1Commission);
        // Create an artist with user1 as owner
        uint256 artistCategory = 1;
        vm.prank(user1);
        ticketingSystem.createArtist(artist1Name, artistCategory);
        // Create a concert
        uint256 concertDate = block.timestamp + oneDay - 1;
        vm.prank(user1);
        ticketingSystem.createConcert(1, 1, concertDate, concertPrice);
        vm.prank(user0);
        ticketingSystem.validateConcert(1);

        // Buying 2 tickets
        vm.deal(user3, concertPrice * 2);
        vm.deal(user4, concertPrice * 2);
        vm.prank(user3);
        ticketingSystem.buyTicket{value: concertPrice}(1);
        vm.prank(user4);
        ticketingSystem.buyTicket{value: concertPrice}(1);
    }

    function testSellingTicket() public {
        // Verifying ticket info
        (uint256 concertId1, address payable owner1, bool isAvailable, bool isAvailableForSale, uint256 amountPaid1) =
            ticketingSystem.ticketsRegister(1);
        assertEq(isAvailable, true);
        assertEq(isAvailableForSale, false);

        // Offering a ticket to sell
        // function offerTicketForSale(uint _ticketId, uint _salePrice)
        vm.prank(user3);
        ticketingSystem.offerTicketForSale(1, concertPrice - 2);

        // Verifying ticket infos
        (concertId1, owner1, isAvailable, isAvailableForSale, amountPaid1) = ticketingSystem.ticketsRegister(1);
        assertEq(isAvailable, true);
        assertEq(isAvailableForSale, true);

        // Trying to sell a ticket that does not belong to me
        vm.prank(user4);
        vm.expectRevert("should be the owner");
        ticketingSystem.offerTicketForSale(1, concertPrice - 2);

        // Trying to sell a ticket for more than I paid for it
        vm.prank(user3);
        vm.expectRevert("should be less than the amount paid");
        ticketingSystem.offerTicketForSale(1, concertPrice + 2);
    }

    function testBuyingAuctionnedTicket() public {
        // Offering a ticket to sell
        // function offerTicketForSale(uint _ticketId, uint _salePrice)
        vm.prank(user3);
        ticketingSystem.offerTicketForSale(1, concertPrice - 2);

        // Trying to buy the ticket for lower than the proposed price
        // function buySecondHandTicket(uint256 _ticketId) public payable
        vm.prank(user4);
        vm.expectRevert("not enough funds");
        ticketingSystem.buySecondHandTicket{value: concertPrice - 3}(1);

        // Buying the ticket
        vm.prank(user4);
        ticketingSystem.buySecondHandTicket{value: concertPrice - 2}(1);
    }

    function testUsingTicketWhileOnSale() public {
        // Offering a ticket to sell
        vm.prank(user3);
        ticketingSystem.offerTicketForSale(1, concertPrice - 2);

        // Changed my mind, using the ticket
        vm.prank(user3);
        ticketingSystem.useTicket(1);

        // Trying to buy the ticket even though it was already used
        vm.prank(user4);
        vm.expectRevert("should be available");
        ticketingSystem.buySecondHandTicket{value: concertPrice - 2}(1);
    }
}
