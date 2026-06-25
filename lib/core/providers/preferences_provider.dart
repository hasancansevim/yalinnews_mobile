import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

class PreferencesNotifier extends Notifier<List<String>> {
  static const _categoriesKey = 'selected_categories';
  static const _onboardingCompleteKey = 'onboarding_complete';

  @override
  List<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return prefs.getStringList(_categoriesKey) ?? [];
  }

  Future<void> toggleCategory(String category) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final currentCategories = prefs.getStringList(_categoriesKey) ?? [];
    
    if (currentCategories.contains(category)) {
      currentCategories.remove(category);
    } else {
      currentCategories.add(category);
    }
    
    await prefs.setStringList(_categoriesKey, currentCategories);
    state = currentCategories;
  }
  
  Future<void> setCategories(List<String> categories) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setStringList(_categoriesKey, categories);
    state = categories;
  }

  bool isOnboardingComplete() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_onboardingCompleteKey, true);
  }
}

final preferencesProvider = NotifierProvider<PreferencesNotifier, List<String>>(() {
  return PreferencesNotifier();
});
