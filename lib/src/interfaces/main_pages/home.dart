import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: Text(
          'Home',
          style: kHeadTitleM.copyWith(fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Charity Trust',
              style: kHeadTitleM.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Explore campaigns, contribute to causes, and make a difference in your community.',
                style: kSmallTitleR.copyWith(color: kTextColor),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Featured Campaigns',
              style: kHeadTitleM.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 16),
            // Placeholder for featured campaigns
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: kBorder,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Featured campaigns will appear here',
                  style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
