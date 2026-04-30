import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/api_constants.dart';
import '../data/models/product_model.dart';
import '../data/repositories/product_repository.dart';
import '../data/services/api_service.dart';
import '../data/services/cache_service.dart';


// ─── 1. Basic Dependency Providers 💉 ──────────────────────────────

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final cacheServiceProvider = Provider<CacheService>((ref) => CacheService());

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    ref.read(apiServiceProvider),
    ref.read(cacheServiceProvider),
  );
});

// ─── 2. State Classes (Search & Category) 🔍 ───────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// ─── 3. FutureProvider for Categories 🏷️ ──────────────────────────

final categoriesProvider = FutureProvider<List<String>>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return repository.getCategories();
});

// ─── 4. Product State Class 📦 ─────────────────────────────────────

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentSkip;

  ProductState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentSkip = 0,
  });

  // copyWith method UI ko smoothly update karne ke liye (Immutable State)
  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error, // Error reset karne ke liye hum null handle karenge
    bool? hasMore,
    int? currentSkip,
    bool clearError = false,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
    );
  }
}

// ─── 5. StateNotifier for Products (The Brain) 🧠 ──────────────────

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductRepository _repository;

  ProductNotifier(this._repository) : super(ProductState()) {
    // Jaise hi provider banega, pehli API call hit ho jayegi
    fetchProducts();
  }

  /// Initial Load (Fresh Start)
  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repository.getProducts(skip: 0);

      state = state.copyWith(
        products: response.products,
        isLoading: false,
        currentSkip: 0,
        hasMore: response.products.length == ApiConstants.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Pagination (Infinite Scroll)
  Future<void> fetchMoreProducts() async {
    // Agar pehle se load ho raha hai ya aur data nahi hai, toh rok do
    if (state.isLoading || !state.hasMore) return;

    // Background loading state (UI ko hang hone se bachane ke liye)
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final nextSkip = state.currentSkip + ApiConstants.pageSize;
      final response = await _repository.getProducts(skip: nextSkip);

      state = state.copyWith(
        // Purane products ke sath naye products append kar diye
        products: [...state.products, ...response.products],
        isLoading: false,
        currentSkip: nextSkip,
        // Agar aane wale items pageSize se kam hain, matlab data khatam!
        hasMore: response.products.length == ApiConstants.pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Search API (Overrides pagination temporarily)
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      // Agar search empty ho gayi, toh wapas normal feed dikhao
      return fetchProducts();
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repository.searchProducts(query);
      state = state.copyWith(
        products: response.products,
        isLoading: false,
        hasMore: false, // Search mein hum infinite scroll nahi laga rahe abhi
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Category Filter
  Future<void> filterByCategory(String category) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _repository.getProductsByCategory(category);
      state = state.copyWith(
        products: response.products,
        isLoading: false,
        hasMore: false, // Category mein infinite scroll nahi hai API end se
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// ─── 6. The Main Provider 🌟 ───────────────────────────────────────

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  final repository = ref.read(productRepositoryProvider);
  return ProductNotifier(repository);
});