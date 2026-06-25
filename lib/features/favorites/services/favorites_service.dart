import '../../../core/network/dio_client.dart';
import '../../news/models/news_model.dart';

class FavoritesService {
  final DioClient _dioClient;

  FavoritesService(this._dioClient);

  Future<List<NewsModel>> getFavorites() async {
    try {
      final response = await _dioClient.dio.get('/api/Favorites');
      final data = response.data as List;
      return data.map((json) => NewsModel.fromJson(json)).toList();
    } catch (e) {
      // Return empty or dummy
      return [];
    }
  }

  Future<void> addFavorite(int newsId) async {
    await _dioClient.dio.post('/api/Favorites', data: {'newsId': newsId});
  }

  Future<void> removeFavorite(int favoriteId) async {
    await _dioClient.dio.delete('/api/Favorites/$favoriteId');
  }
}
