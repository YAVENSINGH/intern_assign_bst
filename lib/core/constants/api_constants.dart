/// API constants for DummyJSON Products API
class ApiConstants {
  ApiConstants._();

  // ─── Base URL ──────────────────────────────────────
  static const String baseUrl = 'https://dummyjson.com';

  // ─── Product Endpoints ─────────────────────────────
  static const String products = '/products';
  static const String productSearch = '/products/search';
  static const String productCategories = '/products/categories';
  static String productById(int id) => '/products/$id';
  static String productsByCategory(String category) =>
      '/products/category/$category';

  // ─── Pagination ────────────────────────────────────
  static const int pageSize = 10;

  // ─── Timeouts ──────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
