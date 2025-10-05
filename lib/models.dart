// Universe models
import 'dart:math';

class Galaxy {
  final Point<double> center;
  final int spiralArms;
  final double starDensity;
  final List<Star> stars;
  
  Galaxy({
    required this.center,
    required this.spiralArms,
    required this.starDensity,
    required this.stars,
  });
}

class Star {
  final Point<double> position;
  final StarType type;
  final List<Planet> planets;
  String get name => 'Star-${position.x.toInt()}-${position.y.toInt()}';
  
  Star({
    required this.position,
    required this.type,
    required this.planets,
  });
}

enum StarType {
  redDwarf,
  yellowDwarf,
  blueSupergiant,
  redGiant,
  whiteDwarf,
}

class Planet {
  final double orbitalDistance;
  final double size;
  final bool hasAtmosphere;
  final double habitability;
  final List<Biome> biomes;
  
  // Exoplanet detection properties
  final double transitDepth;
  final double orbitalPeriod;
  final double transitDuration;

  var radius;

  var moons;

  var type;
  
  Planet({
    required this.orbitalDistance,
    required this.size,
    required this.hasAtmosphere,
    required this.habitability,
    required this.biomes,
    required this.transitDepth,
    required this.orbitalPeriod,
    required this.transitDuration,
  });
}

class Biome {
  final BiomeType type;
  final double temperature;
  final double humidity;
  final double biodiversity;
  
  Biome({
    required this.type,
    required this.temperature,
    required this.humidity,
    required this.biodiversity,
  });
}

enum BiomeType {
  barren,
  desert,
  tundra,
  forest,
  ocean,
  grassland,
  wetland,
}

// Exoplanet models
class ExoplanetData {
  final String name;
  final double orbitalPeriod;
  final double transitDuration;
  final double planetRadius;
  final double starRadius;
  final double starTemperature;
  final ExoplanetStatus status;
  final double transitDepth;
  final double densityEstimate;
  final double? confidence;
  
  ExoplanetData({
    required this.name,
    required this.orbitalPeriod,
    required this.transitDuration,
    required this.planetRadius,
    required this.starRadius,
    required this.starTemperature,
    required this.status,
    required this.transitDepth,
    required this.densityEstimate,
    this.confidence,
  });
  
  ExoplanetData copyWith({
    String? name,
    double? orbitalPeriod,
    double? transitDuration,
    double? planetRadius,
    double? starRadius,
    double? starTemperature,
    ExoplanetStatus? status,
    double? transitDepth,
    double? densityEstimate,
    double? confidence,
  }) {
    return ExoplanetData(
      name: name ?? this.name,
      orbitalPeriod: orbitalPeriod ?? this.orbitalPeriod,
      transitDuration: transitDuration ?? this.transitDuration,
      planetRadius: planetRadius ?? this.planetRadius,
      starRadius: starRadius ?? this.starRadius,
      starTemperature: starTemperature ?? this.starTemperature,
      status: status ?? this.status,
      transitDepth: transitDepth ?? this.transitDepth,
      densityEstimate: densityEstimate ?? this.densityEstimate,
      confidence: confidence ?? this.confidence,
    );
  }
  
  factory ExoplanetData.fromJson(Map<String, dynamic> json) {
    return ExoplanetData(
      name: json['pl_name'] ?? '',
      orbitalPeriod: (json['pl_orbper'] ?? 0).toDouble(),
      transitDuration: (json['pl_trandur'] ?? 0).toDouble(),
      planetRadius: (json['pl_rade'] ?? 0).toDouble(),
      starRadius: (json['st_rad'] ?? 0).toDouble(),
      starTemperature: (json['st_teff'] ?? 0).toDouble(),
      status: _parseStatus(json['pl_status'] ?? ''),
      transitDepth: 0.0, // Calculate from other values
      densityEstimate: 0.0, // Calculate from other values
    );
  }
  
  static ExoplanetStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return ExoplanetStatus.confirmed;
      case 'candidate':
        return ExoplanetStatus.candidate;
      case 'false positive':
        return ExoplanetStatus.falsePositive;
      default:
        return ExoplanetStatus.unknown;
    }
  }
}

enum ExoplanetStatus {
  confirmed,
  candidate,
  falsePositive,
  unknown,
}

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

// Habitat models
class HabitatDesign {
  HabitatShape shape;
  double width;
  double height;
  double depth;
  int crewSize;
  int missionDuration;
  Destination destination;
  List<HabitatModule> modules;
  Layout layout;
  late double totalVolume;

  var validationResult;
  
  HabitatDesign({
    required this.shape,
    required this.width,
    required this.height,
    required this.depth,
    required this.crewSize,
    required this.missionDuration,
    required this.destination,
    required this.modules,
    required this.layout,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'shape': shape.index,
      'width': width,
      'height': height,
      'depth': depth,
      'crewSize': crewSize,
      'missionDuration': missionDuration,
      'destination': destination.index,
      'modules': modules.map((m) => m.toJson()).toList(),
      'layout': layout.toJson(),
    };
  }
  
  factory HabitatDesign.fromJson(Map<String, dynamic> json) {
    return HabitatDesign(
      shape: HabitatShape.values[json['shape']],
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      depth: json['depth'].toDouble(),
      crewSize: json['crewSize'],
      missionDuration: json['missionDuration'],
      destination: Destination.values[json['destination']],
      modules: (json['modules'] as List)
          .map((m) => HabitatModule.fromJson(m))
          .toList(),
      layout: Layout.fromJson(json['layout']),
    );
  }
}

enum HabitatShape {
  cylinder,
  sphere,
  box,
  torus,
}

enum Destination {
  lowEarthOrbit,
  lunarSurface,
  lunarOrbit,
  marsTransit,
  marsSurface,
  marsOrbit,
  any,
}

class HabitatModule {
  final String name;
  final ModuleType type;
  final double volume;
  final double mass;
  final String description;
  final int minCrewSize;
  final int minMissionDuration;
  final Destination destination;
  final bool scalesWithCrew;
  final bool scalesWithDuration;
  final int capacityPerUnit;

  var position;
  
  HabitatModule({
    required this.name,
    required this.type,
    required this.volume,
    required this.mass,
    required this.description,
    required this.minCrewSize,
    required this.minMissionDuration,
    required this.destination,
    required this.scalesWithCrew,
    required this.scalesWithDuration,
    required this.capacityPerUnit,
  });
  
  factory HabitatModule.fromJson(Map<String, dynamic> json) {
    return HabitatModule(
      name: json['name'],
      type: ModuleType.values[json['type']],
      volume: json['volume'].toDouble(),
      mass: json['mass'].toDouble(),
      description: json['description'],
      minCrewSize: json['minCrewSize'],
      minMissionDuration: json['minMissionDuration'],
      destination: Destination.values[json['destination']],
      scalesWithCrew: json['scalesWithCrew'],
      scalesWithDuration: json['scalesWithDuration'],
      capacityPerUnit: json['capacityPerUnit'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type.index,
      'volume': volume,
      'mass': mass,
      'description': description,
      'minCrewSize': minCrewSize,
      'minMissionDuration': minMissionDuration,
      'destination': destination.index,
      'scalesWithCrew': scalesWithCrew,
      'scalesWithDuration': scalesWithDuration,
      'capacityPerUnit': capacityPerUnit,
    };
  }
}

enum ModuleType {
  lifeSupport,
  power,
  communication,
  crewQuarters,
  medical,
  food,
  waste,
  exercise,
  work,
  recreation,
  storage,
  maintenance,
}

class Layout {
  final Map<HabitatModule, ModulePosition> modulePositions;
  final List<AccessPath> accessPaths;
  
  Layout({
    required this.modulePositions,
    required this.accessPaths,
  });
  
  factory Layout.fromJson(Map<String, dynamic> json) {
    final modulePositions = <HabitatModule, ModulePosition>{};
    final modulePositionsJson = json['modulePositions'] as Map<String, dynamic>;
    
    // This is a simplified implementation
    // In a real app, you would need to reconstruct HabitatModule objects
    
    final accessPaths = (json['accessPaths'] as List)
        .map((p) => AccessPath.fromJson(p))
        .toList();
    
    return Layout(
      modulePositions: modulePositions,
      accessPaths: accessPaths,
    );
  }
  
  Map<String, dynamic> toJson() {
    // This is a simplified implementation
    // In a real app, you would need to serialize HabitatModule objects
    return {
      'modulePositions': {},
      'accessPaths': accessPaths.map((p) => p.toJson()).toList(),
    };
  }
  
  ModulePosition? getModulePosition(HabitatModule module) {
    return modulePositions[module];
  }
  
  bool isModuleAccessible(HabitatModule module) {
    // Check if module is accessible via access paths
    for (final path in accessPaths) {
      if (path.modules.contains(module)) {
        return true;
      }
    }
    return false;
  }
  
  bool isModuleOptimallyPlaced(HabitatModule module) {
    // Check if module is optimally placed based on its type
    final position = modulePositions[module];
    if (position == null) return false;
    
    // Simplified implementation
    // In a real app, you would check specific placement rules for each module type
    return true;
  }
}

class ModulePosition {
  final double x;
  final double y;
  final double z;
  final ModuleOrientation orientation;
  
  ModulePosition({
    required this.x,
    required this.y,
    required this.z,
    required this.orientation,
  });

  factory ModulePosition.fromJson(Map<String, dynamic> json) {
    return ModulePosition(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      z: json['z'].toDouble(),
      orientation: ModuleOrientation.values[json['orientation']],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'orientation': orientation.index,
    };
  }

}

enum ModuleOrientation {
  horizontal,
  vertical,
  angled,
}

class AccessPath {
  final List<HabitatModule> modules;
  final double width;
  final double height;
  
  AccessPath({
    required this.modules,
    required this.width,
    required this.height,
  });
  
  factory AccessPath.fromJson(Map<String, dynamic> json) {
    // This is a simplified implementation
    // In a real app, you would need to reconstruct HabitatModule objects
    return AccessPath(
      modules: [],
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    // This is a simplified implementation
    // In a real app, you would need to serialize HabitatModule objects
    return {
      'modules': [],
      'width': width,
      'height': height,
    };
  }
}

class HabitatConstraint {
  final String name;
  final String description;
  final ModuleType moduleType;
  final ConstraintType type;
  final bool isRequired;
  final List<ModuleType> proximityModules;
  final List<ModuleType> separationModules;
  final double maxDistance;
  final double minDistance;
  final ModulePosition? requiredPosition;
  
  HabitatConstraint({
    required this.name,
    required this.description,
    required this.moduleType,
    required this.type,
    required this.isRequired,
    required this.proximityModules,
    required this.separationModules,
    required this.maxDistance,
    required this.minDistance,
    this.requiredPosition,
  });
  
  factory HabitatConstraint.fromJson(Map<String, dynamic> json) {
    return HabitatConstraint(
      name: json['name'],
      description: json['description'],
      moduleType: ModuleType.values[json['moduleType']],
      type: ConstraintType.values[json['type']],
      isRequired: json['isRequired'],
      proximityModules: (json['proximityModules'] as List)
          .map((m) => ModuleType.values[m])
          .toList(),
      separationModules: (json['separationModules'] as List)
          .map((m) => ModuleType.values[m])
          .toList(),
      maxDistance: json['maxDistance'].toDouble(),
      minDistance: json['minDistance'].toDouble(),
      requiredPosition: json['requiredPosition'] != null
          ? ModulePosition.fromJson(json['requiredPosition'])
          : null,
    );
  }
}

enum ConstraintType {
  proximity,
  separation,
  position,
}

class LayoutValidationResult {
  final bool isValid;
  final List<LayoutIssue> issues;
  final double score;
  
  LayoutValidationResult({
    required this.isValid,
    required this.issues,
    required this.score,
  });
}

class LayoutIssue {
  final IssueType type;
  final IssueSeverity severity;
  final String message;
  
  LayoutIssue({
    required this.type,
    required this.severity,
    required this.message,
  });
}

enum IssueType {
  volumeExceeded,
  missingModule,
  placementConstraint,
  inaccessible,
  accessPath,
}

enum IssueSeverity {
  error,
  warning,
  info,
}

// Blockchain models
class ProofOfWork {
  final WorkType workType;
  final String data;
  final String signature;
  
  ProofOfWork({
    required this.workType,
    required this.data,
    required this.signature,
  });
}

enum WorkType {
  exoplanetDiscovery,
  habitatDesign,
  orbitCalculation,
}