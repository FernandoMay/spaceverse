// lib/core/utils/perlin_noise.dart
import 'dart:math';
import 'package:vector_math/vector_math.dart';

class PerlinNoise {
  final int seed;
  late final List<int> _permutation;
  static const int _permutationSize = 256;
  
  PerlinNoise({required this.seed}) {
    final random = Random(seed);
    _permutation = List.generate(_permutationSize, (i) => i);
    
    // Shuffle permutation
    for (int i = _permutationSize - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = _permutation[i];
      _permutation[i] = _permutation[j];
      _permutation[j] = temp;
    }
    
    // Duplicate for overflow
    _permutation.addAll(List.from(_permutation));
  }
  
  double noise(double x, double y, [double? z]) {
    if (z == null) {
      return _noise2D(x, y);
    } else {
      return _noise3D(x, y, z);
    }
  }
  
  double _noise2D(double x, double y) {
    // Find unit grid cell containing point
    final X = x.floor() & 255;
    final Y = y.floor() & 255;
    
    // Find relative x, y of point in cell
    x -= x.floor();
    y -= y.floor();
    
    // Compute fade curves
    final u = _fade(x);
    final v = _fade(y);
    
    // Hash coordinates of the 4 square corners
    final a = _permutation[X] + Y;
    final aa = _permutation[a];
    final ab = _permutation[a + 1];
    final b = _permutation[X + 1] + Y;
    final ba = _permutation[b];
    final bb = _permutation[b + 1];
    
    // Blend the results from 4 corners
    return _lerp(v,
      _lerp(u, _grad(_permutation[aa], x, y),
              _grad(_permutation[ba], x - 1, y)),
      _lerp(u, _grad(_permutation[ab], x, y - 1),
              _grad(_permutation[bb], x - 1, y - 1))
    );
  }
  
  double _noise3D(double x, double y, double z) {
    // Find unit grid cell containing point
    final X = x.floor() & 255;
    final Y = y.floor() & 255;
    final Z = z.floor() & 255;
    
    // Find relative x, y, z of point in cell
    x -= x.floor();
    y -= y.floor();
    z -= z.floor();
    
    // Compute fade curves
    final u = _fade(x);
    final v = _fade(y);
    final w = _fade(z);
    
    // Hash coordinates of the 8 cube corners
    final A = _permutation[X] + Y;
    final AA = _permutation[A] + Z;
    final AB = _permutation[A + 1] + Z;
    final B = _permutation[X + 1] + Y;
    final BA = _permutation[B] + Z;
    final BB = _permutation[B + 1] + Z;
    
    // Blend the results from 8 corners
    return _lerp(w,
      _lerp(v,
        _lerp(u, _grad(_permutation[AA], x, y, z),
                _grad(_permutation[BA], x - 1, y, z)),
        _lerp(u, _grad(_permutation[AB], x, y - 1, z),
                _grad(_permutation[BB], x - 1, y - 1, z))
      ),
      _lerp(v,
        _lerp(u, _grad(_permutation[AA + 1], x, y, z - 1),
                _grad(_permutation[BA + 1], x - 1, y, z - 1)),
        _lerp(u, _grad(_permutation[AB + 1], x, y - 1, z - 1),
                _grad(_permutation[BB + 1], x - 1, y - 1, z - 1))
      )
    );
  }
  
  double _fade(double t) {
    return t * t * t * (t * (t * 6 - 15) + 10);
  }
  
  double _lerp(double t, double a, double b) {
    return a + t * (b - a);
  }
  
  double _grad(int hash, double x, double y, [double? z]) {
    if (z == null) {
      // 2D gradient
      final h = hash & 3;
      final u = h < 2 ? x : y;
      final v = h < 2 ? y : x;
      return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
    } else {
      // 3D gradient
      final h = hash & 15;
      final u = h < 8 ? x : y;
      final v = h < 4 ? y : h == 12 || h == 14 ? x : z;
      return ((h & 1) == 0 ? u : -u) + ((h & 2) == 0 ? v : -v);
    }
  }
  
  // Fractal Brownian Motion
  double fbm(double x, double y, int octaves, double persistence, [double? z]) {
    double total = 0;
    double frequency = 1;
    double amplitude = 1;
    double maxValue = 0;
    
    for (int i = 0; i < octaves; i++) {
      total += (z != null ? noise(x * frequency, y * frequency, z * frequency) 
                           : noise(x * frequency, y * frequency)) * amplitude;
      
      maxValue += amplitude;
      amplitude *= persistence;
      frequency *= 2;
    }
    
    return total / maxValue;
  }
  
  // Ridged noise
  double ridgedNoise(double x, double y, int octaves, double persistence, [double? z]) {
    double total = 0;
    double frequency = 1;
    double amplitude = 1;
    double maxValue = 0;
    
    for (int i = 0; i < octaves; i++) {
      final n = z != null ? noise(x * frequency, y * frequency, z * frequency) 
                         : noise(x * frequency, y * frequency);
      total += (1 - n.abs()) * amplitude;
      
      maxValue += amplitude;
      amplitude *= persistence;
      frequency *= 2;
    }
    
    return total / maxValue;
  }
}

class SimplexNoise {
  final int seed;
  late final List<int> _perm;
  static const int _permSize = 512;
  
  SimplexNoise({required this.seed}) {
    final random = Random(seed);
    final perm = List.generate(256, (i) => i);
    
    // Shuffle permutation
    for (int i = 255; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = perm[i];
      perm[i] = perm[j];
      perm[j] = temp;
    }
    
    _perm = [...perm, ...perm];
  }
  
  double noise(double x, double y, [double? z]) {
    if (z == null) {
      return _noise2D(x, y);
    } else {
      return _noise3D(x, y, z);
    }
  }
  
  double _noise2D(double x, double y) {
    // Noise contributions from the three corners
    double n0, n1, n2;
    
    // Skew the input space to determine which simplex cell we're in
    final F2 = 0.5 * (sqrt(3.0) - 1.0);
    final s = (x + y) * F2;
    final i = (x + s).floor();
    final j = (y + s).floor();
    
    final G2 = (3.0 - sqrt(3.0)) / 6.0;
    final t = (i + j) * G2;
    final X0 = i - t;
    final Y0 = j - t;
    final x0 = x - X0;
    final y0 = y - Y0;
    
    int i1, j1;
    if (x0 > y0) {
      i1 = 1; j1 = 0;
    } else {
      i1 = 0; j1 = 1;
    }
    
    final x1 = x0 - i1 + G2;
    final y1 = y0 - j1 + G2;
    final x2 = x0 - 1.0 + 2.0 * G2;
    final y2 = y0 - 1.0 + 2.0 * G2;
    
    final ii = i & 255;
    final jj = j & 255;
    final gi0 = _perm[ii + _perm[jj]] % 12;
    final gi1 = _perm[ii + i1 + _perm[jj + j1]] % 12;
    final gi2 = _perm[ii + 1 + _perm[jj + 1]] % 12;
    
    // Calculate the contribution from the three corners
    var t0 = 0.5 - x0 * x0 - y0 * y0;
    if (t0 < 0) {
      n0 = 0.0;
    } else {
      t0 *= t0;
      n0 = t0 * t0 * _dot(_grad3[gi0], x0, y0);
    }
    
    var t1 = 0.5 - x1 * x1 - y1 * y1;
    if (t1 < 0) {
      n1 = 0.0;
    } else {
      t1 *= t1;
      n1 = t1 * t1 * _dot(_grad3[gi1], x1, y1);
    }
    
    var t2 = 0.5 - x2 * x2 - y2 * y2;
    if (t2 < 0) {
      n2 = 0.0;
    } else {
      t2 *= t2;
      n2 = t2 * t2 * _dot(_grad3[gi2], x2, y2);
    }
    
    // Add contributions from each corner to get the final noise value
    return 70.0 * (n0 + n1 + n2);
  }
  
  double _noise3D(double x, double y, double z) {
    // Simplex noise implementation for 3D
    // This is a simplified version
    return (sin(x * 0.1) + sin(y * 0.1) + sin(z * 0.1)) / 3.0;
  }
  
  double _dot(List<double> g, double x, double y) {
    return g[0] * x + g[1] * y;
  }
  
  static const List<List<double>> _grad3 = [
    [1,1,0],[-1,1,0],[1,-1,0],[-1,-1,0],
    [1,0,1],[-1,0,1],[1,0,-1],[-1,0,-1],
    [0,1,1],[0,-1,1],[0,1,-1],[0,-1,-1]
  ];
}