import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/participated_campaign_model.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/data/utils/date_formatter.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParticipatedCampaignsPage extends ConsumerWidget {
  const ParticipatedCampaignsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(fetchUserProfileProvider);
    final preferredLanguage = GlobalVariables.getPreferredLanguage();

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('myParticipations'.tr(), style: kBodyTitleM),
      ),
      body: userDataAsync.when(
        data: (user) {
          final campaigns = user?.participatedCampaigns ?? const [];
          if (campaigns.isEmpty) {
            return Center(
              child: Text(
                'noParticipatedCampaigns'.tr(),
                style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            color: kPrimaryColor,
            onRefresh: () async {
              ref.invalidate(fetchUserProfileProvider);
              await ref.read(fetchUserProfileProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              itemCount: campaigns.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final campaign = campaigns[index];
                return _ParticipatedCampaignTile(
                  campaign: campaign,
                  preferredLanguage: preferredLanguage,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: LoadingAnimation()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'errorLoadingParticipatedCampaigns'.tr(),
                  style: kBodyTitleB,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(fetchUserProfileProvider),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipatedCampaignTile extends StatelessWidget {
  final ParticipatedCampaignModel campaign;
  final String preferredLanguage;

  const _ParticipatedCampaignTile({
    required this.campaign,
    required this.preferredLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final title = campaign.getTitle(preferredLanguage);
    final imageUrl = campaign.coverImage ?? '';

    return Material(
      color: kWhite,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey[200],
                  child: Icon(Icons.broken_image, color: Colors.grey[500]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isNotEmpty ? title : 'campaign'.tr(),
                    style: kSmallTitleSB,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((campaign.category ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      campaign.category!,
                      style: kSmallerTitleR.copyWith(
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '${'donated'.tr()}: ₹${campaign.totalAmount.toStringAsFixed(0)}',
                    style: kSmallerTitleM.copyWith(color: kPrimaryColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${'timesParticipated'.tr()}: ${campaign.donationCount}',
                    style: kSmallerTitleR.copyWith(
                      color: kSecondaryTextColor,
                    ),
                  ),
                  if (campaign.latestDonation != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${'lastDonation'.tr()}: ${formatDate(campaign.latestDonation)}',
                      style: kSmallerTitleR.copyWith(
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
