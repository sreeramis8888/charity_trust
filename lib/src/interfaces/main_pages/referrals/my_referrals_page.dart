import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/interfaces/components/cards/referral_card.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'referral_details_page.dart';

class MyReferralsPage extends ConsumerStatefulWidget {
  const MyReferralsPage({super.key});

  @override
  ConsumerState<MyReferralsPage> createState() => _MyReferralsPageState();
}

class _MyReferralsPageState extends ConsumerState<MyReferralsPage> {
  @override
  Widget build(BuildContext context) {
    final pendingApprovalsAsync = ref.watch(pendingApprovalsProvider);
    final userReferralsAsync = ref.watch(userReferralsProvider);

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
          'My Referrals',
          style: kBodyTitleR,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Referrals Summary', style: kBodyTitleM),
              const SizedBox(height: 12),
              anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromBottom,
                duration: anim.AnimationDuration.slow,
                curveType: anim.AnimationCurveType.easeOut,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Color(0xFFFFFFFF), Color(0xFFCEE8F8)],
                        begin: AlignmentGeometry.topCenter,
                        end: AlignmentGeometry.bottomCenter),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: userReferralsAsync.when(
                    data: (referrals) {
                      final total = referrals.length;
                      final approved =
                          referrals.where((r) => r.status == 'active').length;
                      final pending =
                          referrals.where((r) => r.status == 'pending').length;
                      final rejected =
                          referrals.where((r) => r.status == 'rejected').length;

                      return _buildStatsColumn(total, approved, pending, rejected);
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
                  Text('Referrals', style: kBodyTitleM),
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
                      'Add New Member',
                      style: kSmallTitleM.copyWith(color: kWhite),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              pendingApprovalsAsync.when(
                data: (pendingApprovals) {
                  return userReferralsAsync.when(
                    data: (referrals) {
                      final allReferrals = [
                        ...pendingApprovals,
                        ...referrals.where((r) => !pendingApprovals.any((p) => p.id == r.id))
                      ];

                      if (allReferrals.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Text(
                              'No referrals yet',
                              style: kSmallTitleR.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allReferrals.length,
                        itemBuilder: (context, index) {
                          final user = allReferrals[index];
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
                                    .read(pendingApprovalsProvider
                                        .notifier)
                                    .refresh();
                                await ref
                                    .read(userReferralsProvider
                                        .notifier)
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
                                    .read(pendingApprovalsProvider
                                        .notifier)
                                    .refresh();
                                await ref
                                    .read(userReferralsProvider
                                        .notifier)
                                    .refresh();
                              }
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: LoadingAnimation(),
                    ),
                    error: (error, stack) => Center(
                      child: Text('Error loading referrals: $error'),
                    ),
                  );
                },
                loading: () => const Center(
                  child: LoadingAnimation(),
                ),
                error: (error, stack) => Center(
                  child: Text('Error loading approvals: $error'),
                ),
              ),
            ],
          ),
        ),
      ),
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
              child: _buildStatItem(total.toString(), 'Total'),
            ),
            Container(
              width: 1,
              height: 60,
              color: kStrokeColor.withOpacity(0.06),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 18),
                child: _buildStatItem(approved.toString(), 'Approved'),
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
              child: _buildStatItem(pending.toString(), 'Pending'),
            ),
            Container(
              width: 1,
              height: 60,
              color: kStrokeColor.withOpacity(0.06),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 18),
                child: _buildStatItem(rejected.toString(), 'Rejected'),
              ),
            ),
          ],
        ),
      ],
    );
  }

}
