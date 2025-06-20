// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Decentralized Voting System
 * @dev A smart contract for conducting transparent and secure voting
 */
contract Project {
    
    // Structure to represent a candidate
    struct Candidate {
        uint256 id;
        string name;
        uint256 voteCount;
    }
    
    // Structure to track voting status
    struct Voter {
        bool hasVoted;
        uint256 votedCandidateId;
        bool isRegistered;
    }
    
    // State variables
    address public owner;
    string public electionName;
    bool public votingActive;
    uint256 public totalVotes;
    uint256 public candidateCount;
    
    // Mappings
    mapping(uint256 => Candidate) public candidates;
    mapping(address => Voter) public voters;
    
    // Events
    event CandidateAdded(uint256 indexed candidateId, string name);
    event VoterRegistered(address indexed voter);
    event VoteCast(address indexed voter, uint256 indexed candidateId);
    event VotingStatusChanged(bool status);
    
    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier votingIsActive() {
        require(votingActive == true, "Voting is not active");
        _;
    }
    
    modifier hasNotVoted() {
        require(voters[msg.sender].hasVoted == false, "You have already voted");
        _;
    }
    
    modifier isRegisteredVoter() {
        require(voters[msg.sender].isRegistered == true, "You are not registered to vote");
        _;
    }
    
    /**
     * @dev Constructor to initialize the voting system
     * @param _electionName Name of the election
     */
    constructor(string memory _electionName) {
        owner = msg.sender;
        electionName = _electionName;
        votingActive = false;
        totalVotes = 0;
        candidateCount = 0;
    }
    
    /**
     * @dev Core Function 1: Add a candidate to the election
     * @param _name Name of the candidate
     */
    function addCandidate(string memory _name) public onlyOwner {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        require(votingActive == false, "Cannot add candidates while voting is active");
        
        candidateCount = candidateCount + 1;
        candidates[candidateCount] = Candidate({
            id: candidateCount,
            name: _name,
            voteCount: 0
        });
        
        emit CandidateAdded(candidateCount, _name);
    }
    
    /**
     * @dev Core Function 2: Register a voter
     * @param _voterAddress Address of the voter to register
     */
    function registerVoter(address _voterAddress) public onlyOwner {
        require(_voterAddress != address(0), "Invalid voter address");
        require(voters[_voterAddress].isRegistered == false, "Voter already registered");
        
        voters[_voterAddress] = Voter({
            hasVoted: false,
            votedCandidateId: 0,
            isRegistered: true
        });
        
        emit VoterRegistered(_voterAddress);
    }
    
    /**
     * @dev Core Function 3: Cast a vote for a candidate
     * @param _candidateId ID of the candidate to vote for
     */
    function vote(uint256 _candidateId) public 
        votingIsActive 
        isRegisteredVoter 
        hasNotVoted 
    {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        
        // Record the vote
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedCandidateId = _candidateId;
        
        // Increment candidate vote count
        candidates[_candidateId].voteCount = candidates[_candidateId].voteCount + 1;
        totalVotes = totalVotes + 1;
        
        emit VoteCast(msg.sender, _candidateId);
    }
    
    /**
     * @dev Toggle voting status (start/stop voting)
     */
    function toggleVoting() public onlyOwner {
        require(candidateCount > 0, "No candidates added yet");
        votingActive = !votingActive;
        emit VotingStatusChanged(votingActive);
    }
    
    /**
     * @dev Get candidate details
     * @param _candidateId ID of the candidate
     */
    function getCandidate(uint256 _candidateId) public view returns (
        uint256 id,
        string memory name,
        uint256 voteCount
    ) {
        require(_candidateId > 0 && _candidateId <= candidateCount, "Invalid candidate ID");
        Candidate memory candidate = candidates[_candidateId];
        return (candidate.id, candidate.name, candidate.voteCount);
    }
    
    /**
     * @dev Get the winning candidate
     */
    function getWinner() public view returns (
        uint256 winningCandidateId,
        string memory name,
        uint256 voteCount
    ) {
        require(votingActive == false, "Voting is still active");
        require(totalVotes > 0, "No votes cast yet");
        require(candidateCount > 0, "No candidates available");
        
        uint256 maxVotes = 0;
        uint256 winnerId = 1;
        
        for (uint256 i = 1; i <= candidateCount; i++) {
            if (candidates[i].voteCount > maxVotes) {
                maxVotes = candidates[i].voteCount;
                winnerId = i;
            }
        }
        
        return (winnerId, candidates[winnerId].name, candidates[winnerId].voteCount);
    }
    
    /**
     * @dev Get voting statistics
     */
    function getVotingStats() public view returns (
        uint256 _totalVotes,
        uint256 _candidateCount,
        bool _votingActive
    ) {
        return (totalVotes, candidateCount, votingActive);
    }
    
    /**
     * @dev Check if an address has voted
     * @param _voter Address to check
     */
    function checkVoterStatus(address _voter) public view returns (bool) {
        return voters[_voter].hasVoted;
    }
    
    /**
     * @dev Get all candidates (helper function)
     */
    function getAllCandidates() public view returns (string[] memory) {
        string[] memory candidateNames = new string[](candidateCount);
        for (uint256 i = 1; i <= candidateCount; i++) {
            candidateNames[i-1] = candidates[i].name;
        }
        return candidateNames;
    }
}


