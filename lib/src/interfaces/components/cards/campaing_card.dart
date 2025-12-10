import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/components/text_pill.dart';
import 'package:flutter/material.dart';

class CampaignCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String category;
  final String date;
  final String? image;
  final int raised;
  final int goal;
  final VoidCallback onDetails;
  final VoidCallback? onDonate;
  final bool isMyCampaign;
  final bool isApprovalCard;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const CampaignCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.raised,
    required this.goal,
    this.image,
    required this.onDetails,
    this.onDonate,
    this.isMyCampaign = false,
    this.isApprovalCard = false,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final percent = goal > 0 ? (raised / goal) : 0.0;
    final isGeneralCampaign = category == 'General Campaign';

    return Container(
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextPill(
                text: category,
                color: const Color(0xFFFF6900),
                textStyle: kSmallerTitleR.copyWith(fontSize: 10, color: kWhite),
              ),
              if (isGeneralCampaign)
                TextPill(
                  text: "DUE DATE:  $date",
                  color: const Color(0xFFDBDBDB),
                  textStyle: kSmallerTitleR.copyWith(fontSize: 10),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image ?? '',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: kBodyTitleM),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: kSmallerTitleR.copyWith(
                        fontSize: 12,
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isGeneralCampaign) ...[
            const SizedBox(height: 16),
            LinearProgressIndicator(
              color: Color(0xFFFFD400),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
              value: percent,
              backgroundColor: Color(0xFFCFCFCF),
            ),
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 6,
              runSpacing: 4,
              children: [
                Text(
                  "₹$raised",
                  style: kBodyTitleM.copyWith(color: Color(0xFF009000)),
                  maxLines: 3,
                ),
                Text(
                  "raised of",
                  style: kBodyTitleR,
                  maxLines: 3,
                ),
                Text(
                  "₹$goal",
                  style: kBodyTitleSB,
                  maxLines: 3,
                ),
                Text(
                  "goal",
                  style: kBodyTitleR,
                  maxLines: 3,
                ),
                Text(
                  "${(percent * 100).toInt()}%",
                  style: kSmallTitleR,
                  maxLines: 3,
                ),
              ],
            ),
          ] else
            const SizedBox(height: 16),
          const SizedBox(height: 16),
          if (isApprovalCard)
            Row(
              children: [
                Expanded(
                  child: primaryButton(
                    label: "Reject",
                    onPressed: onReject,
                    buttonColor: const Color(0xFFFFEBEE),
                    labelColor: const Color(0xFFC62828),
                    sideColor: const Color(0xFFC62828),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: primaryButton(
                    label: "Accept",
                    onPressed: onApprove,
                    buttonColor: const Color(0xFF2E7D32),
                    labelColor: kWhite,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: primaryButton(
                    label: "View details",
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        'CampaignDetail',
                        arguments: {
                          '_id': id,
                          'title': title,
                          'description': description,
                          'category': category,
                          'date': date,
                          'image': image,
                          'raised': raised,
                          'goal': goal,
                        },
                      );
                    },
                    buttonColor: kCardBackgroundColor,
                    labelColor: kTextColor,
                    sideColor: kTextColor,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
