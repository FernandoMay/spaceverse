// lib/features/ar_viewer/domain/services/ar_core_controller.dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spaceverse/exceptions.dart';
// import 'package:spaceverse/core/errors/exceptions.dart';

class ArCoreController {
  static const MethodChannel _channel = MethodChannel('ar_core_controller');
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Check AR availability
      final isAvailable = await checkArCoreAvailability();
      if (!isAvailable) {
        throw ARException('ARCore is not available on this device');
      }
      
      // Request camera permission
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        throw ARException('Camera permission is required for AR');
      }
      
      // Initialize AR session
      await _channel.invokeMethod('initialize');
      _isInitialized = true;
    } catch (e) {
      throw ARException('Failed to initialize AR', details: e);
    }
  }
  
  static Future<bool> checkArCoreAvailability() async {
    try {
      final result = await _channel.invokeMethod('checkArCoreAvailability');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  Future<void> addArCoreNode(ArCoreNode node) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _channel.invokeMethod('addNode', {
        'shape': node.shape.toJson(),
        'position': node.position.toJson(),
        'rotation': node.rotation?.toJson(),
        'scale': node.scale?.toJson(),
        'materials': node.materials?.map((m) => m.toJson()).toList(),
      });
    } catch (e) {
      throw ARException('Failed to add AR node', details: e);
    }
  }
  
  Future<void> removeArCoreNode(String nodeId) async {
    if (!_isInitialized) await initialize();
    
    try {
      await _channel.invokeMethod('removeNode', {'nodeId': nodeId});
    } catch (e) {
      throw ARException('Failed to remove AR node', details: e);
    }
  }
  
  Future<void> dispose() async {
    if (_isInitialized) {
      await _channel.invokeMethod('dispose');
      _isInitialized = false;
    }
  }
}

class ArCoreNode {
  final ArCoreShape shape;
  final ArCorePosition position;
  final ArCoreRotation? rotation;
  final ArCoreScale? scale;
  final List<ArCoreMaterial>? materials;
  
  ArCoreNode({
    required this.shape,
    required this.position,
    this.rotation,
    this.scale,
    this.materials,
  });
}

class ArCoreShape {
  final ArCoreShapeType type;
  final dynamic size;
  final ArCoreCustom3dModel? custom3dModel;
  
  ArCoreShape({
    required this.type,
    this.size,
    this.custom3dModel,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'size': size?.toJson(),
      'custom3dModel': custom3dModel?.toJson(),
    };
  }
}

enum ArCoreShapeType {
  sphere,
  cube,
  cylinder,
  plane,
  custom3dModel,
}

class ArCoreCustom3dModel {
  final String uri;
  
  ArCoreCustom3dModel({required this.uri});
  
  Map<String, dynamic> toJson() {
    return {'uri': uri};
  }
}

class ArCoreSphere {
  final double size;
  
  ArCoreSphere({required this.size});
  
  Map<String, dynamic> toJson() {
    return {'size': size};
  }
}

class ArCoreCube {
  final double size;
  
  ArCoreCube({required this.size});
  
  Map<String, dynamic> toJson() {
    return {'size': size};
  }
}

class ArCoreCylinder {
  final double height;
  final double radius;
  
  ArCoreCylinder({required this.height, required this.radius});
  
  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'radius': radius,
    };
  }
}

class ArCorePosition {
  final double x;
  final double y;
  final double z;
  
  ArCorePosition({
    required this.x,
    required this.y,
    required this.z,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }
}

class ArCoreRotation {
  final double x;
  final double y;
  final double z;
  final double w;
  
  ArCoreRotation({
    required this.x,
    required this.y,
    required this.z,
    required this.w,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'w': w,
    };
  }
}

class ArCoreScale {
  final double x;
  final double y;
  final double z;
  
  ArCoreScale({
    required this.x,
    required this.y,
    required this.z,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }
}

class ArCoreMaterial {
  final Color color;
  final double metallic;
  final double roughness;
  final String? textureUri;
  
  ArCoreMaterial({
    required this.color,
    required this.metallic,
    required this.roughness,
    this.textureUri,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'color': color.value,
      'metallic': metallic,
      'roughness': roughness,
      'textureUri': textureUri,
    };
  }
}