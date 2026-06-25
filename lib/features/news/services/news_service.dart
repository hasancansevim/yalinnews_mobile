import '../../../core/network/dio_client.dart';
import '../models/news_model.dart';

class NewsService {
  final DioClient _dioClient;

  NewsService(this._dioClient);

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dioClient.dio.get('/api/Categories/getall');
      final List data = response.data['data'] ?? [];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      // Return dummy for UI preview if API fails
      return [
        CategoryModel(id: 1, name: 'Teknoloji'),
        CategoryModel(id: 2, name: 'Ekonomi'),
        CategoryModel(id: 3, name: 'Dünya'),
      ];
    }
  }

  Future<List<NewsModel>> getNews({int page = 1, int size = 10, int? categoryId}) async {
    try {
      if (categoryId != null && categoryId > 0) {
        final response = await _dioClient.dio.get('/api/News/getbycategoryid', queryParameters: {
          'id': categoryId,
        });
        final List data = response.data['data'] ?? [];
        return data.map((json) => NewsModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        final response = await _dioClient.dio.get('/api/News/getnewsbydetails', queryParameters: {
          'page': page,
          'pageSize': size,
        });
        final List data = response.data['data'] ?? [];
        return data.map((json) => NewsModel.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      throw Exception('Haberler yüklenirken bir hata oluştu: $e');
    }
  }

  Future<NewsModel> getNewsBySlug(String slug) async {
    try {
      // Backend does not have getbyslug. The frontend uses getnewsbydetails and filters locally.
      final response = await _dioClient.dio.get('/api/News/getnewsbydetails', queryParameters: {
        'page': 1,
        'pageSize': 100 // Fetch a larger batch to find the slug
      });
      final List data = response.data['data'] ?? [];
      final newsList = data.map((json) => NewsModel.fromJson(json)).toList();
      
      return newsList.firstWhere(
        (news) => news.slug == slug,
        orElse: () => newsList.isNotEmpty ? newsList.first : throw Exception('No news found'),
      );
    } catch (e) {
      throw Exception('Failed to load news detail: $e');
    }
  }
}
