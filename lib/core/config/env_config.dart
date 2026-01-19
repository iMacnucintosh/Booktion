import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for environment variables
/// 
/// Priority:
/// 1. Compile-time constants from --dart-define-from-file (for release builds)
/// 2. Runtime dotenv loading (for development with hot reload)
class EnvConfig {
  // Compile-time constants (injected via --dart-define-from-file)
  static const String _compileTimeApiKey = String.fromEnvironment('NOTION_API_KEY');
  static const String _compileTimeDatabaseId = String.fromEnvironment('NOTION_DATABASE_ID');
  
  // Use compile-time values first, fallback to dotenv
  static String get notionApiKey => 
      _compileTimeApiKey.isNotEmpty ? _compileTimeApiKey : (dotenv.env['NOTION_API_KEY'] ?? '');
  
  static String get notionDatabaseId => 
      _compileTimeDatabaseId.isNotEmpty ? _compileTimeDatabaseId : (dotenv.env['NOTION_DATABASE_ID'] ?? '');

  static bool get isConfigured =>
      notionApiKey.isNotEmpty && notionDatabaseId.isNotEmpty;
  
  /// Returns true if using compile-time configuration
  static bool get isCompileTimeConfig => _compileTimeApiKey.isNotEmpty;

  static Future<void> load() async {
    // Only load dotenv if compile-time vars are not available
    if (!isCompileTimeConfig) {
      try {
        await dotenv.load(fileName: '.env');
      } catch (e) {
        // .env file not found, might be using compile-time config
      }
    }
  }
}
