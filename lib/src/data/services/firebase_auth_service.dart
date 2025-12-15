import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'crashlytics_service.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Send OTP to phone number and return verification ID and resend token
  Future<Map<String, String>> sendOtp(String phoneNumber) async {
    final verificationIdCompleter = Completer<String>();
    final resendTokenCompleter = Completer<String>();

    try {
      log('Sending OTP to: $phoneNumber', name: 'FirebaseAuthService');

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          log('Phone number automatically verified', name: 'FirebaseAuthService');
        },
        verificationFailed: (FirebaseAuthException e) {
          log('🔥 FirebaseAuthException');
          log('CODE  : ${e.code}');
          log('MSG   : ${e.message}');
          log('STACK : ${e.stackTrace}');
          
          CrashlyticsService.logError(e, e.stackTrace);
          CrashlyticsService.setCustomKey('phone_number', phoneNumber);
          CrashlyticsService.setCustomKey('error_code', e.code);

          verificationIdCompleter.complete('');
          resendTokenCompleter.complete('');
        },
        codeSent: (String verificationId, int? resendToken) {
          log('OTP sent successfully. Verification ID: $verificationId',
              name: 'FirebaseAuthService');
          verificationIdCompleter.complete(verificationId);
          resendTokenCompleter.complete(resendToken?.toString() ?? '');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!verificationIdCompleter.isCompleted) {
            verificationIdCompleter.complete('');
          }
        },
      );

      return {
        'verificationId': await verificationIdCompleter.future,
        'resendToken': await resendTokenCompleter.future,
      };
    } catch (e, stackTrace) {
      log('Error sending OTP: $e', name: 'FirebaseAuthService');
      CrashlyticsService.logError(e, stackTrace);
      rethrow;
    }
  }

  /// Resend OTP
  Future<Map<String, String>> resendOtp(
    String phoneNumber,
    String resendToken,
  ) async {
    final verificationIdCompleter = Completer<String>();
    final newResendTokenCompleter = Completer<String>();

    try {
      log('Resending OTP to: $phoneNumber', name: 'FirebaseAuthService');

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: int.tryParse(resendToken),
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {
          log('Phone number automatically verified', name: 'FirebaseAuthService');
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Resend verification failed: ${e.message}',
              name: 'FirebaseAuthService');
          CrashlyticsService.logError(e, e.stackTrace);
          CrashlyticsService.setCustomKey('resend_attempt', true);
          verificationIdCompleter.complete('');
          newResendTokenCompleter.complete('');
        },
        codeSent: (String verificationId, int? resendToken) {
          log('OTP resent successfully', name: 'FirebaseAuthService');
          verificationIdCompleter.complete(verificationId);
          newResendTokenCompleter.complete(resendToken?.toString() ?? '');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!verificationIdCompleter.isCompleted) {
            verificationIdCompleter.complete('');
          }
        },
      );

      return {
        'verificationId': await verificationIdCompleter.future,
        'resendToken': await newResendTokenCompleter.future,
      };
    } catch (e, stackTrace) {
      log('Error resending OTP: $e', name: 'FirebaseAuthService');
      CrashlyticsService.logError(e, stackTrace);
      rethrow;
    }
  }

  /// Verify OTP and get ID token
  Future<String> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('User signed in, but no user information was found.');
      }

      final idToken = await user.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Failed to get ID token');
      }

      log('OTP verified successfully. ID Token obtained',
          name: 'FirebaseAuthService');
      return idToken;
    } on FirebaseAuthException catch (e, stackTrace) {
      log('OTP verification failed: ${e.message}', name: 'FirebaseAuthService');
      CrashlyticsService.logError(e, stackTrace);
      throw Exception('Invalid OTP: ${e.message}');
    } catch (e, stackTrace) {
      log('Error verifying OTP: $e', name: 'FirebaseAuthService');
      CrashlyticsService.logError(e, stackTrace);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      log('Signed out successfully', name: 'FirebaseAuthService');
    } catch (e, stackTrace) {
      log('Error signing out: $e', name: 'FirebaseAuthService');
      CrashlyticsService.logError(e, stackTrace);
      rethrow;
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }
}
