import 'package:Annujoom/src/data/utils/date_formatter.dart';
import 'package:Annujoom/src/interfaces/components/cards/campaing_card.dart';
import 'package:Annujoom/src/interfaces/components/cards/transaction_card.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/choice_chip_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:Annujoom/src/data/providers/campaigns_provider.dart'
    show
        generalCampaignsProvider,
        participatedCampaignsProvider,
        pendingApprovalCampaignsProvider,
        myCampaignsFilterProvider;
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/interfaces/components/confirmation_dialog.dart';
import 'package:Annujoom/src/interfaces/main_pages/campaign_pages/add_campaign.dart';

class CampaignPage extends ConsumerStatefulWidget {
  const CampaignPage({super.key});

  @override
  ConsumerState<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends ConsumerState<CampaignPage>
    with TickerProviderStateMixin {
  late TabController _controller;
  late ScrollController _scrollController;
  bool _isPresident = false;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    final user = await secureStorage.getUserData();
    if (mounted) {
      setState(() {
        _isPresident = user?.role == 'president';
        final tabCount = _isPresident ? 4 : 3;
        if (_controller.length != tabCount) {
          _controller.dispose();
          _controller = TabController(length: tabCount, vsync: this);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMoreBasedOnTab();
    }
  }

  void _loadMoreBasedOnTab() {
    final tabIndex = _controller.index;
    if (tabIndex == 0) {
      ref.read(generalCampaignsProvider.notifier).loadNextPage();
    } else if (tabIndex == 1) {
      ref.read(participatedCampaignsProvider.notifier).loadNextPage();
    } else if (tabIndex == 2) {
      ref.read(participatedCampaignsProvider.notifier).loadNextPage();
    } else if (tabIndex == 3 && _isPresident) {
      ref.read(pendingApprovalCampaignsProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final secureStorage = ref.watch(secureStorageServiceProvider);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: kTextColor,
                  size: 20,
                ),
              )
            : null,
        backgroundColor: kWhite,
        elevation: 0,
        title: Text("Campaign", style: kBodyTitleM),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: FutureBuilder<String?>(
                future: secureStorage.getUserData().then((user) => user?.role),
                builder: (context, snapshot) {
                  final isAdmin = snapshot.data != 'member';
                  if (!isAdmin) {
                    return const SizedBox.shrink();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddCampaignPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add,
                          color: kPrimaryColor,
                          size: 24,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: kBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: kSmallTitleR,
              controller: _controller,
              labelColor: kPrimaryColor,
              unselectedLabelColor: kSecondaryTextColor,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: kPrimaryColor,
                  width: 3,
                ),
                insets: EdgeInsets.zero,
              ),
              tabs: [
                const Tab(
                  text: "Campaign",
                ),
                const Tab(text: "Transactions"),
                const Tab(text: "My Campaigns"),
                if (_isPresident) const Tab(text: "Approvals"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          _generalCampaignTab(),
          _yourTransactionsTab(),
          _myCampaignsTab(),
          if (_isPresident) _approvalsTab(),
        ],
      ),
    );
  }

  // ---------------- TAB 1 ---------------- //
  Widget _generalCampaignTab() {
    final campaignsState = ref.watch(generalCampaignsProvider);

    return campaignsState.when(
      data: (paginationState) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: paginationState.campaigns.length +
              (paginationState.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == paginationState.campaigns.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(generalCampaignsProvider.notifier)
                          .loadNextPage();
                    },
                    child: const Text('Load More'),
                  ),
                ),
              );
            }

            final campaign = paginationState.campaigns[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: index * 50,
                child: CampaignCard(
                  id: campaign.id ?? '',
                  description: campaign.description ?? '',
                  title: campaign.title ?? '',
                  category: campaign.category ?? '',
                  date: formatDate(campaign.targetDate) ?? '',
                  image: campaign.coverImage ?? '',
                  raised: campaign.collectedAmount?.toInt() ?? 0,
                  goal: campaign.targetAmount?.toInt() ?? 0,
                  onDetails: () {
                    Navigator.of(context).pushNamed(
                      'CampaignDetail',
                      arguments: {
                        '_id': campaign.id ?? '',
                        'title': campaign.title ?? '',
                        'description': campaign.description ?? '',
                        'category': campaign.category ?? '',
                        'date': formatDate(campaign.targetDate) ?? '',
                        'image': campaign.coverImage ?? '',
                        'raised': campaign.collectedAmount?.toInt() ?? 0,
                        'goal': campaign.targetAmount?.toInt() ?? 0,
                      },
                    );
                  },
                  onDonate: () {},
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(generalCampaignsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TAB 2 ---------------- //
  Widget _yourTransactionsTab() {
    final participatedState = ref.watch(participatedCampaignsProvider);

    return participatedState.when(
      data: (paginationState) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: paginationState.donations.length +
              (paginationState.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == paginationState.donations.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(participatedCampaignsProvider.notifier)
                          .loadNextPage();
                    },
                    child: const Text('Load More'),
                  ),
                ),
              );
            }

            final donation = paginationState.donations[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: index * 50,
                child: TransactionCard(
                  id: donation.paymentId ?? '',
                  type: donation.campaign?.category ?? '',
                  // campaignTitle: donation.campaign?.title ?? '',
                  amount: donation.amount?.toString() ?? '-',
                  // currency: donation.currency ?? 'INR',
                  // paymentMethod: donation.paymentMethod ?? '',
                  status: donation.status ?? '',
                  date: formatDate(donation.createdAt) ?? '',
                  receipt: donation.receipt ?? '',
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(participatedCampaignsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- TAB 3 ---------------- //
  Widget _myCampaignsTab() {
    final campaignsState = ref.watch(generalCampaignsProvider);
    final secureStorage = ref.watch(secureStorageServiceProvider);
    final currentFilter = ref.watch(myCampaignsFilterProvider);

    return FutureBuilder<String?>(
      future: secureStorage.getUserData().then((user) => user?.role),
      builder: (context, snapshot) {
        final userRole = snapshot.data;
        final isNonMember = userRole != null && userRole != 'member';

        return Column(
          children: [
            if (isNonMember)
              ChoiceChipFilter(
                options: const ['Joined', 'Created'],
                selectedOption: currentFilter ? 'Created' : 'Joined',
                onSelectionChanged: (selected) {
                  ref.read(myCampaignsFilterProvider.notifier).setFilter(selected == 'Created');
                },
              ),
            Expanded(
              child: campaignsState.when(
                data: (paginationState) {
                  if (paginationState.campaigns.isEmpty) {
                    final filterLabel = currentFilter ? 'created' : 'joined';
                    return Center(
                      child: Text(
                        'No $filterLabel campaigns',
                        style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                      ),
                    );
                  }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: paginationState.campaigns.length +
                    (paginationState.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == paginationState.campaigns.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            ref
                                .read(generalCampaignsProvider.notifier)
                                .loadNextPage();
                          },
                          child: const Text('Load More'),
                        ),
                      ),
                    );
                  }

                  final campaign = paginationState.campaigns[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: index * 50,
                      child: CampaignCard(
                        id: campaign.id ?? '',
                        description: campaign.description ?? '',
                        title: campaign.title ?? '',
                        category: campaign.category ?? '',
                        date: formatDate(campaign.targetDate) ?? '',
                        image: campaign.coverImage ?? '',
                        raised: campaign.collectedAmount?.toInt() ?? 0,
                        goal: campaign.targetAmount?.toInt() ?? 0,
                        onDetails: () {
                          Navigator.of(context).pushNamed(
                            'CampaignDetail',
                            arguments: {
                              '_id': campaign.id ?? '',
                              'title': campaign.title ?? '',
                              'description': campaign.description ?? '',
                              'category': campaign.category ?? '',
                              'date': formatDate(campaign.targetDate) ?? '',
                              'image': campaign.coverImage ?? '',
                              'raised': campaign.collectedAmount?.toInt() ?? 0,
                              'goal': campaign.targetAmount?.toInt() ?? 0,
                            },
                          );
                        },
                        isMyCampaign: true,
                      ),
                    ),
                  );
                },
              );
            },
                loading: () => const Center(child: LoadingAnimation()),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(generalCampaignsProvider.notifier).refresh();
                        },
                        child: const Text('Retry'),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
  }

  // ---------------- TAB 4 (APPROVALS) ---------------- //
  Widget _approvalsTab() {
    final approvalsState = ref.watch(pendingApprovalCampaignsProvider);

    return approvalsState.when(
      data: (paginationState) {
        if (paginationState.campaigns.isEmpty) {
          return const Center(
            child: Text('No campaigns pending approval'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: paginationState.campaigns.length +
              (paginationState.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == paginationState.campaigns.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(pendingApprovalCampaignsProvider.notifier)
                          .loadNextPage();
                    },
                    child: const Text('Load More'),
                  ),
                ),
              );
            }

            final campaign = paginationState.campaigns[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: index * 50,
                child: CampaignCard(
                  id: campaign.id ?? '',
                  description: campaign.description ?? '',
                  title: campaign.title ?? '',
                  category: campaign.category ?? '',
                  date: formatDate(campaign.targetDate) ?? '',
                  startDate: formatDate(campaign.startDate),
                  image: campaign.coverImage ?? '',
                  raised: campaign.collectedAmount?.toInt() ?? 0,
                  goal: campaign.targetAmount?.toInt() ?? 0,
                  onDetails: () {},
                  isApprovalCard: true,
                  onApprove: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        title: 'Approve Campaign',
                        message:
                            'Are you sure you want to approve "${campaign.title}"?',
                        confirmButtonText: 'Approve',
                        onConfirm: () async {
                          final approved = await ref
                              .read(pendingApprovalCampaignsProvider.notifier)
                              .approveCampaign(campaign.id ?? '');
                          if (approved) {
                            SnackbarService().showSnackBar(
                              'Campaign approved successfully',
                              type: SnackbarType.success,
                            );
                          }
                        },
                        cancelButtonText: 'Cancel',
                      ),
                    );
                  },
                  onReject: () {
                    _showRejectDialog(context, campaign.id ?? '', campaign.title ?? '');
                  },
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingAnimation()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(pendingApprovalCampaignsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String campaignId, String campaignTitle) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: kWhite,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reject Campaign',
                style: kHeadTitleR,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to reject "$campaignTitle"?',
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'Enter rejection reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kStrokeColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: kSmallerTitleL.copyWith(color: kTextColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final rejected = await ref
                            .read(pendingApprovalCampaignsProvider.notifier)
                            .rejectCampaign(campaignId, reasonController.text);
                        if (rejected) {
                          SnackbarService().showSnackBar(
                            'Campaign rejected successfully',
                            type: SnackbarType.success,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC62828),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Reject',
                        style: kSmallerTitleL.copyWith(color: kWhite),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
