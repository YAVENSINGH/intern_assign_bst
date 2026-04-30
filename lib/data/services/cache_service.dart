import 'dart:developer' as dev;
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  // Box ka naam (Humare Godown ka label)
  static const String _boxName = 'api_cache_box';

  Box<String>? _box;

  /// Call after Hive.initFlutter() in main.dart
  Future<void> init() async {
    try {
      _box = await Hive.openBox<String>(_boxName);
      dev.log('✅ CacheService Initialized');
    } catch (e) {
      dev.log('❌ Hive Initialization Failed: $e');
      throw Exception('Cache Database Error');
    }
  }

  Future<void> cacheResponse(String key, String jsonData) async {
    if (_box == null) {
      dev.log('⚠️ Cache Box is not open! Cannot save data.');
      return;
    }

    try {
      await _box!.put(key, jsonData);
      dev.log('📦 Data Cached Successfully for key: $key');
    } catch (e) {
      dev.log('❌ Failed to cache data: $e');
    }
  }

  String? getCachedResponse(String key) {
    if (_box == null) {
      dev.log('⚠️ Cache Box is not open!');
      return null;
    }

    final data = _box!.get(key);

    if (data != null) {
      dev.log('✅ Cache Hit for key: $key');
    } else {
      dev.log('⚠️ Cache Miss for key: $key');
    }

    return data;
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    if (_box == null) {
      dev.log('⚠️ Cache Box is not open!');
      return;
    }
    await _box!.clear();
    dev.log('🗑️ Cache Cleared');
  }
}