import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:spaceverse/models.dart';
import 'package:spaceverse/tfmodel.dart';

class ExoplanetHunterService {
  late TensorFlowModel _model;
  late List<ExoplanetData> _trainingData;
  
  Future<void> initializeModel() async {
    // Load TensorFlow Lite model
    _model = await TensorFlowModel.fromAsset('assets/models/exoplanet_classifier.tflite');
    
    // Load training data from NASA datasets
    _trainingData = await _loadTrainingData();
  }
  
  Future<List<ExoplanetData>> _loadTrainingData() async {
    // Load data from Kepler, K2, and TESS missions
    final keplerData = await _loadKeplerData();
    final k2Data = await _loadK2Data();
    final tessData = await _loadTessData();
    
    // Combine and preprocess data
    final allData = [...keplerData, ...k2Data, ...tessData];
    return _preprocessData(allData);
  }
  
  Future<List<ExoplanetData>> _loadKeplerData() async {
    // Fetch Kepler data from NASA API
    final response = await http.get(Uri.parse('https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+pl_name,pl_orbper,pl_tranmid,pl_trandur,pl_rade,st_rad,st_teff,pl_status+from+ps+where+pl_status+in+%28%27candidate%27,%27confirmed%27,%27false+positive%27%29&format=json'));
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ExoplanetData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Kepler data');
    }
  }
  
  Future<List<ExoplanetData>> _loadK2Data() async {
    // Similar implementation for K2 data
    final response = await http.get(Uri.parse('https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+pl_name,pl_orbper,pl_tranmid,pl_trandur,pl_rade,st_rad,st_teff,pl_status+from+ps+where+'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ExoplanetData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Kepler data');
    }
  }
  
  Future<List<ExoplanetData>> _loadTessData() async {
    // Similar implementation for TESS data
    final response = await http.get(Uri.parse('https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+pl_name,pl_orbper,pl_tranmid,pl_trandur,pl_rade,st_rad,st_teff,pl_status+from+ps+where+pl_status+in+%28%27candidate%27,%27confirmed%27,%27false+positive%27%29&format=json'));
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ExoplanetData.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Kepler data');
    }
  }
  
  List<ExoplanetData> _preprocessData(List<ExoplanetData> data) {
    // Normalize and preprocess data for training
    final processedData = <ExoplanetData>[];
    
    // Calculate min/max values for normalization
    final minOrbitalPeriod = data.map((d) => d.orbitalPeriod).reduce(min);
    final maxOrbitalPeriod = data.map((d) => d.orbitalPeriod).reduce(max);
    final minTransitDuration = data.map((d) => d.transitDuration).reduce(min);
    final maxTransitDuration = data.map((d) => d.transitDuration).reduce(max);
    final minPlanetRadius = data.map((d) => d.planetRadius).reduce(min);
    final maxPlanetRadius = data.map((d) => d.planetRadius).reduce(max);
    final minStarRadius = data.map((d) => d.starRadius).reduce(min);
    final maxStarRadius = data.map((d) => d.starRadius).reduce(max);
    final minStarTemp = data.map((d) => d.starTemperature).reduce(min);
    final maxStarTemp = data.map((d) => d.starTemperature).reduce(max);
    
    for (final item in data) {
      // Normalize values to [0, 1]
      final normalizedOrbitalPeriod = (item.orbitalPeriod - minOrbitalPeriod) / (maxOrbitalPeriod - minOrbitalPeriod);
      final normalizedTransitDuration = (item.transitDuration - minTransitDuration) / (maxTransitDuration - minTransitDuration);
      final normalizedPlanetRadius = (item.planetRadius - minPlanetRadius) / (maxPlanetRadius - minPlanetRadius);
      final normalizedStarRadius = (item.starRadius - minStarRadius) / (maxStarRadius - minStarRadius);
      final normalizedStarTemp = (item.starTemperature - minStarTemp) / (maxStarTemp - minStarTemp);
      
      // Calculate additional features
      final transitDepth = pow(normalizedPlanetRadius / normalizedStarRadius, 2).toDouble();
      final densityEstimate = normalizedPlanetRadius / pow(normalizedOrbitalPeriod, 2/3);
      
      processedData.add(ExoplanetData(
        name: item.name,
        orbitalPeriod: normalizedOrbitalPeriod,
        transitDuration: normalizedTransitDuration,
        planetRadius: normalizedPlanetRadius,
        starRadius: normalizedStarRadius,
        starTemperature: normalizedStarTemp,
        status: item.status,
        transitDepth: transitDepth,
        densityEstimate: densityEstimate,
      ));
    }
    
    return processedData;
  }
  
  Future<ExoplanetClassification> classifyExoplanet(ExoplanetData data) async {
    // Preprocess input data
    final processedData = _preprocessData([data])[0];
    
    // Create input tensor
    final input = [
      processedData.orbitalPeriod,
      processedData.transitDuration,
      processedData.planetRadius,
      processedData.starRadius,
      processedData.starTemperature,
      processedData.transitDepth,
      processedData.densityEstimate,
    ];
    
    // Run inference
    final output = await _model.run(input);
    
    // Interpret output
    final confidence = output[0] as List<double>;
    final maxIndex = confidence.indexOf(confidence.reduce(max));
    final maxConfidence = confidence[maxIndex];
    
    ExoplanetStatus status;
    switch (maxIndex) {
      case 0:
        status = ExoplanetStatus.confirmed;
        break;
      case 1:
        status = ExoplanetStatus.candidate;
        break;
      case 2:
        status = ExoplanetStatus.falsePositive;
        break;
      default:
        status = ExoplanetStatus.unknown;
    }
    
    return ExoplanetClassification(
      status: status,
      confidence: maxConfidence,
      allProbabilities: {
        ExoplanetStatus.confirmed: confidence[0],
        ExoplanetStatus.candidate: confidence[1],
        ExoplanetStatus.falsePositive: confidence[2],
      },
    );
  }
  
  Future<void> trainModel() async {
    // Split data into training and validation sets
    final shuffledData = List<ExoplanetData>.from(_trainingData)..shuffle();
    final splitIndex = (shuffledData.length * 0.8).toInt();
    final trainingData = shuffledData.sublist(0, splitIndex);
    final validationData = shuffledData.sublist(splitIndex);
    
    // Prepare training data
    final trainInputs = trainingData.map((data) => [
      data.orbitalPeriod,
      data.transitDuration,
      data.planetRadius,
      data.starRadius,
      data.starTemperature,
      data.transitDepth,
      data.densityEstimate,
    ]).toList();
    
    final trainLabels = trainingData.map((data) {
      switch (data.status) {
        case ExoplanetStatus.confirmed:
          return [1.0, 0.0, 0.0];
        case ExoplanetStatus.candidate:
          return [0.0, 1.0, 0.0];
        case ExoplanetStatus.falsePositive:
          return [0.0, 0.0, 1.0];
        default:
          return [0.0, 0.0, 0.0];
      }
    }).toList();
    
    // Train model (simplified)
    await _model.train(trainInputs, trainLabels);
    
    // Validate model
    final validationInputs = validationData.map((data) => [
      data.orbitalPeriod,
      data.transitDuration,
      data.planetRadius,
      data.starRadius,
      data.starTemperature,
      data.transitDepth,
      data.densityEstimate,
    ]).toList();
    
    final validationLabels = validationData.map((data) {
      switch (data.status) {
        case ExoplanetStatus.confirmed:
          return [1.0, 0.0, 0.0];
        case ExoplanetStatus.candidate:
          return [0.0, 1.0, 0.0];
        case ExoplanetStatus.falsePositive:
          return [0.0, 0.0, 1.0];
        default:
          return [0.0, 0.0, 0.0];
      }
    }).toList();
    
    final accuracy = await _model.evaluate(validationInputs, validationLabels);
    print('Model accuracy: ${accuracy * 100}%');
  }
  
  Future<List<ExoplanetData>> discoverExoplanets(Star star) async {
    // Simulate observation data for a star
    final observationData = await _simulateObservation(star);
    
    // Process observation data to find potential exoplanets
    final potentialExoplanets = <ExoplanetData>[];
    
    for (final data in observationData) {
      final classification = await classifyExoplanet(data);
      
      if (classification.status == ExoplanetStatus.confirmed || 
          classification.status == ExoplanetStatus.candidate) {
        potentialExoplanets.add(data.copyWith(
          status: classification.status,
          confidence: classification.confidence,
        ));
      }
    }
    
    return potentialExoplanets;
  }
  
  Future<List<ExoplanetData>> _simulateObservation(Star star) async {
    // Simulate observation data based on star properties
    final exoplanets = <ExoplanetData>[];
    final random = Random();
    
    // Generate random number of potential exoplanets
    final numPotentialExoplanets = random.nextInt(5) + 1;
    
    for (int i = 0; i < numPotentialExoplanets; i++) {
      // Generate random properties
      final orbitalPeriod = random.nextDouble() * 365 + 1; // 1 to 365 days
      final transitDuration = random.nextDouble() * 10 + 1; // 1 to 10 hours
      final planetRadius = random.nextDouble() * 5 + 0.5; // 0.5 to 5.5 Earth radii
      final starRadius = _getStarRadius(star.type);
      final starTemperature = _getStarTemperature(star.type);
      
      // Calculate derived properties
      final transitDepth = pow(planetRadius / starRadius, 2).toDouble();
      final densityEstimate = planetRadius / pow(orbitalPeriod, 2/3);
      
      exoplanets.add(ExoplanetData(
        name: '${star.name}-${i + 1}',
        orbitalPeriod: orbitalPeriod,
        transitDuration: transitDuration,
        planetRadius: planetRadius,
        starRadius: starRadius,
        starTemperature: starTemperature,
        status: ExoplanetStatus.unknown,
        transitDepth: transitDepth,
        densityEstimate: densityEstimate,
      ));
    }
    
    return exoplanets;
  }
  
  double _getStarRadius(StarType type) {
    switch (type) {
      case StarType.redDwarf:
        return 0.5;
      case StarType.yellowDwarf:
        return 1.0;
      case StarType.blueSupergiant:
        return 5.0;
      case StarType.redGiant:
        return 3.0;
      case StarType.whiteDwarf:
        return 0.2;
    }
  }
  
  double _getStarTemperature(StarType type) {
    switch (type) {
      case StarType.redDwarf:
        return 3000;
      case StarType.yellowDwarf:
        return 5800;
      case StarType.blueSupergiant:
        return 20000;
      case StarType.redGiant:
        return 4000;
      case StarType.whiteDwarf:
        return 10000;
    }
  }
}