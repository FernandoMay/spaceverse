// lib/core/utils/helpers.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spaceverse/logger.dart';
// import 'package:spaceverse/core/utils/logger.dart';

class Helpers {
  static Future<File> getLocalFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$filename');
  }
  
  static Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  getTemporaryDirectory() async {
    return await getTemporaryDirectory();
  }
  
  static Future<void> saveToFile(String filename, String content) async {
    try {
      final file = await getLocalFile(filename);
      await file.writeAsString(content);
      AppLogger.i('Saved to file: $filename');
    } catch (e) {
      AppLogger.e('Failed to save to file: $filename', error: e);
      rethrow;
    }
  }
  
  static Future<String> readFromFile(String filename) async {
    try {
      final file = await getLocalFile(filename);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return '';
    } catch (e) {
      AppLogger.e('Failed to read from file: $filename', error: e);
      rethrow;
    }
  }
  
  static Future<bool> fileExists(String filename) async {
    try {
      final file = await getLocalFile(filename);
      return await file.exists();
    } catch (e) {
      AppLogger.e('Failed to check file existence: $filename', error: e);
      return false;
    }
  }
  
  static Future<void> deleteFile(String filename) async {
    try {
      final file = await getLocalFile(filename);
      if (await file.exists()) {
        await file.delete();
        AppLogger.i('Deleted file: $filename');
      }
    } catch (e) {
      AppLogger.e('Failed to delete file: $filename', error: e);
      rethrow;
    }
  }
  
  static void showSnackBar(BuildContext context, String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  static Future<String?> showTextInputDialog(
    BuildContext context, {
    required String title,
    String? initialValue,
    String hintText = '',
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) async {
    final controller = TextEditingController(text: initialValue);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hintText),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result;
  }
  
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
  
  static Future<void> delay(Duration duration) {
    return Future.delayed(duration);
  }
  
  static Null Function() debounce(Function() function, Duration delay) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(delay, function);
    };
  }
  
  static Null Function() throttle(Function() function, Duration duration) {
    bool isThrottled = false;
    return () {
      if (!isThrottled) {
        function();
        isThrottled = true;
        Timer(duration, () => isThrottled = false);
      }
    };
  }
  
  static String generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(10000).toString();
  }
  
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  static String formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m ${seconds}s';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'candidate':
        return Colors.orange;
      case 'false positive':
        return Colors.red;
      case 'pending':
        return Colors.blue;
      case 'error':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'candidate':
        return Icons.help;
      case 'false positive':
        return Icons.cancel;
      case 'pending':
        return Icons.hourglass_empty;
      case 'error':
        return Icons.error;
      case 'warning':
        return Icons.warning;
      case 'success':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}