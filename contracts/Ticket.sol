// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Authors: @xenowits @dB2510
contract Ticket is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _ticketIds;

    constructor() ERC721("BRTicket", "BRT") {}

    // Enum representing status of the ticket
    enum Status {
        BOOKED,
        CANCELLED,
        REFUNDED
    }

    /// mapping from ticketId to Status of the ticket
    mapping(uint => Status) ticketStatus;

    /// @notice Generates a ticket in the form of an NFT
    /// @param passenger Address of the passenger who booking the ticket
    /// @param ticketMetadataURI Ticket details from web3js
    /// @return ticketId 
    function generateTicket(address passenger, string memory ticketMetadataURI) internal returns (uint256) {
        _ticketIds.increment();
        uint newTicketId = _ticketIds.current();

        _safeMint(passenger, newTicketId);

        // set ticketMetadataURI as ipfs metadata URL
        _setTokenURI(newTicketId, ticketMetadataURI);

        return newTicketId;
    }
    
    function cancelTicket(uint256 ticketId) internal returns (bool) {
        require(_exists(ticketId));
        ticketStatus[ticketId] = Status.CANCELLED;
        require(refundTicket(ticketId));
        return true;
    }

    function refundTicket(uint256 ticketId) private returns (bool) {
        ticketStatus[ticketId] = Status.REFUNDED;
        // logic for safe transfer of funds back to the passenger's wallet
        return true;
    }

}