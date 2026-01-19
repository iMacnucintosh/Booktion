import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'env_loader_io.dart' if (dart.library.html) 'env_loader_web.dart'
    as platform;

/// Loads environment variables from various sources
Future<void> loadEnvironment() async {
  // Check if env vars are passed via --dart-define first (used in production/web)
  const apiKey = String.fromEnvironment('NOTION_API_KEY');
  const dbId = String.fromEnvironment('NOTION_DATABASE_ID');

  if (apiKey.isNotEmpty && dbId.isNotEmpty) {
    dotenv.testLoad(fileInput: '''
NOTION_API_KEY=$apiKey
NOTION_DATABASE_ID=$dbId
''');
    debugPrint('✅ Loaded from --dart-define');
    return;
  }

  // Platform-specific loading (file system for desktop, nothing for web)
  await platform.loadEnvFromPlatform();
}
