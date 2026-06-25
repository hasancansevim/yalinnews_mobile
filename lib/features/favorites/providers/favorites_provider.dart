import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/favorites_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../news/models/news_model.dart';

final favoritesServiceProvider = Provider((ref) {
  final client = ref.watch(dioClientProvider);
  return FavoritesService(client);
});

class FavoritesNotifier extends AsyncNotifier<List<NewsModel>> {
  @override
  Future<List<NewsModel>> build() async {
    final service = ref.watch(favoritesServiceProvider);
    return await service.getFavorites();
  }

  Future<void> addFavorite(NewsModel news) async {
    final service = ref.watch(favoritesServiceProvider);
    try {
      await service.addFavorite(news.id);
      if (state.hasValue) {
        state = AsyncValue.data([...state.value!, news]);
      }
    } catch (e) {
      // handle error
    }
  }

  Future<void> removeFavorite(int id) async {
    final service = ref.watch(favoritesServiceProvider);
    try {
      await service.removeFavorite(id);
      if (state.hasValue) {
        state = AsyncValue.data(state.value!.where((n) => n.id != id).toList());
      }
    } catch (e) {
      // handle error
    }
  }
}

final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<NewsModel>>(() {
  return FavoritesNotifier();
});
