import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/components/primaryButton.dart';
import 'package:charity_trust/src/interfaces/components/text_pill.dart';
import 'package:flutter/material.dart';

class CampaignCard extends StatelessWidget {
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

  const CampaignCard({
    super.key,
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
  });

  @override
  Widget build(BuildContext context) {
    final percent = (raised / goal);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: primaryButton(
                  label: "View details",
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      'CampaignDetail',
                      arguments: {
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
                  buttonColor: kWhite,
                  labelColor: kTextColor,
                  sideColor: kTertiary,
                ),
              ),
              if (!isMyCampaign) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: primaryButton(
                    label: "Donate",
                    onPressed: onDonate,
                    buttonColor: kPrimaryColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
