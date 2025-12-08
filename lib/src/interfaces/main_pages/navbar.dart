import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/interfaces/main_pages/home.dart';
import 'package:Annujoom/src/interfaces/main_pages/campaign_pages/campaign.dart';
import 'package:Annujoom/src/interfaces/main_pages/news_bookmark/news_list_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    CampaignPage(),
    NewsListPage(),
    ProfilePage(),
  ];

  static const List<String> _labels = ['Home', 'Campaigns', 'News', 'Profile'];

  static const List<String> _inactiveIcons = [
    'assets/svg/inactive_home.svg',
    'assets/svg/inactive_campaign.svg',
    'assets/svg/inactive_news.svg',
    'assets/svg/inactive_profile.svg',
  ];

  static const List<String> _activeIcons = [
    'assets/svg/active_home.svg',
    'assets/svg/active_campaign.svg',
    'assets/svg/active_news.svg',
    'assets/svg/active_profile.svg',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: kWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 70,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(4, (index) {
                      final bool isSelected = _selectedIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onItemTapped(index),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: isSelected ? 1.2 : 1.0,
                                child: SvgPicture.asset(
                                  isSelected
                                      ? _activeIcons[index]
                                      : _inactiveIcons[index],
                                  colorFilter: ColorFilter.mode(
                                    isSelected
                                        ? kPrimaryColor
                                        : Color(0xFF99A1AF),
                                    BlendMode.srcIn,
                                  ),
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _labels[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? kPrimaryColor
                                      : Color(0xFF99A1AF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
