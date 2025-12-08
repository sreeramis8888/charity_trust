import 'package:Annujoom/src/interfaces/components/cards/news_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/news_model.dart';
import 'package:Annujoom/src/data/providers/news_provider.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
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
      ref.read(bookmarkedNewsListProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncBookmarkedState = ref.watch(bookmarkedNewsListProvider);

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
                      child: LoadingAnimation(),
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
                  child: NewsCard(
                    allNews: paginationState.news,
                    news: newsItem,
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
