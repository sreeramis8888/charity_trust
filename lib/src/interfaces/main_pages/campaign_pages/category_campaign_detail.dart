import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/providers/campaigns_provider.dart';
import 'package:Annujoom/src/interfaces/main_pages/campaign_pages/campaign_detail.dart';

class CategoryCampaignDetailPage extends ConsumerWidget {
  final String category;

  const CategoryCampaignDetailPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsAsync = ref.watch(categoryCampaignsProvider(category));

    return campaignsAsync.when(
      data: (paginationState) {
        if (paginationState.campaigns.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: kWhite,
              scrolledUnderElevation: 0,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: kTextColor,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('Campaign Details', style: kBodyTitleM),
            ),
            backgroundColor: kBackgroundColor,
            body: const Center(
              child: Text('No campaign found'),
            ),
          );
        }

        final campaign = paginationState.campaigns.first;

        return CampaignDetailPage(
          id: campaign.id,
          title: campaign.title,
          description: campaign.description,
          category: campaign.category,
          date: campaign.targetDate?.toString().split(' ')[0],
          image: campaign.coverImage,
          raised: campaign.collectedAmount?.toInt(),
          goal: campaign.targetAmount?.toInt(),
          isDirectCategory: true,
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          backgroundColor: kWhite,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: kTextColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Campaign Details', style: kBodyTitleM),
        ),
        backgroundColor: kBackgroundColor,
        body: const Center(
          child: LoadingAnimation(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(
          backgroundColor: kWhite,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: kTextColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Campaign Details', style: kBodyTitleM),
        ),
        backgroundColor: kBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(categoryCampaignsProvider(category));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
