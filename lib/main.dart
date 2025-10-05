import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spaceverse/advug.dart' hide Planet, Galaxy, Star, StarType;
import 'package:spaceverse/blockchainservice.dart';
import 'package:spaceverse/exoplanethunterservice.dart';
import 'package:spaceverse/habitatdesignerservice.dart';
import 'package:spaceverse/models.dart';
import 'package:spaceverse/proceduraluniverse.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Verse',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
      ),
      home: SpaceVerseApp(),
    );
  }
}

class SpaceVerseApp extends StatelessWidget {
  const SpaceVerseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceVerse',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Orbitron',
      ),
      home: MainScreen(),
      routes: {
        '/universe_explorer': (context) => UniverseExplorerScreen(),
        '/exoplanet_hunter': (context) => ExoplanetHunterScreen(),
        '/habitat_designer': (context) => HabitatDesignerScreen(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.deepPurple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with animated starfield
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    // Animated starfield background
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: StarfieldPainter(_animation.value),
                          child: Container(),
                        );
                      },
                    ),
                    
                    // App title and logo
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/spaceverse_logo.png',
                            width: 120,
                            height: 120,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'SPACEVERSE',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Explore the Universe, Design the Future',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Module selection buttons
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildModuleButton(
                        context,
                        'Universe Explorer',
                        'Generate and explore procedurally created universes',
                        Icons.explore,
                        Colors.blue,
                        () => Navigator.pushNamed(context, '/universe_explorer'),
                      ),
                      _buildModuleButton(
                        context,
                        'Exoplanet Hunter',
                        'Use AI to discover new exoplanets',
                        Icons.search,
                        Colors.purple,
                        () => Navigator.pushNamed(context, '/exoplanet_hunter'),
                      ),
                      _buildModuleButton(
                        context,
                        'Habitat Designer',
                        'Design space habitats for future missions',
                        Icons.home,
                        Colors.green,
                        () => Navigator.pushNamed(context, '/habitat_designer'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildModuleButton(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.4),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: Colors.white,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final double animationValue;
  
  StarfieldPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = Random(42); // Fixed seed for consistent starfield
    
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height + animationValue * size.height) % size.height;
      final radius = random.nextDouble() * 1.5;
      final opacity = random.nextDouble() * 0.8 + 0.2;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class UniverseExplorerScreen extends StatefulWidget {
  const UniverseExplorerScreen({super.key});

  @override
  _UniverseExplorerScreenState createState() => _UniverseExplorerScreenState();
}

class _UniverseExplorerScreenState extends State<UniverseExplorerScreen> {
  final TextEditingController _seedController = TextEditingController(text: '42');
  ProceduralUniverse? _universe;
  Galaxy? _selectedGalaxy;
  Star? _selectedStar;
  Planet? _selectedPlanet;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Universe Explorer'),
        backgroundColor: Colors.deepPurple.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.deepPurple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            // Seed input and generate button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _seedController,
                      decoration: InputDecoration(
                        labelText: 'Universe Seed',
                        labelStyle: TextStyle(color: Colors.white70),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _generateUniverse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                    child: Text('Generate'),
                  ),
                ],
              ),
            ),
            
            // Universe view
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _universe == null
                      ? Center(
                          child: Text(
                            'Enter a seed and generate a universe',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : _buildUniverseView(),
            ),
          ],
        ),
      ),
    );
  }
  
  void _generateUniverse() {
    setState(() {
      _isLoading = true;
    });
    
    final seed = int.tryParse(_seedController.text) ?? 42;
    _universe = ProceduralUniverse(seed);
    
    // Simulate loading time
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }
  
  Widget _buildUniverseView() {
    if (_selectedPlanet != null) {
      return _buildPlanetView();
    } else if (_selectedStar != null) {
      return _buildStarView();
    } else if (_selectedGalaxy != null) {
      return _buildGalaxyView();
    } else {
      return _buildUniverseOverview();
    }
  }
  
  Widget _buildUniverseOverview() {
    return Column(
      children: [
        // Universe info
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            'Universe (Seed: ${_seedController.text})',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        
        // Galaxy grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _universe!.galaxies.length,
            itemBuilder: (context, index) {
              final galaxy = _universe!.galaxies[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGalaxy = galaxy;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.8),
                        Colors.blue.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Galaxy ${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildGalaxyView() {
    return Column(
      children: [
        // Header with back button
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedGalaxy = null;
                  });
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Galaxy View',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Galaxy visualization
        Expanded(
          child: CustomPaint(
            painter: GalaxyPainter(_selectedGalaxy!),
            child: GestureDetector(
              onTapUp: (details) {
                final localPosition = details.localPosition;
                final tappedStar = _findStarAtPosition(localPosition);
                
                if (tappedStar != null) {
                  setState(() {
                    _selectedStar = tappedStar;
                  });
                }
              },
              child: Container(),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStarView() {
    return Column(
      children: [
        // Header with back button
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedStar = null;
                  });
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Star System: ${_selectedStar!.name}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Star info
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStarColor(_selectedStar!.type),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type: ${_selectedStar!.type.toString().split('.').last}',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Planets: ${_selectedStar!.planets.length}',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Planet list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _selectedStar!.planets.length,
            itemBuilder: (context, index) {
              final planet = _selectedStar!.planets[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getPlanetColor(planet),
                  ),
                ),
                title: Text(
                  'Planet ${index + 1}',
                  style: TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Orbital Distance: ${planet.orbitalPeriod.toStringAsFixed(1)} AU',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.white70),
                onTap: () {
                  setState(() {
                    _selectedPlanet = planet;
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildPlanetView() {
    return Column(
      children: [
        // Header with back button
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedPlanet = null;
                  });
                },
                icon: Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  'Planet Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Planet visualization
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.all(16),
            child: CustomPaint(
              painter: PlanetPainter(_selectedPlanet!),
              child: Container(),
            ),
          ),
        ),
        
        // Planet info
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planet Properties',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),
                _buildInfoRow('Size', '${_selectedPlanet!.size.toStringAsFixed(2)} Earth radii'),
                _buildInfoRow('Orbital Distance', '${_selectedPlanet!.orbitalDistance.toStringAsFixed(2)} AU'),
                _buildInfoRow('Orbital Period', '${_selectedPlanet!.orbitalPeriod.toStringAsFixed(1)} days'),
                _buildInfoRow('Transit Duration', '${_selectedPlanet!.transitDuration.toStringAsFixed(2)} hours'),
                _buildInfoRow('Transit Depth', '${_selectedPlanet!.transitDepth.toStringAsFixed(4)}%'),
                _buildInfoRow('Atmosphere', _selectedPlanet!.hasAtmosphere ? 'Present' : 'Absent'),
                _buildInfoRow('Habitability', '${(_selectedPlanet!.habitability * 100).toStringAsFixed(1)}%'),
                
                SizedBox(height: 16),
                
                Text(
                  'Biomes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                
                Expanded(
                  child: ListView.builder(
                    itemCount: _selectedPlanet!.biomes.length,
                    itemBuilder: (context, index) {
                      final biome = _selectedPlanet!.biomes[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              biome.type.toString().split('.').last,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Temp: ${biome.temperature.toStringAsFixed(1)}°C',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Humidity: ${(biome.humidity * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Biodiversity: ${(biome.biodiversity * 100).toStringAsFixed(0)}%',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Star? _findStarAtPosition(Offset position) {
    // Find star at tapped position
    for (final star in _selectedGalaxy!.stars) {
      final starPosition = Offset(
        star.position.x,
        star.position.y,
      );
      
      final distance = (position - starPosition).distance;
      if (distance < 10) {
        return star;
      }
    }
    return null;
  }
  
  Color _getStarColor(StarType type) {
    switch (type) {
      case StarType.redDwarf:
        return Colors.red;
      case StarType.yellowDwarf:
        return Colors.yellow;
      case StarType.blueSupergiant:
        return Colors.blue;
      case StarType.redGiant:
        return Colors.orange;
      case StarType.whiteDwarf:
        return Colors.white;
    }
  }
  
  Color _getPlanetColor(Planet planet) {
    if (!planet.hasAtmosphere) {
      return Colors.grey;
    }
    
    if (planet.habitability > 0.7) {
      return Colors.green;
    } else if (planet.habitability > 0.3) {
      return Colors.brown;
    } else {
      return Colors.orange;
    }
  }
}

class GalaxyPainter extends CustomPainter {
  final Galaxy galaxy;
  
  GalaxyPainter(this.galaxy);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw galaxy background
    paint.color = Colors.white.withOpacity(0.1);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
    
    // Draw spiral arms
    for (int arm = 0; arm < galaxy.spiralArms; arm++) {
      final armAngle = (2 * pi / galaxy.spiralArms) * arm;
      
      paint.color = Colors.white.withOpacity(0.3);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      
      final path = Path();
      for (double t = 0; t < 1; t += 0.01) {
        final distance = t * size.width / 2;
        final angle = armAngle + (t * 2 * pi);
        
        final x = size.width / 2 + distance * cos(angle);
        final y = size.height / 2 + distance * sin(angle);
        
        if (t == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      
      canvas.drawPath(path, paint);
    }
    
    // Draw stars
    for (final star in galaxy.stars) {
      // Scale star position to canvas size
      final x = (star.position.x / 1000) * size.width;
      final y = (star.position.y / 1000) * size.height;
      
      // Draw star
      paint.color = _getStarColor(star.type);
      paint.style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(x, y),
        3,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
  Color _getStarColor(StarType type) {
    switch (type) {
      case StarType.redDwarf:
        return Colors.red;
      case StarType.yellowDwarf:
        return Colors.yellow;
      case StarType.blueSupergiant:
        return Colors.blue;
      case StarType.redGiant:
        return Colors.orange;
      case StarType.whiteDwarf:
        return Colors.white;
    }
  }
}

class PlanetPainter extends CustomPainter {
  final Planet planet;
  
  PlanetPainter(this.planet);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw planet
    if (!planet.hasAtmosphere) {
      paint.color = Colors.grey;
    } else if (planet.habitability > 0.7) {
      paint.color = Colors.green;
    } else if (planet.habitability > 0.3) {
      paint.color = Colors.brown;
    } else {
      paint.color = Colors.orange;
    }
    
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
    
    // Draw atmosphere if present
    if (planet.hasAtmosphere) {
      paint.color = Colors.blue.withOpacity(0.3);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 5;
      canvas.drawCircle(center, radius + 5, paint);
    }
    
    // Draw biomes
    if (planet.hasAtmosphere && planet.biomes.isNotEmpty) {
      final angleStep = 2 * pi / planet.biomes.length;
      
      for (int i = 0; i < planet.biomes.length; i++) {
        final biome = planet.biomes[i];
        final startAngle = i * angleStep;
        final endAngle = (i + 1) * angleStep;
        
        paint.color = _getBiomeColor(biome.type);
        paint.style = PaintingStyle.fill;
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius * 0.8),
          startAngle,
          angleStep,
          true,
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
  
  Color _getBiomeColor(BiomeType type) {
    switch (type) {
      case BiomeType.barren:
        return Colors.grey;
      case BiomeType.desert:
        return Colors.yellow;
      case BiomeType.tundra:
        return Colors.lightBlue;
      case BiomeType.forest:
        return Colors.green;
      case BiomeType.ocean:
        return Colors.blue;
      case BiomeType.grassland:
        return Colors.lightGreen;
      case BiomeType.wetland:
        return Colors.teal;
    }
  }
}

class ExoplanetHunterScreen extends StatefulWidget {
  const ExoplanetHunterScreen({super.key});

  @override
  _ExoplanetHunterScreenState createState() => _ExoplanetHunterScreenState();
}

class _ExoplanetHunterScreenState extends State<ExoplanetHunterScreen> {
  final ExoplanetHunterService _service = ExoplanetHunterService();
  bool _isLoading = false;
  List<ExoplanetData> _discoveredExoplanets = [];
  List<ExoplanetData> _confirmedExoplanets = [];
  List<ExoplanetData> _candidateExoplanets = [];
  List<ExoplanetData> _falsePositiveExoplanets = [];
  ExoplanetData? _selectedExoplanet;
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
    });
    
    await _service.initializeModel();
    
    // Load verified exoplanets from blockchain
    final blockchainService = BlockchainService();
    await blockchainService.initialize();
    _confirmedExoplanets = await blockchainService.getVerifiedExoplanets();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exoplanet Hunter'),
        backgroundColor: Colors.purple.shade900,
        actions: [
          IconButton(
            onPressed: _showTrainingDialog,
            icon: Icon(Icons.school),
            tooltip: 'Train Model',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.purple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            // Tab bar
            Container(
              color: Colors.purple.shade800,
              child: TabBar(
                tabs: [
                  Tab(text: 'Discover'),
                  Tab(text: 'Confirmed'),
                  Tab(text: 'Candidates'),
                  Tab(text: 'False Positives'),
                ],
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
              ),
            ),
            
            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _buildDiscoverTab(),
                        _buildExoplanetList(_confirmedExoplanets),
                        _buildExoplanetList(_candidateExoplanets),
                        _buildExoplanetList(_falsePositiveExoplanets),
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _discoverExoplanets,
        backgroundColor: Colors.purple,
        child: Icon(Icons.search),
        tooltip: 'Discover Exoplanets',
      ),
    );
  }
  
  Widget _buildDiscoverTab() {
    return Column(
      children: [
        // Discovery stats
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Discovered', _discoveredExoplanets.length, Colors.blue),
              _buildStatCard('Confirmed', _confirmedExoplanets.length, Colors.green),
              _buildStatCard('Candidates', _candidateExoplanets.length, Colors.orange),
              _buildStatCard('False Positives', _falsePositiveExoplanets.length, Colors.red),
            ],
          ),
        ),
        
        // Discovered exoplanets
        Expanded(
          child: _discoveredExoplanets.isEmpty
              ? Center(
                  child: Text(
                    'No exoplanets discovered yet. Tap the search button to start!',
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _discoveredExoplanets.length,
                  itemBuilder: (context, index) {
                    final exoplanet = _discoveredExoplanets[index];
                    return _buildExoplanetCard(exoplanet);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, int value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExoplanetList(List<ExoplanetData> exoplanets) {
    if (exoplanets.isEmpty) {
      return Center(
        child: Text(
          'No exoplanets in this category',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: exoplanets.length,
      itemBuilder: (context, index) {
        final exoplanet = exoplanets[index];
        return _buildExoplanetCard(exoplanet);
      },
    );
  }
  
  Widget _buildExoplanetCard(ExoplanetData exoplanet) {
    Color statusColor;
    String statusText;
    
    switch (exoplanet.status) {
      case ExoplanetStatus.confirmed:
        statusColor = Colors.green;
        statusText = 'Confirmed';
        break;
      case ExoplanetStatus.candidate:
        statusColor = Colors.orange;
        statusText = 'Candidate';
        break;
      case ExoplanetStatus.falsePositive:
        statusColor = Colors.red;
        statusText = 'False Positive';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.white.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedExoplanet = exoplanet;
          });
          _showExoplanetDetails(exoplanet);
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      exoplanet.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: statusColor.withOpacity(0.2),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Orbital Period: ${exoplanet.orbitalPeriod.toStringAsFixed(1)} days',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Transit Duration: ${exoplanet.transitDuration.toStringAsFixed(2)} hours',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Planet Radius: ${exoplanet.planetRadius.toStringAsFixed(2)} Earth radii',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Star Temperature: ${exoplanet.starTemperature.toStringAsFixed(0)} K',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              if (exoplanet.confidence != null) ...[
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: exoplanet.confidence,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
                SizedBox(height: 4),
                Text(
                  'Confidence: ${(exoplanet.confidence! * 100).toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _discoverExoplanets() async {
    setState(() {
      _isLoading = true;
    });
    
    // Generate a random star system
    final random = Random();
    final seed = random.nextInt(10000);
    final universe = ProceduralUniverse(seed);
    final galaxy = universe.generateGalaxy();
    final star = galaxy.stars[random.nextInt(galaxy.stars.length)];
    
    // Discover exoplanets
    final discoveredExoplanets = await _service.discoverExoplanets(star);
    
    // Classify exoplanets
    for (final exoplanet in discoveredExoplanets) {
      final classification = await _service.classifyExoplanet(exoplanet);
      
      final classifiedExoplanet = exoplanet.copyWith(
        status: classification.status,
        confidence: classification.confidence,
      );
      
      // Add to appropriate list
      switch (classification.status) {
        case ExoplanetStatus.confirmed:
          _confirmedExoplanets.add(classifiedExoplanet);
          break;
        case ExoplanetStatus.candidate:
          _candidateExoplanets.add(classifiedExoplanet);
          break;
        case ExoplanetStatus.falsePositive:
          _falsePositiveExoplanets.add(classifiedExoplanet);
          break;
        default:
          break;
      }
      
      _discoveredExoplanets.add(classifiedExoplanet);
    }
    
    setState(() {
      _isLoading = false;
    });
    
    // Show results
    _showDiscoveryResults(discoveredExoplanets);
  }
  
  void _showDiscoveryResults(List<ExoplanetData> exoplanets) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Discovery Results'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discovered ${exoplanets.length} potential exoplanets:'),
            SizedBox(height: 16),
            ...exoplanets.map((exoplanet) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(exoplanet.status),
                    color: _getStatusColor(exoplanet.status),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${exoplanet.name}: ${exoplanet.status.toString().split('.').last}',
                      style: TextStyle(
                        color: _getStatusColor(exoplanet.status),
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showExoplanetDetails(ExoplanetData exoplanet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExoplanetDetailsScreen(exoplanet: exoplanet),
      ),
    );
  }
  
  void _showTrainingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Train Model'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Training the model will improve its accuracy in identifying exoplanets.'),
            SizedBox(height: 16),
            Text('This may take a few minutes.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _trainModel();
            },
            child: Text('Train'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _trainModel() async {
    setState(() {
      _isLoading = true;
    });
    
    await _service.trainModel();
    
    setState(() {
      _isLoading = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Model training completed'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  IconData _getStatusIcon(ExoplanetStatus status) {
    switch (status) {
      case ExoplanetStatus.confirmed:
        return Icons.check_circle;
      case ExoplanetStatus.candidate:
        return Icons.help;
      case ExoplanetStatus.falsePositive:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
  
  Color _getStatusColor(ExoplanetStatus status) {
    switch (status) {
      case ExoplanetStatus.confirmed:
        return Colors.green;
      case ExoplanetStatus.candidate:
        return Colors.orange;
      case ExoplanetStatus.falsePositive:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ExoplanetDetailsScreen extends StatefulWidget {
  final ExoplanetData exoplanet;
  
  ExoplanetDetailsScreen({super.key, required this.exoplanet});
  
  @override
  _ExoplanetDetailsScreenState createState() => _ExoplanetDetailsScreenState();
}

class _ExoplanetDetailsScreenState extends State<ExoplanetDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exoplanet.name),
        backgroundColor: Colors.purple.shade900,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.purple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exoplanet visualization
              Container(
                height: 200,
                child: CustomPaint(
                  painter: ExoplanetPainter(widget.exoplanet),
                  child: Container(),
                ),
              ),
              
              SizedBox(height: 24),
              
              // Status
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _getStatusColor(widget.exoplanet.status).withOpacity(0.2),
                  border: Border.all(color: _getStatusColor(widget.exoplanet.status)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(widget.exoplanet.status),
                      color: _getStatusColor(widget.exoplanet.status),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            widget.exoplanet.status.toString().split('.').last,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(widget.exoplanet.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.exoplanet.confidence != null) ...[
                      Text(
                        '${(widget.exoplanet.confidence! * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(widget.exoplanet.status),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Properties
              Text(
                'Properties',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              
              _buildPropertyCard('Orbital Period', '${widget.exoplanet.orbitalPeriod.toStringAsFixed(1)} days'),
              _buildPropertyCard('Transit Duration', '${widget.exoplanet.transitDuration.toStringAsFixed(2)} hours'),
              _buildPropertyCard('Planet Radius', '${widget.exoplanet.planetRadius.toStringAsFixed(2)} Earth radii'),
              _buildPropertyCard('Star Radius', '${widget.exoplanet.starRadius.toStringAsFixed(2)} Sun radii'),
              _buildPropertyCard('Star Temperature', '${widget.exoplanet.starTemperature.toStringAsFixed(0)} K'),
              _buildPropertyCard('Transit Depth', '${widget.exoplanet.transitDepth.toStringAsFixed(4)}%'),
              _buildPropertyCard('Density Estimate', widget.exoplanet.densityEstimate.toStringAsFixed(4)),
              
              SizedBox(height: 24),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saveToBlockchain,
                      icon: Icon(Icons.save),
                      label: Text('Save to Blockchain'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareExoplanet,
                      icon: Icon(Icons.share),
                      label: Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildPropertyCard(String label, String value) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _saveToBlockchain() async {
    final blockchainService = BlockchainService();
    await blockchainService.initialize();
    
    try {
      final txHash = await blockchainService.saveExoplanetDiscovery(
        widget.exoplanet,
        'SpaceVerse User',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exoplanet saved to blockchain: $txHash'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save to blockchain: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _shareExoplanet() {
    Share.share(
      'Check out this exoplanet I discovered with SpaceVerse: ${widget.exoplanet.name}',
    );
  }
  
  IconData _getStatusIcon(ExoplanetStatus status) {
    switch (status) {
      case ExoplanetStatus.confirmed:
        return Icons.check_circle;
      case ExoplanetStatus.candidate:
        return Icons.help;
      case ExoplanetStatus.falsePositive:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }
  
  Color _getStatusColor(ExoplanetStatus status) {
    switch (status) {
      case ExoplanetStatus.confirmed:
        return Colors.green;
      case ExoplanetStatus.candidate:
        return Colors.orange;
      case ExoplanetStatus.falsePositive:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class ExoplanetPainter extends CustomPainter {
  final ExoplanetData exoplanet;
  
  ExoplanetPainter(this.exoplanet);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw star
    final starRadius = size.width / 4;
    paint.color = Colors.yellow;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, starRadius, paint);
    
    // Draw orbit
    paint.color = Colors.white.withOpacity(0.3);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    canvas.drawCircle(center, size.width / 2.5, paint);
    
    // Draw planet
    final planetAngle = DateTime.now().millisecondsSinceEpoch / 1000 * (2 * pi / exoplanet.orbitalPeriod);
    final planetX = center.dx + size.width / 2.5 * cos(planetAngle);
    final planetY = center.dy + size.width / 2.5 * sin(planetAngle);
    
    paint.color = Colors.blue;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(planetX, planetY), starRadius * 0.3, paint);
    
    // Draw transit line if planet is in front of star
    if (planetY < center.dy) {
      paint.color = Colors.white.withOpacity(0.5);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawLine(
        Offset(planetX - starRadius * 0.3, planetY),
        Offset(planetX + starRadius * 0.3, planetY),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class HabitatDesignerScreen extends StatefulWidget {
  const HabitatDesignerScreen({super.key});

  @override
  _HabitatDesignerScreenState createState() => _HabitatDesignerScreenState();
}

class _HabitatDesignerScreenState extends State<HabitatDesignerScreen> {
  final HabitatDesignerService _service = HabitatDesignerService();
  HabitatDesign? _currentDesign;
  bool _isLoading = false;
  LayoutValidationResult? _validationResult;
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }
  
  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
    });
    
    await _service.initialize();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habitat Designer'),
        backgroundColor: Colors.green.shade900,
        actions: [
          IconButton(
            onPressed: _loadSharedDesigns,
            icon: Icon(Icons.cloud_download),
            tooltip: 'Load Shared Designs',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.green.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Column(
          children: [
            // Design parameters
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Design Parameters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<HabitatShape>(
                          decoration: InputDecoration(
                            labelText: 'Habitat Shape',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          value: _currentDesign?.shape,
                          items: HabitatShape.values.map((shape) {
                            return DropdownMenuItem(
                              value: shape,
                              child: Text(
                                shape.toString().split('.').last,
                                style: TextStyle(color: Colors.black),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _updateDesign(shape: value);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Width (m)',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          initialValue: _currentDesign?.width.toString(),
                          onChanged: (value) {
                            final width = double.tryParse(value);
                            if (width != null) {
                              _updateDesign(width: width);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Height (m)',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          initialValue: _currentDesign?.height.toString(),
                          onChanged: (value) {
                            final height = double.tryParse(value);
                            if (height != null) {
                              _updateDesign(height: height);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Depth (m)',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          initialValue: _currentDesign?.depth.toString(),
                          onChanged: (value) {
                            final depth = double.tryParse(value);
                            if (depth != null) {
                              _updateDesign(depth: depth);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Crew Size',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          initialValue: _currentDesign?.crewSize.toString(),
                          onChanged: (value) {
                            final crewSize = int.tryParse(value);
                            if (crewSize != null) {
                              _updateDesign(crewSize: crewSize);
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Mission Duration (days)',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          style: TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          initialValue: _currentDesign?.missionDuration.toString(),
                          onChanged: (value) {
                            final missionDuration = int.tryParse(value);
                            if (missionDuration != null) {
                              _updateDesign(missionDuration: missionDuration);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<Destination>(
                    decoration: InputDecoration(
                      labelText: 'Destination',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    value: _currentDesign?.destination,
                    items: Destination.values.map((destination) {
                      return DropdownMenuItem(
                        value: destination,
                        child: Text(
                          destination.toString().split('.').last,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _updateDesign(destination: value);
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Design visualization
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _currentDesign == null
                      ? Center(
                          child: Text(
                            'Set design parameters to create a habitat',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : _buildDesignView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _validateAndSaveDesign,
        backgroundColor: Colors.green,
        child: Icon(Icons.save),
        tooltip: 'Validate and Save Design',
      ),
    );
  }
  
  Widget _buildDesignView() {
    return Column(
      children: [
        // Design tabs
        Container(
          color: Colors.green.shade800,
          child: TabBar(
            tabs: [
              Tab(text: '3D View'),
              Tab(text: 'Modules'),
              Tab(text: 'Validation'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
          ),
        ),
        
        // Tab content
        Expanded(
          child: TabBarView(
            children: [
              _build3DView(),
              _buildModulesView(),
              _buildValidationView(),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _build3DView() {
    return Container(
      padding: EdgeInsets.all(16),
      child: CustomPaint(
        painter: Habitat3DPainter(_currentDesign!),
        child: Container(),
      ),
    );
  }
  
  Widget _buildModulesView() {
    return Column(
      children: [
        // Module stats
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard('Total Modules', _currentDesign!.modules.length as String, Colors.blue),
              _buildStatCard('Volume Used', '${(_currentDesign!.modules.fold(0.0, (sum, module) => sum + module.volume) / _currentDesign!.totalVolume * 100).toStringAsFixed(1)}%', Colors.green),
              _buildStatCard('Design Score', _validationResult?.score.toStringAsFixed(1) ?? 'N/A', Colors.orange),
            ],
          ),
        ),
        
        // Module list
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _currentDesign!.modules.length,
            itemBuilder: (context, index) {
              final module = _currentDesign!.modules[index];
              return _buildModuleCard(module, index);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildValidationView() {
    if (_validationResult == null) {
      return Center(
        child: ElevatedButton(
          onPressed: _validateDesign,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: Text('Validate Design'),
        ),
      );
    }
    
    return Column(
      children: [
        // Validation result
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                _validationResult!.isValid ? Icons.check_circle : Icons.error,
                color: _validationResult!.isValid ? Colors.green : Colors.red,
                size: 32,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _validationResult!.isValid ? 'Design is Valid' : 'Design has Issues',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _validationResult!.isValid ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      'Score: ${_validationResult!.score.toStringAsFixed(1)}/100',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Issues list
        Expanded(
          child: _validationResult!.issues.isEmpty
              ? Center(
                  child: Text(
                    'No issues found',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _validationResult!.issues.length,
                  itemBuilder: (context, index) {
                    final issue = _validationResult!.issues[index];
                    return _buildIssueCard(issue);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(0.2),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildModuleCard(HabitatModule module, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    module.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _getModuleTypeColor(module.type).withOpacity(0.2),
                    border: Border.all(color: _getModuleTypeColor(module.type)),
                  ),
                  child: Text(
                    module.type.toString().split('.').last,
                    style: TextStyle(
                      color: _getModuleTypeColor(module.type),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Volume: ${module.volume.toStringAsFixed(1)} m³',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Mass: ${module.mass.toStringAsFixed(1)} kg',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              module.description,
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIssueCard(LayoutIssue issue) {
    Color issueColor;
    IconData issueIcon;
    
    switch (issue.severity) {
      case IssueSeverity.error:
        issueColor = Colors.red;
        issueIcon = Icons.error;
        break;
      case IssueSeverity.warning:
        issueColor = Colors.orange;
        issueIcon = Icons.warning;
        break;
      case IssueSeverity.info:
        issueColor = Colors.blue;
        issueIcon = Icons.info;
        break;
    }
    
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              issueIcon,
              color: issueColor,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    issue.type.toString().split('.').last,
                    style: TextStyle(
                      color: issueColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    issue.message,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _updateDesign({
    HabitatShape? shape,
    double? width,
    double? height,
    double? depth,
    int? crewSize,
    int? missionDuration,
    Destination? destination,
  }) {
    if (_currentDesign == null) {
      // Create new design
      _currentDesign = _service.createHabitatDesign(
        shape: shape ?? HabitatShape.cylinder,
        width: width ?? 10.0,
        height: height ?? 10.0,
        depth: depth ?? 10.0,
        crewSize: crewSize ?? 4,
        missionDuration: missionDuration ?? 30,
        destination: destination ?? Destination.lowEarthOrbit,
      );
    } else {
      // Update existing design
      if (shape != null) _currentDesign!.shape = shape;
      if (width != null) _currentDesign!.width = width;
      if (height != null) _currentDesign!.height = height;
      if (depth != null) _currentDesign!.depth = depth;
      if (crewSize != null) _currentDesign!.crewSize = crewSize;
      if (missionDuration != null) _currentDesign!.missionDuration = missionDuration;
      if (destination != null) _currentDesign!.destination = destination;
      
      // Recalculate total volume
      _currentDesign!.totalVolume = _service._calculateVolume(
        _currentDesign!.shape,
        _currentDesign!.width,
        _currentDesign!.height,
        _currentDesign!.depth,
      );
      
      // Recalculate required modules
      final requiredModules = _service._calculateRequiredModules(
        _currentDesign!.crewSize,
        _currentDesign!.missionDuration,
        _currentDesign!.destination,
      );
      
      _currentDesign!.modules.clear();
      _currentDesign!.modules.addAll(requiredModules);
    }
    
    // Reset validation result
    _validationResult = null;
    
    setState(() {});
  }
  
  void _validateDesign() {
    if (_currentDesign == null) return;
    
    setState(() {
      _validationResult = _service.validateLayout(_currentDesign!);
    });
  }
  
  Future<void> _validateAndSaveDesign() async {
    if (_currentDesign == null) return;
    
    // Validate design
    _validateDesign();
    
    if (_validationResult == null || !_validationResult!.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix design issues before saving'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Save to blockchain
    try {
      final blockchainService = BlockchainService();
      await blockchainService.initialize();
      
      final txHash = await blockchainService.saveHabitatDesign(_currentDesign!);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Design saved to blockchain: $txHash'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save to blockchain: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _loadSharedDesigns() async {
    try {
      final blockchainService = BlockchainService();
      await blockchainService.initialize();
      
      final sharedDesigns = await blockchainService.getSharedHabitatDesigns();
      
      if (sharedDesigns.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No shared designs found'),
            backgroundColor: Colors.blue,
          ),
        );
        return;
      }
      
      // Show design selection dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Select a Shared Design'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: sharedDesigns.length,
              itemBuilder: (context, index) {
                final design = sharedDesigns[index];
                return ListTile(
                  title: Text(
                    'Design ${index + 1}',
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    'Crew: ${design.crewSize}, Duration: ${design.missionDuration} days',
                    style: TextStyle(color: Colors.black54),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentDesign = design;
                      _validationResult = null;
                    });
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load shared designs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Color _getModuleTypeColor(ModuleType type) {
    switch (type) {
      case ModuleType.lifeSupport:
        return Colors.blue;
      case ModuleType.power:
        return Colors.yellow;
      case ModuleType.communication:
        return Colors.green;
      case ModuleType.crewQuarters:
        return Colors.purple;
      case ModuleType.medical:
        return Colors.red;
      case ModuleType.food:
        return Colors.orange;
      case ModuleType.waste:
        return Colors.brown;
      case ModuleType.exercise:
        return Colors.teal;
      case ModuleType.work:
        return Colors.indigo;
      case ModuleType.recreation:
        return Colors.pink;
      case ModuleType.storage:
        return Colors.grey;
      case ModuleType.maintenance:
        return Colors.cyan;
      default:
        return Colors.white;
    }
  }
}

class Habitat3DPainter extends CustomPainter {
  final HabitatDesign design;
  
  Habitat3DPainter(this.design);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw habitat based on shape
    switch (design.shape) {
      case HabitatShape.cylinder:
        _drawCylinder(canvas, center, size, paint);
        break;
      case HabitatShape.sphere:
        _drawSphere(canvas, center, size, paint);
        break;
      case HabitatShape.box:
        _drawBox(canvas, center, size, paint);
        break;
      case HabitatShape.torus:
        _drawTorus(canvas, center, size, paint);
        break;
    }
    
    // Draw modules
    _drawModules(canvas, center, size, paint);
  }
  
  void _drawCylinder(Canvas canvas, Offset center, Size size, Paint paint) {
    final radius = size.width / 3;
    final height = size.height / 2;
    
    // Draw cylinder body
    paint.color = Colors.white.withOpacity(0.3);
    paint.style = PaintingStyle.fill;
    
    final rect = Rect.fromCenter(
      center: center,
      width: radius * 2,
      height: height,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(radius)),
      paint,
    );
    
    // Draw cylinder top
    paint.color = Colors.white.withOpacity(0.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - height / 2),
        width: radius * 2,
        height: radius * 0.5,
      ),
      paint,
    );
    
    // Draw cylinder bottom
    paint.color = Colors.white.withOpacity(0.2);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + height / 2),
        width: radius * 2,
        height: radius * 0.5,
      ),
      paint,
    );
  }
  
  void _drawSphere(Canvas canvas, Offset center, Size size, Paint paint) {
    final radius = size.width / 3;
    
    // Draw sphere
    paint.color = Colors.white.withOpacity(0.3);
    paint.style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paint);
    
    // Draw sphere highlight
    paint.color = Colors.white.withOpacity(0.5);
    canvas.drawCircle(
      Offset(center.dx - radius / 3, center.dy - radius / 3),
      radius / 3,
      paint,
    );
  }
  
  void _drawBox(Canvas canvas, Offset center, Size size, Paint paint) {
    final width = size.width / 2;
    final height = size.height / 2;
    final depth = size.width / 3;
    
    // Draw box front
    paint.color = Colors.white.withOpacity(0.5);
    paint.style = PaintingStyle.fill;
    
    final frontRect = Rect.fromCenter(
      center: center,
      width: width,
      height: height,
    );
    
    canvas.drawRect(frontRect, paint);
    
    // Draw box top
    paint.color = Colors.white.withOpacity(0.3);
    
    final topPath = Path()
      ..moveTo(center.dx - width / 2, center.dy - height / 2)
      ..lineTo(center.dx - width / 2 + depth / 2, center.dy - height / 2 - depth / 2)
      ..lineTo(center.dx + width / 2 + depth / 2, center.dy - height / 2 - depth / 2)
      ..lineTo(center.dx + width / 2, center.dy - height / 2)
      ..close();
    
    canvas.drawPath(topPath, paint);
    
    // Draw box side
    paint.color = Colors.white.withOpacity(0.2);
    
    final sidePath = Path()
      ..moveTo(center.dx + width / 2, center.dy - height / 2)
      ..lineTo(center.dx + width / 2 + depth / 2, center.dy - height / 2 - depth / 2)
      ..lineTo(center.dx + width / 2 + depth / 2, center.dy + height / 2 - depth / 2)
      ..lineTo(center.dx + width / 2, center.dy + height / 2)
      ..close();
    
    canvas.drawPath(sidePath, paint);
  }
  
  void _drawTorus(Canvas canvas, Offset center, Size size, Paint paint) {
    final majorRadius = size.width / 3;
    final minorRadius = size.width / 8;
    
    // Draw torus
    paint.color = Colors.white.withOpacity(0.3);
    paint.style = PaintingStyle.fill;
    
    // Draw outer circle
    canvas.drawCircle(center, majorRadius + minorRadius, paint);
    
    // Draw inner circle
    paint.color = Colors.black.withOpacity(0.5);
    canvas.drawCircle(center, majorRadius - minorRadius, paint);
    
    // Draw torus segments
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final x = center.dx + majorRadius * cos(angle);
      final y = center.dy + majorRadius * sin(angle);
      
      paint.color = Colors.white.withOpacity(0.5);
      canvas.drawCircle(Offset(x, y), minorRadius, paint);
    }
  }
  
  void _drawModules(Canvas canvas, Offset center, Size size, Paint paint) {
    if (design.modules.isEmpty) return;
    
    // Calculate module positions
    final modulePositions = _calculateModulePositions(center, size);
    
    // Draw modules
    for (int i = 0; i < design.modules.length && i < modulePositions.length; i++) {
      final module = design.modules[i];
      final position = modulePositions[i];
      
      paint.color = _getModuleTypeColor(module.type);
      paint.style = PaintingStyle.fill;
      
      canvas.drawCircle(position, 8, paint);
      
      // Draw module label
      paint.color = Colors.white;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(position.dx, position.dy - 15),
          width: 40,
          height: 10,
        ),
        paint,
      );
    }
  }
  
  List<Offset> _calculateModulePositions(Offset center, Size size) {
    final positions = <Offset>[];
    
    // Calculate positions based on habitat shape
    switch (design.shape) {
      case HabitatShape.cylinder:
        // Arrange modules in a circle
        final radius = size.width / 4;
        for (int i = 0; i < design.modules.length; i++) {
          final angle = i * 2 * pi / design.modules.length;
          final x = center.dx + radius * cos(angle);
          final y = center.dy + radius * sin(angle);
          positions.add(Offset(x, y));
        }
        break;
        
      case HabitatShape.sphere:
        // Arrange modules on the surface
        final radius = size.width / 3;
        for (int i = 0; i < design.modules.length; i++) {
          final theta = i * pi / design.modules.length;
          final phi = i * 2 * pi / design.modules.length;
          final x = center.dx + radius * sin(theta) * cos(phi);
          final y = center.dy + radius * sin(theta) * sin(phi);
          positions.add(Offset(x, y));
        }
        break;
        
      case HabitatShape.box:
        // Arrange modules in a grid
        final cols = (design.modules.length / 3).ceil();
        final rows = 3;
        final cellWidth = size.width / (cols + 1);
        final cellHeight = size.height / (rows + 1);
        
        for (int i = 0; i < design.modules.length; i++) {
          final col = i % cols;
          final row = i ~/ cols;
          final x = center.dx - size.width / 2 + cellWidth * (col + 1);
          final y = center.dy - size.height / 2 + cellHeight * (row + 1);
          positions.add(Offset(x, y));
        }
        break;
        
      case HabitatShape.torus:
        // Arrange modules along the torus
        final majorRadius = size.width / 3;
        for (int i = 0; i < design.modules.length; i++) {
          final angle = i * 2 * pi / design.modules.length;
          final x = center.dx + majorRadius * cos(angle);
          final y = center.dy + majorRadius * sin(angle);
          positions.add(Offset(x, y));
        }
        break;
    }
    
    return positions;
  }
  
  Color _getModuleTypeColor(ModuleType type) {
    switch (type) {
      case ModuleType.lifeSupport:
        return Colors.blue;
      case ModuleType.power:
        return Colors.yellow;
      case ModuleType.communication:
        return Colors.green;
      case ModuleType.crewQuarters:
        return Colors.purple;
      case ModuleType.medical:
        return Colors.red;
      case ModuleType.food:
        return Colors.orange;
      case ModuleType.waste:
        return Colors.brown;
      case ModuleType.exercise:
        return Colors.teal;
      case ModuleType.work:
        return Colors.indigo;
      case ModuleType.recreation:
        return Colors.pink;
      case ModuleType.storage:
        return Colors.grey;
      case ModuleType.maintenance:
        return Colors.cyan;
      default:
        return Colors.white;
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}