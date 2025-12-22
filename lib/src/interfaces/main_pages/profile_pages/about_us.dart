import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("aboutUs".tr(), style: kBodyTitleM),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromTop,
              duration: anim.AnimationDuration.normal,
              child: Image.asset(
                'assets/png/annujoom_logo.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "dignityMoments".tr(),
                    style: kSmallTitleM,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "aboutUsDescription".tr(),
                    style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeamGrid(
                    context: context,
                    members: [
                      _TeamMember(
                        name: "Shafeeda K M",
                        role: "chairperson".tr(),
                        image: "assets/png/member_1.png",
                      ),
                      _TeamMember(
                        name: "Thasneem Junaid",
                        role: "treasurer".tr(),
                        image: "assets/png/member_2.png",
                      ),
                      _TeamMember(
                        name: "Sameena Bai",
                        role: "secretary".tr(),
                        image: "assets/png/member_3.png",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "boardOfTrustees".tr(),
                        style: kSubHeadingM,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTeamGrid(
                    context: context,
                    members: [
                      _TeamMember(
                        name: "Farisha Sudheer",
                        role: "",
                        image: "assets/png/trustee_1.png",
                      ),
                      _TeamMember(
                        name: "Haseena",
                        role: "",
                        image: "assets/png/trustee_2.png",
                      ),
                      _TeamMember(
                        name: "Hishmiya Naif",
                        role: "",
                        image: "assets/png/trustee_3.png",
                      ),
                      _TeamMember(
                        name: "Naseema V S",
                        role: "",
                        image: "assets/png/trustee_4.png",
                      ),
                      _TeamMember(
                        name: "Niveditha V M",
                        role: "",
                        image: "assets/png/trustee_5.png",
                      ),
                      _TeamMember(
                        name: "Reena Rashid",
                        role: "",
                        image: "assets/png/trustee_6.png",
                      ),
                      _TeamMember(
                        name: "Rubeena Haris",
                        role: "",
                        image: "assets/png/trustee_7.png",
                      ),
                      _TeamMember(
                        name: "Sajitha Aboobacker",
                        role: "",
                        image: "assets/png/trustee_8.png",
                      ),
                      _TeamMember(
                        name: "Samina Shahim",
                        role: "",
                        image: "assets/png/trustee_9.png",
                      ),
                      _TeamMember(
                        name: "Seena Anas",
                        role: "",
                        image: "assets/png/trustee_10.png",
                      ),
                      _TeamMember(
                        name: "Shakkira Haneef",
                        role: "",
                        image: "assets/png/trustee_11.png",
                      ),
                      _TeamMember(
                        name: "Soodha",
                        role: "",
                        image: "assets/png/trustee_12.png",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamGrid({
    required BuildContext context,
    required List<_TeamMember> members,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double childAspectRatio = screenWidth < 360
        ? 0.7 // very small phones
        : screenWidth < 400
            ? 0.75
            : screenWidth < 480
                ? 0.8
                : 0.9; // tablets / large phones

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 20,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: members.length,
      itemBuilder: (context, index) {
        return _buildTeamCard(members[index]);
      },
    );
  }

  Widget _buildTeamCard(_TeamMember member) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: kStrokeColor.withOpacity(0.2),
              width: 2,
            ),
            color: kWhite,
          ),
          child: ClipOval(
            child: Image.asset(
              member.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: kGreyDark,
                  child: const Icon(
                    Icons.person,
                    color: kWhite,
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          member.name,
          style: kSmallTitleM,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (member.role.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            member.role,
            style: kSmallerTitleM.copyWith(color: kPrimaryColor),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _TeamMember {
  final String name;
  final String role;
  final String image;

  _TeamMember({
    required this.name,
    required this.role,
    required this.image,
  });
}
