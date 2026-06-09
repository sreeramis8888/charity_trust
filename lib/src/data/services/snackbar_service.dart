import 'dart:developer';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum SnackbarType { success, error, warning, info }

class SnackbarService {
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void showSnackBar(
    String message, {
    IconData icon = Icons.check_circle,
    Color? backgroundColor,
    SnackbarType type = SnackbarType.success,
  }) {
    final Map<SnackbarType, Color> typeColors = {
      SnackbarType.success: Color(0xFF00C851),
      SnackbarType.error: Color(0xFFFF4D4F),
      SnackbarType.warning: Color(0xFFFF8800),
      SnackbarType.info: kPrimaryColor,
    };

    final Color bgColor = backgroundColor ?? typeColors[type]!;
    final Color iconColor = kWhite;

    final snackBar = SnackBar(
      content: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor, bgColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 12,
                offset: Offset(0, 4)),
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // _iconBox( icon, iconColor),
            // SizedBox(width: 16),
            Expanded(child: _messageText(message)),
            _okButton(),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.all(16),
      duration: Duration(seconds: 4),
    );

    void presentSnackBar() {
      final messenger = scaffoldMessengerKey.currentState;
      if (messenger != null && messenger.mounted) {
        messenger.showSnackBar(snackBar);
        return;
      }

      final navContext = NavigationService.navigatorKey.currentContext;
      if (navContext != null && navContext.mounted) {
        ScaffoldMessenger.of(navContext).showSnackBar(snackBar);
        return;
      }

      log('Snackbar skipped: no active ScaffoldMessenger', name: 'SnackbarService');
    }

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      presentSnackBar();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => presentSnackBar());
    }
  }

  // Widget _iconBox(IconData icon, Color color) => Container(
  //       padding: EdgeInsets.all(8),
  //       decoration: BoxDecoration(
  //         color: kWhite.withOpacity(0.2),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Icon( icon, color: color, size: 24),
  //     );

  Widget _messageText(String message) => Text(
        message,
        style: TextStyle(
          color: kWhite,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      );

  Widget _okButton() => GestureDetector(
        onTap: () {
          scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kWhite.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'OK',
            style: TextStyle(
              color: kWhite,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
