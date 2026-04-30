import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/product_provider.dart';


// ─── HELPER FUNCTION ──────────────────────────────────────────────────
// Ise tum Grid Screen ke app bar mein filter icon press hone pe call karoge
void showFilterBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Keyboard ya badi list aane pe screen adjust hogi
    backgroundColor: Colors.transparent,
    builder: (context) => const FilterBottomSheet(),
  );
}

// ─── BOTTOM SHEET WIDGET ──────────────────────────────────────────────
class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  // Local state for UI interactions before user hits "Apply"
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 2000);

  @override
  void initState() {
    super.initState();
    // Agar pehle se koi category selected hai (Riverpod state se), toh use yahan load karo
    _selectedCategory = ref.read(selectedCategoryProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Categories provider ko watch kiya (API loading, success, ya error handle karne ke liye)
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.bottomSheetRadius)),
      ),
      // SafeArea taaki bottom navigation bar ya iPhone ke notch pe overlap na ho
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Jitna content, utni height
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Section ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.filterTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // ─── Categories Section ───
            Text(
              AppStrings.categoryLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // AsyncValue handling for categories (Smart UI)
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error loading categories', style: TextStyle(color: Colors.red.shade400)),
              data: (categories) {
                return Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      checkmarkColor: AppColors.onPrimary,
                      backgroundColor: AppColors.surfaceVariant,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // ─── Price Range Section ───
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.priceRangeLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            RangeSlider(
              values: _priceRange,
              min: 0,
              max: 2000,
              divisions: 20, // 100-100 ke steps banayega
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Colors.grey.shade300,
              labels: RangeLabels(
                '\$${_priceRange.start.toInt()}',
                '\$${_priceRange.end.toInt()}',
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _priceRange = values;
                });
              },
            ),

            const SizedBox(height: 32),

            // ─── Bottom Action Buttons ───
            Row(
              children: [
                // Reset Button
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {
                      // 1. Local state clear karo
                      setState(() {
                        _selectedCategory = null;
                        _priceRange = const RangeValues(0, 2000);
                      });

                      // 2. Global state clear karo
                      ref.read(selectedCategoryProvider.notifier).state = null;
                      ref.read(productProvider.notifier).fetchProducts(); // Wapas saare products lao

                      // 3. Sheet close karo
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(AppStrings.resetFilters),
                  ),
                ),
                const SizedBox(width: 16),

                // Apply Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      // 1. Global category provider update karo
                      ref.read(selectedCategoryProvider.notifier).state = _selectedCategory;

                      // 2. API trigger karo base on selection
                      if (_selectedCategory != null) {
                        ref.read(productProvider.notifier).filterByCategory(_selectedCategory!);
                      } else {
                        ref.read(productProvider.notifier).fetchProducts();
                      }

                      // Note: DummyJSON API doesn't support complex multi-filters (price + category) natively
                      // via a single endpoint without local sorting, so we applied category filter for now.

                      // 3. Sheet close karo
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(AppStrings.applyFilters, style: TextStyle(color: AppColors.onPrimary)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}