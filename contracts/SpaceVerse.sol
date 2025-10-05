// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../contract/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../contract/@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "../contract/@openzeppelin/contracts/access/Ownable.sol";
import "../contract/@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../contract/@openzeppelin/contracts/utils/Counters.sol";

contract SpaceVerse is ERC721, ERC721URIStorage, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    
    // --- Counters for unique token IDs ---
    Counters.Counter private _exoplanetIds;
    Counters.Counter private _habitatIds;

    // --- Enums ---
    enum WorkType { ExoplanetDiscovery, HabitatDesign, OrbitCalculation }
    enum ExoplanetStatus { Unknown, Candidate, Confirmed, FalsePositive }

    // --- Structs for on-chain data ---
    struct ExoplanetData {
        string name;
        uint256 orbitalPeriod;
        uint256 transitDuration;
        uint256 planetRadius; // Scaled by 100 for precision (e.g., 150 = 1.50 Earth radii)
        uint256 starRadius;   // Scaled by 100
        uint256 starTemperature;
        ExoplanetStatus status;
        address discoverer;
        uint256 timestamp;
    }

    struct HabitatData {
        string name;
        address designer;
        uint256 crewSize;
        uint256 missionDuration;
        uint256 destination; // Using an index for an enum
        uint256 score;
        uint256 timestamp;
    }
    
    struct ProofOfWorkData {
        address submitter;
        WorkType workType;
        string data; // Can be a hash or IPFS link
        uint256 timestamp;
        bool verified;
    }

    // --- Mappings ---
    mapping(uint256 => ExoplanetData) public exoplanets;
    mapping(uint256 => HabitatData) public habitats;
    mapping(bytes32 => ProofOfWorkData) public proofsOfWork;
    mapping(address => uint256[]) public userExoplanets;
    mapping(address => uint256[]) public userHabitats;

    // --- Events ---
    event ExoplanetDiscovered(uint256 indexed tokenId, address indexed discoverer, string name);
    event HabitatDesigned(uint256 indexed tokenId, address indexed designer, string name);
    event ProofOfWorkSubmitted(bytes32 indexed hash, address indexed submitter, WorkType workType);

    // --- Constructor ---
    constructor() ERC721("SpaceVerse Discovery", "SVD") Ownable(msg.sender) {}

    // --- Main Functions for the Flutter App ---

    /**
     * @dev Records a new exoplanet discovery and mints it as an NFT.
     * Called by the BlockchainService in the Flutter app.
     */
    function recordExoplanetDiscovery(
        string memory _name,
        uint256 _orbitalPeriod,
        uint256 _transitDuration,
        uint256 _planetRadius,
        uint256 _starRadius,
        uint256 _starTemperature,
        ExoplanetStatus _status,
        address _discoverer
    ) external nonReentrant returns (uint256) {
        _exoplanetIds.increment();
        uint256 newTokenId = _exoplanetIds.current();

        exoplanets[newTokenId] = ExoplanetData({
            name: _name,
            orbitalPeriod: _orbitalPeriod,
            transitDuration: _transitDuration,
            planetRadius: _planetRadius,
            starRadius: _starRadius,
            starTemperature: _starTemperature,
            status: _status,
            discoverer: _discoverer,
            timestamp: block.timestamp
        });

        userExoplanets[_discoverer].push(newTokenId);
        _safeMint(_discoverer, newTokenId);

        emit ExoplanetDiscovered(newTokenId, _discoverer, _name);
        return newTokenId;
    }

    /**
     * @dev Records a new habitat design and mints it as an NFT.
     */
    function recordHabitatDesign(
        string memory _designJson,
        uint256 _crewSize,
        uint256 _missionDuration,
        uint256 _destination,
        address _designer
    ) external nonReentrant returns (uint256) {
        _habitatIds.increment();
        uint256 newTokenId = _habitatIds.current();
        
        // The designJson is stored as the token's metadata URI
        _setTokenURI(newTokenId, _designJson);

        habitats[newTokenId] = HabitatData({
            name: string(abi.encodePacked("Habitat #", Strings.toString(newTokenId))),
            designer: _designer,
            crewSize: _crewSize,
            missionDuration: _missionDuration,
            destination: _destination,
            score: 0, // Can be updated later
            timestamp: block.timestamp
        });

        userHabitats[_designer].push(newTokenId);
        _safeMint(_designer, newTokenId);

        emit HabitatDesigned(newTokenId, _designer, habitats[newTokenId].name);
        return newTokenId;
    }

    /**
     * @dev Submits a Proof-of-Work for verification.
     * The signature verification is simplified for this demo.
     */
    function submitProofOfWork(
        WorkType _workType,
        string memory _data,
        bytes memory /*signature*/ // Signature would be verified here in production
    ) external returns (bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(msg.sender, _workType, _data, block.timestamp));
        
        proofsOfWork[hash] = ProofOfWorkData({
            submitter: msg.sender,
            workType: _workType,
            data: _data,
            timestamp: block.timestamp,
            verified: false // Would be set to true after verification
        });

        emit ProofOfWorkSubmitted(hash, msg.sender, _workType);
        return hash;
    }

    // --- View Functions for the Flutter App ---

    function getVerifiedExoplanets() external view returns (ExoplanetData[] memory) {
        uint256 totalExoplanets = _exoplanetIds.current();
        ExoplanetData[] memory allExoplanets = new ExoplanetData[](totalExoplanets);
        for (uint256 i = 0; i < totalExoplanets; i++) {
            allExoplanets[i] = exoplanets[i + 1];
        }
        return allExoplanets;
    }

    function getSharedHabitatDesigns() external view returns (HabitatData[] memory) {
        uint256 totalHabitats = _habitatIds.current();
        HabitatData[] memory allHabitats = new HabitatData[](totalHabitats);
        for (uint256 i = 0; i < totalHabitats; i++) {
            allHabitats[i] = habitats[i + 1];
        }
        return allHabitats;
    }
    
    function getUserDiscoveries(address _user) external view returns (uint256[] memory) {
        return userExoplanets[_user];
    }

    function getUserDesigns(address _user) external view returns (uint256[] memory) {
        return userHabitats[_user];
    }

    // --- Required Overrides for ERC721URIStorage ---
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}