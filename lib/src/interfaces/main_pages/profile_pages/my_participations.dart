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
        participatedCampaignsProvider,
        transactionsFilterProvider,
        memberDonationsProvider;
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/models/campaign_model.dart';
import 'package:Annujoom/src/interfaces/main_pages/campaign_pages/add_campaign.dart';

class MyParticipationsPage extends ConsumerStatefulWidget {
  const MyParticipationsPage({super.key});

  @override
  ConsumerState<MyParticipationsPage> createState() =>
      _MyParticipationsPageState();
}

class _MyParticipationsPageState extends ConsumerState<MyParticipationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  late ScrollController _userTransactionsController;
  late ScrollController _memberTransactionsController;
  late ScrollController _joinedCampaignsController;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    _userTransactionsController = ScrollController();
    _memberTransactionsController = ScrollController();
    _joinedCampaignsController = ScrollController();

    _setupScrollController(
      _userTransactionsController,
      () => ref.read(participatedCampaignsProvider.notifier).loadNextPage(),
    );
    _setupScrollController(
      _memberTransactionsController,
      () => ref.read(memberDonationsProvider.notifier).loadNextPage(),
    );
    _setupScrollController(
      _joinedCampaignsController,
      () => ref.read(participatedCampaignsProvider.notifier).loadNextPage(),
    );
    super.initState();
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
    _controller.dispose();
    _userTransactionsController.dispose();
    _memberTransactionsController.dispose();
    _joinedCampaignsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final secureStorage = ref.watch(secureStorageServiceProvider);

    return FutureBuilder<String?>(
      future: secureStorage.getUserData().then((user) => user?.role),
      builder: (context, roleSnapshot) {
        final userRole = roleSnapshot.data;
        final isNonMember = userRole != null && userRole != 'member';
        final pageTitle = isNonMember ? "My Campaigns" : "My Participations";

        return Scaffold(
          backgroundColor: kBackgroundColor,
          appBar: AppBar(
            backgroundColor: kWhite,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: kTextColor,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(pageTitle, style: kBodyTitleM),
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
              color: kWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
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
                Tab(text: isNonMember ? "Member Transactions" : "Your Transactions"),
                Tab(text: isNonMember ? "My Campaigns" : "My Campaigns"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          _yourTransactionsTab(),
          _myCampaignsTab(),
        ],
      ),
        );
      },
    );
  }

  // Transactions Tab
  Widget _yourTransactionsTab() {
    final secureStorage = ref.watch(secureStorageServiceProvider);
    final currentFilter = ref.watch(transactionsFilterProvider);

    return FutureBuilder<String?>(
      future: secureStorage.getUserData().then((user) => user?.role),
      builder: (context, snapshot) {
        final userRole = snapshot.data;
        final isNonMember = userRole != null && userRole != 'member';

        return Column(
          children: [
            if (isNonMember)
              FutureBuilder<String?>(
                future: secureStorage.getUserData().then((user) => user?.name),
                builder: (context, nameSnapshot) {
                  final userName = nameSnapshot.data ?? 'User';
                  return ChoiceChipFilter(
                    options: [userName, 'Member Transactions'],
                    selectedOption: currentFilter ? 'Member Transactions' : userName,
                    onSelectionChanged: (selected) {
                      ref.read(transactionsFilterProvider.notifier).setFilter(selected == 'Member Transactions');
                    },
                  );
                },
              ),
            Expanded(
              child: currentFilter
                  ? _buildMemberTransactionsView()
                  : _buildUserTransactionsView(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserTransactionsView() {
    final participatedState = ref.watch(participatedCampaignsProvider);

    return participatedState.when(
      data: (paginationState) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          controller: _userTransactionsController,
          itemCount: paginationState.donations.length,
          itemBuilder: (context, index) {
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
                  amount: donation.amount?.toString() ?? '-',
                  status: donation.status ?? '',
                  date: formatDate(donation.createdAt) ?? '',
                  receipt: donation.receipt ?? '',
                  donorName: donation.user_name ?? '',
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

  Widget _buildMemberTransactionsView() {
    final memberDonationsState = ref.watch(memberDonationsProvider);

    return memberDonationsState.when(
      data: (paginationState) {
        if (paginationState.donations.isEmpty) {
          return Center(
            child: Text(
              'No member transactions',
              style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          controller: _memberTransactionsController,
          itemCount: paginationState.donations.length,
          itemBuilder: (context, index) {
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
                  amount: donation.amount?.toString() ?? '-',
                  status: donation.status ?? '',
                  date: formatDate(donation.createdAt) ?? '',
                  receipt: donation.receipt ?? '',
                  donorName: donation.user_name ?? '',
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
                ref.read(memberDonationsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // My Campaigns Tab
  Widget _myCampaignsTab() {
    final donationsState = ref.watch(participatedCampaignsProvider);

    return donationsState.when(
      data: (paginationState) {
        final campaigns = paginationState.donations
            .map((donation) => donation.campaign)
            .whereType<CampaignModel>()
            .toList();

        if (campaigns.isEmpty) {
          return Center(
            child: Text(
              'No joined campaigns',
              style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          controller: _joinedCampaignsController,
          itemCount: campaigns.length,
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
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
                ref.read(participatedCampaignsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
