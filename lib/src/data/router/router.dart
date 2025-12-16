import 'package:Annujoom/src/interfaces/main_pages/campaign_pages/campaign.dart';
import 'package:Annujoom/src/interfaces/main_pages/campaign_pages/campaign_detail.dart';
import 'package:Annujoom/src/interfaces/main_pages/home.dart';
import 'package:Annujoom/src/interfaces/main_pages/donation_categories.dart';
import 'package:Annujoom/src/interfaces/main_pages/news_bookmark/news_list_page.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/profile.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/edit_profile.dart';
import 'package:Annujoom/src/interfaces/main_pages/profile_pages/my_participations.dart';
import 'package:Annujoom/src/interfaces/main_pages/navbar.dart';
import 'package:Annujoom/src/interfaces/main_pages/referrals/my_referrals_page.dart';
import 'package:Annujoom/src/interfaces/onboarding/login.dart';
import 'package:Annujoom/src/interfaces/onboarding/registration.dart';
import 'package:Annujoom/src/interfaces/onboarding/create_user.dart';
import 'package:Annujoom/src/interfaces/onboarding/charity_member_otp_verification.dart';
import 'package:Annujoom/src/interfaces/onboarding/request_rejected_state.dart';
import 'package:Annujoom/src/interfaces/onboarding/request_sent_state.dart';
import 'package:Annujoom/src/interfaces/onboarding/account_suspended_state.dart';
import 'package:Annujoom/src/interfaces/onboarding/splash.dart';
import 'package:flutter/material.dart';

/// Usage:
/// Navigator.of(context).pushNamed(
///   'Navbar',
///   arguments: {'transition': TransitionType.slideFromRight},
/// );
///
/// Or use the helper directly:
/// Navigator.of(context).push(createRoute(Navbar(), transition: TransitionType.fadeScale));

enum TransitionType {
  slideFromBottom,
  slideFromRight,
  fade,
  fadeScale,
}

PageRouteBuilder<T> createRoute<T>(
  Widget page, {
  TransitionType? transition,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: _transitionsBuilderFor(transition),
  );
}

RouteTransitionsBuilder _transitionsBuilderFor(TransitionType? type) {
  switch (type) {
    case TransitionType.slideFromRight:
      return (context, animation, secondaryAnimation, child) {
        // Professional smooth right-to-left slide
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: curved.drive(tween), child: child);
      };

    case TransitionType.fade:
      return (context, animation, secondaryAnimation, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        return FadeTransition(opacity: curved, child: child);
      };

    case TransitionType.fadeScale:
      return (context, animation, secondaryAnimation, child) {
        // subtle scale + fade for a polished material-like entrance
        final fadeAnim =
            CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final scaleTween = Tween<double>(begin: 0.98, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut));
        return FadeTransition(
          opacity: fadeAnim,
          child:
              ScaleTransition(scale: animation.drive(scaleTween), child: child),
        );
      };

    case TransitionType.slideFromBottom:
    default:
      return (context, animation, secondaryAnimation, child) {
        // Standard bottom-up slide (good for modal-ish pages)
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final tween = Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: curved.drive(tween), child: child);
      };
  }
}

Route<dynamic> generateRoute(RouteSettings? settings) {
  Widget? page;
  TransitionType? transitionToUse;
  Duration transitionDuration = const Duration(milliseconds: 300);

  if (settings?.arguments != null && settings!.arguments is Map) {
    final args = settings.arguments as Map;
    if (args['transition'] is TransitionType) {
      transitionToUse = args['transition'] as TransitionType;
    }
    if (args['duration'] is Duration) {
      transitionDuration = args['duration'] as Duration;
    }
  }

  switch (settings?.name) {
    case 'Splash':
      page = SplashScreen();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;
    case 'Phone':
      page = PhoneNumberScreen();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;

    case 'Home':
      page = HomePage();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;

    case 'registration':
      page = RegistrationPage();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;
    case 'CreateUser':
      page = CreateUserPage();
      transitionToUse = TransitionType.slideFromBottom;
      transitionDuration = const Duration(milliseconds: 300);
      break;
    case 'charityMemberOtpVerification':
      if (settings?.arguments is Map) {
        final args = settings!.arguments as Map;
        page = CharityMemberOtpVerificationScreen(
          charityMemberId: args['charityMemberId'] ?? '',
          charityMemberName: args['charityMemberName'] ?? '',
        );
      }
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;
    case 'requestRejected':
      page = RequestRejectedState();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;

    case 'requestSent':
      page = RequestSentState();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;

    case 'accountSuspended':
      page = AccountSuspendedState();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;

    case 'Profile':
      page = ProfilePage();
      break;
    case 'EditProfile':
      page = EditProfilePage();
      break;
    case 'MyParticipations':
      page = MyParticipationsPage();
      break;
    case 'News':
      page = NewsListPage();
      break;
    case 'MyReferrals':
      page = MyReferralsPage();
      break;
    case 'Campaign':
      page = CampaignPage();
      break;
    case 'DonationCategories':
      page = DonationCategoriesPage();
      break;
    case 'CampaignDetail':
      if (settings?.arguments is Map) {
        final args = settings!.arguments as Map;
        page = CampaignDetailPage(
          id: args['_id'] ?? '',
          title: args['title'] ?? '',
          description: args['description'] ?? '',
          category: args['category'] ?? '',
          date: args['date'] ?? '',
          image: args['image'],
          raised: args['raised'] ?? 0,
          goal: args['goal'] ?? 0,
        );
      }
      break;

    case 'navbar':
      page = NavBar();
      transitionToUse = TransitionType.fade;
      transitionDuration = const Duration(milliseconds: 500);
      break;

    default:
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.grey[100],
          body: Center(child: Text('No path for ${settings?.name}')),
        ),
      );
  }
  if (transitionToUse == null) {
    return MaterialPageRoute(builder: (_) => page!);
  }
  return createRoute(page!,
      transition: transitionToUse, duration: transitionDuration);
}

extension NavigatorTransitionHelpers on NavigatorState {
  Future<T?> pushWithTransition<T>(Widget page,
      {TransitionType transition = TransitionType.slideFromBottom,
      Duration duration = const Duration(milliseconds: 300)}) {
    return push<T>(
        createRoute(page, transition: transition, duration: duration));
  }
}
