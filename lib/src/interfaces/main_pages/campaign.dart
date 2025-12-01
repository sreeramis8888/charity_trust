import 'package:charity_trust/src/interfaces/components/cards/campaing_card.dart';
import 'package:charity_trust/src/interfaces/components/cards/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;

class CampaignPage extends StatefulWidget {
  const CampaignPage({super.key});

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage>
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
          preferredSize: Size.fromHeight(48), // important!
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          child: CampaignCard(
            description:
                'Help us build homes for families displaced by the recent landslides. Your donation provides shelter and hope.',
            title: "Landslide Relief Fund",
            category: "Funding Campaigns",
            date: "02 Jan 2023",
            image: "https://picsum.photos/id/237/200/300",
            raised: 75000,
            goal: 150000,
            onDetails: () {},
            onDonate: () {},
          ),
        ),
        const SizedBox(height: 16),
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 150,
          child: CampaignCard(
            description:
                'Help us build homes for families displaced by the recent landslides. Your donation provides shelter and hope.',
            title: "Medical Relief Fund",
            category: "General Donations",
            date: "02 Jan 2023",
            raised: 30000,
            goal: 50000,
            image: "https://picsum.photos/id/237/200/300",
            onDetails: () {},
            onDonate: () {},
          ),
        ),
      ],
    );
  }

  // ---------------- TAB 2 ---------------- //
  Widget _yourTransactionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          child: const TransactionCard(
            id: "VCRU65789900",
            type: "Campaigns",
            date: "18th May 2025, 10:45 am",
            amount: "₹1500",
            status: "Success",
          ),
        ),
        const SizedBox(height: 16),
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 150,
          child: const TransactionCard(
            id: "VCRU65789900",
            type: "Campaigns",
            date: "18th May 2025, 10:45 am",
            amount: "₹1500",
            status: "Success",
          ),
        ),
      ],
    );
  }

  // ---------------- TAB 3 ---------------- //
  Widget _myCampaignsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          child: CampaignCard(
            description:
                'Help us build homes for families displaced by the recent landslides. Your donation provides shelter and hope.',
            title: "My Flood Relief",
            category: "Funding Campaigns",
            date: "02 Jan 2023",
            raised: 75000,
            goal: 150000,
            image: "https://picsum.photos/id/237/200/300",
            onDetails: () {},
            isMyCampaign: true, // removes donate button
          ),
        ),
      ],
    );
  }
}
