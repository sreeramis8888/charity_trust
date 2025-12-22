import 'package:Annujoom/src/data/providers/news_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/interfaces/components/cards/news_card.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/utils/get_time_ago.dart';
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

  List<Widget> _buildStatisticsGrid(List<dynamic> statistics) {
    final widgets = <Widget>[];

    for (int i = 0; i < statistics.length; i += 2) {
      final row = <Widget>[];

      // First item
      if (i < statistics.length) {
        row.add(
          Expanded(
            child: _statItem(
              statistics[i]['count']?.toString() ?? '0',
              statistics[i]['name']?.toString() ?? '',
            ),
          ),
        );
      }

      // Divider
      row.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
              width: 2, height: 50, color: kStrokeColor.withOpacity(0.06)),
        ),
      );

      // Second item
      if (i + 1 < statistics.length) {
        row.add(
          Expanded(
            child: _statItem(
              statistics[i + 1]['count']?.toString() ?? '0',
              statistics[i + 1]['name']?.toString() ?? '',
            ),
          ),
        );
      } else {
        row.add(Expanded(child: SizedBox()));
      }

      widgets.add(Row(children: row));

      // Add divider between rows if not last row
      if (i + 2 < statistics.length) {
        widgets.add(const SizedBox(height: 18));
        widgets
            .add(Container(height: 2, color: kStrokeColor.withOpacity(0.06)));
        widgets.add(const SizedBox(height: 18));
      }
    }

    return widgets;
  }

  Widget _statItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: kBodyTitleSB.copyWith(color: kBlue),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: kSmallTitleM,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncNewsState = ref.watch(newsListProvider);
    final secureStorageService = ref.watch(secureStorageServiceProvider);

    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kWhite,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Text(
                  "news".tr(),
                  style: kSubHeadingM,
                ),
              ],
            ),
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.bookmark, color: kPrimaryColor, size: 25),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookmarkPage()),
                    );
                  },
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Color(0xFFF3EFEF), shape: BoxShape.circle),
                    constraints: BoxConstraints(minWidth: 18, minHeight: 18),
                    child: FutureBuilder<String?>(
                      future: secureStorageService.getUserId(),
                      builder: (context, userIdSnapshot) {
                        final bookmarkCount = asyncNewsState.maybeWhen(
                          data: (paginationState) {
                            if (userIdSnapshot.hasData && userIdSnapshot.data != null) {
                              return paginationState.news
                                  .where((news) =>
                                      news.bookmarked?.contains(userIdSnapshot.data) ?? false)
                                  .length;
                            }
                            return 0;
                          },
                          orElse: () => 0,
                        );
                        return Text(
                          '$bookmarkCount',
                          style: kSmallTitleR.copyWith(fontSize: 10),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
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
                  SizedBox(
                    height: 15,
                  ),
                  if (paginationState.statistics.isNotEmpty)
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 50,
                      child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFFFFFF), // solid white
                                  const Color(0xFFFFFFFF)
                                      .withOpacity(0), // fades to transparent
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(1.2), // border thickness
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFF0F0F0),
                                      Color(0xFFF1F8CE),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _buildStatisticsGrid(
                                    paginationState.statistics,
                                  ),
                                ),
                              ),
                            ),
                          )),
                    ),
                  SizedBox(
                    height: 15,
                  ),
                  Expanded(
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
                        return NewsCard(
                          news: paginationState.news[index],
                          allNews: paginationState.news,
                        );
                      },
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: Text(
                  'noNews'.tr(),
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
                  'errorLoadingNews'.tr(),
                  style: kBodyTitleB,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.read(newsListProvider.notifier).refresh();
                  },
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          ),
        ));
  }
}
