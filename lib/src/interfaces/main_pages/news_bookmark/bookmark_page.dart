import 'package:Annujoom/src/interfaces/components/cards/news_card.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:easy_localization/easy_localization.dart';
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
    final secureStorageService = ref.watch(secureStorageServiceProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "bookmarks".tr(),
          style: TextStyle(fontSize: 17),
        ),
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
      ),
      body: FutureBuilder<String?>(
        future: secureStorageService.getUserId(),
        builder: (context, userIdSnapshot) {
          return asyncBookmarkedState.when(
            data: (paginationState) {
              final userId = userIdSnapshot.data;
              final filteredNews = userId != null
                  ? paginationState.news
                      .where((news) =>
                          news.bookmarked?.contains(userId) ?? false)
                      .toList() as List<NewsModel>
                  : <NewsModel>[];

              if (filteredNews.isEmpty) {
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
                          'noBookmarks'.tr(),
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
                  itemCount: filteredNews.length +
                      (paginationState.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredNews.length) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: LoadingAnimation(),
                        ),
                      );
                    }

                    final newsItem = filteredNews[index];
                    return GestureDetector(
                      onTap: () {
                        final initialIndex =
                            filteredNews.indexOf(newsItem);
                        if (initialIndex != -1) {
                          ref.read(currentNewsIndexProvider.notifier).state =
                              initialIndex;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewsDetailView(news: filteredNews),
                            ),
                          );
                        }
                      },
                      child: NewsCard(
                        allNews: filteredNews,
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
                      'errorLoadingBookmarks'.tr(),
                      style: kBodyTitleB,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(bookmarkedNewsListProvider.notifier)
                            .refresh();
                      },
                      child: Text('retry'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
