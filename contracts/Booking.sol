// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./Ticket.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @author @dB2510 @xenowits
contract Booking is Ticket {
    // Assumption: Train moves from A -> B and doesn't stop at any intermediate stations
    // Also, there is no delay
    struct Train {
        uint32 trainNo;
        uint32 availableSeats; // no of available seats
        uint256 fare; // fare in gwei
        string source;
        string destination;
        bool isRunning; // true if train is active, false if it's cancelled
        // TODO: add arrivalTime & DepartureTime
    }

    event Booked(uint32 trainNo, address passenger, uint256 ticketId);

    // trainNo is the index of trains array
    Train[] public trains;

    /// mapping from ticketId to trainNo
    mapping(uint256 => uint32) ticketIdToTrainNo;

    constructor() {
        addNewTrain(250, 120, "A", "B");
        addNewTrain(251, 121, "A", "C");
        addNewTrain(252, 122, "A", "D");
        addNewTrain(253, 123, "A", "E");
        addNewTrain(254, 124, "B", "C");
        addNewTrain(255, 125, "B", "D");
        addNewTrain(256, 126, "B", "E");
        addNewTrain(257, 127, "C", "D");
        addNewTrain(258, 128, "C", "E");
        addNewTrain(259, 129, "D", "E");
    }

    /// @notice Searches train from a given source to destination
    /// @param source Source
    /// @param destination Destination
    /// @return Array of Trains starting at source and ending at destination
    function searchTrains(string memory source, string memory destination)
        public
        view
        returns (Train[] memory)
    {
        Train[] memory output = new Train[](trains.length);
        uint256 j = 0;
        for (uint256 i = 0; i < trains.length; i++) {
            if (
                isTrainAvailable(
                    trains[i].source,
                    trains[i].destination,
                    source,
                    destination
                )
            ) {
                output[j++] = trains[i];
            }
        }
        return output;
    }

    /// @param train_source Train's Source
    /// @param train_destination Train's Destination
    /// @param passenger_source Passenger's Source
    /// @param passenger_destination Passenger's Destination
    /// @return True if the given train's source & dest are the same as the passenger's
    function isTrainAvailable(
        string memory train_source,
        string memory train_destination,
        string memory passenger_source,
        string memory passenger_destination
    ) internal pure returns (bool) {
        return
            keccak256(abi.encodePacked(train_source)) ==
            keccak256(abi.encodePacked(passenger_source)) &&
            keccak256(abi.encodePacked(train_destination)) ==
            keccak256(abi.encodePacked(passenger_destination));
    }

    /// @param trainNo Train Number
    /// @param ticketMetadataURI IPFS Metadata URI from web3
    /// @return ticketId TicketId for the booked ticket
    function bookTicket(uint32 trainNo, string memory ticketMetadataURI)
        public
        payable
        returns (uint256 ticketId)
    {
        require(msg.value >= trains[trainNo].fare);
        require(trains[trainNo].availableSeats > 0);
        trains[trainNo].availableSeats--;
        ticketId = generateTicket(msg.sender, ticketMetadataURI);
        ticketIdToTrainNo[ticketId] = trainNo;
        emit Booked(trainNo, msg.sender, ticketId);
    }

    /// @param availableSeats Seats Available
    /// @param fare Train's Fare
    /// @param source Train's Source
    /// @param destination Train's Destination
    function addNewTrain(
        uint32 availableSeats,
        uint256 fare,
        string memory source,
        string memory destination
    ) internal {
        trains.push(
            Train(
                uint32(trains.length),
                availableSeats,
                fare,
                source,
                destination,
                true
            )
        );
    }

    /// @notice Update train details
    /// @param trainNo Train Number
    /// @param newFare New Fare
    /// @param changeRunningStatus To change Running Status
    function updateTrain(
        uint32 trainNo,
        uint256 newFare,
        bool changeRunningStatus
    ) internal {
        require(trainNo < trains.length);
        trains[trainNo].fare = newFare;
        if (changeRunningStatus) {
            trains[trainNo].isRunning = !trains[trainNo].isRunning;
        }
    }

    /// @param ticketId TicketId for which cancellation needs to be carried out
    /// @param trainNo TrainNo on
    /// @return True if booking cancellation is successful, false otherwise
    function cancelBooking(uint256 ticketId, uint256 trainNo)
        public
        returns (bool)
    {
        require(ownerOf(ticketId) == msg.sender);
        trains[trainNo].availableSeats++;
        require(cancelTicket(ticketId));
        require(refundFunds(ticketId));
        return true;
    }

    /// @notice Refund funds back to the passenger's wallet
    /// @param ticketId Ticket Id to refund
    /// @return True if refunded successfully
    function refundFunds(uint256 ticketId) private returns (bool) {
        ticketStatus[ticketId] = Status.REFUNDED;
        address payable passengerWalletAddress = payable(msg.sender);
        passengerWalletAddress.transfer(
            trains[ticketIdToTrainNo[ticketId]].fare
        );
        return true;
    }
}
