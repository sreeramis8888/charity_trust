
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/models/news_model.dart';
import 'package:charity_trust/src/data/utils/get_time_ago.dart';
import 'package:charity_trust/src/interfaces/main_pages/news_bookmark/news_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewsCard extends ConsumerWidget {
  final NewsModel news;
  final List<NewsModel> allNews;

  const NewsCard({Key? key, required this.news, required this.allNews})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final time = timeAgo(news.updatedAt!);

    return GestureDetector(
      onTap: () {
        final initialIndex = allNews.indexOf(news);
        if (initialIndex != -1) {
          ref.read(currentNewsIndexProvider.notifier).state = initialIndex;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailView(news: allNews),
            ),
          );
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
            color: kBackgroundColor,
            border: Border.all(color: kStrokeColor),
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.network(
                news.media ?? '',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(9),
                      bottomLeft: Radius.circular(9),
                    ),
                  ),
                  child: Icon(Icons.broken_image, color: Colors.grey[600]),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title ?? '',
                      style: kBodyTitleB,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(right: 8.0),
            //   child: IconButton(
            //     icon: Icon(Icons.more_vert, color: Colors.grey),
            //     onPressed: () {
            //       // More options action
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}