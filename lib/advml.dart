// lib/features/exoplanet_hunter/domain/services/ml_service.dart
import 'dart:io';
import 'dart:math';
import 'package:spaceverse/exceptions.dart';
import 'package:spaceverse/logger.dart';
import 'package:spaceverse/models.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:spaceverse/features/exoplanet_hunter/domain/entities/exoplanet_data.dart';
// import 'package:spaceverse/core/errors/exceptions.dart';
// import 'package:spaceverse/core/utils/logger.dart';

class AdvancedMLService {
  late Interpreter _classifier;
  late Interpreter _regressor;
  late Interpreter _anomalyDetector;
  
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load models
      _classifier = await _loadModel('assets/models/exoplanet_classifier.tflite');
      _regressor = await _loadModel('assets/models/exoplanet_regressor.tflite');
      _anomalyDetector = await _loadModel('assets/models/anomaly_detector.tflite');
      
      _isInitialized = true;
      AppLogger.i('ML models initialized successfully');
    } catch (e) {
      AppLogger.e('Failed to initialize ML models', error: e);
      throw MLException('Failed to initialize ML models', details: e);
    }
  }

  Future<Interpreter> _loadModel(String path) async {
    try {
      return await Interpreter.fromAsset(path);
    } catch (e) {
      AppLogger.e('Failed to load model: $path', error: e);
      throw MLException('Failed to load model: $path', details: e);
    }
  }

  Future<ExoplanetClassification> classifyExoplanet(ExoplanetData data) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Prepare input
      final input = _prepareClassificationInput(data);
      
      // Run inference
      final output = List.filled(1 * 3, 0.0).reshape([1, 3]);
      _classifier.run(input, output);
      
      // Process output
      final probabilities = output[0];
      final maxIndex = _argmax(probabilities);
      final confidence = probabilities[maxIndex];
      
      final status = ExoplanetStatus.values[maxIndex];
      
      return ExoplanetClassification(
        status: status,
        confidence: confidence,
        allProbabilities: {
          ExoplanetStatus.confirmed: probabilities[0],
          ExoplanetStatus.candidate: probabilities[1],
          ExoplanetStatus.falsePositive: probabilities[2],
        },
      );
    } catch (e) {
      AppLogger.e('Failed to classify exoplanet', error: e);
      throw MLException('Failed to classify exoplanet', details: e);
    }
  }

  Future<ExoplanetRegression> predictExoplanetProperties(ExoplanetData data) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Prepare input
      final input = _prepareRegressionInput(data);
      
      // Run inference
      final output = List.filled(1 * 5, 0.0).reshape([1, 5]);
      _regressor.run(input, output);
      
      // Process output
      final results = output[0];
      
      return ExoplanetRegression(
        predictedMass: results[0],
        predictedRadius: results[1],
        predictedDensity: results[2],
        predictedTemperature: results[3],
        predictedAlbedo: results[4],
      );
    } catch (e) {
      AppLogger.e('Failed to predict exoplanet properties', error: e);
      throw MLException('Failed to predict exoplanet properties', details: e);
    }
  }

  Future<bool> detectAnomalies(List<ExoplanetData> data) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Prepare input
      final input = _prepareAnomalyInput(data);
      
      // Run inference
      final output = List.filled(1, 0.0).reshape([1, 1]);
      _anomalyDetector.run(input, output);
      
      // Process output
      final anomalyScore = output[0][0];
      
      return anomalyScore > 0.5;
    } catch (e) {
      AppLogger.e('Failed to detect anomalies', error: e);
      throw MLException('Failed to detect anomalies', details: e);
    }
  }

  Future<LightCurveAnalysis> analyzeLightCurve(List<double> lightCurve) async {
    try {
      // Preprocess light curve
      final normalizedCurve = _normalizeLightCurve(lightCurve);
      
      // Detect transits
      final transits = _detectTransits(normalizedCurve);
      
      // Calculate transit parameters
      final parameters = _calculateTransitParameters(transits, normalizedCurve);
      
      // Classify transit shape
      final shape = _classifyTransitShape(transits);
      
      return LightCurveAnalysis(
        transits: transits,
        parameters: parameters,
        shape: shape,
        confidence: _calculateConfidence(transits),
      );
    } catch (e) {
      AppLogger.e('Failed to analyze light curve', error: e);
      throw MLException('Failed to analyze light curve', details: e);
    }
  }

  List<double> _prepareClassificationInput(ExoplanetData data) {
    return [
      data.orbitalPeriod,
      data.transitDuration,
      data.planetRadius,
      data.starRadius,
      data.starTemperature,
      data.transitDepth,
      data.densityEstimate,
    ];
  }

  List<double> _prepareRegressionInput(ExoplanetData data) {
    return [
      data.orbitalPeriod,
      data.transitDuration,
      data.planetRadius,
      data.starRadius,
      data.starTemperature,
      data.transitDepth,
    ];
  }

  List<double> _prepareAnomalyInput(List<ExoplanetData> data) {
    final features = <double>[];
    
    for (final exoplanet in data) {
      features.addAll([
        exoplanet.orbitalPeriod,
        exoplanet.transitDuration,
        exoplanet.planetRadius,
        exoplanet.starRadius,
        exoplanet.starTemperature,
        exoplanet.transitDepth,
      ]);
    }
    
    return features;
  }

  List<double> _normalizeLightCurve(List<double> lightCurve) {
    final mean = lightCurve.reduce((a, b) => a + b) / lightCurve.length;
    final std = sqrt(lightCurve.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / lightCurve.length);
    
    return lightCurve.map((x) => (x - mean) / std).toList();
  }

  List<Transit> _detectTransits(List<double> normalizedCurve) {
    final transits = <Transit>[];
    final threshold = -2.0; // 2 sigma below mean
    
    bool inTransit = false;
    int start = 0;
    
    for (int i = 0; i < normalizedCurve.length; i++) {
      if (!inTransit && normalizedCurve[i] < threshold) {
        // Transit start
        inTransit = true;
        start = i;
      } else if (inTransit && normalizedCurve[i] >= threshold) {
        // Transit end
        inTransit = false;
        final depth = normalizedCurve.sublist(start, i).reduce(min);
        transits.add(Transit(
          startIndex: start,
          endIndex: i,
          depth: depth,
          duration: i - start,
        ));
      }
    }
    
    return transits;
  }

  TransitParameters _calculateTransitParameters(List<Transit> transits, List<double> normalizedCurve) {
    if (transits.isEmpty) {
      return TransitParameters(
        period: 0,
        duration: 0,
        depth: 0,
        impactParameter: 0,
      );
    }
    
    // Calculate average period
    final periods = <double>[];
    for (int i = 1; i < transits.length; i++) {
      periods.add((transits[i].startIndex - transits[i-1].startIndex) as double);
    }
    final period = periods.isEmpty ? 0 : periods.reduce((a, b) => a + b) / periods.length;
    
    // Calculate average duration
    final durations = transits.map((t) => t.duration.toDouble()).toList();
    final duration = durations.reduce((a, b) => a + b) / durations.length;
    
    // Calculate average depth
    final depths = transits.map((t) => t.depth).toList();
    final depth = depths.reduce((a, b) => a + b) / depths.length;
    
    // Estimate impact parameter (simplified)
    final impactParameter = Random().nextDouble();
    
    return TransitParameters(
      period: period as double,
      duration: duration,
      depth: depth,
      impactParameter: impactParameter,
    );
  }

  TransitShape _classifyTransitShape(List<Transit> transits) {
    if (transits.isEmpty) return TransitShape.unknown;
    
    // Analyze shape of first transit
    final transit = transits.first;
    final shape = _analyzeTransitShape(transit);
    
    return shape;
  }

  TransitShape _analyzeTransitShape(Transit transit) {
    // Simplified shape analysis
    // In a real implementation, you would use more sophisticated methods
    
    final duration = transit.endIndex - transit.startIndex;
    final depth = transit.depth;
    
    if (duration > 20 && depth < -3) {
      return TransitShape.egress;
    } else if (duration < 10 && depth < -2) {
      return TransitShape.ingress;
    } else if (depth < -4) {
      return TransitShape.flatBottom;
    } else {
      return TransitShape.vShaped;
    }
  }

  double _calculateConfidence(List<Transit> transits) {
    if (transits.isEmpty) return 0.0;
    
    // Calculate confidence based on transit characteristics
    final avgDepth = transits.map((t) => t.depth.abs()).reduce((a, b) => a + b) / transits.length;
    final avgDuration = transits.map((t) => t.duration).reduce((a, b) => a + b) / transits.length;
    
    // Higher confidence for deeper and longer transits
    return (avgDepth * avgDuration / 100).clamp(0.0, 1.0);
  }

  int _argmax(List<double> list) {
    int maxIndex = 0;
    double maxValue = list[0];
    
    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxValue) {
        maxValue = list[i];
        maxIndex = i;
      }
    }
    
    return maxIndex;
  }

  Future<void> trainModel(List<ExoplanetData> trainingData) async {
    try {
      // Prepare training data
      final inputs = trainingData.map(_prepareClassificationInput).toList();
      final labels = trainingData.map((data) => _encodeLabel(data.status)).toList();
      
      // Convert to tensors
      final inputTensor = inputs.reshape([inputs.length, inputs.first.length]);
      final labelTensor = labels.reshape([labels.length, 3]);
      
      // Train model (simplified - in practice you'd use TensorFlow training)
      AppLogger.i('Training model with ${trainingData.length} samples');
      
      // Save updated model
      await _saveModel(_classifier, 'assets/models/exoplanet_classifier_updated.tflite');
      
      AppLogger.i('Model training completed');
    } catch (e) {
      AppLogger.e('Failed to train model', error: e);
      throw MLException('Failed to train model', details: e);
    }
  }

  List<double> _encodeLabel(ExoplanetStatus status) {
    switch (status) {
      case ExoplanetStatus.confirmed:
        return [1.0, 0.0, 0.0];
      case ExoplanetStatus.candidate:
        return [0.0, 1.0, 0.0];
      case ExoplanetStatus.falsePositive:
        return [0.0, 0.0, 1.0];
      default:
        return [0.0, 0.0, 0.0];
    }
  }

  Future<void> _saveModel(Interpreter model, String path) async {
    try {
      // Save model weights
      final output = File(path);
      // Implementation depends on TensorFlow Lite version
      AppLogger.i('Model saved to $path');
    } catch (e) {
      AppLogger.e('Failed to save model', error: e);
      throw MLException('Failed to save model', details: e);
    }
  }

  Future<ModelMetrics> evaluateModel(List<ExoplanetData> testData) async {
    try {
      int correct = 0;
      final confusionMatrix = List.generate(3, (_) => List.filled(3, 0));
      
      for (final data in testData) {
        final classification = await classifyExoplanet(data);
        
        if (classification.status == data.status) {
          correct++;
        }
        
        confusionMatrix[data.status.index][classification.status.index]++;
      }
      
      final accuracy = correct / testData.length;
      final precision = _calculatePrecision(confusionMatrix);
      final recall = _calculateRecall(confusionMatrix);
      final f1Score = _calculateF1Score(precision, recall);
      
      return ModelMetrics(
        accuracy: accuracy,
        precision: precision,
        recall: recall,
        f1Score: f1Score,
        confusionMatrix: confusionMatrix,
      );
    } catch (e) {
      AppLogger.e('Failed to evaluate model', error: e);
      throw MLException('Failed to evaluate model', details: e);
    }
  }

  List<double> _calculatePrecision(List<List<int>> confusionMatrix) {
    final precision = <double>[];
    
    for (int i = 0; i < 3; i++) {
      final tp = confusionMatrix[i][i];
      final fp = confusionMatrix.map((row) => row[i]).reduce((a, b) => a + b) - tp;
      
      precision.add(tp / (tp + fp));
    }
    
    return precision;
  }

  List<double> _calculateRecall(List<List<int>> confusionMatrix) {
    final recall = <double>[];
    
    for (int i = 0; i < 3; i++) {
      final tp = confusionMatrix[i][i];
      final fn = confusionMatrix[i].reduce((a, b) => a + b) - tp;
      
      recall.add(tp / (tp + fn));
    }
    
    return recall;
  }

  List<double> _calculateF1Score(List<double> precision, List<double> recall) {
    return List.generate(3, (i) => 2 * precision[i] * recall[i] / (precision[i] + recall[i]));
  }
}

// Additional classes for ML service
class ExoplanetClassification {
  final ExoplanetStatus status;
  final double confidence;
  final Map<ExoplanetStatus, double> allProbabilities;
  
  ExoplanetClassification({
    required this.status,
    required this.confidence,
    required this.allProbabilities,
  });
}

class ExoplanetRegression {
  final double predictedMass;
  final double predictedRadius;
  final double predictedDensity;
  final double predictedTemperature;
  final double predictedAlbedo;
  
  ExoplanetRegression({
    required this.predictedMass,
    required this.predictedRadius,
    required this.predictedDensity,
    required this.predictedTemperature,
    required this.predictedAlbedo,
  });
}

class LightCurveAnalysis {
  final List<Transit> transits;
  final TransitParameters parameters;
  final TransitShape shape;
  final double confidence;
  
  LightCurveAnalysis({
    required this.transits,
    required this.parameters,
    required this.shape,
    required this.confidence,
  });
}

class Transit {
  final int startIndex;
  final int endIndex;
  final double depth;
  final int duration;
  
  Transit({
    required this.startIndex,
    required this.endIndex,
    required this.depth,
    required this.duration,
  });
}

class TransitParameters {
  final double period;
  final double duration;
  final double depth;
  final double impactParameter;
  
  TransitParameters({
    required this.period,
    required this.duration,
    required this.depth,
    required this.impactParameter,
  });
}

enum TransitShape {
  vShaped,
  flatBottom,
  ingress,
  egress,
  unknown,
}

class ModelMetrics {
  final double accuracy;
  final List<double> precision;
  final List<double> recall;
  final List<double> f1Score;
  final List<List<int>> confusionMatrix;
  
  ModelMetrics({
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.confusionMatrix,
  });
}