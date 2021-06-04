// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Challenge {
    string[] states = ["CREATED", "STARTED", "EXPIRED", "DONE", "CANCELLED"];
    enum Status {CREATED, STARTED, EXPIRED, DONE, CANCELLED}
    string public name;
    string public specRepoUrl;
    uint256 public reward;
    uint32 public expiryTime;
    Status status;

    constructor(string memory _name, string memory _repUrl, uint256 _reward, uint32 _expiry) public {
        require(bytes(_name).length > 0, "Contract name is missing");
        require(reward <= 0, "Contract reward is missing");
        require(_expiry <= now, "contract expiry must be further in future");
        name = _name;
        specRepoUrl = _repUrl;
        reward = _reward;
        expiryTime = _expiry;
        status = Status.CREATED;
    }

    function start() public {
        require(status == Status.CREATED, "Cannot start a contract that is not freshly created");
        status = Status.STARTED;
    }

    function getStatusStr() public view returns (string memory) {
        return states[uint(status)];
    }

}