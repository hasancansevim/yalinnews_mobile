import 'package:flutter_riverpod/flutter_riverpod.dart';

class FontSizeNotifier extends Notifier<double> {
  @override
  double build() {
    return 1.0; // Default multiplier
  }

  void increase() {
    if (state < 1.5) {
      state += 0.1;
    }
  }

  void decrease() {
    if (state > 0.8) {
      state -= 0.1;
    }
  }
}

final fontSizeProvider = NotifierProvider<FontSizeNotifier, double>(() {
  return FontSizeNotifier();
});
