import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/services/cache_service.dart';
import 'providers/product_provider.dart';
import 'providers/wishlist_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Hive for offline caching
  await Hive.initFlutter();

  // 2. Initialize CacheService (open box) BEFORE app starts
  final cacheService = CacheService();
  await cacheService.init();

  // 3. Initialize SharedPreferences for wishlist
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override providers with pre-initialized instances
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        cacheServiceProvider.overrideWithValue(cacheService),
      ],
      child: const MyApp(),
    ),
  );
}
