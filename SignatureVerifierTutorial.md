#### Tutorial Class: Exploring Smart Contracts with Remix IDE

#### Class Objective:
Students will learn how to create, compile, and deploy a Solidity smart contract using the Remix IDE. 

Tools Needed:
- Web browser with access to [Remix IDE](https://remix.ethereum.org/).

**Setting Up the Development Environment**

1. Introduction to Remix IDE:
   - Navigate to Remix IDE in your web browser
   - Overview of the Remix IDE interface (File explorers, code editor, compile tab, deploy & run tab)

2. Creating a New File: Create a new file in Remix with the `SignatureVerifier.sol` extension for Solidity.


#### Signature Verifier Tutorial

The VerifySig contract is designed to ensure the integrity and authorship of messages and tokens within the Ethereum blockchain. It serves as a crucial component in establishing trust and security in decentralized applications, particularly when dealing with oracles and ensuring reliable sources of information.

#### Overview of the Contract
The VerifySig contract provides functionalities to verify digital signatures, associate addresses with "member" status, and confirm the authenticity of messages sent by these members. It's especially relevant in scenarios where verifying the sender's identity and ensuring the data hasn't been tampered with is vital.

Importance in the Context of Oracles

Oracles are external services that provide smart contracts with data from the outside world. Since smart contracts can't access external data directly, oracles act as a bridge, feeding data into the blockchain. However, the data's reliability hinges on the oracle's trustworthiness. By using signature verification, we can ensure that the data indeed comes from a known, reliable source, thereby reducing the risk of malicious interference.

Ensuring Integrity and Authorship

- Integrity: By verifying the hash of a message alongside its signature, the contract confirms that the message hasn't been altered. This process ensures data integrity, a fundamental aspect when decisions within a smart contract depend on external inputs.
- Authorship: Through digital signatures, the contract ascertains that a message or transaction originates from a specific entity. This verification is crucial for actions that require explicit approval or origination from trusted entities.


```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
```

This is the license identifier and the version pragma. The license identifier `SPDX-License-Identifier: MIT` specifies that the code is released under the MIT license. The `pragma solidity ^0.8.0;` line specifies that the contract is written for Solidity version 0.8.0.

```solidity
contract VerifySig {
```

Begins the definition of a contract named `VerifySig`. Everything within the curly braces `{}` is part of the contract.

```solidity
    mapping(address => bool) public isMember;
```
Mapping in Solidity is used to store a key value pair like a dictionary in any other language.   

Declares a public state variable `isMember`, which is a mapping from an address to a boolean. It's used to keep track of which addresses are considered members.

```solidity
    event MemberAdded(address indexed member);
```

Declares an event `MemberAdded` that logs when an address is added as a member. The `indexed` keyword allows the `member` address to be indexed, making it searchable in the event logs.

```solidity
    event IsMemberCheck(address indexed _member, bool isMember);
```
Declares an event `IsMemberCheck` that logs the membership status of an address when checked. It includes the address being checked and a boolean indicating whether it's a member.

#### Message Hashing and Signature Verification:
The core functionality revolves around hashing messages and verifying their signatures.This function is pivotal in confirming that a message received is indeed from the claimed sender (_signer) and that the message content is intact.
```solidity
    function verify(address _signer, string memory _message, bytes memory _sig) 
        external pure returns (bool)
```

Defines a `verify` function that takes an expected signer address (`_signer`), a message (`_message`), and a signature (`_sig`). The function is `external` meaning it can be called from outside the contract, and `pure` indicating it doesn't read from or write to the blockchain. It returns a boolean indicating if the signature is valid and matches the `_signer`.

```solidity
    {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recover(ethSignedMessageHash, _sig) == _signer;
    }
```

Inside the `verify` function, it calculates the hash of the message using `getMessageHash`, then gets the Ethereum-specific hash using `getEthSignedMessageHash`. It uses `recover` to extract the signer from the signature and compares it to `_signer`.

```solidity
    function getMessageHash(string memory _message) public pure returns (bytes32) {
```

Defines a function `getMessageHash` that takes a message string and returns its keccak256 hash as `bytes32`. This function is public and pure.

```solidity
        return keccak256(abi.encodePacked(_message));
    }
```

Returns the keccak256 hash of the provided `_message`.

```solidity
    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
```

Defines `getEthSignedMessageHash` that takes a message hash and returns the Ethereum-specific hash. This is necessary for recovering the signer address from the signature.

```solidity
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }
```

Returns the Ethereum-specific hash by prefixing the message hash with `"\x19Ethereum Signed Message:\n32"` before hashing it.

#### Recovering the Signer: 
The `recover` function is the technical core, extracting the signer's address from the message's signature. In the context of oracles, this step is crucial for confirming that the data provided to the smart contract is from a verified source, enhancing the reliability of the data used in smart contract executions.
```solidity
    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig)
        public pure returns (address)
```

Defines `recover`, a function that takes the Ethereum-specific message hash and the signature, and returns the address that signed the message.

```solidity
    {
        (uint8 v, bytes32 r, bytes32 s) = split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }
```

Inside `recover`, it first splits the signature into `v`, `r`, and `s` using `split`, then uses `ecrecover` to get the address that created the signature.
- `uint8 v`: The recovery byte.
- `bytes32 r`: The first 32 bytes of the signature.
- `bytes32 s`: The second 32 bytes of the signature.

```solidity
    function split(bytes memory _sig) internal pure
        returns (uint8 v, bytes32 r, bytes32 s)
```

Defines `split`, a function to break down a signature into its components: `v`, `r`, and `s`.

```solidity
    {
        require(_sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        return (v, r, s);
    }
```

Inside `split`, it checks the signature length, then uses inline assembly to extract `r`, `s`, and `v`. If `v` is less than 27, it adjusts it to match Ethereum's signature format.

#### Member Management
The ability to designate certain addresses as members allows the contract to establish a list of trusted entities. When oracles or data providers are marked as members, their provided data carries a stamp of authenticity.

```solidity
    function addMember(address member) public {
```
This function adds a trusted oracle or data provider to the member list, enabling their data to be recognized as authentic by the smart contract.
Adds a new `addMember` function to allow member addresses to be added to the contract.

```solidity
        require(!isMember[member], "Member already added.");
        isMember[member] = true;
        emit MemberAdded(member);
    }
```

- Inside `addMember`, it checks if the address is already a member, then adds it to `isMember` and emits the `MemberAdded` event.

```solidity
    function isAddressMember(address _member) public returns (bool) {
```

Adds an `isAddressMember` function to check if an address is a member.

```solidity
        bool memberStatus = isMember[_member];
        emit IsMemberCheck(_member, memberStatus);
        return memberStatus;
    }
}
```

Inside `isAddressMember`, it retrieves the member status, emits the `IsMemberCheck` event, and returns the status.

The contract is now ready to be used. :)
Here's a step-by-step guide on how you can interact with the `VerifySig` contract using the Remix IDE, including how to sign a message using Remix's built-in functionality:

### Step 1: Deploy the Contract

1. **Compile the Contract**: In Remix, open the "Solidity Compiler" tab and click "Compile VerifySig.sol" to compile your contract.
2. **Deploy the Contract**: Switch to the "Deploy & Run Transactions" tab. Ensure that "Remix VM (either Shanghai, Merge, London or Berlin)" is selected as the environment. Click "Deploy" to deploy your contract onto the blockchain.
   
### Step 2: Add a Member

1. **Add Member Function**: After deploying, you'll see the contract under "Deployed Contracts". Find the `addMember` function input box.
2. **Input Address**: Enter the Ethereum address you want to add as a member in the `addMember` input field.
3. **Execute**: Click the "transact" button to execute the function, adding this address to the list of members.

### Step 3: Check Member Status

1. **Use the IsAddressMember Function**: Find the `isAddressMember` function in the deployed contract.
2. **Input Address**: Enter the address you want to check in the input field.
3. **Execute**: Click "call". It will return `true` if the address is a member and `false` if it's not.

### Step 4: Sign a Message

1. **Enter Your Message**: In the `getMessageHash`,enter your message as a string, then call the function.
2. **Use Remix's Sign Message Tool**: In Remix, there's a feature to sign messages. Go to the account address at the top left, click on the ellipsis (...), and select "Sign Message".
4. **Enter Your MessageHash**: In the popup, enter the `MessageHash` that was retuned by the call, e.g 0: bytes32: 0x...
5. **Sign**: Click "Sign" to sign the message. Remix will generate a signature.

### Step 5: Use the Recover Function

1. **Access the recover Function**: Find the recover function in the deployed VerifySig contract within the "Deployed Contracts" section of Remix.
2. **Input Parameters**: You need to provide two parameters to the recover function:
- **_ethSignedMessageHash**: This is the hash of the message prefixed with the Ethereum-specific message prefix (\x19Ethereum Signed Message:\n32 followed by the message length and the message itself). You can use the getEthSignedMessageHash function by entering the parameter `MessageHash` to obtain this hash.
- **_sig**: This is the signature obtained from the signing process in Step 3.
3. **Execute the Function**: Click "call" to execute the recover function. It will return the address that signed the message.

### Step 6: Verify the Signature

1. **Access the Verify Function**: In the `VerifySig` contract under "Deployed Contracts", locate the `verify` function.
2. **Input Parameters**: You need to enter three parameters:
   - `_signer`: The address that you used to sign the message. 
   - `_message`: The string message that you signed.
   - `_sig`: The signature generated by Remix.
3. **Execute Verify**: Click "call" to execute the `verify` function. The function will return `true` if the signature is valid and `false` otherwise.

### Understanding the Results

- **Events**: The contract emits events when actions are taken (e.g., adding a member or verifying a signature). In Remix, you can view these events in the logs to confirm the actions were successful.
- **Transaction Receipt**: Each time you interact with the contract (e.g., adding a member or verifying a signature), Remix provides a transaction receipt. This receipt includes important information like gas used, block number, and event logs.

By following these steps, you can learn how to deploy and interact with a smart contract in Remix, understand the process of signing messages, and verify those signatures within a smart contract.
