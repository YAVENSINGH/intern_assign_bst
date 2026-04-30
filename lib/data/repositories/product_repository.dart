import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../models/product_response_model.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';


class ProductRepository {
  // Dependency Injection 💉
  final ApiService _apiService;
  final CacheService _cacheService;

  ProductRepository(this._apiService, this._cacheService);

  /// 🛠️ THE MASTER HELPER (Pro Move)
  /// Ye function API call, caching aur offline fallback sab akele handle karta hai.
  /// DRY (Don't Repeat Yourself) principle in action!
  Future<T> _fetchData<T>({
    required String endpoint,
    Map<String, String>? queryParams,
    required String cacheKey,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      // 1. API (Field Agent) se naya data mangwao
      final response = await _apiService.get(
        endpoint,
        queryParams: queryParams,
      );

      // 2. Data aate hi Godown (Cache) mein raw string format mein save kar lo
      await _cacheService.cacheResponse(cacheKey, jsonEncode(response));

      // 3. Response ko Object (Model) mein map karke return karo
      return fromJson(response);
    } catch (e) {
      // 4. OFFLINE FALLBACK 🚨: Agar internet nahi hai, toh Cache se try karo
      final cachedString = _cacheService.getCachedResponse(cacheKey);

      if (cachedString != null) {
        // Tumhara style: Explicit type casting for safety!
        final decodedMap = jsonDecode(cachedString) as Map<String, dynamic>;
        return fromJson(decodedMap);
      }

      // 5. Agar Godown bhi khali hai, tab finally error throw karo
      throw Exception('Network failed & no offline data available: $e');
    }
  }

  // ─── 1. Get Products ──────────────────────────────────────
  Future<ProductResponse> getProducts({
    int skip = 0,
    int limit = ApiConstants.pageSize,
  }) async {
    final queryParams = {
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    // Cache key mein params zaroor dalna taaki Page 1 aur Page 2 mix na hon
    final cacheKey = '${ApiConstants.products}?skip=$skip&limit=$limit';

    return _fetchData(
      endpoint: ApiConstants.products,
      queryParams: queryParams,
      cacheKey: cacheKey,
      fromJson: (json) => ProductResponse.fromJson(json),
    );
  }

  // ─── 2. Search Products ───────────────────────────────────
  Future<ProductResponse> searchProducts(String query) async {
    final queryParams = {'q': query};
    final cacheKey = '${ApiConstants.productSearch}?q=$query';

    return _fetchData(
      endpoint: ApiConstants.productSearch,
      queryParams: queryParams,
      cacheKey: cacheKey,
      fromJson: (json) => ProductResponse.fromJson(json),
    );
  }

  // ─── 3. Get Products By Category ──────────────────────────
  Future<ProductResponse> getProductsByCategory(String category) async {
    final endpoint = ApiConstants.productsByCategory(category);

    return _fetchData(
      endpoint: endpoint,
      cacheKey: endpoint, // Yahan endpoint hi cache key ban sakti hai
      fromJson: (json) => ProductResponse.fromJson(json),
    );
  }

  // ─── 4. Get Single Product By ID ──────────────────────────
  Future<Product> getProductById(int id) async {
    final endpoint = ApiConstants.productById(id);

    return _fetchData(
      endpoint: endpoint,
      cacheKey: endpoint,
      fromJson: (json) => Product.fromJson(json),
    );
  }

  // ─── 5. Get Categories ────────────────────────────────────
  /// NOTE: This endpoint returns a JSON Array, not a Map.
  /// So we can't use _fetchData here — handling separately.
  Future<List<String>> getCategories() async {
    final endpoint = ApiConstants.productCategories;
    final cacheKey = endpoint;

    try {
      final response = await _apiService.get(endpoint);

      // DummyJSON returns list of objects: [{"slug": "beauty", "name": "Beauty"}, ...]
      final categories = <String>[];
      if (response.containsKey('categories')) {
        categories.addAll(
          (response['categories'] as List).map((e) => e['name'].toString()),
        );
      }

      // Cache the result
      await _cacheService.cacheResponse(cacheKey, jsonEncode(categories));
      return categories;
    } catch (e) {
      // Offline fallback
      final cached = _cacheService.getCachedResponse(cacheKey);
      if (cached != null) {
        return (jsonDecode(cached) as List).map((e) => e.toString()).toList();
      }
      throw Exception('Failed to load categories: $e');
    }
  }
}