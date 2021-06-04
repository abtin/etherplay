// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Participants {
    uint16 MAX_PARTICIPANTS = 3;
    enum Status {JOINED, LEFT, KICKED_OUT}
    mapping(address => Status) participantStatus;
    address[] participants;

    event CallResult(address to, string result);

    function registerParticipant(address sender) public {
        require(participants.length < MAX_PARTICIPANTS);
        participantStatus[sender] = Status.JOINED;
        participants.push(sender);
        emit CallResult(msg.sender, "success");
    }

    function getParticipants() public view returns (address[] memory) {
        return participants;
    }
}
