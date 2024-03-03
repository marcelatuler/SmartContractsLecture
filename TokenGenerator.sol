// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenGenerator {
    event TokenCreated(address indexed author, bytes32 indexed payloadHash, bytes signature);

    function createToken(string memory payload, bytes memory signature) public {
        bytes32 payloadHash = keccak256(abi.encodePacked(payload));
        emit TokenCreated(msg.sender, payloadHash, signature);
    }
}
