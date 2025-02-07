// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DNAStorage {
    struct DNAData {
        string rawDNA;
        string hash;
        uint256 timestamp;
    }

    mapping(address => DNAData) private dnaRecords;
    mapping(address => mapping(address => bool)) private authorizedViewers;
    
    event DNAStored(address indexed wallet, string rawDNA, string hash, uint256 timestamp);
    event ViewerAdded(address indexed owner, address indexed viewer);
    event ViewerRemoved(address indexed owner, address indexed viewer);

    function storeDNA(string memory _rawDNA, string memory _hash) public {
        require(bytes(_rawDNA).length > 0, "Raw DNA data cannot be empty");
        require(bytes(_hash).length > 0, "Hash cannot be empty");

        dnaRecords[msg.sender] = DNAData({
            rawDNA: _rawDNA,
            hash: _hash,
            timestamp: block.timestamp
        });

        emit DNAStored(msg.sender, _rawDNA, _hash, block.timestamp);
    }

    function addViewer(address _viewer) public {
        authorizedViewers[msg.sender][_viewer] = true;
        emit ViewerAdded(msg.sender, _viewer);
    }

    function removeViewer(address _viewer) public {
        authorizedViewers[msg.sender][_viewer] = false;
        emit ViewerRemoved(msg.sender, _viewer);
    }

    function getDNA(address _wallet) public view returns (string memory rawDNA, string memory hash, uint256 timestamp) {
        require(msg.sender == _wallet || authorizedViewers[_wallet][msg.sender], "Not authorized to view this DNA data");
        
        DNAData memory data = dnaRecords[_wallet];
        require(bytes(data.rawDNA).length > 0, "No DNA data found for this wallet");

        return (data.rawDNA, data.hash, data.timestamp);
    }

    function hasDNA(address _wallet) public view returns (bool) {
        return bytes(dnaRecords[_wallet].rawDNA).length > 0;
    }
}
