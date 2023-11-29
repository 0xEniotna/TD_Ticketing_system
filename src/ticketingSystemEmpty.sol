// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract TicketingSystem {
    // VARIABLES AND STRUCTS

    //An artist as a name, a category and has an address
    struct artist {
        bytes32 name;
        uint256 artistCategory;
        address owner;
        uint256 totalTicketSold;
    }

    struct venue {
        bytes32 name;
        uint256 capacity;
        uint256 standardComission;
        address payable owner;
    }

    struct concert {
        uint256 artistId;
        uint256 venueId;
        uint256 concertDate;
        uint256 ticketPrice;
        //not declared by user
        bool validatedByArtist;
        bool validatedByVenue;
        uint256 totalSoldTicket;
        uint256 totalMoneyCollected;
    }

    struct ticket {
        uint256 concertId;
        address payable owner;
        bool isAvailable;
        bool isAvailableForSale;
        uint256 amountPaid;
    }

    //Counts number of artists created
    uint256 public artistCount = 0;
    //Counts the number of venues
    uint256 public venueCount = 0;
    //Counts the number of concerts
    uint256 public concertCount = 0;

    uint256 public ticketCount = 0;

    //MAPPINGS & ARRAYS
    mapping(uint256 => artist) public artistsRegister;
    mapping(bytes32 => uint256) private artistsID;

    mapping(uint256 => venue) public venuesRegister;
    mapping(bytes32 => uint256) private venuesID;

    mapping(uint256 => concert) public concertsRegister;

    mapping(uint256 => ticket) public ticketsRegister;

    //EVENTS
    event CreatedArtist(bytes32 name, uint256 id);
    event ModifiedArtist(bytes32 name, uint256 id, address sender);
    event CreatedVenue(bytes32 name, uint256 id);
    event ModifiedVenue(bytes32 name, uint256 id);
    event CreatedConcert(uint256 concertDate, bytes32 name, uint256 id);

    constructor() {}

    //FUNCTIONS TEST 1 -- ARTISTS

    function createArtist(bytes32 _name, uint256 _artistCategory) public {}

    function getArtistId(bytes32 _name) public view returns (uint256 ID) {
        return 0;
    }

    function modifyArtist(uint256 _artistId, bytes32 _name, uint256 _artistCategory, address payable _newOwner)
        public
    {}

    //FUNCTIONS TEST 2 -- VENUES
    function createVenue(bytes32 _name, uint256 _capacity, uint256 _standardComission) public {}

    function getVenueId(bytes32 _name) public view returns (uint256 ID) {
        return 0;
    }

    function modifyVenue(
        uint256 _venueId,
        bytes32 _name,
        uint256 _capacity,
        uint256 _standardComission,
        address payable _newOwner
    ) public {}

    //FUNCTIONS TEST 3 -- CONCERTS
    function createConcert(uint256 _artistId, uint256 _venueId, uint256 _concertDate, uint256 _ticketPrice) public {}

    function validateConcert(uint256 _concertId) public {}

    //Creation of a ticket, only artists can create tickets
    function emitTicket(uint256 _concertId, address payable _ticketOwner) public {}

    function useTicket(uint256 _ticketId) public {}

    //FUNCTIONS TEST 4 -- BUY/TRANSFER
    function buyTicket(uint256 _concertId) public payable {}

    function transferTicket(uint256 _ticketId, address payable _newOwner) public {}

    //FUNCTIONS TEST 5 -- CONCERT CASHOUT
    function cashOutConcert(uint256 _concertId, address payable _cashOutAddress) public {}

    //FUNCTIONS TEST 6 -- TICKET SELLING
    function offerTicketForSale(uint256 _ticketId, uint256 _salePrice) public {}

    function buySecondHandTicket(uint256 _ticketId) public payable {}
}
