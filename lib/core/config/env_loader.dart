import 'package:flutter/foundation.dart';

import 'env_config.dart';
import 'env_loader_io.dart' if (dart.library.html) 'env_loader_web.dart'
    as platform;

/// Loads environment variables from various sources
Future<void> loadEnvironment() async {
  // Check if env vars are passed via --dart-define first (used in production/release)
  if (EnvConfig.isCompileTimeConfig) {
    debugPrint('✅ Loaded from --dart-define (compile-time)');
    debugPrint('   API Key: ${EnvConfig.notionApiKey.substring(0, 10)}...');
    return;
  }

  // Platform-specific loading (file system for desktop/mobile)
  await platform.loadEnvFromPlatform();
  
  if (EnvConfig.isConfigured) {
    debugPrint('✅ Loaded from .env file');
  } else {
    debugPrint('⚠️ Environment variables not configured!');
  }
}
