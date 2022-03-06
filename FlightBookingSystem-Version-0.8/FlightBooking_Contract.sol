// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {ERC721} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/db58acead175c62f8d6ae1ea030865503029ff49/contracts/token/ERC721/ERC721.sol";


contract FlightBookingSystem is ERC721 {
    
    enum SeatCategory {Economy, Business, First}
    enum SeatOccupiedStatus {Vacant, Occupied}
    enum FlightStatus {Enabled, OnTime, Delayed, Cancelled, Departed, Landed}
    
    // a struct model for a Flight
    struct Flight {
        bytes32 flightId;
        bytes8 flightNumber;
        bytes3 origin;
        bytes3 destination;
        address airlineAddress;
        uint departureDateTime;
        uint totalNumberSeats;
        uint256[] seatIds;
        FlightStatus flightStatus;
    }

    // a struct model for a Seat
    struct Seat {
        uint256 seatId;
        bytes4 seatNumber;
        uint price;
        SeatOccupiedStatus occupiedStatus;
        SeatCategory seatCategory;
        bytes32 flightId;
    }
    
    // a struct model for a Booking Refund
    struct PassengerRefund {
        address recipient;
        uint amount;
        bool paid;
    }
    
    struct AirlinePayment {
        address recipient;
        uint amount;
        bool paid;
    }
    
    
    mapping(bytes32 => Flight) internal flights; // flightIds to flights.

    mapping(uint256 => Seat) internal seats; // seatIds to seats.
    
    mapping(address => bytes32[]) internal flightIds; // airlines to their belonging flightIds
    
    mapping(address => AirlinePayment ) internal airlineBalancePayment;
    
    mapping(address => PassengerRefund) internal passengerRefunds;
    
    mapping(bytes32 => uint) internal flightBalance;
    
    
    // gets the flightId for a given flightNumber and _departureDateTime
    function getFlightId(bytes8 _flightNumber, uint _departureDateTime) public pure returns (bytes32){
        return keccak256(abi.encodePacked(_flightNumber, "_", _departureDateTime));
    }

    // gets the seatId for a given flightNumber, _departureDateTime and seatNumber
    function getSeatId(bytes8 _flightNumber, uint _departureDateTime, bytes4 _seatNumber) public pure returns (uint256){
        return uint256(keccak256(abi.encodePacked(_flightNumber, "_", _departureDateTime, "_", _seatNumber)));
    }
    
    
    // get the airline who owns the flight containing the given seatId
    function getAirlineAddressForSeat(uint _seatId) private view returns (address){
        return flights[seats[_seatId].flightId].airlineAddress;
    }
    
    
    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol){
        createFlight(0x4241313235000000,0x4c4852,0x4a464b,1637507767,2);
        createFlight(0x4241313236000000,0x4c4852,0x4a464b,1637507767,2);
        createFlight(0x4241313237000000,0x4c4852,0x4a464b,1637507767,2);
        addSeatToFlight(0x4241313235000000,1637507767,0x31410000,10000000000000000000, SeatCategory.Economy);
        addSeatToFlight(0x4241313235000000,1637507767,0x31420000,10000000000000000000, SeatCategory.Economy);
        addSeatToFlight(0x4241313236000000,1637507767,0x31410000,10000000000000000000, SeatCategory.Economy);
        addSeatToFlight(0x4241313236000000,1637507767,0x31420000,10000000000000000000, SeatCategory.Economy);
        addSeatToFlight(0x4241313237000000,1637507767,0x31410000,10000000000000000000, SeatCategory.Economy);
        addSeatToFlight(0x4241313237000000,1637507767,0x31420000,10000000000000000000, SeatCategory.Economy);
    }
    
    /**
     * @dev Initialises a Flight in storage for an airline
     * @param _flightNumber bytes8 of the flight
     * @param _origin bytes3 IATA code for origin airport
     * @param _destination bytes3 IATA code for destination airport
     * @param _departureDateTime uint256 representing the departure dateTime
     * @param _totalNumberSeats uint256 to represent total seat count for this flight
     * @return bytes32 flight ID of the flight which is used as the key to obtain the Flight model from storage
     */
    function createFlight(
        bytes8 _flightNumber,
        bytes3 _origin,
        bytes3 _destination,
        uint256 _departureDateTime,
        uint256 _totalNumberSeats
    )
        private
        returns (bytes32)
    {
        bytes32 _flightId = getFlightId(_flightNumber, _departureDateTime);
        require(_departureDateTime > block.timestamp, "EC01");

        flights[_flightId] = Flight({
            flightId: _flightId,
            flightNumber: _flightNumber,
            origin: _origin,
            destination: _destination,
            airlineAddress: msg.sender,
            departureDateTime: _departureDateTime,
            totalNumberSeats: _totalNumberSeats,
            seatIds: new uint[](0),
            flightStatus : FlightStatus.Enabled
            });

        flightIds[msg.sender].push(_flightId);

        return _flightId;
    }
    

    function addSeatToFlight(
        bytes8 _flightNumber, 
        uint256 _departureDateTime, 
        bytes4 _seatNumber, 
        uint256 _seatPrice, 
        SeatCategory seatCategory ) 
    private 
    {
        bytes32 _flightId = getFlightId(_flightNumber, _departureDateTime);
        require(flights[_flightId].flightNumber != 0, "EC02");
        require(flights[_flightId].seatIds.length <= (flights[_flightId].totalNumberSeats-1), "EC03");
        flights[_flightId].seatIds.push(createSeat(_flightNumber, _departureDateTime, _seatNumber, _seatPrice, seatCategory));
    }
    
    function  createSeat(
        bytes8 _flightNumber,
        uint _departureDateTime,
        bytes4 _seatNumber,
        uint256 _price,
        SeatCategory _seatCategory
    )
        private returns (uint256)
    {
        uint256 _seatId = getSeatId(_flightNumber, _departureDateTime, _seatNumber);
        Seat memory _seat = Seat({
            seatId: _seatId,
            seatNumber: _seatNumber,
            price: _price,
            occupiedStatus: SeatOccupiedStatus.Vacant,
            seatCategory : _seatCategory,
            flightId: getFlightId(_flightNumber, _departureDateTime)
            });

        seats[_seatId] = _seat;
        return _seatId;
    }
    
    
    function bookSeat (uint256 _seatId)
        external
        payable
        returns (uint256)
    {
        
        if (seats[_seatId].seatId != _seatId) {
            revert("EC04");}
        else if (flights[seats[_seatId].flightId].departureDateTime <= block.timestamp){
            revert("EC05");}
        else if (flights[seats[_seatId].flightId].flightStatus == FlightStatus.Departed || flights[seats[_seatId].flightId].flightStatus == FlightStatus.Cancelled || flights[seats[_seatId].flightId].flightStatus == FlightStatus.Landed){
            revert("EC06");}
        else if (seats[_seatId].flightId == 0){
            revert("EC07");}
        else if (seats[_seatId].occupiedStatus != SeatOccupiedStatus.Vacant){
            revert("EC08");}
        else if (msg.value != seats[_seatId].price){
            revert("EC09");}
        else {
            seats[_seatId].occupiedStatus = SeatOccupiedStatus.Occupied;
        
            address _airlineAddress = getAirlineAddressForSeat(_seatId);
    
            if(_exists(_seatId)){ // seat will already exist if was previously booked/minted and subsequently cancelled. In this case the seat should have been returned to the airline.
                require(ownerOf(_seatId) == _airlineAddress, "EC10");
                safeTransferFrom(_airlineAddress, msg.sender, _seatId);
            }
            else{
                _mint(msg.sender, _seatId);
            }
    
            approve(_airlineAddress, _seatId);
            flightBalance[seats[_seatId].flightId] = flightBalance[seats[_seatId].flightId] + msg.value;
            return _seatId;}

    }
    
    
    function safeTransfer(address recipient, uint amount, uint256 _seatId, uint bal_deducted) private{
        address _airline = getAirlineAddressForSeat(_seatId);
        seats[_seatId].occupiedStatus = SeatOccupiedStatus.Vacant;

        safeTransferFrom(recipient, _airline, _seatId);
        PassengerRefund memory _passengerRefund = PassengerRefund(
            {
                recipient: recipient,
                amount: amount,
                paid: false
            });
        passengerRefunds[recipient] = _passengerRefund;    
        flightBalance[seats[_seatId].flightId] = flightBalance[seats[_seatId].flightId] - bal_deducted;
        _burn(_seatId);
    }
    
    function cancelSeat(uint256 _seatId) external returns (uint256){
        
        if (_exists(_seatId) == false) {
            revert("EC04");}
        else if (ownerOf(_seatId) != msg.sender){
            revert("EC11");}
        else if (seats[_seatId].occupiedStatus != SeatOccupiedStatus.Occupied){
            revert("EC12");}
        else if (flights[seats[_seatId].flightId].flightStatus == FlightStatus.Departed || flights[seats[_seatId].flightId].flightStatus == FlightStatus.Cancelled || flights[seats[_seatId].flightId].flightStatus == FlightStatus.Landed){
            revert("EC06");}
        else if ((flights[seats[_seatId].flightId].departureDateTime < block.timestamp) || (flights[seats[_seatId].flightId].departureDateTime - block.timestamp < 7200)){
            revert("EC13");}
        else {
            safeTransfer(msg.sender, (seats[_seatId].price / 2), _seatId, seats[_seatId].price);
            // Send the amount-penalty to the customer
            claimPassengerRefund();
            //Send the penalty amount to the airline
            payable(getAirlineAddressForSeat(_seatId)).transfer(seats[_seatId].price / 2);
            return _seatId;}
    }
    
    function airlineCancellation(bytes32 _flightId) private {
        require (flights[_flightId].seatIds.length > 0, "EC15");
        for (uint i = 0; i<flights[_flightId].seatIds.length; i++)  {
           uint256 _seatId = flights[_flightId].seatIds[i];
           if (seats[_seatId].occupiedStatus == SeatOccupiedStatus.Occupied) {
               safeTransfer(ownerOf(_seatId), (seats[_seatId].price), _seatId, (seats[_seatId].price));}
        } 
    }
    
    
    
    function airlineDelay(bytes32 _flightId, uint percent) private {
        require (flights[_flightId].flightStatus == FlightStatus.Departed, "EC31");
        require (flights[_flightId].seatIds.length > 0, "EC15");
        for (uint i = 0; i<flights[_flightId].seatIds.length; i++)  {
           uint256 _seatId = flights[_flightId].seatIds[i];
           if (seats[_seatId].occupiedStatus == SeatOccupiedStatus.Occupied) {
               // Calculate penalty amount
               uint amount = delayPenaltyCalculator(seats[_seatId].price, percent);
               safeTransfer(ownerOf(_seatId), amount , _seatId, amount);}
        } 
    }
    
    //Calculates penalty of pre-defined percentages w.r.t seat price
    function delayPenaltyCalculator(uint price, uint percent) private pure returns (uint) {
        if (percent == 10) {
            return (price/10);
        } else if (percent == 20 ){
            return (price/5);
        } else if (percent == 30) {
            return((price/5) + (price/10));
        } else if (percent == 40) {
            return ((price/5) + (price/5));
        } else if (percent == 60) {
            return((price/2) + (price/10));
        } else if (percent == 70) {
            return((price/2) + (price/5));
        } else if (percent == 75) {
            return((price/2) + (price/4));
        } else {
            revert("EC33");
        }
    }

    function claimPassengerRefund() private {
        PassengerRefund memory _passengerRefund = passengerRefunds[msg.sender];
        if (_passengerRefund.recipient != address(0) && _passengerRefund.recipient != msg.sender) {
            revert("EC16");}
        else if (_passengerRefund.recipient == address(0)) {
            revert("EC17");}
        else if (_passengerRefund.paid == true) {
            revert("EC18");}
        else if (_passengerRefund.amount <= 0){
            revert("EC32");}
        else {
            _passengerRefund.paid = true;
            passengerRefunds[msg.sender] = _passengerRefund;
            payable(msg.sender).transfer(_passengerRefund.amount);}
    }
    
    function claimPassengerRefunds(bytes32 _flightId) public payable {
        // customer can claim refund only after 24 hours of flight departure time
        require(block.timestamp > flights[_flightId].departureDateTime , "EC30");
        require(block.timestamp - flights[_flightId].departureDateTime > 86400, "EC30");
        require(flights[_flightId].flightNumber != 0, "EC02");
        if (flights[_flightId].flightStatus == FlightStatus.Enabled) {
            airlineCancellation(_flightId);
        }
        claimPassengerRefund();
    }
 
    function claimAirlinePayment() public payable{
        AirlinePayment memory _balancePayment = airlineBalancePayment[msg.sender];
        if (_balancePayment.recipient != address(0) && _balancePayment.recipient != msg.sender) {
            revert("EC19");}
        else if (_balancePayment.recipient == address(0)) {
            revert("EC20");}
        else if (_balancePayment.paid == true) {
            revert("EC21");}
        else if (_balancePayment.amount <= 0){
            revert("EC32");}
        else {
            _balancePayment.paid = true;
            airlineBalancePayment[msg.sender] = _balancePayment;
            payable(msg.sender).transfer(_balancePayment.amount);}
    }
    
    function updateFlightStatus(bytes8 _flightNumber,uint _departureDateTime, FlightStatus _flightStatus) external  {
        bytes32 _flightId = getFlightId(_flightNumber, _departureDateTime);
        require(flights[_flightId].airlineAddress == msg.sender, "EC22");
        uint penalty_percent = 0;
        FlightStatus currentFlightStatus = flights[_flightId].flightStatus;
        if(currentFlightStatus == FlightStatus.Enabled){
            if(_flightStatus == FlightStatus.OnTime || _flightStatus == FlightStatus.Delayed || _flightStatus == FlightStatus.Cancelled){
                //Airlines should update the first flight status within 24 hours of the flight departure time
                if ((block.timestamp > flights[_flightId].departureDateTime) || (flights[_flightId].departureDateTime - block.timestamp > 86400)) {
                     revert("EC29"); }
                else {
                    flights[_flightId].flightStatus = _flightStatus;}
            } else {
                revert("EC23");
            }
        }else if(currentFlightStatus == FlightStatus.OnTime){
            if(_flightStatus == FlightStatus.Cancelled || _flightStatus == FlightStatus.Departed || _flightStatus == FlightStatus.Delayed){
                flights[_flightId].flightStatus = _flightStatus;
            }else {
                revert("EC24");
            }
        }else if(currentFlightStatus == FlightStatus.Departed){
            if(_flightStatus == FlightStatus.Landed){
                flights[_flightId].flightStatus = _flightStatus;
            }else {
                revert("EC26");
            }
        }else if (currentFlightStatus == FlightStatus.Landed || currentFlightStatus == FlightStatus.Cancelled ){
            revert("EC27");
        } else if (currentFlightStatus == FlightStatus.Delayed){
            if(_flightStatus == FlightStatus.Cancelled){
                flights[_flightId].flightStatus = _flightStatus;
            } else if (_flightStatus == FlightStatus.Departed){
                flights[_flightId].flightStatus = _flightStatus;
                //Process delay penalties
                uint _delayTime = block.timestamp - flights[_flightId].departureDateTime;
                //Penalty for more than 1 hour delay - 30% of seat price
                if(_delayTime >= 3600 && _delayTime < 7200){
                    penalty_percent = 30;
                //Penalty for more than 2 hours delay - 60% of seat price
                }else if (_delayTime >= 7200 && _delayTime < 10800 ){
                    penalty_percent = 60;
                //Penalty for 3 or more hours delay - 75% of seat price
                }else {
                    penalty_percent = 75;
                }
                airlineDelay(_flightId, penalty_percent);
            }
            else {
                revert("EC28");
            }
        }
        // Proceed if Airline has cancelled flight
        if (flights[_flightId].flightStatus == FlightStatus.Cancelled) {
            airlineCancellation(_flightId);
        }else if (flights[_flightId].flightStatus == FlightStatus.Landed) {
            flights[_flightId].flightStatus = _flightStatus;
            AirlinePayment memory  _balancePayment = airlineBalancePayment[flights[_flightId].airlineAddress];
            _balancePayment.recipient = flights[_flightId].airlineAddress;
            _balancePayment.amount = flightBalance[_flightId];
            _balancePayment.paid = false;
            airlineBalancePayment[msg.sender] = _balancePayment;
            flightBalance[_flightId] = 0;
            claimAirlinePayment();
        }
        
    }

}
