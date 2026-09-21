import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/providers/news_provider.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/interfaces/components/cards/news_card.dart';
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/main_pages/news_bookmark/bookmark_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewsOnlyList extends ConsumerStatefulWidget {
  const NewsOnlyList({super.key});

  @override
  ConsumerState<NewsOnlyList> createState() => _NewsListPageState();
}

class _NewsListPageState extends ConsumerState<NewsOnlyList> {
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
      ref.read(newsListProvider.notifier).loadNextPage();
    }
  }

  /// Converts `dd-MM-yyyy` / `dd/MM/yyyy` to API `yyyy-MM-dd`.
  String? _toApiDate(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;

    final normalized = trimmed.replaceAll('/', '-');
    final parts = normalized.split('-');
    if (parts.length != 3) return null;

    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    final year = parts[2];
    if (year.length != 4) return null;

    return '$year-$month-$day';
  }

  String _toDisplayDate(String apiDate) {
    final date = DateTime.tryParse(apiDate);
    if (date == null) return apiDate;
    return DateFormat('dd-MM-yyyy', 'en').format(date);
  }

  bool _hasActiveFilter(Map<String, String?> dates) {
    return (dates['start_date']?.isNotEmpty ?? false) ||
        (dates['end_date']?.isNotEmpty ?? false);
  }

  bool _isStartAfterEnd(String startApi, String endApi) {
    final start = DateTime.tryParse(startApi);
    final end = DateTime.tryParse(endApi);
    if (start == null || end == null) return false;
    return start.isAfter(end);
  }

  void _showFilterBottomSheet(BuildContext context) {
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();
    final currentDates = ref.read(newsDateFilterProvider);

    if (currentDates['start_date'] != null) {
      startDateController.text = _toDisplayDate(currentDates['start_date']!);
    }
    if (currentDates['end_date'] != null) {
      endDateController.text = _toDisplayDate(currentDates['end_date']!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kGrey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('filter'.tr(), style: kBodyTitleSB),
              const SizedBox(height: 24),
              Text('startDate'.tr(), style: kSmallTitleM),
              const SizedBox(height: 8),
              InputField(
                type: CustomFieldType.date,
                hint: 'dd-mm-yyyy',
                controller: startDateController,
              ),
              const SizedBox(height: 20),
              Text('endDate'.tr(), style: kSmallTitleM),
              const SizedBox(height: 8),
              InputField(
                type: CustomFieldType.date,
                hint: 'dd-mm-yyyy',
                controller: endDateController,
              ),
              const SizedBox(height: 32),
              primaryButton(
                label: 'apply'.tr(),
                onPressed: () {
                  final formattedStart = _toApiDate(startDateController.text);
                  final formattedEnd = _toApiDate(endDateController.text);

                  // Backend requires both dates together.
                  if ((formattedStart != null) != (formattedEnd != null)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('selectBothDates'.tr()),
                      ),
                    );
                    return;
                  }

                  if (formattedStart != null &&
                      formattedEnd != null &&
                      _isStartAfterEnd(formattedStart, formattedEnd)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('endBeforeStart'.tr()),
                      ),
                    );
                    return;
                  }

                  ref.read(newsDateFilterProvider.notifier).state = {
                    'start_date': formattedStart,
                    'end_date': formattedEnd,
                  };
                  Navigator.pop(sheetContext);
                },
              ),
              const SizedBox(height: 12),
              if (_hasActiveFilter(currentDates))
                Center(
                  child: TextButton(
                    onPressed: () {
                      ref.read(newsDateFilterProvider.notifier).state = {
                        'start_date': null,
                        'end_date': null,
                      };
                      Navigator.pop(sheetContext);
                    },
                    child: Text(
                      'clearFilters'.tr(),
                      style: kSmallTitleM.copyWith(color: kPrimaryColor),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    ).whenComplete(() {
      startDateController.dispose();
      endDateController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncNewsState = ref.watch(newsListProvider);
    final dateFilter = ref.watch(newsDateFilterProvider);
    final secureStorageService = ref.watch(secureStorageServiceProvider);
    final hasFilter = _hasActiveFilter(dateFilter);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'news1'.tr(),
            style: kSubHeadingM,
          ),
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: hasFilter,
              smallSize: 8,
              backgroundColor: kPrimaryColor,
              child: Icon(
                Icons.filter_list,
                color: hasFilter ? kPrimaryColor : kTextColor,
                size: 24,
              ),
            ),
            onPressed: () => _showFilterBottomSheet(context),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.bookmark, color: kPrimaryColor, size: 25),
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
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3EFEF),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: FutureBuilder<String?>(
                    future: secureStorageService.getUserId(),
                    builder: (context, userIdSnapshot) {
                      final bookmarkCount = asyncNewsState.maybeWhen(
                        data: (paginationState) {
                          if (userIdSnapshot.hasData &&
                              userIdSnapshot.data != null) {
                            return paginationState.news
                                .where((news) =>
                                    news.bookmarked
                                        ?.contains(userIdSnapshot.data) ??
                                    false)
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
          const SizedBox(width: 8),
        ],
      ),
      body: asyncNewsState.when(
        data: (paginationState) {
          if (paginationState.news.isNotEmpty) {
            return Column(
              children: [
                const SizedBox(height: 15),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: paginationState.news.length +
                        (paginationState.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == paginationState.news.length) {
                        return const Padding(
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
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'noNews1'.tr(),
                    style: kBodyTitleB,
                    textAlign: TextAlign.center,
                  ),
                  if (hasFilter) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        ref.read(newsDateFilterProvider.notifier).state = {
                          'start_date': null,
                          'end_date': null,
                        };
                      },
                      child: Text(
                        'clearFilters'.tr(),
                        style: kSmallTitleM.copyWith(color: kPrimaryColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(newsListProvider.notifier).refresh();
                },
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
