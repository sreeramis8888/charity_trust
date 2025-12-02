import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:flutter/material.dart';

class CampaignPage extends StatelessWidget {
  const CampaignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Text(
          'Campaigns',
          style: kHeadTitleM.copyWith(fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Campaigns',
              style: kHeadTitleM.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            // Placeholder for campaigns list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Campaign ${index + 1}',
                        style: kHeadTitleM.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Description for campaign ${index + 1}',
                        style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.6,
                          minHeight: 8,
                          backgroundColor: kBorder,
                          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
