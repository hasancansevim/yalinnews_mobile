import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/favorites_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/widgets/news_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    
    if (authState.value == false) {
      return Scaffold(
        appBar: AppBar(title: const Text('Favorilerim')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('Favorilerinizi görmek için giriş yapmalısınız.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.go('/profile'); // Redirects to login when unauthenticated
                },
                child: const Text('Giriş Yap'),
              ),
            ],
          ),
        ),
      );
    }

    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorilerim')),
      body: favoritesState.when(
        data: (favorites) {
          if (favorites.isEmpty) {
            return const Center(child: Text('Henüz favori haberiniz yok.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final news = favorites[index];
              return Dismissible(
                key: Key(news.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(favoritesProvider.notifier).removeFavorite(news.id);
                },
                child: NewsCard(
                  title: news.title,
                  imageUrl: news.imageUrl,
                  category: news.categoryName,
                  date: news.createdAt.toString().substring(0, 10),
                  onTap: () {
                    context.push('/news/${news.slug}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Hata: $err')),
      ),
    );
  }
}
