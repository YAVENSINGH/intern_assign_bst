# LUXE - Premium E-Commerce App 🛍️✨


> A highly optimized, production-grade E-Commerce mobile application built with Flutter. It focuses on delivering a seamless shopping experience with a "LUXE" minimal UI, offline-first capabilities, and blazing-fast performance.

## ✨ Key Features

* **Offline Fallback (Smart Caching):** Uses **Hive** NoSQL database. If the internet drops, the app instantly serves the last loaded products without crashing.
* **Highly Optimized Search:** Integrated a custom **Debouncer (500ms delay)** to prevent unnecessary API calls and server overloads while typing.
* **Infinite Scrolling (Pagination):** Smooth data fetching using `ScrollController` as the user scrolls to the bottom of the feed.
* **Smart Wishlist:** O(1) time complexity lookups using `Set<int>` and `SharedPreferences`. Features an elegant **Swipe-to-Delete** with an 'Undo' SnackBar.
* **Premium UI/UX:**
    * **Shimmer Loading Skeletons** for a premium loading experience.
    * **Hero Animations** for seamless image transitions between screens.
    * **SliverAppBar** with collapsing effects on the Product Detail Screen.
* **Targeted Rebuilds:** Built using `flutter_riverpod` (`Provider.family`) to ensure only specific widgets (like a single heart icon) rebuild, maintaining a 120fps experience.

## 🛠️ Tech Stack & Packages

* **Framework:** Flutter
* **Architecture:** Clean Architecture (Services, Repositories, Providers, UI Layer)
* **State Management:** `flutter_riverpod`
* **Networking:** `http`
* **Local Storage (Caching):** `hive`, `hive_flutter`
* **Local Storage (Preferences):** `shared_preferences`
* **UI Utilities:** `cached_network_image`, `shimmer`, `flutter_rating_bar`

## 📂 Architecture Overview

The project strictly follows the **Clean Architecture** pattern to separate logic from UI:
- **`services/`**: Handles raw data fetching (API Service) and raw local storage operations (Cache Service, Wishlist Service).
- **`repositories/`**: Acts as the "Manager". It decides whether to fetch data from the API or serve it from the local Cache (Offline Fallback).
- **`providers/`**: The "Brain" containing Riverpod `StateNotifiers` to manage state based on repository data.
- **`widgets/` & `screens/`**: Purely reactive UI components that listen to providers.

## 🚀 Getting Started

Follow these steps to run the project on your local machine:

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/YAVENSINGH/intern_assign_bst.git](https://github.com/YAVENSINGH/intern_assign_bst.git)