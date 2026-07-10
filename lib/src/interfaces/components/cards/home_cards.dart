import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/utils/currency_formatter.dart';
import 'package:Annujoom/src/data/utils/date_formatter.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/components/text_pill.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ============================================================================
// WARNING BADGE WITH BLINKING ANIMATION
// ============================================================================
class _WarningBadge extends StatefulWidget {
  const _WarningBadge();

  @override
  State<_WarningBadge> createState() => _WarningBadgeState();
}

class _WarningBadgeState extends State<_WarningBadge>
    with TickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final AnimationController _pulseController;
  late final Animation<double> _blinkAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color warningYellow = Color(0xFFFFC107); // Amber warning

    return Stack(
      alignment: Alignment.center,
      children: [
        // Subtle pulse ring
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: warningYellow.withOpacity(0.35),
                width: 1.5,
              ),
            ),
          ),
        ),

        // Main badge
        FadeTransition(
          opacity: _blinkAnimation,
          child: Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: warningYellow,
              boxShadow: [
                BoxShadow(
                  color: warningYellow.withOpacity(0.55),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class HomeCompletedCampaignCard extends StatelessWidget {
  final String heading;
  final String subtitle;
  final dynamic goal;
  final dynamic collected;
  final String? posterImage;
  final bool isImagePoster;
  final VoidCallback? onTap;
  final DateTime? completionDate;
  final DateTime? targetDate;

  const HomeCompletedCampaignCard({
    super.key,
    required this.heading,
    required this.subtitle,
    required this.goal,
    required this.collected,
    this.posterImage,
    this.isImagePoster = true,
    this.onTap,
    this.completionDate,
    this.targetDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (isImagePoster && posterImage != null)
              Image.network(
                posterImage!,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 280,
                  color: Colors.grey[800],
                ),
              )
            else
              Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      heading,
                      style: kBodyTitleSB.copyWith(
                        color: kWhite,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      targetDate != null
                          ? "${'successfullyCompletedOn'.tr()} ${formatDate(targetDate)}"
                          : "Successfully Completed on $subtitle",
                      style: kSmallTitleL.copyWith(
                        color: kWhite.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "goalLabel".tr() + ": ${formatCurrency(goal)}",
                          style: kSmallTitleM.copyWith(
                            color: kWhite,
                          ),
                        ),
                        Text(
                          "collectedLabel".tr() +
                              ": ${formatCurrency((collected != null && goal != null && (double.tryParse(collected.toString()) ?? 0) > (double.tryParse(goal.toString()) ?? 0)) ? goal : collected)} ✅",
                          style: kSmallTitleM.copyWith(
                            color: kWhite,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeNewsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? image;
  final VoidCallback? onTap;

  const HomeNewsCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.image,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: kWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: image != null && image!.isNotEmpty
                    ? Image.network(
                        image!,
                        height: 70,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _shimmerPlaceholder(),
                      )
                    : _shimmerPlaceholder(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: kBodyTitleSB,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: kSmallerTitleR.copyWith(
                      color: kSecondaryTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerPlaceholder() {
    return Container(
      height: 70,
      width: double.infinity,
      color: Colors.grey[300],
    );
  }
}

// ============================================================================
// HOME YOUTUBE PLAYER CARD - For Video Content
// ============================================================================
class HomeYoutubePlayerCard extends StatelessWidget {
  final String videoId;
  final String title;
  final String? thumbnail;
  final VoidCallback? onTap;

  const HomeYoutubePlayerCard({
    super.key,
    required this.videoId,
    required this.title,
    this.thumbnail,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Thumbnail
            Image.network(
              thumbnail ??
                  'https://img.youtube.com/vi/$videoId/maxresdefault.jpg',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey[800],
              ),
            ),
            // Dark overlay
            Container(
              height: 200,
              color: Colors.black.withOpacity(0.3),
            ),
            // Play button
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: kWhite,
                size: 32,
              ),
            ),
            // Title overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Text(
                  title,
                  style: kSmallTitleSB.copyWith(color: kWhite),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// HOME GRADIENT CAMPAIGN CARD - For Active Campaigns with Gradient Background
// ============================================================================
class HomeGradientCampaignCard extends StatelessWidget {
  final String title;
  final String description;
  final String? image;
  final int raised;
  final int? goal;
  final String dueDate;
  final String? category;
  final VoidCallback onViewDetails;
  final VoidCallback? onDonate;

  const HomeGradientCampaignCard({
    super.key,
    required this.title,
    required this.description,
    required this.raised,
    required this.goal,
    required this.dueDate,
    required this.onViewDetails,
    this.onDonate,
    this.image,
    this.category,
  });

  String _displayDueDate() {
    if (dueDate.isEmpty || dueDate == '-') return '';
    return dueDate;
  }

  bool get _hasDueDate => dueDate.isNotEmpty && dueDate != '-';

  @override
  Widget build(BuildContext context) {
    final isGeneralCampaign = category == 'General Campaign';
    final hasGoal = goal != null && goal! > 0;
    final percent = hasGoal ? (raised / goal!).clamp(0.0, 1.0) : 0.0;
    final displayDueDate = _displayDueDate();
    final hasDueDate = _hasDueDate;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF0A39C4), const Color(0xFF181818)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (isGeneralCampaign && hasDueDate)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: _WarningBadge(),
                        ),
                      if (hasDueDate)
                        Text(
                          "dueDate".tr(),
                          style: kSmallerTitleSB.copyWith(
                            fontSize: 10,
                            color: kWhite,
                          ),
                        ),
                    ],
                  ),
                  if (hasDueDate)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: kWhite, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            displayDueDate,
                            style: kSmallerTitleM.copyWith(
                              fontSize: 10,
                              color: kWhite,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  image ?? '',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: kBodyTitleSB.copyWith(color: kWhite),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: kSmallerTitleR.copyWith(
                  color: kWhite.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              if (isGeneralCampaign)
                Column(
                  children: [
                    if (hasGoal) ...[
                      LinearProgressIndicator(
                        color: const Color(0xFFFFD400),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                        value: percent,
                        backgroundColor: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        Text(
                          hasGoal
                              ? "₹${raised > goal! ? goal : raised}"
                              : "₹$raised",
                          style: kSmallTitleM.copyWith(
                              color: const Color(0xFFFFD400)),
                        ),
                        const SizedBox(width: 4),
                        if (hasGoal) ...[
                          Text(
                            "raisedOf".tr(),
                            style: kSmallTitleR.copyWith(color: kWhite),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "₹$goal",
                            style: kSmallTitleSB.copyWith(color: kWhite),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "goal".tr(),
                            style: kSmallTitleR.copyWith(color: kWhite),
                          ),
                          const Spacer(),
                          Text(
                            "${(percent * 100).toInt()}%",
                            style: kSmallTitleSB.copyWith(color: kWhite),
                          ),
                        ] else
                          Text(
                            "raised".tr(),
                            style: kSmallTitleR.copyWith(color: kWhite),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "₹$raised",
                          style: kSmallTitleM.copyWith(
                              color: const Color(0xFFFFD400)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "raised".tr(),
                          style: kSmallTitleR.copyWith(color: kWhite),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              Row(
                children: [
                  Expanded(
                    child: primaryButton(
                      label: "viewDetails".tr(),
                      onPressed: onViewDetails,
                      buttonColor: kWhite.withOpacity(0.2),
                      labelColor: kWhite,
                      sideColor: kWhite,
                      fontSize: 14,
                      buttonHeight: 40,
                    ),
                  ),
                  // const SizedBox(width: 12),
                  // Expanded(
                  //   child: primaryButton(
                  //     label: "Donate",
                  //     onPressed: onDonate,
                  //     buttonColor: kWhite,
                  //     labelColor: kPrimaryColor,
                  //     fontSize: 14,
                  //     buttonHeight: 40,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
