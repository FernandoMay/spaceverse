// lib/core/services/firebase_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Initialize Firebase services
    await _initializeAuth();
    await _initializeAnalytics();
    await _initializeCrashlytics();
    await _initializeRemoteConfig();
    await _initializeMessaging();
  }
  
  static Future<void> _initializeAuth() async {
    // Configure Firebase Auth
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }
  
  static Future<void> _initializeAnalytics() async {
    // Configure Firebase Analytics
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
  }
  
  static Future<void> _initializeCrashlytics() async {
    // Configure Firebase Crashlytics
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    
    // Set user identifier
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
    }
  }
  
  static Future<void> _initializeRemoteConfig() async {
    // Configure Firebase Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    
    await remoteConfig.setDefaults({
      'feature_ar_enabled': true,
      'feature_ml_enabled': true,
      'max_universe_size': 1000,
      'max_exoplanet_discoveries': 100,
    });
    
    await remoteConfig.fetchAndActivate();
  }
  
  static Future<void> _initializeMessaging() async {
    // Configure Firebase Messaging
    final messaging = FirebaseMessaging.instance;
    
    // Request permission
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      final token = await messaging.getToken();
      print('FCM Token: $token');
    }
  }
}