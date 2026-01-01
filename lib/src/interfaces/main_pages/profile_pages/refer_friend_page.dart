import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReferFriendPage extends StatefulWidget {
  const ReferFriendPage({super.key});

  @override
  State<ReferFriendPage> createState() => _ReferFriendPageState();
}

class _ReferFriendPageState extends State<ReferFriendPage> {
  static const String _androidLink = 'https://play.google.com/store/apps/details?id=com.annujoomconnect';
  static const String _iosLink = 'https://apps.apple.com/in/app/annujoom-connect/id6756281138';
  
  late String referralLink;
  bool _isLinkCopied = false;

  @override
  void initState() {
    super.initState();
    referralLink = 'Android: $_androidLink\n\nIOS: $_iosLink';
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: referralLink));
    setState(() {
      _isLinkCopied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('linkCopied'.tr()),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF0601B4),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLinkCopied = false;
        });
      }
    });
  }

  Future<void> _shareReferral() async {
    final message =
        '${'joinAnnujoom'.tr()}\n\n${'referralMessage'.tr()}\n\n$referralLink';
    try {
      await Share.share(
        message,
        subject: 'referAFriend'.tr(),
      );
    } catch (e) {
      _showErrorSnackBar('Error sharing: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: kWhite,
        elevation: 0,
        title: Text("referAFriend".tr(), style: kSubHeadingM),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: kTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Hero Section with Gradient
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromTop,
              duration: anim.AnimationDuration.normal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: kPrimaryColor.withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kPrimaryColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.people_outline,
                        color: kPrimaryColor,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'referralTitle'.tr(),
                      textAlign: TextAlign.center,
                      style: kHeadTitleSB.copyWith(
                        color: kTextColor,
                        fontSize: 24,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'referralDescription'.tr(),
                      textAlign: TextAlign.center,
                      style: kBodyTitleR.copyWith(
                        color: kSecondaryTextColor,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),



            /// Why Share Section
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromRight,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Share Annujoom?',
                    style: kBodyTitleM,
                  ),
                  const SizedBox(height: 20),
                  _FeatureCard(
                    icon: Icons.favorite_outline,
                    title: 'Make a Difference',
                    description: 'Help your friends join a community dedicated to charity and trust',
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    icon: Icons.group_outlined,
                    title: 'Build Community',
                    description: 'Connect with like-minded people who care about giving back',
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    icon: Icons.lightbulb_outline,
                    title: 'Spread Awareness',
                    description: 'Share meaningful campaigns and causes with your network',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            /// Share Button
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 200,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _shareReferral,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: kPrimaryColor.withOpacity(0.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.share_outlined,
                            color: kWhite,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Share Your Link',
                            style: kSmallerTitleL.copyWith(
                              color: kWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _copyToClipboard,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: kPrimaryColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isLinkCopied ? Icons.check : Icons.copy,
                            color: kPrimaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isLinkCopied ? 'Copied!' : 'Copy Link',
                            style: kSmallerTitleL.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Info Box
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeScaleUp,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 250,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: kBorder.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: kPrimaryColor.withOpacity(0.6),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No limits on referrals. Share with as many friends as you want!',
                        style: kSmallTitleM.copyWith(
                          color: kSecondaryTextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: kBorder.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: kPrimaryColor.withOpacity(0.7),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: kSmallTitleM.copyWith(
                    color: kTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: kSmallerTitleR.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOptionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: kSmallerTitleL.copyWith(
                  color: kTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: kSecondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0601B4).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0601B4),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: kSmallTitleM.copyWith(
                  color: kTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: kSmallTitleM.copyWith(
                  color: kSecondaryTextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final int step;
  final String title;
  final String description;

  const _StepItem({
    required this.step,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: kPrimaryColor.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '$step',
              style: kBodyTitleM.copyWith(
                color: kPrimaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  title,
                  style: kSmallTitleM.copyWith(
                    color: kTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: kSmallTitleM.copyWith(
                  color: kSecondaryTextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
