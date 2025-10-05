// lib/app/constants/app_constants.dart
class AppConstants {
  // App Information
  static const String appName = 'SpaceVerse';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  
  // Environment
  static const bool isDebugMode = true;
  static const bool isProductionMode = false;
  
  // API Keys (should be stored securely in production)
  static const String nasaApiKey = 'DEMO_KEY';
  static const String weatherApiKey = 'demo_key';
  static const String blockchainApiKey = 'demo_key';
  
  // API URLs
  static const String nasaBaseUrl = 'https://api.nasa.gov';
  static const String weatherBaseUrl = 'https://api.meteomatics.com';
  static const String blockchainUrl = 'https://mainnet.infura.io/v3';
  
  // Universe Generation
  static const int defaultUniverseSeed = 42;
  static const int maxGalaxyCount = 1000;
  static const int maxStarCount = 10000;
  static const double maxUniverseSize = 1e22; // 10 million light years
  
  // Exoplanet Detection
  static const int maxExoplanetDiscoveries = 100;
  static const double minConfidenceThreshold = 0.7;
  static const int maxLightCurvePoints = 1000;
  
  // Habitat Design
  static const double maxHabitatVolume = 10000.0; // cubic meters
  static const int maxCrewSize = 20;
  static const int maxMissionDuration = 1000; // days
  
  // AR/VR
  static const double maxARObjectSize = 10.0; // meters
  static const double minARObjectSize = 0.1; // meters
  static const int maxARObjects = 10;
  
  // Social
  static const int maxPostLength = 500;
  static const int maxCommentLength = 200;
  static const int maxImageCount = 10;
  static const int maxFollowCount = 1000;
  
  // Cache
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB
  static const Duration cacheExpiration = Duration(hours: 24);
  
  // Animation
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const Duration shortAnimationDuration = Duration(milliseconds: 150);
  
  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  // File paths
  static const String modelsPath = 'assets/models/';
  static const String imagesPath = 'assets/images/';
  static const String animationsPath = 'assets/animations/';
  static const String dataPath = 'assets/data/';
  
  // Storage Keys
  static const String userPreferencesKey = 'user_preferences';
  static const String userProfileKey = 'user_profile';
  static const String discoveriesKey = 'discoveries';
  static const String designsKey = 'habitat_designs';
  static const String universeSeedKey = 'universe_seed';
  
  // Error Messages
  static const String networkErrorMessage = 'Network error occurred. Please check your connection.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String unknownErrorMessage = 'An unknown error occurred. Please try again.';
  
  // Success Messages
  static const String discoverySavedMessage = 'Discovery saved successfully!';
  static const String designSavedMessage = 'Design saved successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  
  // Feature Flags
  static const bool arFeatureEnabled = true;
  static const bool mlFeatureEnabled = true;
  static const bool socialFeatureEnabled = true;
  static const bool blockchainFeatureEnabled = true;
  
  // Limits
  static const int maxUniverseGenerationsPerDay = 10;
  static const int maxExoplanetAnalysesPerDay = 50;
  static const int maxHabitatDesignsPerDay = 20;
  static const int maxSharesPerDay = 30;
}