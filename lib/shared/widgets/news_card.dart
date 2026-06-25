import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';

class NewsCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String category;
  final String date;
  final VoidCallback onTap;

  const NewsCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppColors.getCategoryColor(category);

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Hero(
                    tag: 'news_image_$imageUrl',
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 72,
                      height: 56,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 72,
                        height: 56,
                        color: AppColors.surfaceDark,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 72,
                        height: 56,
                        color: AppColors.surfaceDark,
                        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 24),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Right Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: categoryColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            date,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5, color: AppColors.divider),
        ],
      ),
    );
  }
}
