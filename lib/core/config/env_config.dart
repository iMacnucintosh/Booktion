import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuration class for environment variables
class EnvConfig {
  static String get notionApiKey => dotenv.env['NOTION_API_KEY'] ?? '';
  static String get notionDatabaseId => dotenv.env['NOTION_DATABASE_ID'] ?? '';

  static bool get isConfigured =>
      notionApiKey.isNotEmpty && notionDatabaseId.isNotEmpty;

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }
}
