Tutorial Class: Introduction to Smart Contracts with Remix IDE

#### Class Objective:
Students will learn how to create, compile, and deploy two Solidity smart contracts using the Remix IDE. The first contract will generate a token with a digitally signed payload, and the second contract will verify digital signatures against a list of members.

Tools Needed:
- Web browser with access to [Remix IDE](https://remix.ethereum.org/).

Part 1: Setting Up the Development Environment

1. Introduction to Remix IDE:
   - Navigate to Remix IDE in your web browser
   - Overview of the Remix IDE interface (File explorers, code editor, compile tab, deploy & run tab)

2. Creating a New File:
   - Create a new file in Remix with the `TokenGeneration.sol` extension for Solidity.
   - Explain the Solidity version pragma.

### Writing the Token Generation Contract
1. Defining the Contract:
   - Begin by writing the contract declaration.
   ```solidity
   pragma solidity ^0.8.0;

   contract TokenGenerator {
       // Contract code will go here
   }
   ```
### TokenGenerator Contract Functions
createToken Function

In Solidity, an event is a way for a smart contract to communicate that something has happened on the blockchain to external clients, which could be user interfaces, server-side applications, or other contracts. Events are inheritable members of contracts. When you emit an event, it stores the arguments passed in transaction logs, which are a special data structure in the Ethereum blockchain. These logs are associated with the address of the contract and are incorporated into the blockchain, allowing applications to listen for changes and react accordingly.

Let's break down the TokenCreated event in the TokenGenerator contract:

```
event TokenCreated(address indexed author, bytes32 indexed payload, bytes signature);
```

- `TokenCreated`: This is the name of the event. By convention, event names are usually nouns in the past tense, as they signify actions that have already occurred.
- `address indexed author`: This is the first parameter of the event. The address keyword indicates that the author is an Ethereum address. The indexed keyword allows this parameter to be searchable when filtering logs. There can be up to three indexed parameters per event. When a parameter is indexed, it means that you can query for logs that have a specific author. It's helpful for listeners who are only interested in certain transactions related to a specific address.
- `bytes32 indexed payload`: This is the second parameter and is also indexed. The bytes32 type indicates that the payload is expected to be a 32-byte string, which is commonly used to represent fixed-size data like hashes. By indexing this parameter, you can also filter logs for events where the payload matches a specific hash.
- `bytes signature`: This is the third parameter and is not indexed. It's meant to hold the digital signature bytes. A signature does not need to be indexed because it's generally not used as a filter; it's unique data that you would typically just retrieve from the event log rather than query by.

Let's break down the createToken function. This function is designed to be called by someone who wants to generate a new token associated with a payload and a signature.

Here's the function signature:

```
function createToken(bytes32 payload, bytes memory signature) public {
    emit TokenCreated(msg.sender, payload, signature);
}
```
- `function createToken`: This is the declaration of a function named createToken. It's the part of the contract that will be executed when someone calls it.
- `(bytes32 payload, bytes memory signature)`: These are the parameters that the createToken function takes:
   - `bytes32 payload`: A bytes32 type parameter named payload. It's expected to be a 32-byte hash, which is a typical way to represent data that's been hashed for efficiency and security reasons.
   - `bytes memory signature`: A dynamically-sized byte array that holds the digital signature. The memory keyword indicates that the signature is a temporary variable that will not be stored on the blockchain, saving gas. This signature is meant to prove that the creator of the token is the one initiating this transaction.
   - `public`: This visibility specifier means that the function can be called from outside the contract, not just internally by other functions of the contract.
   - `{ ... }`: These curly braces contain the body of the function.
   - `emit TokenCreated(...)`: Inside the function body, we have an emit statement which triggers the TokenCreated event to log the transaction in the blockchain. When this line of code executes, it records the event data in the transaction logs.
   - `msg.sender`: It's a global variable in Solidity that refers to the address that called the function, in other words, the creator of the token. By including msg.sender in the event, we are logging who initiated the token creation.
   - `payload`: This is the 32-byte hash that represents the data or information associated with the token. It is included in the event so that applications listening for TokenCreated can know what data this token represents.
   - `signature`: The digital signature associated with the token's creation is also included in the event. This allows applications to verify the authenticity of the token by checking that the signature is valid and was indeed created by msg.sender.


When the createToken function is called and the TokenCreated event is emitted, it logs the transaction's author, payload, and signature in the blockchain. This allows applications to listen for the TokenCreated event and perform actions such as displaying a confirmation message to the user or updating a UI element to reflect the new token's creation.

For instance, a DApp (Decentralized Application) might listen for the TokenCreated event and, upon detecting it, could display the newly created token along with its details to the user without requiring a page refresh or manual update, creating a dynamic and responsive experience.

```
function createToken(bytes32 payload, bytes memory signature) public {
    emit TokenCreated(msg.sender, payload, signature);
}
```


This createToken function is the heart of our `TokenGenerator` contract. It takes two parameters: `payload` and `signature`. The payload is a piece of data, hashed into a 32-byte hash, representing the information you want to associate with the token. The signature is a digital signature generated by the author of the token, proving they have authorized this token creation.

When this function is called, it emits an event `TokenCreated` with the sender's address (`msg.sender`), the payload, and the signature. `msg.sender` is a global variable in Solidity that refers to the address that called the function. Events in Solidity are a way for contracts to communicate that something has happened on the blockchain to external consumers, which can be frontend applications, or other contracts."
   
When a user (or another contract) calls the `createToken` function with their payload and signature, this function will log the event on the blockchain with the specified details. This way, anyone who has access to the blockchain can verify that a certain address (`msg.sender`) claimed to have created a token with a specific payload and signature at a certain point in time. This information is now immutable and can be trusted to have not been altered after the fact.


```// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenGenerator {
    event TokenCreated(address indexed author, bytes32 indexed payloadHash, bytes signature);

    function createToken(string memory payload, bytes memory signature) public {
        bytes32 payloadHash = keccak256(abi.encodePacked(payload));
        emit TokenCreated(msg.sender, payloadHash, signature);
    }
}
```
