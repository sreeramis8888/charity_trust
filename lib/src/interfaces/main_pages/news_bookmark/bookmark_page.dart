import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/models/news_model.dart';
import 'package:charity_trust/src/data/providers/news_provider.dart';
import 'package:charity_trust/src/interfaces/components/loading_indicator.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:shimmer/shimmer.dart';
import 'news_page.dart';

class BookmarkPage extends ConsumerStatefulWidget {
  const BookmarkPage({super.key});

  @override
  ConsumerState<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends ConsumerState<BookmarkPage> {
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
      ref
          .read(bookmarkedNewsListProvider.notifier)
          .loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncBookmarkedState =
        ref.watch(bookmarkedNewsListProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Bookmarks",
          style: TextStyle(fontSize: 17),
        ),
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
      ),
      body: asyncBookmarkedState.when(
        data: (paginationState) {
          if (paginationState.news.isEmpty) {
            return anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No bookmarked news yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return anim.AnimatedWidgetWrapper(
            animationType: anim.AnimationType.fadeSlideInFromBottom,
            duration: anim.AnimationDuration.normal,
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

                final newsItem = paginationState.news[index];
                return GestureDetector(
                  onTap: () {
                    final initialIndex = paginationState.news.indexOf(newsItem);
                    if (initialIndex != -1) {
                      ref.read(currentNewsIndexProvider.notifier).state =
                          initialIndex;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NewsDetailView(news: paginationState.news),
                        ),
                      );
                    }
                  },
                  child: BookmarkNewsCard(
                    news: newsItem,
                    onBookmarkRemoved: () {
                      ref
                          .read(bookmarkedNewsListProvider.notifier)
                          .removeBookmark(newsItem.id ?? '');
                    },
                  ),
                );
              },
            ),
          );
        },
        loading: () => Center(child: LoadingAnimation()),
        error: (error, stackTrace) => anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading bookmarks',
                  style: kBodyTitleB,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(bookmarkedNewsListProvider.notifier).refresh();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BookmarkNewsCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback onBookmarkRemoved;

  const BookmarkNewsCard({
    Key? key,
    required this.news,
    required this.onBookmarkRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('MMM dd, yyyy, hh:mm a').format(news.updatedAt!.toLocal());

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    news.media ?? '',
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return ShimmerLoadingEffect(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return ShimmerLoadingEffect(
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(
                    Icons.bookmark,
                    color: kPrimaryColor,
                    size: 28,
                  ),
                  onPressed: onBookmarkRemoved,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color.fromARGB(255, 192, 252, 194),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 2,
                      horizontal: 10,
                    ),
                    child: Text(
                      news.category ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  news.title ?? '',
                  style: kHeadTitleB,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Spacer(),
                    Text(
                      calculateReadingTimeAndWordCount(news.content ?? ''),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String calculateReadingTimeAndWordCount(String text) {
  List<String> words = text.trim().split(RegExp(r'\s+'));
  int wordCount = words.length;
  const int averageWPM = 250;
  double readingTimeMinutes = wordCount / averageWPM;
  int minutes = readingTimeMinutes.floor();
  int seconds = ((readingTimeMinutes - minutes) * 60).round();
  String formattedTime;
  if (minutes > 0) {
    formattedTime = '$minutes min ${seconds > 0 ? '$seconds sec' : ''}';
  } else {
    formattedTime = '$seconds sec';
  }
  return '$formattedTime read';
}

class ShimmerLoadingEffect extends StatelessWidget {
  final Widget child;

  const ShimmerLoadingEffect({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: child,
    );
  }
}
