import 'package:charity_trust/src/data/utils/date_formatter.dart';
import 'package:charity_trust/src/interfaces/components/cards/campaing_card.dart';
import 'package:charity_trust/src/interfaces/components/cards/transaction_card.dart';
import 'package:charity_trust/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:charity_trust/src/data/providers/campaigns_provider.dart'
    show participatedCampaignsProvider;

class MyParticipationsPage extends ConsumerStatefulWidget {
  const MyParticipationsPage({super.key});

  @override
  ConsumerState<MyParticipationsPage> createState() =>
      _MyParticipationsPageState();
}

class _MyParticipationsPageState extends ConsumerState<MyParticipationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Text("My Participations", style: kHeadTitleSB),
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
              tabs: const [
                Tab(text: "My Campaigns"),
                Tab(text: "Your Transactions"),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          _myCampaignsTab(),
          _yourTransactionsTab(),
        ],
      ),
    );
  }

  Widget _myCampaignsTab() {
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
            final campaign = donation.campaign;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.normal,
                delayMilliseconds: index * 50,
                child: CampaignCard(
                  id: campaign?.id ?? '',
                  description: campaign?.description ?? '',
                  title: campaign?.title ?? '',
                  category: campaign?.category ?? '',
                  date: formatDate(campaign?.targetDate) ?? '',
                  image: campaign?.coverImage ?? '',
                  raised: campaign?.collectedAmount?.toInt() ?? 0,
                  goal: campaign?.targetAmount?.toInt() ?? 0,
                  onDetails: () {
                    Navigator.of(context).pushNamed(
                      'CampaignDetail',
                      arguments: {
                        '_id': campaign?.id ?? '',
                        'title': campaign?.title ?? '',
                        'description': campaign?.description ?? '',
                        'category': campaign?.category ?? '',
                        'date': formatDate(campaign?.targetDate) ?? '',
                        'image': campaign?.coverImage ?? '',
                        'raised': campaign?.collectedAmount?.toInt() ?? 0,
                        'goal': campaign?.targetAmount?.toInt() ?? 0,
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
                  amount: donation.amount?.toString() ?? '-',
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
}
