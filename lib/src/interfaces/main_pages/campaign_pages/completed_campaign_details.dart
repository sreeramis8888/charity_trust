import 'package:Annujoom/src/data/models/promotions_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:intl/intl.dart';

class CompletedCampaignDetailsPage extends ConsumerWidget {
  final Promotions promotion;

  const CompletedCampaignDetailsPage({super.key, required this.promotion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageCode = GlobalVariables.getPreferredLanguage();
    final title = promotion.getTitle(languageCode);
    final description = promotion.getDescription(languageCode);
    final imageUrl = promotion.media ?? 'https://placehold.co/400x225';

    // Format numbers
    final formatter = NumberFormat('#,##,###');
    final goalAmount = promotion.targetAmount != null
        ? formatter.format(promotion.targetAmount)
        : '0';
    final collectedAmount = promotion.collectedAmount != null
        ? formatter.format(promotion.collectedAmount)
        : '0';

    // Date calculations
    final startDate = promotion.startDate;
    final targetDate = promotion.targetDate;
    final endDate = promotion.endDate; // Assuming this is Completion Date

    final startStr = startDate != null
        ? DateFormat('dd MMM, yyyy').format(startDate)
        : 'N/A';
    final targetStr = targetDate != null
        ? DateFormat('dd MMM, yyyy').format(targetDate)
        : 'N/A';
    final endStr =
        endDate != null ? DateFormat('dd MMM, yyyy').format(endDate) : 'N/A';

    String timeTaken = 'N/A';
    if (startDate != null && endDate != null) {
      final difference = endDate.difference(startDate).inDays;
      timeTaken = '$difference days';
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Completed Campaign Details', // Or localize if needed
          style: kHeadTitleSB.copyWith(fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: kHeadTitleSB.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Completed Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Light green background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Color(0xFF009000), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Campaign Completed', // Or localize
                    style: kBodyTitleM.copyWith(
                        color: const Color(0xFF009000), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Goal & Collected
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: 'Goal: ',
                    style:
                        kBodyTitleR.copyWith(color: kTextColor, fontSize: 16),
                    children: [
                      TextSpan(
                        text: '₹$goalAmount',
                        style: kHeadTitleSB.copyWith(
                            color: kTextColor, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: 'Collected: ',
                    style: kBodyTitleR.copyWith(
                        color: kSecondaryTextColor, fontSize: 16),
                    children: [
                      TextSpan(
                        text: '₹$collectedAmount',
                        style: kHeadTitleSB.copyWith(
                            color: const Color(0xFF009000), fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Divider
            const Divider(color: kBorder),
            const SizedBox(height: 16),

            // About Campaign
            Text(
              'About Campaign', // Or localize
              style: kBodyTitleSB.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              description.isNotEmpty ? description : 'No description provided.',
              style: kBodyTitleR.copyWith(
                  color: kSecondaryTextColor, height: 1.5, fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Dates List
            _buildDateRow('Start Date', startStr),
            const SizedBox(height: 12),
            _buildDateRow('Target Date', targetStr),
            const SizedBox(height: 12),
            _buildDateRow('Completion Date', endStr),
            const SizedBox(height: 16),
            _buildDateRow('Time Taken', timeTaken),

            const SizedBox(height: 48),

            // Share Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Implement Share functionality
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kTextColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Share', // Or localize
                  style: kBodyTitleR.copyWith(color: kTextColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 150, // Fixed width for alignment as seen in design
          child: Text(
            label,
            style: kBodyTitleSB.copyWith(color: kTextColor, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: kBodyTitleR.copyWith(color: kTextColor, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
