import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/components/primaryButton.dart';
import 'package:charity_trust/src/interfaces/components/text_pill.dart';
import 'package:flutter/material.dart';

// ============================================================================
// HOME CAMPAIGN CARD - For Active Campaigns (with progress bar)
// ============================================================================
class HomeCampaignCard extends StatelessWidget {
  final String title;
  final String description;
  final String? image;
  final int raised;
  final int goal;
  final String dueDate;
  final VoidCallback onViewDetails;
  final VoidCallback? onDonate;

  const HomeCampaignCard({
    super.key,
    required this.title,
    required this.description,
    required this.raised,
    required this.goal,
    required this.dueDate,
    required this.onViewDetails,
    this.onDonate,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (raised / goal).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextPill(
                text: "DUE DATE",
                color: const Color(0xFF1E3C72),
                textStyle: kSmallerTitleSB.copyWith(
                  fontSize: 10,
                  color: kWhite,
                ),
              ),
              TextPill(
                text: dueDate,
                color: const Color(0xFF2B2B2B),
                textStyle: kSmallerTitleM.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              image ?? '',
              height: 120,
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
          Text(title, style: kBodyTitleSB),
          const SizedBox(height: 8),
          Text(
            description,
            style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            color: const Color(0xFFFFD400),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
            value: percent,
            backgroundColor: const Color(0xFFCFCFCF),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "₹$raised",
                style: kSmallTitleM.copyWith(color: const Color(0xFF009000)),
              ),
              const SizedBox(width: 4),
              Text(
                "raised of",
                style: kSmallTitleR,
              ),
              const SizedBox(width: 4),
              Text(
                "₹$goal",
                style: kSmallTitleSB,
              ),
              const SizedBox(width: 4),
              Text(
                "goal",
                style: kSmallTitleR,
              ),
              const Spacer(),
              Text(
                "${(percent * 100).toInt()}%",
                style: kSmallTitleSB,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: primaryButton(
                  label: "View details",
                  onPressed: onViewDetails,
                  buttonColor: kCardBackgroundColor,
                  labelColor: kTextColor,
                  sideColor: kTextColor,
                  fontSize: 14,
                  buttonHeight: 40,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: primaryButton(
                  label: "Donate",
                  onPressed: onDonate,
                  buttonColor: kPrimaryColor,
                  fontSize: 14,
                  buttonHeight: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HOME COMPLETED CAMPAIGN CARD - For Completed Campaigns (poster style)
// ============================================================================
class HomeCompletedCampaignCard extends StatelessWidget {
  final String heading;
  final String subtitle;
  final String goal;
  final String collected;
  final String? posterImage;
  final bool isImagePoster;
  final VoidCallback? onTap;

  const HomeCompletedCampaignCard({
    super.key,
    required this.heading,
    required this.subtitle,
    required this.goal,
    required this.collected,
    this.posterImage,
    this.isImagePoster = true,
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
          children: [
            // Background Image or Gradient
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
            // Dark overlay
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
                      style: kBodyTitleB.copyWith(
                        color: kWhite,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: kSmallerTitleR.copyWith(
                        color: kWhite.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Goal: $goal",
                              style: kSmallerTitleR.copyWith(
                                color: kWhite.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Collected: $collected",
                              style: kSmallTitleSB.copyWith(
                                color: kWhite,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: kWhite,
                            size: 20,
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

// ============================================================================
// HOME NEWS CARD - For News/Updates
// ============================================================================
class HomeNewsCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? image;
  final String authorName;
  final String? authorImage;
  final String timeAgo;
  final VoidCallback? onTap;

  const HomeNewsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.authorName,
    required this.timeAgo,
    this.image,
    this.authorImage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kCardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (image != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  image!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: Colors.grey[300],
                    child: Icon(Icons.broken_image, color: Colors.grey[600]),
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author info
                  Row(
                    children: [
                      if (authorImage != null)
                        ClipOval(
                          child: Image.network(
                            authorImage!,
                            height: 32,
                            width: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authorName,
                              style: kSmallTitleSB,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              timeAgo,
                              style: kSmallerTitleL.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    title,
                    style: kSmallTitleSB,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Subtitle
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
  final int goal;
  final String dueDate;
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
  });

  @override
  Widget build(BuildContext context) {
    final percent = (raised / goal).clamp(0.0, 1.0);

    return Container(
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
              Text(
                "DUE DATE",
                style: kSmallerTitleSB.copyWith(
                  fontSize: 10,
                  color: kWhite,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: kWhite, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      dueDate,
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
          LinearProgressIndicator(
            color: const Color(0xFFFFD400),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
            value: percent,
            backgroundColor: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "₹$raised",
                style: kSmallTitleM.copyWith(color: const Color(0xFFFFD400)),
              ),
              const SizedBox(width: 4),
              Text(
                "raised of",
                style: kSmallTitleR.copyWith(color: kWhite),
              ),
              const SizedBox(width: 4),
              Text(
                "₹$goal",
                style: kSmallTitleSB.copyWith(color: kWhite),
              ),
              const SizedBox(width: 4),
              Text(
                "goal",
                style: kSmallTitleR.copyWith(color: kWhite),
              ),
              const Spacer(),
              Text(
                "${(percent * 100).toInt()}%",
                style: kSmallTitleSB.copyWith(color: kWhite),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: primaryButton(
                  label: "View details",
                  onPressed: onViewDetails,
                  buttonColor: kWhite.withOpacity(0.2),
                  labelColor: kWhite,
                  sideColor: kWhite,
                  fontSize: 14,
                  buttonHeight: 40,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: primaryButton(
                  label: "Donate",
                  onPressed: onDonate,
                  buttonColor: kWhite,
                  labelColor: kPrimaryColor,
                  fontSize: 14,
                  buttonHeight: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
