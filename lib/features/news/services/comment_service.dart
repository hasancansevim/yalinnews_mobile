import '../../../core/network/dio_client.dart';
import '../models/comment_model.dart';

class CommentService {
  final DioClient _dioClient;

  CommentService(this._dioClient);

  Future<List<CommentModel>> getCommentsByNewsId(int newsId) async {
    try {
      final response = await _dioClient.dio.get('/api/Comments/getallbynewsid', queryParameters: {
        'newsId': newsId,
      });
      final List data = response.data['data'] ?? [];
      return data.map((json) => CommentModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Yorumlar yüklenirken bir hata oluştu: $e');
    }
  }

  Future<bool> addComment(CommentModel comment) async {
    try {
      final response = await _dioClient.dio.post('/api/Comments/add', data: comment.toJson());
      return response.data['success'] ?? false;
    } catch (e) {
      throw Exception('Yorum eklenirken hata oluştu: $e');
    }
  }
}
