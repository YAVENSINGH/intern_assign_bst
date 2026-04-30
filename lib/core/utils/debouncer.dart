import 'dart:async';

/// Debouncer utility to delay action execution.
/// Used primarily for search input to avoid excessive API calls.
///
/// Usage:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 500);
/// debouncer.run(() => searchProducts(query));
/// ```
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  /// Runs the [action] after the debounce delay.
  /// Cancels any previously scheduled action.
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancels any pending action.
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer. Call this in widget's dispose method.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

typedef VoidCallback = void Function();
