import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:charity_trust/src/interfaces/main_pages/profile_pages/my_participations.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: kWhite,
        elevation: 0,
        title: Text("Profile", style: kSubHeadingM),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromTop,
              duration: anim.AnimationDuration.normal,
              child: Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: kGreyDark,
                      child: const Icon(Icons.person, color: kWhite, size: 40),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sreeram I S",
                          style: kHeadTitleR,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Phone number",
                          style:
                              kBodyTitleR.copyWith(color: kSecondaryTextColor),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('EditProfile');
                    },
                    icon: const Icon(Icons.edit_square, color: kTextColor),
                  )
                ],
              ),
              ),
            ),
            const SizedBox(height: 22),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromLeft,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 100,
              child: Text("Account Statistics", style: kBodyTitleM),
            ),
            const SizedBox(height: 10),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 150,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color(0xFFFFFFFF), Color(0xFFEEEDFF)],
                      begin: AlignmentGeometry.topCenter,
                      end: AlignmentGeometry.bottomCenter),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statItem("10", "My Participations"),
                      _statItem("₹12,500", "Contributions"),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(height: 2, color: kStrokeColor.withOpacity(0.06)),
                  const SizedBox(height: 18),
                  _statItem("₹10,000", "Zakat"),
                ],
              ),
              ),
            ),
            const SizedBox(height: 26),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 200,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFD8DADC)),
                  color:  kCardBackgroundColor,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MyParticipationsPage(),
                        ),
                      );
                    },
                    child: _tile(Icons.volunteer_activism, "My Participations"),
                  ),
                  _divider(),
                  _tile(Icons.headset_mic_rounded, "Help & Support"),
                  _divider(),
                  _tile(Icons.privacy_tip_outlined, "Privacy Policy"),
                  _divider(),
                  _tile(Icons.description_outlined, "Terms of Service"),
                  _divider(),
                  _tile(Icons.group_outlined, "About Us"),
                  _divider(),
                  _tile(Icons.calculate_outlined, "Zakat Calculator"),
                  _divider(),
                  _tile(Icons.logout, "Logout"),
                ],
              ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: kBodyTitleSB.copyWith(
            color: kThirdTextColor,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          label,
          style: kSmallTitleM,
        ),
      ],
    );
  }

  Widget _tile(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          _iconCircle(icon),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: kSmallerTitleL),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: kTextColor,
          ),
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: const Color(0xFF0601B4).withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 15,
        color: Colors.black54,
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Divider(
        color: Color(0xFFDADADA),
        thickness: 1,
        height: 0,
      ),
    );
  }
}
