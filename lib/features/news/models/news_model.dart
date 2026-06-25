class CategoryModel {
  final int id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class NewsModel {
  final int id;
  final String title;
  final String slug;
  final String content;
  final String imageUrl;
  final String categoryName;
  final String author;
  final String authorName;
  final String spotText;
  final DateTime createdAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.imageUrl,
    required this.categoryName,
    required this.author,
    required this.authorName,
    required this.spotText,
    required this.createdAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    String mapCategory(int id) {
      switch (id) {
        case 1: return 'Teknoloji';
        case 2: return 'Ekonomi';
        case 3: return 'Dünya';
        case 4: return 'Yapay Zeka';
        case 5: return 'Oyun';
        case 6: return 'Bilim';
        default: return 'Genel';
      }
    }

    String generateSlug(String title) {
      const turkishChars = {'ı':'i','ğ':'g','ü':'u','ş':'s','ö':'o','ç':'c','İ':'i','Ğ':'g','Ü':'u','Ş':'s','Ö':'o','Ç':'c'};
      String text = title;
      turkishChars.forEach((key, value) => text = text.replaceAll(key, value));
      return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
    }

    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? generateSlug(json['title'] ?? ''),
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'] ?? 'https://via.placeholder.com/400x200',
      categoryName: mapCategory(json['categoryId'] ?? 0),
      author: 'Editör', // fallback
      authorName: json['authorName'] ?? 'YALIN AI',
      spotText: json['spotText'] ?? '',
      createdAt: json['publishDate'] != null ? DateTime.parse(json['publishDate']) : DateTime.now(),
    );
  }
}
