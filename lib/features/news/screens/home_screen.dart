import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/news_provider.dart';
import '../models/news_model.dart';
import '../../../shared/widgets/news_card.dart';
import '../../../shared/widgets/hero_news_card.dart';
import '../../../shared/widgets/category_chip.dart';
import '../../../shared/widgets/yalin_app_bar.dart';

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
      appBar: const YalinAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(newsListProvider.notifier).fetchFirstPage();
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 60,
                child: categoriesAsync.when(
                  data: (categories) {
                    final allCategories = [
                      CategoryModel(id: 0, name: 'Tümü'),
                      CategoryModel(id: -1, name: 'Sana Özel'),
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
