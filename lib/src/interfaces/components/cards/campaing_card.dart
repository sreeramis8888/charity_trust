import 'dart:developer';

import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/providers/campaigns_provider.dart';
import 'package:Annujoom/src/data/services/deep_link_service.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/components/text_pill.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

class CampaignCard extends ConsumerWidget {
  final String id;
  final String title;
  final String description;
  final String category;
  final String date;
  final String? startDate;
  final String? image;
  final int raised;
  final int? goal;
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
    this.startDate,
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

  bool get _hasDueDate => date.isNotEmpty && date != '-';

  bool get _hasGoal => goal != null && goal! > 0;

  Future<void> _shareCampaign(WidgetRef ref) async {
    if (id.isEmpty) {
      SnackbarService().showSnackBar(
        'Unable to share this campaign',
        type: SnackbarType.error,
      );
      return;
    }

    try {
      final campaignsApi = ref.read(campaignsApiProvider);
      final response = await campaignsApi.getCampaignShareLink(id);

      String shareUrl = ref
          .read(deepLinkServiceProvider)
          .generateDeepLink('campaign', id: id);

      if (response.success && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) {
          shareUrl = data['share_url'] as String? ?? shareUrl;
        }
      }

      final message = StringBuffer()
        ..writeln(title)
        ..writeln();

      final trimmedDescription = description.trim();
      if (trimmedDescription.isNotEmpty) {
        message.writeln(trimmedDescription);
        message.writeln();
      }

      message.write(shareUrl);

      await Share.share(message.toString(), subject: title);
    } catch (e) {
      log('Error sharing campaign: $e');
      SnackbarService().showSnackBar(
        'Error sharing campaign',
        type: SnackbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasGoal = _hasGoal;
    final hasDueDate = _hasDueDate;
    final percent = hasGoal ? (raised / goal!).clamp(0.0, 1.0) : 0.0;
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
              if (!isApprovalCard)
                TextPill(
                  text: _getLocalizedCategory(category),
                  color: const Color(0xFFFF6900),
                  textStyle:
                      kSmallerTitleR.copyWith(fontSize: 10, color: kWhite),
                ),
              if (isApprovalCard && startDate != null)
                TextPill(
                  text: "${'start'.tr()}: $startDate",
                  color: const Color(0xFFDBDBDB),
                  textStyle: kSmallerTitleR.copyWith(fontSize: 10),
                ),
              if (isGeneralCampaign && !isApprovalCard && hasDueDate)
                TextPill(
                  text: "${'dueDate'.tr()}:  $date",
                  color: const Color(0xFFDBDBDB),
                  textStyle: kSmallerTitleR.copyWith(fontSize: 10),
                ),
              if (isApprovalCard && hasDueDate)
                TextPill(
                  text: "${'dueDate'.tr()}: $date",
                  color: const Color(0xFFDBDBDB),
                  textStyle: kSmallerTitleR.copyWith(fontSize: 10),
                ),
              if (!isApprovalCard && id.isNotEmpty)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  icon: const Icon(
                    Icons.share_outlined,
                    color: kTextColor,
                    size: 20,
                  ),
                  onPressed: () => _shareCampaign(ref),
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
          if (isGeneralCampaign && !isApprovalCard) ...[
            const SizedBox(height: 16),
            if (hasGoal) ...[
              LinearProgressIndicator(
                color: Color(0xFFFFD400),
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
                value: percent,
                backgroundColor: Color(0xFFCFCFCF),
              ),
              const SizedBox(height: 8),
            ],
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 6,
              runSpacing: 4,
              children: [
                Text(
                  hasGoal ? "₹${raised > goal! ? goal : raised}" : "₹$raised",
                  style: kBodyTitleM.copyWith(color: Color(0xFF009000)),
                  maxLines: 3,
                ),
                if (hasGoal) ...[
                  Text(
                    "raisedOf".tr(),
                    style: kBodyTitleR,
                    maxLines: 3,
                  ),
                  Text(
                    "₹$goal",
                    style: kBodyTitleSB,
                    maxLines: 3,
                  ),
                  Text(
                    "goal".tr(),
                    style: kBodyTitleR,
                    maxLines: 3,
                  ),
                  Text(
                    "${(percent * 100).toInt()}%",
                    style: kSmallTitleR,
                    maxLines: 3,
                  ),
                ] else
                  Text(
                    "raised".tr(),
                    style: kBodyTitleR,
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
                    label: "reject".tr(),
                    onPressed: onReject,
                    buttonColor: kCardBackgroundColor,
                    labelColor: const Color(0xFFC62828),
                    sideColor: const Color(0xFFC62828),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: primaryButton(
                    label: "accept".tr(),
                    onPressed: onApprove,
                    buttonColor: const Color(0xFF009B0A),
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
                    label: "viewDetails".tr(),
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

  String _getLocalizedCategory(String category) {
    switch (category) {
      case 'General Campaign':
        return 'generalCampaign'.tr();
      case 'General Funding':
        return 'generalFunding'.tr();
      case 'Zakat':
        return 'zakat'.tr();
      case 'Orphan':
        return 'orphan'.tr();
      case 'Widow':
        return 'widow'.tr();
      case 'Ghusl Mayyit':
        return 'ghusalMayyit'.tr();
      case 'Patient Relief':
        return 'patientRelief'.tr();
      case 'Food Kit':
        return 'foodKit'.tr();
      default:
        return category;
    }
  }
}
