// Constants used throughout the application
class Constants {
  // Private constructor to prevent instantiation
  Constants._();
  
  // App general constants
  static const String appName = 'D&D OldSchool';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String homeRoute = '/';
  static const String characterRoute = '/character';
  static const String inventoryRoute = '/inventory';
  static const String spellsRoute = '/spells';
  
  // Asset paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';
  
  // API endpoints (if needed)
  static const String baseApiUrl = 'https://api.example.com';
  
  // Shared Preferences keys
  static const String prefsCharacterKey = 'character_data';
  static const String prefsSettingsKey = 'app_settings';
  
  // Default values
  static const int defaultAnimationDuration = 300; // milliseconds
  static const double defaultPadding = 16.0;
  static const double defaultMargin = 8.0;
}