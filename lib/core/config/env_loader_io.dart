import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Load .env from file system (desktop/mobile only)
Future<void> loadEnvFromPlatform() async {
  try {
    final possiblePaths = [
      '.env',
      '${Directory.current.path}/.env',
      '/home/manu/Desarrollo/Projects/Booktion/.env',
    ];

    for (final path in possiblePaths) {
      final file = File(path);
      if (await file.exists()) {
        final content = await file.readAsString();
        dotenv.testLoad(fileInput: content);
        debugPrint('✅ Loaded .env from: $path');
        return;
      }
    }

    debugPrint('❌ No .env file found.');
    debugPrint('   Create a .env file in the project root with:');
    debugPrint('   NOTION_API_KEY=your_api_key');
    debugPrint('   NOTION_DATABASE_ID=your_database_id');
  } catch (e) {
    debugPrint('⚠️ Error loading .env: $e');
  }
}
