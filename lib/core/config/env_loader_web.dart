import 'package:flutter/foundation.dart';

/// Web platform doesn't support file system access
/// Environment variables must be passed via --dart-define during build
Future<void> loadEnvFromPlatform() async {
  debugPrint('❌ No environment variables set for web.');
  debugPrint('   Build with: flutter build web --dart-define=NOTION_API_KEY=xxx --dart-define=NOTION_DATABASE_ID=xxx');
}
