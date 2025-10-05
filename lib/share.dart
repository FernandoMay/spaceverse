// lib/core/utils/share.dart
import 'package:share_plus/share_plus';
import 'package:spaceverse/features/universe_explorer/domain/entities/planet.dart';
import 'package:spaceverse/features/exoplanet_hunter/domain/entities/exoplanet_data.dart';
import 'package:spaceverse/features/habitat_designer/domain/entities/habitat_design.dart';

class ShareUtils {
  static Future<void> shareExoplanet(ExoplanetData exoplanet) async {
    final text = '''
Check out this exoplanet I discovered with SpaceVerse!

Name: ${exoplanet.name}
Status: ${exoplanet.status.toString().split('.').last}
Orbital Period: ${exoplanet.orbitalPeriod.toStringAsFixed(1)} days
Planet Radius: ${exoplanet.planetRadius.toStringAsFixed(2)} Earth radii
Star Temperature: ${exoplanet.starTemperature.toStringAsFixed(0)} K

Download SpaceVerse to discover your own exoplanets!
https://spaceverse.app/download
    ''';
    
    await Share.share(text.trim(), subject: 'Exoplanet Discovery: ${exoplanet.name}');
  }
  
  static Future<void> sharePlanet(Planet planet) async {
    final text = '''
Explore this amazing planet from SpaceVerse!

Type: ${planet.type.toString().split('.').last}
Orbital Distance: ${planet.orbitalDistance.toStringAsFixed(2)} AU
Size: ${planet.size.toStringAsFixed(2)} Earth radii
Atmosphere: ${planet.hasAtmosphere ? 'Present' : 'Absent'}
Habitability: ${(planet.habitability * 100).toStringAsFixed(1)}%

Biomes: ${planet.biomes.map((b) => b.type.toString().split('.').last).join(', ')}

Download SpaceVerse to explore the universe!
https://spaceverse.app/download
    ''';
    
    await Share.share(text.trim(), subject: 'Planet Exploration');
  }
  
  static Future<void> shareHabitatDesign(HabitatDesign design) async {
    final text = '''
Check out this space habitat I designed with SpaceVerse!

Shape: ${design.shape.toString().split('.').last}
Crew Size: ${design.crewSize}
Mission Duration: ${design.missionDuration} days
Destination: ${design.destination.toString().split('.').last}
Total Volume: ${design.totalVolume.toStringAsFixed(1)} m³
Modules: ${design.modules.length}

Design Score: ${design.validationResult?.score.toStringAsFixed(1) ?? 'N/A'}/100

Download SpaceVerse to design your own habitats!
https://spaceverse.app/download
    ''';
    
    await Share.share(text.trim(), subject: 'Space Habitat Design');
  }
  
  static Future<void> shareUniverse(int seed) async {
    final text = '''
I generated an amazing universe with SpaceVerse using seed: $seed

Every universe is unique and procedurally generated with realistic physics!
Explore galaxies, stars, planets, and discover new exoplanets.

Download SpaceVerse to generate your own universe!
https://spaceverse.app/download
    ''';
    
    await Share.share(text.trim(), subject: 'Procedural Universe: Seed $seed');
  }
  
  static Future<void> shareApp() async {
    final text = '''
Discover the universe with SpaceVerse! 🚀

🌌 Generate procedurally created universes
🔍 Use AI to discover new exoplanets
🏠 Design space habitats for future missions
🥽 Explore in AR/VR
🌍 Share your discoveries with the community

Download now and start your space exploration journey!
https://spaceverse.app/download

#SpaceVerse #SpaceExploration #Exoplanets #NASA
    ''';
    
    await Share.share(text.trim(), subject: 'Download SpaceVerse');
  }
  
  static Future<void> shareAchievement(String achievement) async {
    final text = '''
I just unlocked the "$achievement" achievement in SpaceVerse! 🏆

Join me in exploring the universe and discovering new worlds!
https://spaceverse.app/download

#SpaceVerse #Achievement #SpaceExploration
    ''';
    
    await Share.share(text.trim(), subject: 'Achievement Unlocked: $achievement');
  }
  
  static Future<void> shareLeaderboard(int rank, String category) async {
    final text = '''
I'm ranked #$rank on the SpaceVerse leaderboard for $category! 🌟

Can you beat my score? Download SpaceVerse and try!
https://spaceverse.app/download

#SpaceVerse #Leaderboard #Competition
    ''';
    
    await Share.share(text.trim(), subject: 'SpaceVerse Leaderboard: #$rank in $category');
  }
}