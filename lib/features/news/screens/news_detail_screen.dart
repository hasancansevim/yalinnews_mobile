import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/news_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class NewsDetailScreen extends ConsumerWidget {
  final String slug;

  const NewsDetailScreen({super.key, required this.slug});

  String applyDropCap(String html) {
    // A simple regex to wrap the first letter of the first paragraph in a stylized span
    return html.replaceFirstMapped(RegExp(r'<p[^>]*>\s*([a-zA-ZÇĞİÖŞÜçğıöşü])'), (match) {
      return '<p><span style="color: #3A7BD5; font-size: 56px; font-weight: bold; float: left; line-height: 1; margin-right: 8px;">${match.group(1)}</span>';
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsDetailProvider(slug));
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              Share.share('YalınNews\'te bu haberi oku: https://yalinnews.com/news/$slug');
            },
          ),
        ],
      ),
      body: newsAsync.when(
        data: (news) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                Text(
                  'ANA SAYFA / ${news.categoryName.toUpperCase()} / ${news.title.toUpperCase()}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // Category & Date
                Row(
                  children: [
                    Text(
                      news.categoryName.toUpperCase(),
                      style: TextStyle(color: AppColors.getCategoryColor(news.categoryName), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      news.createdAt.toString().substring(0, 10),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, color: AppColors.textSecondary, size: 12),
                    const SizedBox(width: 4),
                    const Text(
                      '3 DK OKUMA SÜRESİ',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Title
                Text(
                  news.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Spot Text
                if (news.spotText.isNotEmpty)
                  Text(
                    news.spotText,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                const SizedBox(height: 24),
                
                // Author & Favorite Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF1E293B),
                          radius: 20,
                          child: Text(
                            news.authorName.isNotEmpty ? news.authorName[0] : 'Y',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  news.authorName.toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.primary),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'YALIN AI',
                                    style: TextStyle(color: AppColors.primary, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              'Yapay Zeka Destekli Editör',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        if (authState.value == true) {
                          ref.read(favoritesProvider.notifier).addFavorite(news);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favorilere eklendi!')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favoriye eklemek için giriş yapmalısınız.')));
                        }
                      },
                      icon: const Icon(Icons.favorite_border, size: 16),
                      label: const Text('Favoriye Ekle', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppColors.textMuted),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: news.imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Content with Drop Cap
                Html(
                  data: applyDropCap(news.content),
                  style: {
                    "body": Style(
                      fontSize: FontSize(16.0),
                      lineHeight: const LineHeight(1.8),
                      color: AppColors.textPrimary,
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "p": Style(
                      margin: Margins.only(bottom: 16.0),
                    ),
                  },
                ),
                
                const SizedBox(height: 40),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 16),
                
                // Disclaimer
                const Center(
                  child: Text(
                    'Bu içerik Yalın AI tarafından objektif gazetecilik ilkelerine\nbağlı kalınarak özetlenmiştir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Haber yüklenemedi: $err')),
      ),
    );
  }
}
