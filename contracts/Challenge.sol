// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract Challenge {
    // Challenge
    string[] states = ["CREATED", "IN_PROGRESS", "EXPIRED", "DONE", "CANCELLED"];
    enum ChallengeStatus {CREATED, IN_PROGRESS, EXPIRED, DONE, CANCELLED}
    address public issuer;
    string public name;
    string public specRepoUrl;
    uint256 public reward;
    uint public expiryTime;
    ChallengeStatus status;
    // Participants
    uint8 maxParticipants = 3;
    mapping(address => string) participantsPublicKey;
    mapping(address => bool) activeParticipants;
    address[] public participants;
    // solution Validators
    mapping(address => bool) activeValidators;
    address[] public validators;
    // Solutions
    // enum TestType {ACCEPTANCE, SECURITY, PERFORMANCE}
    struct TestResult {
        address participant;
        string testName;
        //        TestType testTYpe;
        string testType;
        bool outcome;
    }

    mapping(address => string) particpantResults;

    struct Solution {
        address submitter;
        int8 score;
        string signedTestResults;
    }

    Solution[] public solutions;

    constructor(string memory _name, string memory _repUrl, uint256 _reward, uint _expiry, uint8 _max_participants) public {
        require(bytes(_name).length > 0, "Contract name is missing");
        require(_reward > 1, "Contract reward is too low");
        require(_expiry > block.timestamp, "contract expiry must be further in future");
        require(_max_participants >= 1 && _max_participants <= 256, "between 1 to 256 participants are needed for a challenge");
        issuer = msg.sender;
        name = _name;
        specRepoUrl = _repUrl;
        reward = _reward;
        expiryTime = _expiry;
        status = ChallengeStatus.CREATED;
        maxParticipants = _max_participants;
    }

    function start() public {
        require(status == ChallengeStatus.CREATED, "Cannot start a contract that is not freshly created");
        require(validators.length >= 1, "at least one validator is needed for a challenge");
        require(activeParticipantsCount() >= 1, "at least one active participant is needed for a challenge");
        status = ChallengeStatus.IN_PROGRESS;
    }

    function getChallengeStatusStr() public view returns (string memory) {
        return states[uint(status)];
    }

    function registerValidator(address _validator) public {
        require(msg.sender == issuer, "only challenge issuer can add validators");
        require(_validator != issuer, "issuer cannot be a validator too");
        validators.push(_validator);
        activeValidators[_validator] = true;
    }

    function registerParticipant(address _participant, string memory _publicKey) public {
        require(msg.sender == issuer, "only challenge issuer can add participants");
        require(status == ChallengeStatus.CREATED, "cannot add participant to an on-going challenge");
        require(participants.length < maxParticipants, "challenge has reached maximum number of participants");
        participantsPublicKey[_participant] = _publicKey;
        activeParticipants[_participant] = true;
        participants.push(_participant);
    }

    function isActiveParticipant(address _participant) public view returns (bool) {
        return activeParticipants[_participant];
    }

    function deactivateParticipant(address _participant) public returns (bool){
        require(msg.sender == issuer, "only challenge issuer can deactivate participants");
        bool success = false;
        if (activeParticipants[_participant]) {
            activeParticipants[_participant] = false;
            success = true;
        }
        return success;
    }

    function activateParticipant(address _participant) public returns (bool){
        require(msg.sender == issuer, "only challenge issuer can activate participants");
        bool success = false;
        bool foundParticipant = false;
        for (uint i = 0; i < participants.length; i++) {
            address p = participants[i];
            if (participants[i] == p) {
                foundParticipant = true;
            }
        }
        if (foundParticipant && activeParticipants[_participant] == false) {
            activeParticipants[_participant] = true;
            success = true;
        }
        return success;
    }

    function activeParticipantsCount() public view returns (uint8) {
        uint8 count = 0;
        address p;
        for (uint8 i = 0; i < participants.length; i++) {
            p = participants[i];
            if (activeParticipants[p]) {
                count++;
            }
        }
        return count;
    }

    function retrieveParticipantPublicKey(address _participant) public view returns (string memory, bool) {
        require(msg.sender == issuer, "only challenge issuer can retrieve participants public keys");
        return (participantsPublicKey[_participant], activeParticipants[_participant]);
    }

    function extendExpiryTime(uint _expiry) public {
        require(msg.sender == issuer, "only challenge issuer can extend the expiry time");
        require(_expiry > expiryTime, "expiry can only be extended past original expiry time");
        expiryTime = _expiry;
    }

    function submitSolution(address _participant, string memory _encryptedTestResults, int8 _score) public {
        address submittingValidator = msg.sender;
        require(status == ChallengeStatus.IN_PROGRESS, "only in-progress challenges accept solutions");
        require(activeValidators[submittingValidator] == true, "only active validators can submit solutions on behalf od participants");
        require(activeParticipants[_participant] == true, "only solutions from active participants are accepted");
        solutions.push(Solution(_participant, _score, _encryptedTestResults));
    }

    function retrieveParticipantResult(address _participant) public view returns (string memory) {
        require(msg.sender == issuer, "only challenge issuer can retrieve participants results");
        return "N/A";
    }

}
