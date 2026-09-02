import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/dua_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/hadith_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/quran_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/qibla_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/subscription/subscription_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeQuickAccessRow extends StatelessWidget {
  const HomeQuickAccessRow({super.key});

  static const double _cardWidth = 100;
  static const double _cardHeight = 118;

  @override
  Widget build(BuildContext context) {
    final items = [
      _QuickAccessItem(
        svgPath: 'assets/svg/subscription.svg',
        label: 'homeSubscriptions'.tr(),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SubscriptionPage(),
            ),
          );
        },
      ),
      _QuickAccessItem(
        svgPath: 'assets/svg/quran.svg',
        label: 'quran'.tr(),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const QuranPage(),
            ),
          );
        },
      ),
      _QuickAccessItem(
        svgPath: 'assets/svg/Qibla.svg',
        label: 'homeQiblaFinder'.tr(),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const QiblaPage(),
            ),
          );
        },
      ),
      _QuickAccessItem(
        svgPath: 'assets/svg/hadith.svg',
        label: 'hadith'.tr(),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HadithPage(),
            ),
          );
        },
      ),
      _QuickAccessItem(
        svgPath: 'assets/svg/dua.svg',
        label: 'dua'.tr(),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DuaPage(),
            ),
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              _QuickAccessCard(
                width: _cardWidth,
                height: _cardHeight,
                svgPath: items[i].svgPath,
                label: items[i].label,
                onTap: items[i].onTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickAccessItem {
  final String svgPath;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.svgPath,
    required this.label,
    required this.onTap,
  });
}

class _QuickAccessCard extends StatelessWidget {
  final double width;
  final double height;
  final String svgPath;
  final String label;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.width,
    required this.height,
    required this.svgPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF0F3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        svgPath,
                        colorFilter: const ColorFilter.mode(
                          kPrimaryColor,
                          BlendMode.srcIn,
                        ),
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  label,
                  style: kSmallerTitleSB.copyWith(
                    fontSize: 12,
                    height: 1.25,
                    color: kTextColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
