import 'package:Annujoom/src/data/models/user_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/interfaces/components/cards/referral_card.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/components/dropdown.dart';
import 'referral_details_page.dart';

class MyReferralsPage extends ConsumerStatefulWidget {
  const MyReferralsPage({super.key});

  @override
  ConsumerState<MyReferralsPage> createState() => _MyReferralsPageState();
}

class _MyReferralsPageState extends ConsumerState<MyReferralsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _referralsScrollController;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _referralsScrollController = ScrollController();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _setupScrollController(
      _referralsScrollController,
      () {
        if (_tabController.index == 0) {
          ref.read(allReferralsProvider.notifier).loadNextPage();
        } else {
          ref.read(indirectReferralsProvider.notifier).loadNextPage();
        }
      },
    );
  }

  void _setupScrollController(
    ScrollController controller,
    VoidCallback onEndReached,
  ) {
    controller.addListener(() {
      if (!controller.hasClients) return;
      final position = controller.position;
      if (position.pixels >= position.maxScrollExtent - 500) {
        onEndReached();
      }
    });
  }

  @override
  void dispose() {
    // Reset filters when leaving the page
    ref.invalidate(referralSearchProvider);
    ref.invalidate(referralStatusFilterProvider);
    ref.invalidate(referralDateFilterProvider);
    ref.invalidate(referralTypeFilterProvider);

    _tabController.dispose();
    _referralsScrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🟣 [MyReferralsPage] BUILD called');
    final allReferralsAsync = ref.watch(allReferralsProvider);
    final indirectReferralsAsync = ref.watch(indirectReferralsProvider);
    print(
        '🟣 [MyReferralsPage] allReferralsAsync state: ${allReferralsAsync.runtimeType}');
    print(
        '🟣 [MyReferralsPage] indirectReferralsAsync state: ${indirectReferralsAsync.runtimeType}');
    print(
        '🟣 [MyReferralsPage] indirectReferralsAsync data: ${indirectReferralsAsync.maybeWhen(data: (d) => d.referrals.length, orElse: () => 0)} items');

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, size: 18),
          ),
        ),
        title: Text(
          'myReferrals'.tr(),
          style: kBodyTitleR,
        ),
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Unfocus the search field when tapping elsewhere
          _searchFocusNode.unfocus();
        },
        child: ListView(
          controller: _referralsScrollController,
          padding: const EdgeInsets.all(16),
          children: [
            Text('referralsSummary'.tr(), style: kBodyTitleM),
            const SizedBox(height: 12),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.slow,
              curveType: anim.AnimationCurveType.easeOut,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xFFFFFFFF),
                    const Color(0xFFCEE8F8)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: allReferralsAsync.when(
                  data: (paginationState) {
                    final total = paginationState.totalCount;
                    final approved = paginationState.totalApproved;
                    final pending = paginationState.totalPending;
                    final rejected = paginationState.totalRejected;

                    return _buildStatsColumn(
                        total, approved, pending, rejected);
                  },
                  loading: () => _buildStatsColumn(0, 0, 0, 0),
                  error: (error, stack) => _buildStatsColumn(0, 0, 0, 0),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('referrals'.tr(), style: kBodyTitleM),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('CreateUser');
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 18,
                    color: kWhite,
                  ),
                  label: Text(
                    'addNewMember'.tr(),
                    style: kSmallTitleM.copyWith(color: kWhite),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            allReferralsAsync.when(
                data: (data) => _buildTotalReferralsContainer(
                    totalMemberDonation: data.totalMemberDonations.toString()),
                error: (error, stackTrace) => _buildTotalReferralsContainer(),
                loading: () => _buildTotalReferralsContainer()),
            const SizedBox(height: 16),
            _buildSearchAndFilterBar(),
            const SizedBox(height: 16),
            _buildReferralTabBar(),
            const SizedBox(height: 16),
            _tabController.index == 0
                ? allReferralsAsync.when(
                    data: (paginationState) {
                      final displayReferrals = paginationState.referrals;

                      if (displayReferrals.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'noReferralsYet'.tr(),
                              style: kSmallTitleR.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ),
                        );
                      }

                      final hasMore = paginationState.hasMore;

                      return Column(
                        children: [
                          ...displayReferrals.map((user) {
                            final isPending = user.status == 'pending';

                            return ReferralCard(
                              user: user,
                              isPending: isPending,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReferralDetailsPage(
                                      user: user,
                                      isPending: isPending,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  await ref
                                      .read(allReferralsProvider.notifier)
                                      .refresh();
                                }
                              },
                              onViewDetails: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReferralDetailsPage(
                                      user: user,
                                      isPending: isPending,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  await ref
                                      .read(allReferralsProvider.notifier)
                                      .refresh();
                                }
                              },
                            );
                          }).toList(),
                          // Show loading indicator if there are more items to load
                          if (hasMore)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: LoadingAnimation(size: 24),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: LoadingAnimation(),
                    ),
                    error: (error, stack) => Center(
                      child: Text('errorLoadingReferrals'.tr() + ': $error'),
                    ),
                  )
                : indirectReferralsAsync.when(
                    data: (paginationState) {
                      final displayReferrals = paginationState.referrals;

                      if (displayReferrals.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'noReferralsYet'.tr(),
                              style: kSmallTitleR.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ),
                        );
                      }

                      final hasMore = paginationState.hasMore;

                      return Column(
                        children: [
                          ...displayReferrals.map((user) {
                            final isPending = user.status == 'pending';

                            return ReferralCard(
                              user: user,
                              isPending: isPending,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReferralDetailsPage(
                                      user: user,
                                      isPending: isPending,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  await ref
                                      .read(indirectReferralsProvider.notifier)
                                      .refresh();
                                }
                              },
                              onViewDetails: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReferralDetailsPage(
                                      user: user,
                                      isPending: isPending,
                                    ),
                                  ),
                                );

                                if (result == true) {
                                  await ref
                                      .read(indirectReferralsProvider.notifier)
                                      .refresh();
                                }
                              },
                            );
                          }).toList(),
                          // Show loading indicator if there are more items to load
                          if (hasMore)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: LoadingAnimation(size: 24),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: LoadingAnimation(),
                    ),
                    error: (error, stack) => Center(
                      child: Text('errorLoadingReferrals'.tr() + ': $error'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: kBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: kSmallTitleR,
        controller: _tabController,
        labelColor: kPrimaryColor,
        unselectedLabelColor: kSecondaryTextColor,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: kPrimaryColor,
            width: 3,
          ),
          insets: EdgeInsets.zero,
        ),
        onTap: (_) {
          setState(() {});
        },
        tabs: [
          Tab(child: Text('directReferrals'.tr())),
          Tab(child: Text('indirectReferrals'.tr())),
        ],
      ),
    );
  }

  Widget _buildTotalReferralsContainer({String? totalMemberDonation}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: kCardBackgroundColor, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Text(
            'totalMemberDonations'.tr(),
            style: kSmallTitleM,
          ),
          Spacer(),
          Text(
            "₹",
            style: kSubHeadingM.copyWith(color: kPrimaryColor),
          ),
          Text(
            totalMemberDonation ?? '-',
            style: kSubHeadingM.copyWith(color: kPrimaryColor),
          )
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (value) {
                  print(
                      '🟢 [SearchField] onChanged called with value: "$value"');
                  // Update search state first
                  ref.read(referralSearchProvider.notifier).setSearch(value);
                  print('🟢 [SearchField] Search state updated');
                },
                decoration: InputDecoration(
                  hintText: 'search'.tr(),
                  hintStyle: kSmallTitleL.copyWith(color: kGrey),
                  prefixIcon: const Icon(Icons.search, color: kGrey),
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              height: 24,
              width: 1,
              color: kBorder,
            ),
            GestureDetector(
              onTap: () => _showFilterBottomSheet(context),
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Icon(Icons.tune, color: kGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    final currentStatus = ref.read(referralStatusFilterProvider);
    final currentDates = ref.read(referralDateFilterProvider);

    if (currentDates['start_date'] != null) {
      final date = DateTime.parse(currentDates['start_date']!);
      startDateController.text =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }
    if (currentDates['end_date'] != null) {
      final date = DateTime.parse(currentDates['end_date']!);
      endDateController.text =
          "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    }

    final statusOptions = [
      ('', 'all'.tr()),
      ('active', 'active'.tr()),
      ('inactive', 'inactive'.tr()),
      ('pending', 'pendingLabel'.tr()),
      ('deleted', 'deleted'.tr()),
      ('suspended', 'suspended'.tr()),
      ('rejected', 'rejectedLabel'.tr()),
    ];

    String selectedStatus = currentStatus;

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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
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
                  Text("status".tr(), style: kSmallTitleM),
                  const SizedBox(height: 8),
                  AnimatedDropdown<String>(
                    hint: 'selectStatus'.tr(),
                    value: selectedStatus.isEmpty ? null : selectedStatus,
                    items: statusOptions.map((e) => e.$1).toList(),
                    onChanged: (value) {
                      setModalState(() {
                        selectedStatus = value ?? '';
                      });
                    },
                    itemLabel: (value) {
                      return statusOptions.firstWhere((e) => e.$1 == value).$2;
                    },
                    height: 48,
                  ),
                  const SizedBox(height: 20),
                  Text("startDate".tr(), style: kSmallTitleM),
                  const SizedBox(height: 8),
                  InputField(
                    type: CustomFieldType.date,
                    hint: 'ddmmyyyy'.tr(),
                    controller: startDateController,
                  ),
                  const SizedBox(height: 20),
                  Text("endDate".tr(), style: kSmallTitleM),
                  const SizedBox(height: 8),
                  InputField(
                    type: CustomFieldType.date,
                    hint: 'ddmmyyyy'.tr(),
                    controller: endDateController,
                  ),
                  const SizedBox(height: 32),
                  primaryButton(
                    label: 'apply'.tr(),
                    onPressed: () {
                      print('🟡 [FilterButton] Apply button pressed');
                      String? formattedStart;
                      String? formattedEnd;

                      if (startDateController.text.isNotEmpty) {
                        final parts = startDateController.text.split('/');
                        formattedStart = "${parts[2]}-${parts[1]}-${parts[0]}";
                        print(
                            '🟡 [FilterButton] Formatted start date: $formattedStart');
                      }
                      if (endDateController.text.isNotEmpty) {
                        final parts = endDateController.text.split('/');
                        formattedEnd = "${parts[2]}-${parts[1]}-${parts[0]}";
                        print(
                            '🟡 [FilterButton] Formatted end date: $formattedEnd');
                      }

                      print(
                          '🟡 [FilterButton] Setting status to: $selectedStatus');
                      ref
                          .read(referralStatusFilterProvider.notifier)
                          .setStatus(selectedStatus);
                      ref
                          .read(referralDateFilterProvider.notifier)
                          .setDates(formattedStart, formattedEnd);
                      print('🟡 [FilterButton] Filter states updated');

                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  if (currentStatus.isNotEmpty ||
                      currentDates['start_date'] != null ||
                      currentDates['end_date'] != null)
                    Center(
                      child: TextButton(
                        onPressed: () {
                          print('🟠 [ClearFilters] Clear button pressed');
                          ref
                              .read(referralStatusFilterProvider.notifier)
                              .clear();
                          ref.read(referralDateFilterProvider.notifier).clear();
                          ref
                              .read(referralSearchProvider.notifier)
                              .setSearch('');
                          _searchController.clear();
                          print('🟠 [ClearFilters] All filters cleared');

                          Navigator.pop(context);
                        },
                        child: Text(
                          'clearFilters'.tr(),
                          style: kSmallTitleM.copyWith(color: Colors.red),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: kLargeTitleSB.copyWith(
            color: kThirdTextColor,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          label,
          style: kSmallTitleM,
        ),
      ],
    );
  }

  Widget _buildStatsColumn(int total, int approved, int pending, int rejected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatItem(total.toString(), 'totalLabel'.tr()),
            ),
            Container(
              width: 1,
              height: 60,
              color: kStrokeColor.withOpacity(0.06),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 18),
                child:
                    _buildStatItem(approved.toString(), 'approvedLabel'.tr()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          height: 2,
          color: kStrokeColor.withOpacity(0.06),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(pending.toString(), 'pendingLabel'.tr()),
            ),
            Container(
              width: 1,
              height: 60,
              color: kStrokeColor.withOpacity(0.06),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 18),
                child:
                    _buildStatItem(rejected.toString(), 'rejectedLabel'.tr()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
