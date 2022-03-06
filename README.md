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
  - https://www.loom.com/share/c999b4472d4146199da159145d6380c4 - This video contains the step by step instructions for setting up the private blockchain using above mentioned AWS Cloud Formation 
- Solidity contract
  - FightBooking_ContractDesign.pdf - High level contract design documenn
  - FlightBookingSystem-Version-0.8/FlightBooking_Contract.sol  - Flight Booking Solidity contract
  - FlightBookingSystem-Version-0.8/ErrorCode_Mapping.txt - Error codes
  - contract-test - Unit test and integration test suite for the FlightBookingSystem Contract
  - scripts - CodeDeploy scripts to deploy blockchain network
  - contract-test-execution.png - Contract execution demonstration via test execution

### Live Environment URL(s)

- ChainID - 2701
- Blockchain Explorer - https://gl-blockchain-stg.anirudhwarrier.com
- Chainlink Operator - https://gl-blockchain-stg.anirudhwarrier.com:6688 (Username: user@test.com, Passowrd: password)
- Grafana Dashboard - https://gl-blockchain-stg.anirudhwarrier.com:3000/d/XE4V0WGZz/besu-overview?orgId=1&refresh=10s
- JSON RPC Endpoint - https://gl-blockchain-stg.anirudhwarrier.com:8545
- Member 1 JSON RPC Endpoint - https://gl-blockchain-stg.anirudhwarrier.com:20000
- Member 2 JSON RPC Endpoint - https://gl-blockchain-stg.anirudhwarrier.com:20002
- Member 3 JSON RPC Endpoint - https://gl-blockchain-stg.anirudhwarrier.com:20004
- Oracle contract deployed to (oracle_contract_address): 0x345cA3e014Aaf5dcA488057592ee47305D9B3e10
- LinkToken contract deployed to (link_contract_address): 0x8CdaF0CD259887258Bc13a92C0a6dA92698644C0
- chainLinkNodeAddress:  0xf01893aA1807a76D5aB04198Ec203581BAf102a


