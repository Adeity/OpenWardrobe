import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'router/app_router.dart';

import 'models/wardrobe_item.dart';
import 'models/outfit.dart';
import 'models/brand.dart';
import 'models/item_category.dart';


Future<void> main() async {
  print('before ensureInitialized');
  WidgetsFlutterBinding.ensureInitialized();

  print('before intiFlutter');
  // Initialize Hive for local storage
  await Hive.initFlutter();

  print('Before getting the envs');
  // Initialize Supabase
  // final supabaseUrl = "http://wardrobe-supabase-915d3j-65d190-130-61-239-90.traefik.me";
  final supabaseUrl = "/supabase";
  final supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3NjQ3NzA2OTYsImV4cCI6MTg5MzQ1NjAwMCwicm9sZSI6ImFub24iLCJpc3MiOiJzdXBhYmFzZSJ9.unZYiPr0Ya77f92P2iPYchPFHbLw19lET7F5OE3rsyc";

  // --- TEMPORARY DEBUG PRINT ---
  print('URL CHECK: $supabaseUrl');
  print('KEY CHECK: $supabaseAnonKey');
  // -----------------------------

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

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
