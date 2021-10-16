// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Booking {
    // Assumption: Train moves from A -> B and doesn't stop at any intermediate stations
    // Also, there is no delay
    struct Train {
        uint32 trainNo;
        uint32 availableSeats; // no of available seats
        uint256 fare; // fare in gwei
        string source;
        string destination;
        // add arrivalTime & DepartureTime
    }

    event Booked(uint32 trainNo, address passenger);

    // trainNo is the index of trains array
    Train[] public trains;

    constructor() {
        trains.push(Train(0, 250, 120, "A", "B"));
        trains.push(Train(1, 251, 121, "A", "C"));
        trains.push(Train(2, 252, 122, "A", "D"));
        trains.push(Train(3, 253, 123, "A", "E"));
        trains.push(Train(4, 254, 124, "B", "C"));
        trains.push(Train(5, 255, 125, "B", "D"));
        trains.push(Train(6, 256, 126, "B", "E"));
        trains.push(Train(7, 257, 127, "C", "D"));
        trains.push(Train(8, 258, 128, "C", "E"));
        trains.push(Train(9, 259, 129, "D", "E"));
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
        for (uint256 i = 0; i < trains.length; i++) {
            if (isTrainAvailable(trains[i].source, trains[i].destination, source, destination)) {
                output[i] = trains[i];
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

    function bookTicket(uint32 trainNo) public payable {
        require(msg.value >= trains[trainNo].fare);
        require(trains[trainNo].availableSeats > 0);
        trains[trainNo].availableSeats--;
        emit Booked(trainNo, msg.sender);
    }
}
