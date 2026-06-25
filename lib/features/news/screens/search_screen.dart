import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/news_provider.dart';

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final searchResultsProvider = FutureProvider.family<List<dynamic>, String>((ref, query) async {
  if (query.isEmpty) return [];
  
  final service = ref.watch(newsServiceProvider);
  // Fetch a couple of pages and filter locally since there's no native search endpoint
  try {
    final page1 = await service.getNews(page: 1);
    final page2 = await service.getNews(page: 2);
    final allNews = [...page1, ...page2];
    
    final lowerQuery = query.toLowerCase();
    return allNews.where((n) => n.title.toLowerCase().contains(lowerQuery)).toList();
  } catch (e) {
    return [];
  }
});

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: const InputDecoration(
            hintText: 'Haberlerde ara...',
            border: InputBorder.none,
          ),
          onChanged: (val) {
            ref.read(searchQueryProvider.notifier).updateQuery(val);
          },
        ),
      ),
      body: query.isEmpty
          ? Center(
              child: Text(
                'Aramak istediğiniz kelimeyi girin.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            )
          : searchResults.when(
              data: (newsList) {
                if (newsList.isEmpty) {
                  return Center(
                    child: Text(
                      'Sonuç bulunamadı.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: newsList.length,
                  itemBuilder: (context, index) {
                    final news = newsList[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          news.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey,
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                      title: Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        news.categoryName,
                        style: TextStyle(color: AppColors.primary, fontSize: 12),
                      ),
                      onTap: () {
                        context.push('/news/${news.slug}');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Hata oluştu: $e')),
            ),
    );
  }
}
