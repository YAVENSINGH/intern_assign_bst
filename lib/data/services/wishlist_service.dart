import 'package:shared_preferences/shared_preferences.dart';

class WishlistService {
  // SharedPreferences ko inject kar rahe hain testability aur Riverpod ke liye
  final SharedPreferences _prefs;

  WishlistService(this._prefs);

  // Storage key ko constant rakha hai taki spelling mistake na ho
  static const String _wishlistKey = 'wishlist_product_ids';

  /// 1. Get all Wishlist IDs
  List<int> getWishlistIds() {
    final List<String>? savedStringList = _prefs.getStringList(_wishlistKey);

    // Agar list null hai, toh empty list return karo
    if (savedStringList == null || savedStringList.isEmpty) {
      return <int>[];
    }

    // String list ko int list mein convert karna (with safety)
    return savedStringList
        .map((idString) => int.tryParse(idString))
        .whereType<int>() // Null values ko filter out karta hai
        .toList();
  }

  /// 2. Add to Wishlist
  Future<bool> addToWishlist(int id) async {
    final currentList = getWishlistIds();

    // Check karna ki ID pehle se toh nahi hai (Duplicate se bachne ke liye)
    if (!currentList.contains(id)) {
      currentList.add(id);

      // Wapas String list mein convert karke save karna
      final stringList = currentList.map((e) => e.toString()).toList();
      return await _prefs.setStringList(_wishlistKey, stringList);
    }
    return false; // Agar pehle se hai toh false return karega
  }

  /// 3. Remove from Wishlist
  Future<bool> removeFromWishlist(int id) async {
    final currentList = getWishlistIds();

    if (currentList.contains(id)) {
      currentList.remove(id);

      final stringList = currentList.map((e) => e.toString()).toList();
      return await _prefs.setStringList(_wishlistKey, stringList);
    }
    return false;
  }

  /// 4. Check if item is in Wishlist
  bool isInWishlist(int id) {
    final currentList = getWishlistIds();
    return currentList.contains(id);
  }

  /// 5. Clear entire Wishlist
  Future<bool> clearWishlist() async {
    return await _prefs.remove(_wishlistKey);
  }
}