import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart';
import 'package:Annujoom/src/interfaces/main_pages/campaign_pages/category_campaign_detail.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DonationCategoriesPage extends StatelessWidget {
  const DonationCategoriesPage({super.key});

  List<Map<String, String>> get categories => [
        {
          'title': 'generalCampaign'.tr(),
          'subtitle': 'generalCampaignSubtitle'.tr(),
          'image': 'assets/png/general_campaign.png',
          'category': 'General Campaign'
        },
        {
          'title': 'generalFunding'.tr(),
          'subtitle': 'generalFundingSubtitle'.tr(),
          'image': 'assets/jpg/general_funding.jpg',
          'category': 'General Funding'
        },
        {
          'title': 'zakat'.tr(),
          'subtitle': 'zakatSubtitle'.tr(),
          'image': 'assets/png/zakat.png',
          'category': 'Zakat'
        },
        {
          'title': 'orphan'.tr(),
          'subtitle': 'orphanSubtitle'.tr(),
          'image': 'assets/jpg/orphan.jpg',
          'category': 'Orphan'
        },
        {
          'title': 'widow'.tr(),
          'subtitle': 'widowSubtitle'.tr(),
          'image': 'assets/png/widow.png',
          'category': 'Widow'
        },
        {
          'title': 'ghusalMayyit'.tr(),
          'subtitle': 'ghusalMayyitSubtitle'.tr(),
          'image': 'assets/png/ghusal_mayyt.png',
          'category': 'Ghusl Mayyit'
        },
      ];

  void _handleCategoryTap(BuildContext context, String category) {
    if (category == 'General Campaign') {
      Navigator.of(context).pushNamed(
        'Campaign',
        arguments: {'category': category},
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CategoryCampaignDetailPage(category: category),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'donations'.tr(),
          style: kBodyTitleM,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'donateSupportCommunity'.tr(),
                    style: kSubHeadingM.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'contributionMessage'.tr(),
                    style: kSmallTitleL,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return AnimatedWidgetWrapper(
                    animationType: AnimationType.fadeScaleUp,
                    duration: AnimationDuration.normal,
                    curveType: AnimationCurveType.easeOut,
                    child: GestureDetector(
                      onTap: () {
                        _handleCategoryTap(context, category['category']!);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, left: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    category['image'] ?? '',
                                    fit: BoxFit.cover,
                                    cacheWidth: 200,
                                    cacheHeight: 200,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                            Icons.image_not_supported),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category['title'] ?? '',
                                    style: kBodyTitleM.copyWith(fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category['subtitle'] ?? '',
                                    style: kSmallerTitleL,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
