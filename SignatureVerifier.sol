// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VerifySig {

    // Mapping to keep track of member addresses
    mapping(address => bool) public isMember;

    // Event to emit when a member is added
    event MemberAdded(address indexed member);

    // Event to emit when a member's status is checked
    event IsMemberCheck(address indexed _member, bool isMember);

    function verify(address _signer, string memory _message, bytes memory _sig) 
        external pure returns (bool)
    {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, _sig) == _signer;
    }    

    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    } 

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    } 

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig)
        public pure returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function split(bytes memory _sig) internal pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(_sig.length == 65, "invalid signature length");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
        
        // Adjust v for Ethereum's signature format
        if (v < 27) {
            v += 27;
        }

        return (v, r, s);
    }

    // Function to add a member address
    function addMember(address member) public {
        require(!isMember[member], "Member already added.");
        isMember[member] = true;
        emit MemberAdded(member);
    }

    // Function to check if an address is a member
    function isAddressMember(address _member) public returns (bool) {
        bool memberStatus = isMember[_member];
        emit IsMemberCheck(_member, memberStatus);
        return memberStatus;
    }
}
