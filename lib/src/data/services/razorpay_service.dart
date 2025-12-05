import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  late Razorpay _razorpay;
  Function(PaymentSuccessResponse)? _onPaymentSuccess;
  Function(PaymentFailureResponse)? _onPaymentError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  RazorpayService() {
    _razorpay = Razorpay();
    _setupHandlers();
  }

  void _setupHandlers() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    log('Razorpay handlers setup complete', name: 'RazorpayService');
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    log('Payment Success callback triggered: ${response.paymentId}', name: 'RazorpayService');
    if (_onPaymentSuccess != null) {
      log('Calling onPaymentSuccess callback', name: 'RazorpayService');
      _onPaymentSuccess!(response);
    } else {
      log('WARNING: onPaymentSuccess callback is null', name: 'RazorpayService');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    log('Payment Error callback triggered: ${response.message}', name: 'RazorpayService');
    if (_onPaymentError != null) {
      log('Calling onPaymentError callback', name: 'RazorpayService');
      _onPaymentError!(response);
    } else {
      log('WARNING: onPaymentError callback is null', name: 'RazorpayService');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    log('External Wallet callback triggered: ${response.walletName}', name: 'RazorpayService');
    if (_onExternalWallet != null) {
      log('Calling onExternalWallet callback', name: 'RazorpayService');
      _onExternalWallet!(response);
    } else {
      log('WARNING: onExternalWallet callback is null', name: 'RazorpayService');
    }
  }

  void setCallbacks({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onError,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    log('Setting Razorpay callbacks', name: 'RazorpayService');
    _onPaymentSuccess = onSuccess;
    _onPaymentError = onError;
    _onExternalWallet = onExternalWallet;
  }

  void openCheckout({
    required String orderId,
    required double amount,
    required String email,
    required String phone,
    String? description,
  }) {
    final options = {
      'key': dotenv.env['RAZORPAY_KEY_ID'],
      'order_id': orderId,
      'amount': (amount * 100).toInt(),
      'name': 'Charity Trust',
      'description': description ?? 'Donation',
      'prefill': {
        'email': email,
        'contact': phone,
      },
      'theme': {
        'color': '#1e3a81',
      },
    };

    try {
      log('Opening Razorpay checkout with options: $options', name: 'RazorpayService');
      _razorpay.open(options);
    } catch (e) {
      log('Error opening Razorpay: $e', name: 'RazorpayService');
      rethrow;
    }
  }

  void dispose() {
    log('Disposing Razorpay service', name: 'RazorpayService');
    _razorpay.clear();
  }
}
