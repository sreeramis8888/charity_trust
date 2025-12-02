import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/interfaces/main_pages/home.dart';
import 'package:charity_trust/src/interfaces/main_pages/campaign.dart';
import 'package:charity_trust/src/interfaces/main_pages/news_bookmark/news_list_page.dart';
import 'package:charity_trust/src/interfaces/main_pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  static const List<IconData> _inactiveIcons = [
    Icons.home_outlined,
    Icons.campaign_outlined,
    Icons.newspaper_outlined,
    Icons.person_outline,
  ];

  static const List<IconData> _activeIcons = [
    Icons.home,
    Icons.campaign,
    Icons.newspaper,
    Icons.person,
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
          border: Border(
            top: BorderSide(color: kBorder, width: 0.5),
          ),
          color: kWhite,
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
                                child: Icon(
                                  isSelected
                                      ? _activeIcons[index]
                                      : _inactiveIcons[index],
                                  color: isSelected ? kPrimaryColor : kSecondaryTextColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _labels[index],
                                style: TextStyle(
                                  color: isSelected ? kPrimaryColor : kSecondaryTextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: List.generate(4, (index) {
                        final bool isSelected = _selectedIndex == index;
                        return Expanded(
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isSelected ? 50 : 0,
                              height: 3.5,
                              decoration: BoxDecoration(
                                color: isSelected ? kPrimaryColor : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(45),
                                  topRight: Radius.circular(45),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
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
