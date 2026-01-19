import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style (will be updated by theme)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // Load environment variables
  await _loadEnv();

  runApp(
    const ProviderScope(
      child: BooktionApp(),
    ),
  );
}

Future<void> _loadEnv() async {
  // Check if env vars are passed via --dart-define first
  const apiKey = String.fromEnvironment('NOTION_API_KEY');
  const dbId = String.fromEnvironment('NOTION_DATABASE_ID');

  if (apiKey.isNotEmpty && dbId.isNotEmpty) {
    dotenv.testLoad(fileInput: '''
NOTION_API_KEY=$apiKey
NOTION_DATABASE_ID=$dbId
''');
    debugPrint('✅ Loaded from --dart-define-from-file');
    return;
  }

  // Fallback: Try to load from file system
  try {
    final possiblePaths = [
      '.env',
      '${Directory.current.path}/.env',
      // Add your project path for Linux debug mode
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

    debugPrint('❌ No .env file found and no environment variables set.');
    debugPrint('   Create a .env file in the project root with:');
    debugPrint('   NOTION_API_KEY=your_api_key');
    debugPrint('   NOTION_DATABASE_ID=your_database_id');
  } catch (e) {
    debugPrint('⚠️ Error loading .env: $e');
  }
}

class BooktionApp extends ConsumerWidget {
  const BooktionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Booktion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automático según el dispositivo
      routerConfig: router,
    );
  }
}
