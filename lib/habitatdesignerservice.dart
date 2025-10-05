import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:spaceverse/blockchainservice.dart';
import 'package:spaceverse/models.dart';

class HabitatDesignerService {
  final List<HabitatModule> _availableModules = [];
  final List<HabitatConstraint> _constraints = [];
  
  Future<void> initialize() async {
    // Load available habitat modules
    await _loadHabitatModules();
    
    // Load habitat constraints
    await _loadHabitatConstraints();
  }
  
  Future<void> _loadHabitatModules() async {
    // Load modules from NASA resources
    final response = await rootBundle.loadString('assets/data/habitat_modules.json');
    final List<dynamic> jsonList = json.decode(response);
    
    _availableModules.addAll(jsonList.map((json) => HabitatModule.fromJson(json)));
  }
  
  Future<void> _loadHabitatConstraints() async {
    // Load constraints from NASA resources
    final response = await rootBundle.loadString('assets/data/habitat_constraints.json');
    final List<dynamic> jsonList = json.decode(response);
    
    _constraints.addAll(jsonList.map((json) => HabitatConstraint.fromJson(json)));
  }
  
  List<HabitatModule> getAvailableModules() {
    return List.from(_availableModules);
  }
  
  HabitatDesign createHabitatDesign({
    required HabitatShape shape,
    required double width,
    required double height,
    required double depth,
    required int crewSize,
    required int missionDuration,
    required Destination destination,
  }) {
    // Create a new habitat design
    final design = HabitatDesign(
      shape: shape,
      width: width,
      height: height,
      depth: depth,
      crewSize: crewSize,
      missionDuration: missionDuration,
      destination: destination,
      modules: [],
      layout: Layout(modulePositions: {}, accessPaths: []),
    );
    
    // Calculate total volume
    final volume = _calculateVolume(shape, width, height, depth);
    design.totalVolume = volume;
    
    // Calculate required modules based on crew size and mission duration
    final requiredModules = _calculateRequiredModules(crewSize, missionDuration, destination);
    
    // Add required modules to design
    for (final module in requiredModules) {
      design.modules.add(module);
    }
    
    return design;
  }
  
  double _calculateVolume(HabitatShape shape, double width, double height, double depth) {
    switch (shape) {
      case HabitatShape.cylinder:
        return pi * pow(width / 2, 2) * height;
      case HabitatShape.sphere:
        return (4/3) * pi * pow(width / 2, 3);
      case HabitatShape.box:
        return width * height * depth;
      case HabitatShape.torus:
        final majorRadius = width / 2;
        final minorRadius = depth / 2;
        return 2 * pow(pi, 2) * majorRadius * pow(minorRadius, 2);
    }
  }
  
  List<HabitatModule> _calculateRequiredModules(int crewSize, int missionDuration, Destination destination) {
    final requiredModules = <HabitatModule>[];
    
    // Calculate required modules based on crew size and mission duration
    for (final module in _availableModules) {
      if (_isModuleRequired(module, crewSize, missionDuration, destination)) {
        // Calculate required quantity
        final quantity = _calculateModuleQuantity(module, crewSize, missionDuration);
        
        for (int i = 0; i < quantity; i++) {
          requiredModules.add(module);
        }
      }
    }
    
    return requiredModules;
  }
  
  bool _isModuleRequired(HabitatModule module, int crewSize, int missionDuration, Destination destination) {
    // Check if module is required based on crew size, mission duration, and destination
    if (module.minCrewSize > crewSize) {
      return false;
    }
    
    if (module.minMissionDuration > missionDuration) {
      return false;
    }
    
    if (module.destination != Destination.any && module.destination != destination) {
      return false;
    }
    
    return true;
  }
  
  int _calculateModuleQuantity(HabitatModule module, int crewSize, int missionDuration) {
    // Calculate required quantity based on crew size and mission duration
    int baseQuantity = 1;
    
    // Adjust for crew size
    if (module.scalesWithCrew) {
      baseQuantity = (crewSize / module.capacityPerUnit).ceil();
    }
    
    // Adjust for mission duration
    if (module.scalesWithDuration) {
      final durationFactor = missionDuration / 30; // Normalize to 30 days
      baseQuantity = (baseQuantity * durationFactor).ceil();
    }
    
    return baseQuantity;
  }
  
  LayoutValidationResult validateLayout(HabitatDesign design) {
    final issues = <LayoutIssue>[];
    
    // Check if all modules fit within the habitat volume
    final totalModuleVolume = design.modules.fold(0.0, (sum, module) => sum + module.volume);
    if (totalModuleVolume > design.totalVolume) {
      issues.add(LayoutIssue(
        type: IssueType.volumeExceeded,
        severity: IssueSeverity.error,
        message: 'Total module volume exceeds habitat volume',
      ));
    }
    
    // Check if all required modules are present
    final requiredModuleTypes = _constraints
        .where((c) => c.isRequired)
        .map((c) => c.moduleType)
        .toSet();
    
    final presentModuleTypes = design.modules
        .map((m) => m.type)
        .toSet();
    
    final missingModules = requiredModuleTypes.difference(presentModuleTypes);
    for (final missing in missingModules) {
      issues.add(LayoutIssue(
        type: IssueType.missingModule,
        severity: IssueSeverity.error,
        message: 'Missing required module: $missing',
      ));
    }
    
    // Check module placement constraints
    for (final constraint in _constraints) {
      final affectedModules = design.modules
          .where((m) => m.type == constraint.moduleType)
          .toList();
      
      for (final module in affectedModules) {
        if (!_checkModulePlacement(module, design, constraint)) {
          issues.add(LayoutIssue(
            type: IssueType.placementConstraint,
            severity: IssueSeverity.warning,
            message: 'Module ${module.type} violates placement constraint: ${constraint.description}',
          ));
        }
      }
    }
    
    // Check access paths between modules
    final accessIssues = _checkAccessPaths(design);
    issues.addAll(accessIssues);
    
    // Calculate overall score
    final score = _calculateLayoutScore(design, issues);
    
    return LayoutValidationResult(
      isValid: issues.where((i) => i.severity == IssueSeverity.error).isEmpty,
      issues: issues,
      score: score,
    );
  }
  
  bool _checkModulePlacement(HabitatModule module, HabitatDesign design, HabitatConstraint constraint) {
    // Check if module placement satisfies constraint
    switch (constraint.type) {
      case ConstraintType.proximity:
        // Check proximity to other modules
        final requiredProximityModules = design.modules
            .where((m) => constraint.proximityModules.contains(m.type))
            .toList();
        
        for (final otherModule in requiredProximityModules) {
          final distance = _calculateDistance(module, otherModule, design);
          if (distance > constraint.maxDistance) {
            return false;
          }
        }
        break;
        
      case ConstraintType.separation:
        // Check separation from other modules
        final forbiddenProximityModules = design.modules
            .where((m) => constraint.separationModules.contains(m.type))
            .toList();
        
        for (final otherModule in forbiddenProximityModules) {
          final distance = _calculateDistance(module, otherModule, design);
          if (distance < constraint.minDistance) {
            return false;
          }
        }
        break;
        
      case ConstraintType.position:
        // Check position within habitat
        if (constraint.requiredPosition != null) {
          final position = design.layout.getModulePosition(module);
          if (position != constraint.requiredPosition) {
            return false;
          }
        }
        break;
    }
    
    return true;
  }
  
  double _calculateDistance(HabitatModule module1, HabitatModule module2, HabitatDesign design) {
    final pos1 = design.layout.getModulePosition(module1);
    final pos2 = design.layout.getModulePosition(module2);
    
    if (pos1 == null || pos2 == null) {
      return double.infinity;
    }
    
    // Calculate Euclidean distance
    return sqrt(
      pow(pos2.x - pos1.x, 2) +
      pow(pos2.y - pos1.y, 2) +
      pow(pos2.z - pos1.z, 2)
    );
  }
  
  List<LayoutIssue> _checkAccessPaths(HabitatDesign design) {
    final issues = <LayoutIssue>[];
    
    // Check if all modules are accessible
    for (final module in design.modules) {
      if (!design.layout.isModuleAccessible(module)) {
        issues.add(LayoutIssue(
          type: IssueType.inaccessible,
          severity: IssueSeverity.error,
          message: 'Module ${module.type} is not accessible',
        ));
      }
    }
    
    // Check access path width
    for (final path in design.layout.accessPaths) {
      if (path.width < _getMinimumAccessWidth()) {
        issues.add(LayoutIssue(
          type: IssueType.accessPath,
          severity: IssueSeverity.warning,
          message: 'Access path is too narrow',
        ));
      }
    }
    
    return issues;
  }
  
  double _getMinimumAccessWidth() {
    // Return minimum access width based on NASA standards
    return 1.0; // meters
  }
  
  double _calculateLayoutScore(HabitatDesign design, List<LayoutIssue> issues) {
    double score = 100.0;
    
    // Deduct points for issues
    for (final issue in issues) {
      switch (issue.severity) {
        case IssueSeverity.error:
          score -= 20.0;
          break;
        case IssueSeverity.warning:
          score -= 10.0;
          break;
        case IssueSeverity.info:
          score -= 5.0;
          break;
      }
    }
    
    // Add points for efficiency
    final volumeEfficiency = _calculateVolumeEfficiency(design);
    score += volumeEfficiency * 10.0;
    
    // Add points for ergonomics
    final ergonomicsScore = _calculateErgonomicsScore(design);
    score += ergonomicsScore * 10.0;
    
    return score.clamp(0.0, 100.0);
  }
  
  double _calculateVolumeEfficiency(HabitatDesign design) {
    final totalModuleVolume = design.modules.fold(0.0, (sum, module) => sum + module.volume);
    return totalModuleVolume / design.totalVolume;
  }
  
  double _calculateErgonomicsScore(HabitatDesign design) {
    // Calculate ergonomics score based on module placement and access paths
    double score = 0.0;
    
    // Check module placement
    for (final module in design.modules) {
      if (design.layout.isModuleOptimallyPlaced(module)) {
        score += 1.0;
      }
    }
    
    // Normalize to [0, 1]
    return score / design.modules.length;
  }
  
  Future<void> saveDesignToBlockchain(HabitatDesign design) async {
    // Save design to blockchain for verification and sharing
    final blockchainService = BlockchainService();
    await blockchainService.saveHabitatDesign(design);
  }
  
  Future<List<HabitatDesign>> getSharedDesigns() async {
    // Get shared designs from blockchain
    final blockchainService = BlockchainService();
    return await blockchainService.getSharedHabitatDesigns();
  }

  double calculateVolume(HabitatShape shape, double width, double height, double depth) {
    switch (shape) {
      case HabitatShape.cylinder:
        return pi * pow(width / 2, 2) * height;
      case HabitatShape.sphere:
        return (4/3) * pi * pow(width / 2, 3);
      case HabitatShape.box:
        return width * height * depth;
      case HabitatShape.torus:
        final majorRadius = width / 2;
        final minorRadius = depth / 2;
        return 2 * pow(pi, 2) * majorRadius * pow(minorRadius, 2);
    }
  }

  List<HabitatModule> calculateRequiredModules(int crewSize, int missionDuration, Destination destination) {
    final requiredModules = <HabitatModule>[];
    
    // Calculate required modules based on crew size and mission duration
    for (final module in _availableModules) {
      if (_isModuleRequired(module, crewSize, missionDuration, destination)) {
        // Calculate required quantity
        final quantity = _calculateModuleQuantity(module, crewSize, missionDuration);
        
        for (int i = 0; i < quantity; i++) {
          requiredModules.add(module);
        }
      }
    }
    
    return requiredModules;
  }
}