import 'dart:convert';

import 'package:spaceverse/models.dart';
import 'package:web3dart/web3dart.dart';

class BlockchainService {
  late Web3Client _client;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  
  Future<void> initialize() async {
    // Initialize blockchain connection
    final apiUrl = "https://mainnet.infura.io/v3/YOUR_API_KEY";
    _client = Web3Client(apiUrl, Client());
    
    // Load contract ABI and address
    final contractJson = await rootBundle.loadString('assets/contracts/SpaceVerse.json');
    final contractAbi = json.decode(contractJson)['abi'];
    _contractAddress = EthereumAddress.fromHex('0x1234567890123456789012345678901234567890');
    
    // Create contract instance
    _contract = DeployedContract(
      ContractAbi.fromJson(json.encode(contractAbi), 'SpaceVerse'),
      _contractAddress,
    );
  }
  
  Future<String> saveExoplanetDiscovery(ExoplanetData exoplanet, String discoverer) async {
    // Save exoplanet discovery to blockchain
    final function = _contract.function('recordExoplanetDiscovery');
    
    final result = await _client.sendTransaction(
      Credentials.fromPrivateKey('YOUR_PRIVATE_KEY'),
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [
          exoplanet.name,
          exoplanet.orbitalPeriod,
          exoplanet.transitDuration,
          exoplanet.planetRadius,
          exoplanet.starRadius,
          exoplanet.starTemperature,
          exoplanet.status.index,
          discoverer,
        ],
      ),
    );
    
    return result;
  }
  
  Future<String> saveHabitatDesign(HabitatDesign design) async {
    // Save habitat design to blockchain
    final function = _contract.function('recordHabitatDesign');
    
    // Serialize design
    final designJson = json.encode(design.toJson());
    
    final result = await _client.sendTransaction(
      Credentials.fromPrivateKey('YOUR_PRIVATE_KEY'),
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [
          designJson,
          design.crewSize,
          design.missionDuration,
          design.destination.index,
        ],
      ),
    );
    
    return result;
  }
  
  Future<List<ExoplanetData>> getVerifiedExoplanets() async {
    // Get verified exoplanets from blockchain
    final function = _contract.function('getVerifiedExoplanets');
    
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [],
    );
    
    final exoplanets = <ExoplanetData>[];
    for (final item in result[0] as List) {
      exoplanets.add(ExoplanetData(
        name: item[0],
        orbitalPeriod: item[1],
        transitDuration: item[2],
        planetRadius: item[3],
        starRadius: item[4],
        starTemperature: item[5],
        status: ExoplanetStatus.values[item[6]],
      ));
    }
    
    return exoplanets;
  }
  
  Future<List<HabitatDesign>> getSharedHabitatDesigns() async {
    // Get shared habitat designs from blockchain
    final function = _contract.function('getSharedHabitatDesigns');
    
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [],
    );
    
    final designs = <HabitatDesign>[];
    for (final item in result[0] as List) {
      final designJson = item[0];
      final designMap = json.decode(designJson);
      designs.add(HabitatDesign.fromJson(designMap));
    }
    
    return designs;
  }
  
  Future<String> submitProofOfWork(ProofOfWork proof) async {
    // Submit proof of work for verification
    final function = _contract.function('submitProofOfWork');
    
    final result = await _client.sendTransaction(
      Credentials.fromPrivateKey('YOUR_PRIVATE_KEY'),
      Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [
          proof.workType.index,
          proof.data,
          proof.signature,
        ],
      ),
    );
    
    return result;
  }
  
  Future<bool> verifyProofOfWork(ProofOfWork proof) async {
    // Verify proof of work
    final function = _contract.function('verifyProofOfWork');
    
    final result = await _client.call(
      contract: _contract,
      function: function,
      params: [
        proof.workType.index,
        proof.data,
        proof.signature,
      ],
    );
    
    return result[0];
  }
}