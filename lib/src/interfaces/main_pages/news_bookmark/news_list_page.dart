import 'package:charity_trust/src/data/providers/news_provider.dart';
import 'package:charity_trust/src/interfaces/components/loading_indicator.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/utils/get_time_ago.dart';
import '../../../data/models/news_model.dart';
import 'news_page.dart';
import 'bookmark_page.dart';

class NewsListPage extends ConsumerStatefulWidget {
  const NewsListPage({super.key});

  @override
  ConsumerState<NewsListPage> createState() => _NewsListPageState();
}

class _NewsListPageState extends ConsumerState<NewsListPage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load next page when reaching bottom
      ref.read(newsListProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncNewsState = ref.watch(newsListProvider);

    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kBackgroundColor,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Icon(Icons.feed_outlined, color: kPrimaryColor, size: 22),
                SizedBox(width: 8),
                Text(
                  "News",
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: kWhite),
                ),
              ],
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.bookmark, color: kPrimaryColor, size: 22),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookmarkPage()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(width: 16),
          ],
        ),
        body: asyncNewsState.when(
          data: (paginationState) {
            if (paginationState.news.isNotEmpty) {
              return Column(
                children: [
                  anim.AnimatedWidgetWrapper(
                    animationType: anim.AnimationType.fadeSlideInFromLeft,
                    duration: anim.AnimationDuration.normal,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16, right: 16, top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.feed_outlined,
                              color: kPrimaryColor, size: 18),
                          SizedBox(width: 6),
                          Text('Latest News', style: kBodyTitleB),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 100,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: paginationState.news.length +
                            (paginationState.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == paginationState.news.length) {
                            return Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return NewsCard(
                            news: paginationState.news[index],
                            allNews: paginationState.news,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: Text(
                  'No News',
                  style: kBodyTitleB,
                ),
              );
            }
          },
          loading: () => const Center(child: LoadingAnimation()),
          error: (error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading news',
                  style: kBodyTitleB,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(newsListProvider.notifier).refresh();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ));
  }
}

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
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(Icons.bookmark_border, color: kPrimaryColor),
                onPressed: () {
                  ref
                      .read(newsListProvider.notifier)
                      .toggleBookmark(news.id ?? '');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
