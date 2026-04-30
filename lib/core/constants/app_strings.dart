/// App-wide static strings
class AppStrings {
  AppStrings._();

  // ─── App ───────────────────────────────────────────
  static const String appName = 'ProMedia';
  static const String appTagline = 'Discover Amazing Products';

  // ─── Screen Titles ─────────────────────────────────
  static const String homeTitle = 'Products';
  static const String productDetailTitle = 'Product Detail';
  static const String wishlistTitle = 'My Wishlist';

  // ─── Search ────────────────────────────────────────
  static const String searchHint = 'Search products...';
  static const String noSearchResults = 'No products found';
  static const String searchResultsFor = 'Results for';

  // ─── Filter ────────────────────────────────────────
  static const String filterTitle = 'Filter Products';
  static const String categoryLabel = 'Category';
  static const String priceRangeLabel = 'Price Range';
  static const String ratingLabel = 'Rating';
  static const String allCategories = 'All';
  static const String applyFilters = 'Apply Filters';
  static const String resetFilters = 'Reset';

  // ─── Product ───────────────────────────────────────
  static const String addToWishlist = 'Add to Wishlist';
  static const String removeFromWishlist = 'Remove from Wishlist';
  static const String inStock = 'In Stock';
  static const String outOfStock = 'Out of Stock';
  static const String description = 'Description';
  static const String reviews = 'reviews';
  static const String off = 'OFF';

  // ─── Wishlist ──────────────────────────────────────
  static const String wishlistEmpty = 'Your wishlist is empty';
  static const String wishlistEmptySubtitle =
      'Start adding products you love!';
  static const String browseProducts = 'Browse Products';
  static const String clearAll = 'Clear All';
  static const String removeItem = 'Remove';

  // ─── Loading & Error ───────────────────────────────
  static const String loading = 'Loading...';
  static const String loadingMore = 'Loading more products...';
  static const String errorGeneric = 'Something went wrong';
  static const String errorNoInternet = 'No internet connection';
  static const String errorTimeout = 'Request timed out';
  static const String retry = 'Retry';
  static const String offlineMode = 'You are viewing cached data';

  // ─── Pagination ────────────────────────────────────
  static const String noMoreProducts = 'No more products to load';
}
