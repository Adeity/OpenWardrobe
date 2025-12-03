import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'router/app_router.dart';

import 'models/wardrobe_item.dart';
import 'models/outfit.dart';
import 'models/brand.dart';
import 'models/item_category.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Supabase
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  final envFile = File('.env');
  final configFile = File('web/config.json');

  if (!await envFile.exists()) {
    print('Error: .env file not found.');
    return;
  }

  final lines = await envFile.readAsLines();
  final config = <String, String>{};

  for (var line in lines) {
    // Simple parser for KEY=VALUE
    if (line.isNotEmpty && !line.startsWith('#') && line.contains('=')) {
      final parts = line.split('=');
      final key = parts[0].trim();
      final value = parts.sublist(1).join('=').trim(); // Rejoin in case value has =
      config[key] = value;
    }
  }

  await configFile.writeAsString(jsonEncode(config));
  print('✅ web/config.json generated from .env');


   Hive.registerAdapter(WardrobeItemAdapter());
  Hive.registerAdapter(OutfitAdapter());
  Hive.registerAdapter(BrandAdapter());
  Hive.registerAdapter(ItemCategoryAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OpenWardrobe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,  // Enable Material 3 (modern UI)
      ),
      darkTheme: ThemeData.dark(),  // Support dark mode
      themeMode: ThemeMode.system,  // Automatically switch theme

      routerConfig: AppRouter.router,
    );
  }
}
