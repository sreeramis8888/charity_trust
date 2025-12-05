import 'package:charity_trust/src/data/utils/date_formatter.dart';
import 'package:charity_trust/src/interfaces/components/cards/campaing_card.dart';
import 'package:charity_trust/src/interfaces/components/cards/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:charity_trust/src/data/providers/campaigns_provider.dart';

class CampaignPage extends ConsumerStatefulWidget {
  const CampaignPage({super.key});

  @override
  ConsumerState<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends ConsumerState<CampaignPage>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Text("Campaign", style: kHeadTitleSB),
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
              tabs: const [
                Tab(
                  text: "General Campaign",
                ),
                Tab(text: "Your Transactions"),
                Tab(text: "My Campaigns"),
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
                child: CampaignCard(id: campaign.id??'',
                  description: campaign.description ?? '',
                  title: campaign.title ?? '',
                  category: campaign.category ?? '',
                  date: formatDate(campaign.targetDate) ?? '',
                  image: campaign.coverImage ?? '',
                  raised: campaign.collectedAmount?.toInt() ?? 0,
                  goal: campaign.targetAmount?.toInt() ?? 0,
                  onDetails: () {},
                  onDonate: () {},
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Transactions feature coming soon'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('View Transactions'),
          ),
        ],
      ),
    );
  }

  // ---------------- TAB 3 ---------------- //
  Widget _myCampaignsTab() {
    final myCampaignsState = ref.watch(myCampaignsProvider);

    return myCampaignsState.when(
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
                      ref.read(myCampaignsProvider.notifier).loadNextPage();
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
                child: CampaignCard(id: campaign.id??'',
                  description: campaign.description ?? '',
                  title: campaign.title ?? '',
                  category: campaign.category ?? '',
                  date: formatDate(campaign.targetDate) ?? '',
                  image: campaign.coverImage ?? '',
                  raised: campaign.collectedAmount?.toInt() ?? 0,
                  goal: campaign.targetAmount?.toInt() ?? 0,
                  onDetails: () {},
                  isMyCampaign: true,
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(myCampaignsProvider.notifier).refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
