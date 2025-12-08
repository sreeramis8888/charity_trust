import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/news_model.dart';
import 'package:Annujoom/src/data/utils/get_time_ago.dart';
import 'package:Annujoom/src/interfaces/components/text_pill.dart';
import 'package:Annujoom/src/interfaces/main_pages/news_bookmark/news_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewsCard extends ConsumerWidget {
  final NewsModel news;
  final List<NewsModel> allNews;

  const NewsCard({super.key, required this.news, required this.allNews});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = timeAgo(news.updatedAt!);

    return GestureDetector(
      onTap: () {
        final index = allNews.indexOf(news);
        if (index != -1) {
          ref.read(currentNewsIndexProvider.notifier).state = index;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NewsDetailView(news: allNews),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: kCardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                news.media ?? '',
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 85,
                  height: 85,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.broken_image, color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextPill(
                        text: news.category ?? "Latest",
                        color: kCardBackgroundColor,
                        borderColor: const Color(0xFF2EC866),
                        textStyle: kSmallTitleSB.copyWith(
                          color: const Color(0xFF2EC866),
                          fontSize: 10,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      Text(
                        time,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    news.title ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: kSmallTitleM.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    news.subTitle ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kSmallerTitleL.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
