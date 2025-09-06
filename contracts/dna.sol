// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DNAStorage {
    struct DNAData {
        bytes32 dataHash;
        uint64 timestamp;
    }

    mapping(address => DNAData) private dnaRecords;
    mapping(address => mapping(address => bool)) private authorizedViewers;
    
    event DNAStored(address indexed wallet, bytes32 indexed dataHash, uint64 timestamp);
    event ViewerAdded(address indexed owner, address indexed viewer);
    event ViewerRemoved(address indexed owner, address indexed viewer);

    function storeDNA(string memory _rawDNA) public {
        require(bytes(_rawDNA).length > 0, "Raw DNA data cannot be empty");

        bytes32 computedHash = keccak256(bytes(_rawDNA));
        dnaRecords[msg.sender] = DNAData({
            dataHash: computedHash,
            timestamp: uint64(block.timestamp)
        });

        emit DNAStored(msg.sender, computedHash, uint64(block.timestamp));
    }

    function storeDNAHash(bytes32 _hash) public {
        require(_hash != bytes32(0), "Hash cannot be empty");

        dnaRecords[msg.sender] = DNAData({
            dataHash: _hash,
            timestamp: uint64(block.timestamp)
        });

        emit DNAStored(msg.sender, _hash, uint64(block.timestamp));
    }

    function addViewer(address _viewer) public {
        require(_viewer != address(0), "Invalid viewer address");
        require(!authorizedViewers[msg.sender][_viewer], "Viewer already authorized");
        authorizedViewers[msg.sender][_viewer] = true;
        emit ViewerAdded(msg.sender, _viewer);
    }

    function removeViewer(address _viewer) public {
        require(_viewer != address(0), "Invalid viewer address");
        require(authorizedViewers[msg.sender][_viewer], "Viewer not authorized");
        authorizedViewers[msg.sender][_viewer] = false;
        emit ViewerRemoved(msg.sender, _viewer);
    }

    function getDNA(address _wallet) public view returns (bytes32 dataHash, uint64 timestamp) {
        require(msg.sender == _wallet || authorizedViewers[_wallet][msg.sender], "Not authorized to view this DNA data");
        
        DNAData memory data = dnaRecords[_wallet];
        require(data.dataHash != bytes32(0), "No DNA data found for this wallet");

        return (data.dataHash, data.timestamp);
    }

    function hasDNA(address _wallet) public view returns (bool) {
        return dnaRecords[_wallet].dataHash != bytes32(0);
    }
}
