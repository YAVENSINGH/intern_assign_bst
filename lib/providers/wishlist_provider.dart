import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/wishlist_service.dart';


// ─── 1. SharedPreferences Provider ⚙️ ──────────────────────────────
// Note: Isko main.dart mein ProviderScope(overrides: [...]) ke andar 
// initialize karna hoga app start hone pe.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize SharedPreferences in main.dart');
});

// ─── 2. Wishlist Service Provider 🛠️ ──────────────────────────────
final wishlistServiceProvider = Provider<WishlistService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WishlistService(prefs);
});

// ─── 3. Wishlist State Class 📦 ────────────────────────────────────
class WishlistState {
  final Set<int> wishlistIds; // Set use kiya for ultra-fast lookups
  final bool isLoading;

  WishlistState({
    this.wishlistIds = const {},
    this.isLoading = false,
  });

  WishlistState copyWith({
    Set<int>? wishlistIds,
    bool? isLoading,
  }) {
    return WishlistState(
      wishlistIds: wishlistIds ?? this.wishlistIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// ─── 4. StateNotifier (The Brain) 🧠 ───────────────────────────────
class WishlistNotifier extends StateNotifier<WishlistState> {
  final WishlistService _wishlistService;

  WishlistNotifier(this._wishlistService) : super(WishlistState()) {
    loadWishlist(); // Provider bante hi purana data load kar lo
  }

  /// Load from Local Storage
  void loadWishlist() {
    state = state.copyWith(isLoading: true);
    final idsList = _wishlistService.getWishlistIds();

    state = state.copyWith(
      wishlistIds: idsList.toSet(), // List ko Set mein convert kar diya
      isLoading: false,
    );
  }

  /// Toggle Item (Optimistic UI Update 🔥)
  Future<void> toggleWishlist(int id) async {
    // Current state ki ek copy banai
    final currentIds = Set<int>.from(state.wishlistIds);
    final isAdding = !currentIds.contains(id);

    // 1. UI ko turant update kar diya (bina storage ka wait kiye)
    if (isAdding) {
      currentIds.add(id);
    } else {
      currentIds.remove(id);
    }
    state = state.copyWith(wishlistIds: currentIds);

    // 2. Background mein SharedPreferences mein save/remove hone do
    if (isAdding) {
      await _wishlistService.addToWishlist(id);
    } else {
      await _wishlistService.removeFromWishlist(id);
    }
  }

  /// Clear All
  Future<void> clearWishlist() async {
    state = state.copyWith(isLoading: true);
    await _wishlistService.clearWishlist();
    state = state.copyWith(wishlistIds: const {}, isLoading: false);
  }
}

// ─── 5. The Main Providers 🌟 ──────────────────────────────────────

final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  final service = ref.watch(wishlistServiceProvider);
  return WishlistNotifier(service);
});

// ─── 6. The Targeted Rebuilder (Pro Move) 🎯 ───────────────────────
final isInWishlistProvider = Provider.family<bool, int>((ref, id) {
  final wishlistState = ref.watch(wishlistProvider);
  return wishlistState.wishlistIds.contains(id);
});