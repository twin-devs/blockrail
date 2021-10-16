// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Booking.sol";

/// @author @xenowits @dB2510
/// @title Ticket for train bookings
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
    mapping(uint256 => Status) ticketStatus;

    /// @notice Generates a ticket in the form of an NFT
    /// @param passenger Address of the passenger who booking the ticket
    /// @param ticketMetadataURI Ticket details from web3js
    /// @return ticketId
    function generateTicket(address passenger, string memory ticketMetadataURI)
        internal
        returns (uint256)
    {
        _ticketIds.increment();
        uint256 newTicketId = _ticketIds.current();
        _safeMint(passenger, newTicketId);

        // set ticketMetadataURI as ipfs metadata URL
        _setTokenURI(newTicketId, ticketMetadataURI);
        return newTicketId;
    }

    /// @param ticketId Ticket Id to cancel
    /// @return True if cancelled successfully
    function cancelTicket(uint256 ticketId) internal returns (bool) {
        require(_exists(ticketId));
        ticketStatus[ticketId] = Status.CANCELLED;
        return true;
    }
}
