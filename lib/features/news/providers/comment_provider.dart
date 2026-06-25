import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/comment_service.dart';
import '../models/comment_model.dart';
import '../../auth/providers/auth_provider.dart';

final commentServiceProvider = Provider((ref) {
  final client = ref.watch(dioClientProvider);
  return CommentService(client);
});

final commentListProvider = FutureProvider.family.autoDispose<List<CommentModel>, int>((ref, newsId) {
  final service = ref.watch(commentServiceProvider);
  return service.getCommentsByNewsId(newsId);
});
