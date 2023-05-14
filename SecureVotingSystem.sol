// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

contract VotingSystem {
    struct vote {
        address voterAddress;
        bool choice;
    }

    struct voter {
        string voterName;
        bool voted;
    }

    uint256 private countResult = 0;
    uint256 public finalResult = 0;
    uint256 public totalVote = 0;
    address public ballotOfficialAddress;
    string public ballotOfficialName;
    string public proposal;

    mapping(uint256 => vote) private votes;
    mapping(address => voter) public voterRegister;

    enum State {
        Created,
        Voting,
        Ended
    }
    State public state;

    event voterAdded(address indexed _voterAddress);
    event voteStarted();
    event voteDone(address indexed _voterAddress);
    event voteEnded(uint256 indexed _finalResult);

    constructor(string memory _ballotOfficialName, string memory _proposal) {
        ballotOfficialAddress = msg.sender;
        ballotOfficialName = _ballotOfficialName;
        proposal = _proposal;
        state = State.Created;
    }

    function addVoter(address _voterAddress, string memory _voterName)
        public
        inState(State.Created)
        onlyOfficial
    {
        voter memory v;
        v.voterName = _voterName;
        v.voted = false;
        voterRegister[_voterAddress] = v;
        emit voterAdded(_voterAddress);
    }

    modifier inState(State _state) {
        require(state == _state, "Invalid state");
        _;
    }

    modifier onlyOfficial() {
        require(
            msg.sender == ballotOfficialAddress,
            "Only Chairman can perform this action"
        );
        _;
    }

    function startVote() public inState(State.Created) onlyOfficial {
        state = State.Voting;
        emit voteStarted();
    }

    function doVote(bool _choice) public inState(State.Voting) returns (bool) {
        voter storage v = voterRegister[msg.sender];
        if (bytes(v.voterName).length == 0 || v.voted) {
            return false;
        }
        v.voted = true;
        vote memory newVote = vote({voterAddress: msg.sender, choice: _choice});
        if (_choice) {
            countResult++;
        }
        votes[totalVote] = newVote;
        totalVote++;
        emit voteDone(msg.sender);
        return true;
    }

    function endVote() public inState(State.Voting) onlyOfficial {
        state = State.Ended;
        finalResult = countResult;
        emit voteEnded(finalResult);
    }
}
