import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/comment_model.dart';
import '../providers/news_provider.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/font_size_provider.dart';
import '../providers/comment_provider.dart';

class NewsDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const NewsDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String applyDropCap(String html) {
    // A simple regex to wrap the first letter of the first paragraph in a stylized span
    return html.replaceFirstMapped(RegExp(r'<p[^>]*>\s*([a-zA-ZÇĞİÖŞÜçğıöşü])'), (match) {
      return '<p><span style="color: #3A7BD5; font-size: 56px; font-weight: bold; float: left; line-height: 1; margin-right: 8px;">${match.group(1)}</span>';
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(newsDetailProvider(widget.slug));
    final authState = ref.watch(authProvider);
    final fontScale = ref.watch(fontSizeProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Text('A-', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => ref.read(fontSizeProvider.notifier).decrease(),
          ),
          IconButton(
            icon: const Text('A+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            onPressed: () => ref.read(fontSizeProvider.notifier).increase(),
          ),
          IconButton(
            icon: Icon(Icons.share, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Share.share('YalınNews\'te bu haberi oku: https://yalinnews.com/news/${widget.slug}');
            },
          ),
        ],
      ),
      body: newsAsync.when(
        data: (news) {
          String sourceText = '';
          String htmlContent = news.content;
          final int sourceIndex = htmlContent.lastIndexOf('Kaynak:');
          if (sourceIndex != -1) {
             final afterSource = htmlContent.substring(sourceIndex + 7);
             sourceText = afterSource.replaceAll(RegExp(r'<[^>]*>'), '').trim();
             htmlContent = htmlContent.substring(0, sourceIndex);
          }

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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
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
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12),
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
                        foregroundColor: Theme.of(context).colorScheme.onSurface,
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
                  data: applyDropCap(htmlContent),
                  style: {
                    "body": Style(
                      fontSize: FontSize(16.0 * fontScale),
                      lineHeight: const LineHeight(1.8),
                      color: Theme.of(context).colorScheme.onSurface,
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "p": Style(
                      margin: Margins.only(bottom: 16.0 * fontScale),
                    ),
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Source section (if parsed)
                if (sourceText.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Kaynak: ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        sourceText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

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
                
                // Comments Section
                const Divider(color: AppColors.divider),
                const SizedBox(height: 24),
                Text(
                  'Yorumlar',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Add Comment Input
                if (authState.value == true) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Habere yorum yap...',
                            hintStyle: const TextStyle(color: AppColors.textMuted),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          maxLines: 3,
                          minLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () async {
                          if (_commentController.text.trim().isEmpty) return;
                          
                          // We need the user ID. For now we assume we can get it from authState or just send 1 as a fallback.
                          // Ideally, user object is in authState. 
                          final success = await ref.read(commentServiceProvider).addComment(
                            CommentModel(
                              newsId: news.id,
                              userId: 1, // fallback
                              content: _commentController.text.trim(),
                            ),
                          );
                          
                          if (!mounted) return;
                          
                          if (success) {
                            _commentController.clear();
                            ref.invalidate(commentListProvider(news.id));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yorum eklendi!')));
                          }
                        },
                        icon: const Icon(Icons.send),
                        color: AppColors.primary,
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Center(
                      child: Text(
                        'Yorum yapmak için giriş yapmalısınız.',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                
                // Comments List
                Consumer(
                  builder: (context, ref, child) {
                    final commentsState = ref.watch(commentListProvider(news.id));
                    return commentsState.when(
                      data: (comments) {
                        if (comments.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.0),
                            child: Center(
                              child: Text(
                                'Henüz yorum yapılmamış. İlk yorumu sen yap!',
                                style: TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic),
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFF1E293B),
                                        radius: 16,
                                        child: Text(
                                          comment.userName != null && comment.userName!.isNotEmpty 
                                              ? comment.userName![0].toUpperCase() 
                                              : 'K',
                                          style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            comment.userName ?? 'Kullanıcı ${comment.userId}',
                                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                          if (comment.createdAt != null)
                                            Text(
                                              comment.createdAt!.toString().substring(0, 16),
                                              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    comment.content,
                                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, st) => Center(child: Text('Yorumlar yüklenemedi: $err')),
                    );
                  },
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
