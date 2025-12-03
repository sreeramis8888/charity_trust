import 'package:charity_trust/src/interfaces/components/cards/campaing_card.dart';
import 'package:charity_trust/src/interfaces/components/cards/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;

class MyParticipationsPage extends StatefulWidget {
  const MyParticipationsPage({super.key});

  @override
  State<MyParticipationsPage> createState() => _MyParticipationsPageState();
}

class _MyParticipationsPageState extends State<MyParticipationsPage>
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
            isMyCampaign: true,
          ),
        ),
      ],
    );
  }

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
}
