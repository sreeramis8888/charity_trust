import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:intl/intl.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/models/news_model.dart';
import 'package:charity_trust/src/data/providers/news_provider.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:shimmer/shimmer.dart';

final currentNewsIndexProvider = StateProvider<int>((ref) => 0);

class NewsDetailView extends ConsumerWidget {
  final List<NewsModel> news;
  const NewsDetailView({super.key, required this.news});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          scrolledUnderElevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_ios)),
          ),
          // actions: [
          //   IconButton(
          //     icon: Icon(
          //       Icons.bookmark_border,
          //       color: kWhite,
          //     ),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => BookmarkPage()),
          //       );
          //     },
          //   ),
          // ],
        ),
        body: NewsModelDetailContentView(news: news));
  }
}

class NewsModelDetailContentView extends ConsumerStatefulWidget {
  final List<NewsModel> news;

  const NewsModelDetailContentView({Key? key, required this.news})
      : super(key: key);

  @override
  ConsumerState<NewsModelDetailContentView> createState() =>
      _NewsModelDetailContentViewState();
}

class _NewsModelDetailContentViewState
    extends ConsumerState<NewsModelDetailContentView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(currentNewsIndexProvider),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(currentNewsIndexProvider, (_, nextIndex) {
      _pageController.jumpToPage(nextIndex);
    });

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
                child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.news.length,
                    onPageChanged: (index) {
                      ref.read(currentNewsIndexProvider.notifier).state = index;
                    },
                    itemBuilder: (context, index) {
                      return NewsContent(
                        key: PageStorageKey<int>(index),
                        newsItem: widget.news[index],
                      );
                    })),
            if (widget.news.length > 1)
              Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, bottom: 10, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: kBackgroundColor,
                        side: const BorderSide(color: kStrokeColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                      ),
                      onPressed: () {
                        int currentIndex = ref.read(currentNewsIndexProvider);
                        if (currentIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_back, color: kWhite),
                          SizedBox(width: 8),
                          Text('Previous', style: TextStyle(color: kWhite)),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: kBackgroundColor,
                        side: const BorderSide(color: kStrokeColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 10),
                      ),
                      onPressed: () {
                        int currentIndex = ref.read(currentNewsIndexProvider);
                        if (currentIndex < widget.news.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: const Row(
                        children: [
                          Text('Next', style: TextStyle(color: kWhite)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: kWhite),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class NewsContent extends ConsumerWidget {
  final NewsModel newsItem;

  const NewsContent({
    Key? key,
    required this.newsItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = DateFormat('MMM dd, yyyy, hh:mm a')
        .format(newsItem.updatedAt!.toLocal());

    final minsToRead = calculateReadingTimeAndWordCount(newsItem.content ?? '');

    return Stack(
      children: [
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromTop,
                  duration: anim.AnimationDuration.normal,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      newsItem.media ?? '',
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
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 100,
                  child: Padding(
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
                              newsItem.category ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          newsItem.title ?? '',
                          style: kHeadTitleB,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              minsToRead,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(newsItem.content ?? '',
                            style: TextStyle(
                                color: kSecondaryTextColor,
                                fontWeight: FontWeight.w300,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Consumer(
            builder: (context, ref, child) {
              return IconButton(
                icon: Icon(
                  Icons.bookmark_border,
                  color: kPrimaryColor,
                  size: 28,
                ),
                onPressed: () {
                  ref
                      .read(newsListProvider.notifier)
                      .toggleBookmark(newsItem.id ?? '');
                },
              );
            },
          ),
        ),
      ],
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
