import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';

class AccountSuspendedState extends StatelessWidget {
  const AccountSuspendedState({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/account_suspended.svg',
              ),
              const SizedBox(height: 40),
              Text(
                'Account Suspended',
                style: kHeadTitleSB,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your account has been suspended. Please contact support for more information.',
                style: kSmallTitleR.copyWith(
                  color: kSecondaryTextColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
