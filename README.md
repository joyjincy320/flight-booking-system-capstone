# GL IITM ACSE Capstone - Blockchain based Flight Ticket Management System

[More Details](https://olympus.greatlearning.in/courses/28746/pages/blockchain-based-ticket-management?module_item_id=1815637)

## Team Members
1. [Anirudh Ajith Warrier](https://github.com/anirudhwarrier)
2. [Jincy Joy](https://github.com/joyjincy320)
3. [Abhishek](https://github.com/shekabhias)
4. Srinivas Kandi
5. [Prasad Natu](https://github.com/prasadnatu)

## Project Details
- Private blockchain infrastructure powered by Hyperledger Besu :- The final version of the infrastcture has 7 peer nodes in 1 c5.large AWS instance and blockchain is initiated with 3 accounts. 
  - BlockChain-InfraDiagram.pdf: Blockchain node Architecture
  - cloudformation/hyperledger-besu-development.json - AWS Cloud Formation template for setting up the private blockchain

- Solidity contract
  - FightBooking_ContractDesign.pdf - High level contract design documenn
  - FlightBookingSystem-Version-0.8/FlightBooking_Contract.sol  - Flight Booking Solidity contract
  - FlightBookingSystem-Version-0.8/ErrorCode_Mapping.txt - Error codes
  - contract-test - Unit test and integration test suite for the FlightBookingSystem Contract
  - scripts - CodeDeploy scripts to deploy blockchain network
  - contract-test-execution.png - Contract execution demonstration via test execution

## Solidity contract features
 - base ticketing contract functionality
 - The customer should be able to trigger a cancellation anytime till 2 hours before the flight start time. This should refund money to the customer minus the percentage penalty predefined in the contract by the airlines. The penalty amount should be automatically sent to the airline account.
 - Any cancellation triggered by the airline before or after departure time should result in a complete amount refund to the customer.
 - The airline should update the status of the flight within 24 hours of the flight start time. It can be on-time start, cancelled or delayed.
 - 24 hours after the flight departure time, the customer can trigger a claim function to demand a refund.
 - They should get a complete refund in case of cancellation by the airline. 
 - In case of a delay, they should get a predefined percentage amount, and the rest should be sent to the airline.
 - If the airline hasn’t updated the status within 24 hours of the flight departure time, and a customer claim is made, it should be treated as an airline cancellation case by the contract.
 - Randomness and call based simulation of various features like normal flights, cancellation by the airline, cancellation by the customer, and delayed flights.

