import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MswipeService {
  late WebViewController _controller;
  Function(String paymentId, String rrn)? _onPaymentSuccess;
  Function(String? error)? _onPaymentError;
  VoidCallback? _onPaymentCancelled;

  void setCallbacks({
    required Function(String paymentId, String rrn) onSuccess,
    required Function(String? error) onError,
    required VoidCallback onCancelled,
  }) {
    log('Setting Mswipe callbacks', name: 'MswipeService');
    _onPaymentSuccess = onSuccess;
    _onPaymentError = onError;
    _onPaymentCancelled = onCancelled;
  }

  WebViewController initializeWebView({
    required String paymentUrl,
    required String donationId,
  }) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            log('Mswipe page started: $url', name: 'MswipeService');
          },
          onPageFinished: (String url) {
            log('Mswipe page finished: $url', name: 'MswipeService');
          },
          onWebResourceError: (WebResourceError error) {
            log('Mswipe WebView error: ${error.description}',
                name: 'MswipeService');
            _onPaymentError?.call(error.description);
          },
          onNavigationRequest: (NavigationRequest request) {
            log('Mswipe navigation request: ${request.url}',
                name: 'MswipeService');

            // Check for success callback URL pattern
            if (request.url.contains('success') ||
                request.url.contains('callback')) {
              log('Payment success detected from URL: ${request.url}',
                  name: 'MswipeService');
              // Extract payment details from URL if available
              _handlePaymentSuccess(request.url);
              return NavigationDecision.prevent;
            }

            // Check for failure/cancel callback URL pattern
            if (request.url.contains('failed') ||
                request.url.contains('cancel')) {
              log('Payment failed/cancelled detected from URL: ${request.url}',
                  name: 'MswipeService');
              _onPaymentCancelled?.call();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));

    return _controller;
  }

  void _handlePaymentSuccess(String url) {
    try {
      // Extract payment ID and RRN from URL parameters if available
      final uri = Uri.parse(url);
      final paymentId = uri.queryParameters['payment_id'] ?? '';
      final rrn = uri.queryParameters['rrn'] ?? '';

      log('Extracted from URL - paymentId: $paymentId, rrn: $rrn',
          name: 'MswipeService');

      if (_onPaymentSuccess != null) {
        _onPaymentSuccess!(paymentId, rrn);
      }
    } catch (e) {
      log('Error handling payment success: $e', name: 'MswipeService');
      _onPaymentError?.call('Error processing payment response');
    }
  }

  void dispose() {
    log('Mswipe service disposed', name: 'MswipeService');
    _onPaymentSuccess = null;
    _onPaymentError = null;
    _onPaymentCancelled = null;
  }
}
