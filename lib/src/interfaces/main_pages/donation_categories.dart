import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart';
import 'package:Annujoom/src/interfaces/main_pages/campaign_pages/category_campaign_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DonationCategoriesPage extends StatelessWidget {
  const DonationCategoriesPage({super.key});

  static const List<Map<String, String>> categories = [
    {
      'title': 'General Campaign',
      'subtitle': 'Donate for community initiatives and development',
      'image': 'assets/png/general_campaign.png',
      'category': 'General Campaign'
    },
    {
      'title': 'General Funding',
      'subtitle': 'Support overall social and welfare activities',
      'image': 'assets/jpg/general_funding.jpg',
      'category': 'General Funding'
    },
    {
      'title': 'Zakat',
      'subtitle': 'Fulfill religious duty by helping eligible people',
      'image': 'assets/png/zakat.png',
      'category': 'Zakat'
    },
    {
      'title': 'Orphan',
      'subtitle': 'Help children live, learn & grow',
      'image': 'assets/jpg/orphan.jpg',
      'category': 'Orphan'
    },
    {
      'title': 'Widow',
      'subtitle': 'Support widows with essential needs',
      'image': 'assets/png/widow.png',
      'category': 'Widow'
    },
    {
      'title': 'Ghusal Mayyit',
      'subtitle': 'Provide burial support for needy families',
      'image': 'assets/png/ghusal_mayyt.png',
      'category': 'Ghusl Mayyit'
    },
  ];

  void _handleCategoryTap(BuildContext context, String category) {
    if (category == 'General Campaign') {
      Navigator.of(context).pushNamed('Campaign');
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
          'Donations',
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
                    'Donate & Support Our Community',
                    style: kSubHeadingM.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your contribution can change someone\'s life today.',
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
