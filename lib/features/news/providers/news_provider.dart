import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/news_service.dart';
import '../models/news_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/providers/preferences_provider.dart';

final newsServiceProvider = Provider((ref) {
  final client = ref.watch(dioClientProvider);
  return NewsService(client);
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  final service = ref.watch(newsServiceProvider);
  return service.getCategories();
});

class SelectedCategoryNotifier extends Notifier<CategoryModel?> {
  @override
  CategoryModel? build() => null;

  void selectCategory(CategoryModel? category) {
    state = category;
  }
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, CategoryModel?>(() {
  return SelectedCategoryNotifier();
});

class NewsPaginationState {
  final List<NewsModel> news;
  final int page;
  final bool isLoading;
  final bool hasMore;

  NewsPaginationState({
    this.news = const [],
    this.page = 1,
    this.isLoading = false,
    this.hasMore = true,
  });

  NewsPaginationState copyWith({
    List<NewsModel>? news,
    int? page,
    bool? isLoading,
    bool? hasMore,
  }) {
    return NewsPaginationState(
      news: news ?? this.news,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class NewsNotifier extends Notifier<NewsPaginationState> {
  @override
  NewsPaginationState build() {
    // Initial state, but we fetch immediately
    Future.microtask(() => fetchFirstPage());
    return NewsPaginationState();
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, page: 1, hasMore: true);
    try {
      final service = ref.read(newsServiceProvider);
      final category = ref.read(selectedCategoryProvider);
      
      List<NewsModel> fetchedNews = [];
      if (category?.id == -1) {
        final prefs = ref.read(preferencesProvider);
        // Fetch a bit more to ensure we have content after filtering
        final rawNews1 = await service.getNews(page: 1);
        final rawNews2 = await service.getNews(page: 2);
        final combined = [...rawNews1, ...rawNews2];
        fetchedNews = combined.where((n) => prefs.contains(n.categoryName)).toList();
      } else {
        fetchedNews = await service.getNews(page: 1, categoryId: category?.id == 0 ? null : category?.id);
      }

      state = state.copyWith(
        news: fetchedNews,
        isLoading: false,
        hasMore: fetchedNews.length == 10,
        page: 2,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(newsServiceProvider);
      final category = ref.read(selectedCategoryProvider);
      
      List<NewsModel> fetchedNews = [];
      if (category?.id == -1) {
        final prefs = ref.read(preferencesProvider);
        final rawNews1 = await service.getNews(page: state.page + 1);
        final rawNews2 = await service.getNews(page: state.page + 2);
        final combined = [...rawNews1, ...rawNews2];
        fetchedNews = combined.where((n) => prefs.contains(n.categoryName)).toList();
        state = state.copyWith(page: state.page + 2);
      } else {
        fetchedNews = await service.getNews(page: state.page, categoryId: category?.id == 0 ? null : category?.id);
      }

      state = state.copyWith(
        news: [...state.news, ...fetchedNews],
        isLoading: false,
        hasMore: fetchedNews.length == 10,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final newsListProvider = NotifierProvider<NewsNotifier, NewsPaginationState>(() {
  return NewsNotifier();
});

final newsDetailProvider = FutureProvider.family<NewsModel, String>((ref, slug) {
  final service = ref.watch(newsServiceProvider);
  return service.getNewsBySlug(slug);
});
