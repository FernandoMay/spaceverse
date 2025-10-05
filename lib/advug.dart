// lib/features/universe_explorer/domain/services/universe_generator.dart
import 'dart:math';
import 'dart:ui';
import 'package:spaceverse/perlin.dart';
import 'package:vector_math/vector_math.dart' hide SimplexNoise;
// import 'package:spaceverse/features/universe_explorer/domain/entities/universe.dart';
// import 'package:spaceverse/core/utils/math_utils.dart';

class AdvancedUniverseGenerator {
  final int seed;
  final Random random;
  final PerlinNoise perlinNoise;
  final SimplexNoise simplexNoise;
  
  // Physical constants
  static const double gravitationalConstant = 6.67430e-11;
  static const double speedOfLight = 299792458.0;
  static const double solarMass = 1.989e30;
  static const double earthMass = 5.972e24;
  static const double au = 1.496e11; // Astronomical Unit in meters
  
  AdvancedUniverseGenerator(this.seed) 
    : random = Random(seed),
      perlinNoise = PerlinNoise(seed: seed),
      simplexNoise = SimplexNoise(seed: seed);

  Universe generateUniverse({
    int galaxyCount = 100,
    double universeSize = 1e22, // 10 million light years
  }) {
    final galaxies = <Galaxy>[];
    
    // Generate galaxy clusters using Voronoi tessellation
    final clusterCenters = _generateClusterCenters(galaxyCount ~/ 10);
    
    for (int i = 0; i < galaxyCount; i++) {
      final position = _generateGalaxyPosition(universeSize, clusterCenters);
      final galaxy = _generateGalaxy(position, i);
      galaxies.add(galaxy);
    }
    
    // Generate intergalactic medium
    final intergalacticMedium = _generateIntergalacticMedium(universeSize);
    
    // Generate dark matter distribution
    final darkMatterDistribution = _generateDarkMatterDistribution(universeSize);
    
    return Universe(
      seed: seed,
      size: universeSize,
      galaxies: galaxies,
      intergalacticMedium: intergalacticMedium,
      darkMatterDistribution: darkMatterDistribution,
      age: _calculateUniverseAge(),
      expansionRate: _calculateExpansionRate(),
    );
  }

  List<Vector3> _generateClusterCenters(int clusterCount) {
    final centers = <Vector3>[];
    
    for (int i = 0; i < clusterCount; i++) {
      final theta = random.nextDouble() * 2 * pi;
      final phi = acos(2 * random.nextDouble() - 1);
      final r = pow(random.nextDouble(), 1/3) * 1e21; // Uniform distribution in sphere
      
      centers.add(Vector3(
        r * sin(phi) * cos(theta),
        r * sin(phi) * sin(theta),
        r * cos(phi),
      ));
    }
    
    return centers;
  }

  Vector3 _generateGalaxyPosition(double universeSize, List<Vector3> clusterCenters) {
    // Find nearest cluster center
    final clusterIndex = random.nextInt(clusterCenters.length);
    final clusterCenter = clusterCenters[clusterIndex];
    
    // Generate position near cluster center with Gaussian distribution
    final sigma = universeSize / 50; // Cluster size
    final offset = Vector3(
      _gaussianRandom() * sigma,
      _gaussianRandom() * sigma,
      _gaussianRandom() * sigma,
    );
    
    return clusterCenter + offset;
  }

  Galaxy _generateGalaxy(Vector3 position, int index) {
    final galaxyType = _determineGalaxyType();
    final mass = _generateGalaxyMass(galaxyType);
    final age = _generateGalaxyAge();
    final metallicity = _calculateMetallicity(age);
    
    // Generate spiral arms for spiral galaxies
    final spiralArms = galaxyType == GalaxyType.spiral 
        ? _generateSpiralArms() 
        : <SpiralArm>[];
    
    // Generate stars
    final stars = _generateStars(position, mass, galaxyType, spiralArms);
    
    // Generate central black hole
    final blackHole = _generateBlackHole(mass);
    
    // Generate dark matter halo
    final darkMatterHalo = _generateDarkMatterHalo(mass);
    
    return Galaxy(
      id: 'galaxy_$index',
      position: position,
      type: galaxyType,
      mass: mass,
      age: age,
      metallicity: metallicity,
      stars: stars,
      spiralArms: spiralArms,
      blackHole: blackHole,
      darkMatterHalo: darkMatterHalo,
      rotationCurve: _calculateRotationCurve(mass, stars),
    );
  }

  GalaxyType _determineGalaxyType() {
    final roll = random.nextDouble();
    if (roll < 0.6) return GalaxyType.spiral;
    if (roll < 0.8) return GalaxyType.elliptical;
    if (roll < 0.95) return GalaxyType.irregular;
    return GalaxyType.lenticular;
  }

  double _generateGalaxyMass(GalaxyType type) {
    switch (type) {
      case GalaxyType.spiral:
        return _logNormalRandom(12, 0.5) * solarMass; // 10^12 solar masses
      case GalaxyType.elliptical:
        return _logNormalRandom(12.5, 0.6) * solarMass;
      case GalaxyType.irregular:
        return _logNormalRandom(10, 0.5) * solarMass;
      case GalaxyType.lenticular:
        return _logNormalRandom(11.5, 0.4) * solarMass;
    }
  }

  double _generateGalaxyAge() {
    // Universe age is ~13.8 billion years
    return 13.8 * random.nextDouble(); // billion years
  }

  double _calculateMetallicity(double age) {
    // Metallicity increases with age (simplified)
    return 0.001 + (age / 13.8) * 0.03; // Z = 0.001 to 0.03
  }

  List<SpiralArm> _generateSpiralArms() {
    final armCount = random.nextInt(3) + 2; // 2-4 arms
    final arms = <SpiralArm>[];
    
    for (int i = 0; i < armCount; i++) {
      final pitchAngle = random.nextDouble() * 30 + 10; // 10-40 degrees
      final winding = random.nextDouble() * 0.5 + 0.3; // 0.3-0.8
      final armWidth = random.nextDouble() * 0.2 + 0.1; // 0.1-0.3
      
      arms.add(SpiralArm(
        id: 'arm_$i',
        pitchAngle: pitchAngle,
        winding: winding,
        width: armWidth,
        starDensity: random.nextDouble() * 0.5 + 0.5,
      ));
    }
    
    return arms;
  }

  List<Star> _generateStars(
    Vector3 galaxyPosition, 
    double galaxyMass, 
    GalaxyType galaxyType,
    List<SpiralArm> spiralArms,
  ) {
    final starCount = (galaxyMass / (2 * solarMass)).round(); // Average star mass
    final stars = <Star>[];
    
    for (int i = 0; i < min(starCount, 10000); i++) { // Limit for performance
      final position = _generateStarPosition(galaxyPosition, galaxyType, spiralArms);
      final mass = _generateStarMass();
      final age = _generateStarAge();
      final metallicity = _generateStarMetallicity(age, galaxyType);
      final type = _determineStarType(mass, metallicity);
      
      // Generate planetary system
      final planets = random.nextDouble() < 0.4 
          ? _generatePlanetarySystem(mass, position) 
          : <Planet>[];
      
      stars.add(Star(
        id: 'star_${galaxyPosition}_$i',
        position: position,
        mass: mass,
        age: age,
        metallicity: metallicity,
        type: type,
        luminosity: _calculateLuminosity(mass, type) as double,
        temperature: _calculateTemperature(mass, type),
        planets: planets,
        habitableZone: _calculateHabitableZone(_determinePlanetType(position.length, mass, mass), mass, null, age),
      ));
    }
    
    return stars;
  }

  Vector3 _generateStarPosition(
    Vector3 galaxyPosition, 
    GalaxyType galaxyType,
    List<SpiralArm> spiralArms,
  ) {
    switch (galaxyType) {
      case GalaxyType.spiral:
        return _generateSpiralPosition(galaxyPosition, spiralArms);
      case GalaxyType.elliptical:
        return _generateEllipticalPosition(galaxyPosition);
      case GalaxyType.irregular:
        return _generateIrregularPosition(galaxyPosition);
      case GalaxyType.lenticular:
        return _generateLenticularPosition(galaxyPosition);
    }
  }

  Vector3 _generateSpiralPosition(Vector3 galaxyPosition, List<SpiralArm> arms) {
    if (arms.isEmpty) {
      return _generateEllipticalPosition(galaxyPosition);
    }
    
    final arm = arms[random.nextInt(arms.length)];
    final distance = _exponentialRandom(3000); // pc from center
    final angle = _logSpiralAngle(distance, arm.pitchAngle, arm.winding);
    
    // Add scatter around arm
    final scatter = _gaussianRandom() * arm.width * distance;
    
    final x = galaxyPosition.x + distance * cos(angle) + scatter * cos(angle + pi/2);
    final y = galaxyPosition.y + distance * sin(angle) + scatter * sin(angle + pi/2);
    final z = galaxyPosition.z + _gaussianRandom() * 100; // Thin disk
    
    return Vector3(x, y, z);
  }

  Vector3 _generateEllipticalPosition(Vector3 galaxyPosition) {
    // Elliptical galaxies have de Vaucouleurs profile
    final r = _deVaucouleursRandom();
    final theta = random.nextDouble() * 2 * pi;
    final phi = acos(2 * random.nextDouble() - 1);
    
    return Vector3(
      galaxyPosition.x + r * sin(phi) * cos(theta),
      galaxyPosition.y + r * sin(phi) * sin(theta),
      galaxyPosition.z + r * cos(phi),
    );
  }

  Vector3 _generateIrregularPosition(Vector3 galaxyPosition) {
    // Irregular galaxies have clumpy distribution
    final clusterIndex = random.nextInt(5);
    final clusterCenter = Vector3(
      _gaussianRandom() * 2000,
      _gaussianRandom() * 2000,
      _gaussianRandom() * 500,
    );
    
    final r = _exponentialRandom(300);
    final theta = random.nextDouble() * 2 * pi;
    final phi = acos(2 * random.nextDouble() - 1);
    
    return Vector3(
      galaxyPosition.x + clusterCenter.x + r * sin(phi) * cos(theta),
      galaxyPosition.y + clusterCenter.y + r * sin(phi) * sin(theta),
      galaxyPosition.z + clusterCenter.z + r * cos(phi),
    );
  }

  Vector3 _generateLenticularPosition(Vector3 galaxyPosition) {
    // Lenticular galaxies have disk + bulge
    final isBulge = random.nextDouble() < 0.3;
    
    if (isBulge) {
      return _generateEllipticalPosition(galaxyPosition);
    } else {
      final r = _exponentialRandom(2000);
      final theta = random.nextDouble() * 2 * pi;
      final z = _gaussianRandom() * 50; // Very thin disk
      
      return Vector3(
        galaxyPosition.x + r * cos(theta),
        galaxyPosition.y + r * sin(theta),
        galaxyPosition.z + z,
      );
    }
  }

  double _generateStarMass() {
    // Initial Mass Function (IMF) - Salpeter
    return _powerLawRandom(0.08, 100, -2.35) * solarMass;
  }

  double _generateStarAge() {
    // Star formation rate varies over time
    return 13.8 * pow(random.nextDouble(), 2); // billion years
  }

  double _generateStarMetallicity(double age, GalaxyType galaxyType) {
    // Metallicity depends on age and galaxy type
    final baseMetallicity = galaxyType == GalaxyType.elliptical ? 0.02 : 0.01;
    return baseMetallicity * (1 - age / 13.8) + _gaussianRandom() * 0.005;
  }

  StarType _determineStarType(double mass, double metallicity) {
    // Hertzsprung-Russell diagram classification
    if (mass > 16 * solarMass) return StarType.o;
    if (mass > 2.1 * solarMass) return StarType.b;
    if (mass > 1.4 * solarMass) return StarType.a;
    if (mass > 1.04 * solarMass) return StarType.f;
    if (mass > 0.8 * solarMass) return StarType.g;
    if (mass > 0.45 * solarMass) return StarType.k;
    return StarType.m;
  }

  num _calculateLuminosity(double mass, StarType type) {
    // Mass-luminosity relation
    if (mass < 0.43 * solarMass) {
      return 0.23 * pow(mass / solarMass, 2.3);
    } else if (mass < 2 * solarMass) {
      return pow(mass / solarMass, 4);
    } else if (mass < 20 * solarMass) {
      return 1.5 * pow(mass / solarMass, 3.5);
    } else {
      return 3200 * mass / solarMass;
    }
  }

  double _calculateTemperature(double mass, StarType type) {
    // Mass-temperature relation
    switch (type) {
      case StarType.o: return 30000 + random.nextDouble() * 20000;
      case StarType.b: return 10000 + random.nextDouble() * 20000;
      case StarType.a: return 7500 + random.nextDouble() * 2500;
      case StarType.f: return 6000 + random.nextDouble() * 1500;
      case StarType.g: return 5200 + random.nextDouble() * 800;
      case StarType.k: return 3700 + random.nextDouble() * 1500;
      case StarType.m: return 2400 + random.nextDouble() * 1300;
    }
  }

  List<Planet> _generatePlanetarySystem(double starMass, Vector3 starPosition) {
    final planetCount = _poissonRandom(3); // Average 3 planets
    final planets = <Planet>[];
    
    for (int i = 0; i < planetCount; i++) {
      final semiMajorAxis = _generateOrbitalRadius(i, planetCount);
      final eccentricity = random.nextDouble() * 0.3;
      final inclination = random.nextDouble() * 0.1;
      final mass = _generatePlanetMass(semiMajorAxis, starMass);
      final radius = _calculatePlanetRadius(mass);
      final type = _determinePlanetType(semiMajorAxis, mass, starMass);
      
      // Generate atmosphere
      final atmosphere = random.nextDouble() < 0.7 
          ? _generateAtmosphere(type, mass) 
          : null;
      
      // Generate moons
      final moons = mass > 0.1 * earthMass && random.nextDouble() < 0.5
          ? _generateMoons(mass)
          : <Moon>[];
      
      // Generate rings
      final rings = (type == PlanetType.gasGiant || type == PlanetType.iceGiant) &&
                   random.nextDouble() < 0.3
          ? _generateRings()
          : null;
      
      planets.add(Planet(
        id: 'planet_${starPosition}_$i',
        starPosition: starPosition,
        semiMajorAxis: semiMajorAxis,
        eccentricity: eccentricity,
        inclination: inclination,
        mass: mass,
        radius: radius,
        type: type,
        atmosphere: atmosphere,
        moons: moons,
        rings: rings,
        orbitalPeriod: _calculateOrbitalPeriod(semiMajorAxis, starMass),
        rotationPeriod: _generateRotationPeriod(type),
        axialTilt: random.nextDouble() * 180,
        albedo: _generateAlbedo(type),
        surfaceTemperature: _calculateSurfaceTemperature(
          semiMajorAxis, 
          starMass, 
          atmosphere,
          albedo: 0.3,
        ) as double,
        habitability: _calculateHabitability(
          type,
          mass,
          atmosphere,
          surfaceTemperature: 0,
        ),
      ));
    }
    
    return planets;
  }

  double _generateOrbitalRadius(int index, int totalPlanets) {
    // Titius-Bode law with variation
    final baseDistance = 0.4 * au;
    final bodeConstant = 0.3 * au;
    final distance = baseDistance + bodeConstant * pow(2, index);
    return distance * (0.8 + random.nextDouble() * 0.4); // ±20% variation
  }

  double _generatePlanetMass(double orbitalRadius, double starMass) {
    // Planet mass depends on distance from star (snow line)
    final snowLine = 2.7 * au * pow(starMass / solarMass, 2);
    
    if (orbitalRadius < snowLine) {
      // Rocky planet
      return _logNormalRandom(0.3, 0.5) * earthMass;
    } else {
      // Gas/ice giant
      return _logNormalRandom(1.5, 0.8) * earthMass;
    }
  }

  double _calculatePlanetRadius(double mass) {
    // Mass-radius relationship
    if (mass < 0.5 * earthMass) {
      return pow(mass / earthMass, 0.27) * 6371; // km
    } else if (mass < 2 * earthMass) {
      return pow(mass / earthMass, 0.3) * 6371;
    } else if (mass < 100 * earthMass) {
      return pow(mass / earthMass, 0.5) * 6371;
    } else {
      return pow(mass / earthMass, 0.1) * 6371;
    }
  }

  PlanetType _determinePlanetType(double orbitalRadius, double mass, double starMass) {
    final snowLine = 2.7 * au * pow(starMass / solarMass, 2);
    
    if (orbitalRadius < 0.5 * au) {
      return PlanetType.chthonian;
    } else if (orbitalRadius < snowLine) {
      if (mass < 0.1 * earthMass) {
        return PlanetType.terranoid;
      } else if (mass < 2 * earthMass) {
        return PlanetType.terrestrial;
      } else {
        return PlanetType.superEarth;
      }
    } else {
      if (mass < 10 * earthMass) {
        return PlanetType.neptuneLike;
      } else if (mass < 50 * earthMass) {
        return PlanetType.iceGiant;
      } else {
        return PlanetType.gasGiant;
      }
    }
  }

  Atmosphere _generateAtmosphere(PlanetType type, double mass) {
    // Atmosphere composition depends on planet type and mass
    switch (type) {
      case PlanetType.terrestrial:
      case PlanetType.superEarth:
        if (mass > 0.5 * earthMass) {
          return Atmosphere(
            composition: {
              'N2': 0.78,
              'O2': 0.21,
              'Ar': 0.01,
            },
            pressure: _logNormalRandom(1, 0.5), // bar
            hasWaterVapor: true,
            hasOzone: true,
          );
        }
        break;
      case PlanetType.gasGiant:
        return Atmosphere(
          composition: {
            'H2': 0.90,
            'He': 0.10,
          },
          pressure: 1000, // bar
          hasWaterVapor: false,
          hasOzone: false,
        );
      case PlanetType.iceGiant:
        return Atmosphere(
          composition: {
            'H2': 0.80,
            'He': 0.19,
            'CH4': 0.01,
          },
          pressure: 100, // bar
          hasWaterVapor: false,
          hasOzone: false,
        );
      case PlanetType.chthonian:
        return Atmosphere(
          composition: {'CO2': 0.95, 'N2': 0.05},
          pressure: 0.01, // bar
          hasWaterVapor: false,
          hasOzone: false,
        );
      case PlanetType.terranoid:
        return Atmosphere(
          composition: {'CO2': 0.95, 'N2': 0.05},
          pressure: 0.01, // bar
          hasWaterVapor: false,
          hasOzone: false,
        );
      case PlanetType.neptuneLike:
        return Atmosphere(
          composition: {'N2': 0.78, 'O2': 0.21, 'Ar': 0.01},
          pressure: _logNormalRandom(1, 0.5), // bar
          hasWaterVapor: true,
          hasOzone: true,
        );
    }
    
    return Atmosphere(
      composition: {'CO2': 0.95, 'N2': 0.05},
      pressure: 0.01, // bar
      hasWaterVapor: false,
      hasOzone: false,
    );
  }

  List<Moon> _generateMoons(double planetMass) {
    final moonCount = min(_poissonRandom(planetMass / earthMass), 20);
    final moons = <Moon>[];
    
    for (int i = 0; i < moonCount; i++) {
      final orbitalRadius = 10000 + i * 5000 + random.nextDouble() * 10000; // km
      final mass = _logNormalRandom(-2, 0.5) * earthMass;
      
      moons.add(Moon(
        id: 'moon_$i',
        orbitalRadius: orbitalRadius,
        mass: mass,
        radius: _calculatePlanetRadius(mass),
        orbitalPeriod: _calculateOrbitalPeriod(orbitalRadius * 1000, planetMass),
        tidallyLocked: orbitalRadius < 100000, // km
      ));
    }
    
    return moons;
  }

  PlanetaryRings? _generateRings() {
    if (random.nextDouble() < 0.3) {
      return PlanetaryRings(
        innerRadius: 50000 + random.nextDouble() * 50000, // km
        outerRadius: 100000 + random.nextDouble() * 100000, // km
        thickness: random.nextDouble() * 100, // km
        composition: _determineRingComposition(),
        opacity: random.nextDouble() * 0.8 + 0.1,
      );
    }
    return null;
  }

  Map<String, double> _determineRingComposition() {
    final roll = random.nextDouble();
    if (roll < 0.5) {
      return {'ice': 0.9, 'rock': 0.1};
    } else if (roll < 0.8) {
      return {'ice': 0.5, 'rock': 0.5};
    } else {
      return {'rock': 0.9, 'ice': 0.1};
    }
  }

  // Utility methods for random distributions
  double _gaussianRandom() {
    // Box-Muller transform
    double u1 = random.nextDouble();
    double u2 = random.nextDouble();
    return sqrt(-2.0 * log(u1)) * cos(2.0 * pi * u2);
  }

  double _logNormalRandom(double mean, double stdDev) {
    return exp(mean + stdDev * _gaussianRandom());
  }

  double _exponentialRandom(double mean) {
    return -mean * log(1 - random.nextDouble());
  }

  num _powerLawRandom(double min, double max, double exponent) {
    return pow(
      (pow(max, exponent + 1) - pow(min, exponent + 1)) * random.nextDouble() + 
      pow(min, exponent + 1),
      1 / (exponent + 1)
    );
  }

  int _poissonRandom(double mean) {
    final L = exp(-mean);
    int k = 0;
    double p = 1.0;
    
    do {
      k++;
      p *= random.nextDouble();
    } while (p > L);
    
    return k - 1;
  }

  num _deVaucouleursRandom() {
    // de Vaucouleurs profile for elliptical galaxies
    return 1000 * pow(-log(random.nextDouble()), 4); // pc
  }

  double _logSpiralAngle(double r, double pitchAngle, double winding) {
    // Logarithmic spiral
    final k = tan(pitchAngle * pi / 180);
    return winding * log(r / 100) / k;
  }

  // Additional physics calculations
  double _calculateOrbitalPeriod(double semiMajorAxis, double centralMass) {
    // Kepler's third law
    return 2 * pi * sqrt(pow(semiMajorAxis, 3) / (gravitationalConstant * centralMass));
  }

  num _calculateSurfaceTemperature(
    double orbitalRadius,
    double starMass,
    Atmosphere? atmosphere, {
    double albedo = 0.3,
  }) {
    // Effective temperature
    final starLuminosity = _calculateLuminosity(starMass, StarType.g);
    final effectiveTemp = pow(
      (1 - albedo) * starLuminosity / (16 * pi * pow(orbitalRadius, 2) * 5.67e-8),
      0.25,
    );
    
    // Greenhouse effect
    if (atmosphere != null && atmosphere.hasWaterVapor) {
      return effectiveTemp * 1.2; // Simplified greenhouse effect
    }
    
    return effectiveTemp;
  }

  HabitableZone _calculateHabitableZone(
    PlanetType type,
    double mass,
    Atmosphere? atmosphere,
    double surfaceTemperature,
  ) {
    // Complex habitability calculation
    double habitability = 0.0;
    
    // Planet type
    switch (type) {
      case PlanetType.terrestrial:
      case PlanetType.superEarth:
        habitability += 0.3;
        break;
      case PlanetType.terranoid:
        habitability += 0.1;
        break;
      default:
        return HabitableZone(innerRadius: 0, outerRadius: 0);
    }
    
    // Mass (Earth-like is best)
    if (mass >= 0.5 * earthMass && mass <= 5 * earthMass) {
      habitability += 0.2;
    }
    
    // Atmosphere
    if (atmosphere != null) {
      if (atmosphere.hasWaterVapor && atmosphere.hasOzone) {
        habitability += 0.3;
      }
      
      // Pressure
      if (atmosphere.pressure >= 0.5 && atmosphere.pressure <= 2) {
        habitability += 0.1;
      }
    }
    
    // Temperature
    if (surfaceTemperature >= 273 && surfaceTemperature <= 373) {
      habitability += 0.1;
    }
    
    return HabitableZone(
      innerRadius: habitability.clamp(0.0, 1.0),
      outerRadius: habitability.clamp(1.0, 0.0),
    );
  }

  double _generateRotationPeriod(PlanetType type) {
    switch (type) {
      case PlanetType.terrestrial:
      case PlanetType.superEarth:
        return 0.5 + random.nextDouble() * 2; // 0.5-2.5 days
      case PlanetType.gasGiant:
      case PlanetType.iceGiant:
        return 0.3 + random.nextDouble() * 0.7; // 0.3-1 day
      case PlanetType.chthonian:
        return random.nextDouble() * 100; // Tidally locked
      default:
        return 1 + random.nextDouble() * 10; // 1-11 days
    }
  }

  double _generateAlbedo(PlanetType type) {
    switch (type) {
      case PlanetType.terrestrial:
        return 0.1 + random.nextDouble() * 0.3;
      case PlanetType.gasGiant:
        return 0.3 + random.nextDouble() * 0.4;
      case PlanetType.iceGiant:
        return 0.4 + random.nextDouble() * 0.4;
      default:
        return 0.1 + random.nextDouble() * 0.2;
    }
  }

  // Additional methods for universe generation
  IntergalacticMedium _generateIntergalacticMedium(double universeSize) {
    return IntergalacticMedium(
      temperature: 2.725, // CMB temperature
      density: 1e-27, // kg/m³
      composition: {
        'H': 0.75,
        'He': 0.25,
        'Li': 1e-10,
      },
      ionizationFraction: 0.9,
    );
  }

  DarkMatterDistribution _generateDarkMatterDistribution(double universeSize) {
    // NFW profile for dark matter
    return DarkMatterDistribution(
      profileType: DarkMatterProfile.nfw,
      scaleRadius: universeSize / 100,
      density: 1e-26, // kg/m³
      particles: _generateDarkMatterParticles(),
    );
  }

  List<DarkMatterParticle> _generateDarkMatterParticles() {
    final particles = <DarkMatterParticle>[];
    final particleCount = 1000;
    
    for (int i = 0; i < particleCount; i++) {
      particles.add(DarkMatterParticle(
        position: Vector3(
          _gaussianRandom() * 1e20,
          _gaussianRandom() * 1e20,
          _gaussianRandom() * 1e20,
        ),
        velocity: Vector3(
          _gaussianRandom() * 1000,
          _gaussianRandom() * 1000,
          _gaussianRandom() * 1000,
        ),
        mass: 1e-22, // kg (WIMP mass estimate)
      ));
    }
    
    return particles;
  }

  BlackHole _generateBlackHole(double galaxyMass) {
    final blackHoleMass = galaxyMass * 0.001; // 0.1% of galaxy mass
    final schwarzschildRadius = 2 * gravitationalConstant * blackHoleMass / pow(speedOfLight, 2);
    
    return BlackHole(
      mass: blackHoleMass,
      radius: schwarzschildRadius,
      accretionDisk: random.nextDouble() < 0.7,
      jet: random.nextDouble() < 0.3,
      spin: random.nextDouble(),
    );
  }

  DarkMatterHalo _generateDarkMatterHalo(double galaxyMass) {
    return DarkMatterHalo(
      mass: galaxyMass * 5, // Dark matter is ~5x baryonic matter
      scaleRadius: 10000, // pc
      concentration: 10,
    );
  }

  RotationCurve _calculateRotationCurve(double galaxyMass, List<Star> stars) {
    final radii = <double>[];
    final velocities = <double>[];
    
    for (double r = 100; r <= 50000; r *= 1.5) {
      // Calculate enclosed mass
      double enclosedMass = 0;
      for (final star in stars) {
        final distance = star.position.length;
        if (distance <= r) {
          enclosedMass += star.mass;
        }
      }
      
      // Add dark matter contribution
      enclosedMass += galaxyMass * 5 * (1 - exp(-r / 10000));
      
      // Calculate orbital velocity
      final velocity = sqrt(gravitationalConstant * enclosedMass / r);
      
      radii.add(r);
      velocities.add(velocity);
    }
    
    return RotationCurve(radii: radii, velocities: velocities);
  }

  double _calculateUniverseAge() {
    return 13.8; // billion years
  }

  double _calculateExpansionRate() {
    return 70; // km/s/Mpc (Hubble constant)
  }
  
  double _calculateHabitability(PlanetType type, double mass, Atmosphere? atmosphere, {required int surfaceTemperature}) {
    switch (type) {
      case PlanetType.terrestrial:
      case PlanetType.superEarth:
        return 0.3;
      case PlanetType.terranoid:
        return 0.1;
      default:
        return 0.0;
    }
  }
}

// Additional classes for the universe model
class Universe {
  final int seed;
  final double size;
  final List<Galaxy> galaxies;
  final IntergalacticMedium intergalacticMedium;
  final DarkMatterDistribution darkMatterDistribution;
  final double age;
  final double expansionRate;
  
  Universe({
    required this.seed,
    required this.size,
    required this.galaxies,
    required this.intergalacticMedium,
    required this.darkMatterDistribution,
    required this.age,
    required this.expansionRate,
  });
}

class Galaxy {
  final String id;
  final Vector3 position;
  final GalaxyType type;
  final double mass;
  final double age;
  final double metallicity;
  final List<Star> stars;
  final List<SpiralArm> spiralArms;
  final BlackHole blackHole;
  final DarkMatterHalo darkMatterHalo;
  final RotationCurve rotationCurve;
  
  Galaxy({
    required this.id,
    required this.position,
    required this.type,
    required this.mass,
    required this.age,
    required this.metallicity,
    required this.stars,
    required this.spiralArms,
    required this.blackHole,
    required this.darkMatterHalo,
    required this.rotationCurve,
  });
}

enum GalaxyType {
  spiral,
  elliptical,
  irregular,
  lenticular,
}

class SpiralArm {
  final String id;
  final double pitchAngle;
  final double winding;
  final double width;
  final double starDensity;
  
  SpiralArm({
    required this.id,
    required this.pitchAngle,
    required this.winding,
    required this.width,
    required this.starDensity,
  });
}

class Star {
  final String id;
  final Vector3 position;
  final double mass;
  final double age;
  final double metallicity;
  final StarType type;
  final double luminosity;
  final double temperature;
  final List<Planet> planets;
  final HabitableZone habitableZone;

  var name;
  
  Star({
    required this.id,
    required this.position,
    required this.mass,
    required this.age,
    required this.metallicity,
    required this.type,
    required this.luminosity,
    required this.temperature,
    required this.planets,
    required this.habitableZone,
  });
}

enum StarType {
  o, b, a, f, g, k, m,
}

class Planet {
  final String id;
  final Vector3 starPosition;
  final double semiMajorAxis;
  final double eccentricity;
  final double inclination;
  final double mass;
  final double radius;
  final PlanetType type;
  final Atmosphere? atmosphere;
  final List<Moon> moons;
  final PlanetaryRings? rings;
  final double orbitalPeriod;
  final double rotationPeriod;
  final double axialTilt;
  final double albedo;
  final double surfaceTemperature;
  final double habitability;
  
  Planet({
    required this.id,
    required this.starPosition,
    required this.semiMajorAxis,
    required this.eccentricity,
    required this.inclination,
    required this.mass,
    required this.radius,
    required this.type,
    this.atmosphere,
    required this.moons,
    this.rings,
    required this.orbitalPeriod,
    required this.rotationPeriod,
    required this.axialTilt,
    required this.albedo,
    required this.surfaceTemperature,
    required this.habitability,
  });
}

enum PlanetType {
  chthonian,
  terranoid,
  terrestrial,
  superEarth,
  neptuneLike,
  iceGiant,
  gasGiant,
}

class Atmosphere {
  final Map<String, double> composition;
  final double pressure;
  final bool hasWaterVapor;
  final bool hasOzone;
  
  Atmosphere({
    required this.composition,
    required this.pressure,
    required this.hasWaterVapor,
    required this.hasOzone,
  });
}

class Moon {
  final String id;
  final double orbitalRadius;
  final double mass;
  final double radius;
  final double orbitalPeriod;
  final bool tidallyLocked;
  
  Moon({
    required this.id,
    required this.orbitalRadius,
    required this.mass,
    required this.radius,
    required this.orbitalPeriod,
    required this.tidallyLocked,
  });
}

class PlanetaryRings {
  final double innerRadius;
  final double outerRadius;
  final double thickness;
  final Map<String, double> composition;
  final double opacity;
  
  PlanetaryRings({
    required this.innerRadius,
    required this.outerRadius,
    required this.thickness,
    required this.composition,
    required this.opacity,
  });
}

class HabitableZone {
  final double innerRadius;
  final double outerRadius;
  
  HabitableZone({
    required this.innerRadius,
    required this.outerRadius,
  });
}

class IntergalacticMedium {
  final double temperature;
  final double density;
  final Map<String, double> composition;
  final double ionizationFraction;
  
  IntergalacticMedium({
    required this.temperature,
    required this.density,
    required this.composition,
    required this.ionizationFraction,
  });
}

class DarkMatterDistribution {
  final DarkMatterProfile profileType;
  final double scaleRadius;
  final double density;
  final List<DarkMatterParticle> particles;
  
  DarkMatterDistribution({
    required this.profileType,
    required this.scaleRadius,
    required this.density,
    required this.particles,
  });
}

enum DarkMatterProfile {
  nfw,
  einasto,
  isothermal,
}

class DarkMatterParticle {
  final Vector3 position;
  final Vector3 velocity;
  final double mass;
  
  DarkMatterParticle({
    required this.position,
    required this.velocity,
    required this.mass,
  });
}

class BlackHole {
  final double mass;
  final double radius;
  final bool accretionDisk;
  final bool jet;
  final double spin;
  
  BlackHole({
    required this.mass,
    required this.radius,
    required this.accretionDisk,
    required this.jet,
    required this.spin,
  });
}

class DarkMatterHalo {
  final double mass;
  final double scaleRadius;
  final double concentration;
  
  DarkMatterHalo({
    required this.mass,
    required this.scaleRadius,
    required this.concentration,
  });
}

class RotationCurve {
  final List<double> radii;
  final List<double> velocities;
  
  RotationCurve({
    required this.radii,
    required this.velocities,
  });
}