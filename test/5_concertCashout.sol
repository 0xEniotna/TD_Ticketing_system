// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {TicketingSystem} from "../src/ticketingSystem.sol";

contract ConcertCashoutTest is Test {
    TicketingSystem private ticketingSystem;

    bytes32 venue1Name = "Bercy";
    bytes32 venue2Name = "Olympia";

    uint256 venue1Capacity = 300;
    uint256 venue2Capacity = 4000;

    uint256 venue1Commission = 2000;
    uint256 venue2Commission = 1500;

    address payable private user0 = payable(address(1));
    address payable private user1 = payable(address(2));
    address payable private user2 = payable(address(3));
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
        uint256 fifteenSeconds = 15;
        uint256 concertDate = block.timestamp + oneWeek;
        uint256 concertDate2 = oneDay + fifteenSeconds;
        vm.prank(user1);
        ticketingSystem.createConcert(1, 1, concertDate2, concertPrice);
        vm.prank(user0);
        ticketingSystem.validateConcert(1);

        // Buying 2 tickets
        vm.deal(user3, concertPrice * 2);
        vm.deal(user4, concertPrice * 2);
        vm.prank(user3);
        ticketingSystem.buyTicket{value: concertPrice}(1);
        vm.prank(user4);
        ticketingSystem.buyTicket{value: concertPrice}(1);

        // // Using tickets
        vm.warp(oneDay);

        vm.prank(user3);
        ticketingSystem.useTicket(1);
        vm.prank(user4);
        ticketingSystem.useTicket(2);
    }

    function testCashingOutConcert() public {
        // Checking initial balance
        vm.deal(user6, 100000);
        uint256 user6initialBalance = user6.balance;
        uint256 ticketingSystemInitialBalance = address(ticketingSystem).balance;
        vm.deal(user0, 10000);
        uint256 venue1InitialBalance = user0.balance;

        // Trying to cash out before the start of the concert
        // function cashOutConcert(uint _concertId, address payable _cashOutAddress)
        vm.prank(user1);
        vm.expectRevert("should be after the concert");
        ticketingSystem.cashOutConcert(1, user6);

        // Waiting for the concert to start
        uint256 fifteenSeconds = 15;
        // Current block timestamp
        uint256 currentTimestamp = block.timestamp;
        // Simulate waiting for fifteen seconds
        vm.warp(currentTimestamp + fifteenSeconds);

        // Trying to cash out with another account
        vm.prank(user2);
        vm.expectRevert("should be the artist");
        ticketingSystem.cashOutConcert(1, user6);

        vm.prank(user1);
        ticketingSystem.cashOutConcert(1, user6);
        // Attempt to call cashOutConcert and catch any reverts

        uint256 user6FinalBalance = user6.balance;
        uint256 ticketingSystemFinalBalance = address(ticketingSystem).balance;
        uint256 venue1FinalBalance = user0.balance;

        // Calculating the share of each stakeholder. The commission is recorded in % with 2 decimals (eg 24.23 %)
        uint256 totalTicketSale = concertPrice * 2;
        uint256 venueShare = (totalTicketSale * venue1Commission) / 10000;
        uint256 artistShare = totalTicketSale - venueShare;

        uint256 expectedAccount6Balance = user6initialBalance + artistShare;
        uint256 expectedAccount0Balance = venue1InitialBalance + venueShare;

        assertEq(user6FinalBalance, expectedAccount6Balance);
        assertEq(venue1FinalBalance, expectedAccount0Balance);
        assertEq(ticketingSystemFinalBalance, 0);

        // Retrieve concert info

        // checking that the tickets that were sold are accounted in artist profile
        // Retrieving artist info
        (bytes32 name1, uint256 artistCategory1, address owner1, uint256 totalTicketSold2) =
            ticketingSystem.artistsRegister(1);
        assertEq(totalTicketSold2, 2);
    }
}
