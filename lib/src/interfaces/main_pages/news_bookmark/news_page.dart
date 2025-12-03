import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:intl/intl.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/models/news_model.dart';
import 'package:charity_trust/src/data/providers/news_provider.dart';
import 'package:charity_trust/src/data/feature_tours/news_swipe_tour.dart';
import 'package:charity_trust/src/data/feature_tours/feature_tour_provider.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:charity_trust/src/interfaces/components/feature_tour_overlay.dart';
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
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 20,
                )),
          ),
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final currentIndex = ref.watch(currentNewsIndexProvider);
                final newsListState = ref.watch(newsListProvider);

                return newsListState.maybeWhen(
                  data: (paginationState) {
                    final currentNews = news[currentIndex];
                    final updatedNews = paginationState.news.firstWhere(
                      (n) => n.id == currentNews.id,
                      orElse: () => currentNews,
                    );

                    return IconButton(
                      icon: Icon(
                        (updatedNews.bookmarked?.isNotEmpty ?? false)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: kSecondaryTextColor,
                        size: 22,
                      ),
                      onPressed: () {
                        ref
                            .read(newsListProvider.notifier)
                            .toggleBookmark(currentNews.id ?? '');
                      },
                    );
                  },
                  orElse: () => IconButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      color: kSecondaryTextColor,
                      size: 22,
                    ),
                    onPressed: () {
                      ref
                          .read(newsListProvider.notifier)
                          .toggleBookmark(news[currentIndex].id ?? '');
                    },
                  ),
                );
              },
            ),
            SizedBox(width: 8),
          ],
        ),
        body: NewsDetailContentView(news: news));
  }
}

class NewsDetailContentView extends ConsumerStatefulWidget {
  final List<NewsModel> news;

  const NewsDetailContentView({Key? key, required this.news}) : super(key: key);

  @override
  ConsumerState<NewsDetailContentView> createState() =>
      _NewsModelDetailContentViewState();
}

class _NewsModelDetailContentViewState
    extends ConsumerState<NewsDetailContentView> {
  late final PageController _pageController;
  final GlobalKey _pageViewKey = GlobalKey();
  bool _tourShown = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(currentNewsIndexProvider),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showFeatureTourIfNeeded();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showFeatureTourIfNeeded() {
    if (_tourShown || widget.news.length <= 1) return;

    final completedTours = ref.read(completedFeatureToursProvider);
    if (!completedTours.contains(NewsSwipeTour.tourId)) {
      _tourShown = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => FeatureTourOverlay(
          tour: NewsSwipeTour.create(pageViewKey: _pageViewKey),
        ),
      );
    }
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
                    key: _pageViewKey,
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
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    newsItem.title ?? '',
                    style: kBodyTitleB,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: anim.AnimatedWidgetWrapper(
                    animationType: anim.AnimationType.fadeSlideInFromTop,
                    duration: anim.AnimationDuration.normal,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
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
                        SizedBox(
                          height: 10,
                        ),
                        Text(newsItem.subTitle ?? '',
                            style: kSmallTitleL.copyWith(
                                color: kSecondaryTextColor)),
                        const SizedBox(height: 16),
                        Text(newsItem.content ?? '',
                            style: kSmallTitleR.copyWith(
                                color: kSecondaryTextColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
