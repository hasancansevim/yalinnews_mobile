class CommentModel {
  final int? id;
  final int newsId;
  final int userId;
  final String content;
  final DateTime? createdAt;
  final String? userName;

  CommentModel({
    this.id,
    required this.newsId,
    required this.userId,
    required this.content,
    this.createdAt,
    this.userName,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      newsId: json['newsId'] ?? 0,
      userId: json['userId'] ?? 0,
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'newsId': newsId,
      'userId': userId,
      'content': content,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}
