import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/news_provider.dart';
import '../models/news_model.dart';
import '../../../shared/widgets/news_card.dart';
import '../../../shared/widgets/hero_news_card.dart';
import '../../../shared/widgets/category_chip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(newsListProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'YalınNews',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.search, size: 18),
              onPressed: () {},
            ),
          ),
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(color: Color(0xFF1A1A1A), shape: BoxShape.circle),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.notifications_none, size: 18),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(newsListProvider.notifier).fetchFirstPage();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Breaking News Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFF334155).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: Color(0xFFEF4444), size: 6),
                          SizedBox(width: 4),
                          Text(
                            'SON DAKİKA',
                            style: TextStyle(
                              color: Color(0xFFEF4444), 
                              fontSize: 10, 
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Yapay zeka modelleri sınırları zorluyor: Yeni gelişmeler!',
                        style: TextStyle(
                          color: Color(0xFFE2E8F0), 
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: categoriesAsync.when(
                  data: (categories) {
                    final allCategories = [
                      CategoryModel(id: 0, name: 'Tümü'),
                      ...categories,
                    ];
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      itemCount: allCategories.length,
                      itemBuilder: (context, index) {
                        final category = allCategories[index];
                        final isTumu = category.id == 0;
                        final isSelected = isTumu ? selectedCategory == null : selectedCategory?.id == category.id;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: CategoryChip(
                            label: category.name,
                            isSelected: isSelected,
                            onTap: () {
                              if (isTumu) {
                                ref.read(selectedCategoryProvider.notifier).selectCategory(null);
                              } else {
                                ref.read(selectedCategoryProvider.notifier).selectCategory(category);
                              }
                              ref.read(newsListProvider.notifier).fetchFirstPage();
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, st) => const SizedBox(),
                ),
              ),
            ),
            
            // News List
            if (newsState.news.isEmpty && !newsState.isLoading)
              const SliverToBoxAdapter(
                child: Center(child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Haber bulunamadı.'),
                )),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == newsState.news.length) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ));
                      }
                      
                      final news = newsState.news[index];
                      
                      // Hero News Card for the first item
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeroNewsCard(
                              title: news.title,
                              spotText: '', // not needed for new design, removed in visual
                              imageUrl: news.imageUrl,
                              category: news.categoryName,
                              date: news.createdAt.toString().substring(0, 10),
                              onTap: () {
                                context.push('/news/${news.slug}');
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 16, bottom: 8, left: 4),
                              child: Text(
                                'Son Haberler',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      
                      // Regular News Card
                      return NewsCard(
                        title: news.title,
                        imageUrl: news.imageUrl,
                        category: news.categoryName,
                        date: news.createdAt.toString().substring(0, 10),
                        onTap: () {
                          context.push('/news/${news.slug}');
                        },
                      );
                    },
                    childCount: newsState.news.length + (newsState.hasMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
