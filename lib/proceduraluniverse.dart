import 'dart:math';

import 'package:spaceverse/models.dart';

class ProceduralUniverse {
  final int seed;
  final Random random;

  var galaxies;
  
  ProceduralUniverse(this.seed) : random = Random(seed);
  
  Galaxy generateGalaxy() {
    // Mandelbrot-inspired galaxy generation
    final galaxyCenter = Point<double>(random.nextDouble() * 1000, random.nextDouble() * 1000);
    final spiralArms = random.nextInt(5) + 2;
    final starDensity = _calculateStarDensity(galaxyCenter);
    
    return Galaxy(
      center: galaxyCenter,
      spiralArms: spiralArms,
      starDensity: starDensity,
      stars: _generateStars(galaxyCenter, spiralArms, starDensity),
    );
  }
  
  double _calculateStarDensity(Point<double> center) {
    // Use fractal noise to determine star density
    return PerlinNoise.noise(center.x / 100, center.y / 100, seed) * 0.5 + 0.5;
  }
  
  List<Star> _generateStars(Point<double> center, int arms, double density) {
    // Generate stars along spiral arms using mathematical formulas
    final stars = <Star>[];
    final starsPerArm = (density * 1000).toInt();
    
    for (int arm = 0; arm < arms; arm++) {
      final armAngle = (2 * pi / arms) * arm;
      
      for (int i = 0; i < starsPerArm; i++) {
        final distance = i * 0.5 + random.nextDouble() * 2;
        final angle = armAngle + (i * 0.1) + (random.nextDouble() - 0.5) * 0.2;
        
        final x = center.x + distance * cos(angle);
        final y = center.y + distance * sin(angle);
        
        // Determine star type based on position and random factors
        final starType = _determineStarType(distance, random.nextDouble());
        
        // Generate planetary system if conditions are right
        final hasPlanets = random.nextDouble() < 0.3;
        final planets = hasPlanets ? _generatePlanetarySystem(starType) : <Planet>[];
        
        stars.add(Star(
          position: Point<double>(x, y),
          type: starType,
          planets: planets,
        ));
      }
    }
    
    return stars;
  }
  
  StarType _determineStarType(double distanceFromCenter, double randomFactor) {
    // Star type distribution based on distance from galaxy center
    if (distanceFromCenter < 100) {
      return randomFactor < 0.7 ? StarType.redGiant : StarType.blueSupergiant;
    } else if (distanceFromCenter < 300) {
      final rand = randomFactor;
      if (rand < 0.6) return StarType.yellowDwarf;
      if (rand < 0.8) return StarType.redDwarf;
      return StarType.whiteDwarf;
    } else {
      return randomFactor < 0.8 ? StarType.redDwarf : StarType.whiteDwarf;
    }
  }
  
  List<Planet> _generatePlanetarySystem(StarType starType) {
    final planetCount = random.nextInt(8) + 1;
    final planets = <Planet>[];
    
    for (int i = 0; i < planetCount; i++) {
      final distance = (i + 1) * 50 + random.nextDouble() * 20;
      final size = random.nextDouble() * 5 + 0.5;
      final hasAtmosphere = random.nextDouble() < 0.6;
      final habitability = _calculateHabitability(starType, distance, size, hasAtmosphere);
      
      // Generate biome data based on habitability and other factors
      final biomes = hasAtmosphere ? _generateBiomes(habitability) : <Biome>[];
      
      planets.add(Planet(
        orbitalDistance: distance,
        size: size,
        hasAtmosphere: hasAtmosphere,
        habitability: habitability,
        biomes: biomes,
        // Additional properties for exoplanet detection
        transitDepth: _calculateTransitDepth(size, starType),
        orbitalPeriod: _calculateOrbitalPeriod(distance, starType),
        transitDuration: _calculateTransitDuration(distance, starType),
      ));
    }
    
    return planets;
  }
  
  double _calculateHabitability(StarType starType, double distance, double size, bool hasAtmosphere) {
    // Simplified habitability calculation based on star type, distance, size, and atmosphere
    double habitability = 0.0;
    
    // Goldilocks zone calculation based on star type
    double goldilocksInner, goldilocksOuter;
    switch (starType) {
      case StarType.redDwarf:
        goldilocksInner = 20;
        goldilocksOuter = 80;
        break;
      case StarType.yellowDwarf:
        goldilocksInner = 80;
        goldilocksOuter = 150;
        break;
      case StarType.blueSupergiant:
        goldilocksInner = 200;
        goldilocksOuter = 400;
        break;
      case StarType.redGiant:
        goldilocksInner = 150;
        goldilocksOuter = 300;
        break;
      case StarType.whiteDwarf:
        goldilocksInner = 10;
        goldilocksOuter = 30;
        break;
    }
    
    // Check if planet is in habitable zone
    if (distance >= goldilocksInner && distance <= goldilocksOuter) {
      habitability += 0.5;
    }
    
    // Size factor (Earth-like size is best)
    if (size >= 0.8 && size <= 1.5) {
      habitability += 0.3;
    } else if (size >= 0.5 && size <= 2.0) {
      habitability += 0.1;
    }
    
    // Atmosphere factor
    if (hasAtmosphere) {
      habitability += 0.2;
    }
    
    return habitability.clamp(0.0, 1.0);
  }
  
  List<Biome> _generateBiomes(double habitability) {
    final biomes = <Biome>[];
    final biomeCount = (habitability * 5).toInt() + 1;
    
    for (int i = 0; i < biomeCount; i++) {
      // Generate biome based on habitability and random factors
      final biomeType = _determineBiomeType(habitability, random.nextDouble());
      final temperature = _generateTemperature(biomeType, random.nextDouble());
      final humidity = _generateHumidity(biomeType, random.nextDouble());
      final biodiversity = _calculateBiodiversity(habitability, biomeType, temperature, humidity);
      
      biomes.add(Biome(
        type: biomeType,
        temperature: temperature,
        humidity: humidity,
        biodiversity: biodiversity,
      ));
    }
    
    return biomes;
  }
  
  BiomeType _determineBiomeType(double habitability, double randomFactor) {
    if (habitability < 0.3) {
      return BiomeType.barren;
    } else if (habitability < 0.6) {
      return randomFactor < 0.5 ? BiomeType.desert : BiomeType.tundra;
    } else {
      final rand = randomFactor;
      if (rand < 0.3) return BiomeType.forest;
      if (rand < 0.6) return BiomeType.ocean;
      if (rand < 0.8) return BiomeType.grassland;
      return BiomeType.wetland;
    }
  }
  
  double _generateTemperature(BiomeType biomeType, double randomFactor) {
    switch (biomeType) {
      case BiomeType.barren:
        return randomFactor * 100 - 50; // -50 to 50°C
      case BiomeType.desert:
        return randomFactor * 40 + 10; // 10 to 50°C
      case BiomeType.tundra:
        return randomFactor * 30 - 40; // -40 to -10°C
      case BiomeType.forest:
        return randomFactor * 25 - 5; // -5 to 20°C
      case BiomeType.ocean:
        return randomFactor * 30 + 5; // 5 to 35°C
      case BiomeType.grassland:
        return randomFactor * 30 - 10; // -10 to 20°C
      case BiomeType.wetland:
        return randomFactor * 25 + 5; // 5 to 30°C
    }
  }
  
  double _generateHumidity(BiomeType biomeType, double randomFactor) {
    switch (biomeType) {
      case BiomeType.barren:
        return randomFactor * 0.2; // 0 to 20%
      case BiomeType.desert:
        return randomFactor * 0.3; // 0 to 30%
      case BiomeType.tundra:
        return randomFactor * 0.4; // 0 to 40%
      case BiomeType.forest:
        return randomFactor * 0.4 + 0.4; // 40 to 80%
      case BiomeType.ocean:
        return randomFactor * 0.2 + 0.8; // 80 to 100%
      case BiomeType.grassland:
        return randomFactor * 0.4 + 0.2; // 20 to 60%
      case BiomeType.wetland:
        return randomFactor * 0.3 + 0.7; // 70 to 100%
    }
  }
  
  double _calculateBiodiversity(double habitability, BiomeType biomeType, double temperature, double humidity) {
    // Calculate biodiversity based on multiple factors
    double biodiversity = habitability * 0.5;
    
    // Biome type factor
    switch (biomeType) {
      case BiomeType.barren:
        biodiversity += 0.0;
        break;
      case BiomeType.desert:
      case BiomeType.tundra:
        biodiversity += 0.2;
        break;
      case BiomeType.grassland:
        biodiversity += 0.4;
        break;
      case BiomeType.forest:
      case BiomeType.wetland:
        biodiversity += 0.6;
        break;
      case BiomeType.ocean:
        biodiversity += 0.7;
        break;
    }
    
    // Temperature factor (moderate temperatures are better)
    if (temperature >= 10 && temperature <= 25) {
      biodiversity += 0.2;
    } else if (temperature >= 0 && temperature <= 35) {
      biodiversity += 0.1;
    }
    
    // Humidity factor
    if (humidity >= 0.4 && humidity <= 0.8) {
      biodiversity += 0.2;
    } else if (humidity >= 0.2 && humidity <= 0.9) {
      biodiversity += 0.1;
    }
    
    return biodiversity.clamp(0.0, 1.0);
  }
  
  // Methods for calculating exoplanet detection parameters
  double _calculateTransitDepth(double planetSize, StarType starType) {
    // Calculate transit depth based on planet size and star type
    double starRadius;
    switch (starType) {
      case StarType.redDwarf:
        starRadius = 0.5;
        break;
      case StarType.yellowDwarf:
        starRadius = 1.0;
        break;
      case StarType.blueSupergiant:
        starRadius = 5.0;
        break;
      case StarType.redGiant:
        starRadius = 3.0;
        break;
      case StarType.whiteDwarf:
        starRadius = 0.2;
        break;
    }
    
    // Transit depth is proportional to (planet radius / star radius)^2
    return pow(planetSize / starRadius, 2).toDouble() * 100; // in percentage
  }
  
  double _calculateOrbitalPeriod(double distance, StarType starType) {
    // Calculate orbital period using Kepler's third law
    // P^2 = (4π^2/GM) * a^3, simplified for our purposes
    double starMass;
    switch (starType) {
      case StarType.redDwarf:
        starMass = 0.3;
        break;
      case StarType.yellowDwarf:
        starMass = 1.0;
        break;
      case StarType.blueSupergiant:
        starMass = 10.0;
        break;
      case StarType.redGiant:
        starMass = 3.0;
        break;
      case StarType.whiteDwarf:
        starMass = 0.8;
        break;
    }
    
    // Simplified calculation: P ∝ sqrt(a^3/M)
    return sqrt(pow(distance, 3) / starMass) * 10; // in days
  }
  
  double _calculateTransitDuration(double distance, StarType starType) {
    // Calculate transit duration based on orbital distance and star properties
    double starRadius;
    switch (starType) {
      case StarType.redDwarf:
        starRadius = 0.5;
        break;
      case StarType.yellowDwarf:
        starRadius = 1.0;
        break;
      case StarType.blueSupergiant:
        starRadius = 5.0;
        break;
      case StarType.redGiant:
        starRadius = 3.0;
        break;
      case StarType.whiteDwarf:
        starRadius = 0.2;
        break;
    }
    
    // Simplified calculation: duration ∝ star radius / orbital velocity
    final orbitalPeriod = _calculateOrbitalPeriod(distance, starType);
    final orbitalVelocity = 2 * pi * distance / orbitalPeriod;
    
    return (starRadius * 2) / orbitalVelocity * 24; // in hours
  }
}