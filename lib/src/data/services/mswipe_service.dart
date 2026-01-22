import 'dart:developer';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MswipeService {
  late WebViewController _controller;

  WebViewController initializeWebView({
    required String paymentUrl,
    required String donationId,
  }) {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.parse(request.url);
            
            // Check if it's a UPI or other app deep link
            if (uri.scheme == 'upi' || 
                uri.scheme == 'gpay' || 
                uri.scheme == 'phonepe' || 
                uri.scheme == 'paytm' ||
                uri.scheme == 'paytmmp' ||
                uri.scheme == 'tez' ||
                uri.scheme == 'cred' ||
                uri.scheme == 'credpay') {
              log('Launching external app: ${request.url}', name: 'MswipeService');
              _launchUrl(request.url);
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            log('Mswipe page started: $url', name: 'MswipeService');
          },
          onPageFinished: (String url) {
            log('Mswipe page finished: $url', name: 'MswipeService');
          },
          onWebResourceError: (WebResourceError error) {
            log('Mswipe WebView error: ${error.description}',
                name: 'MswipeService');
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));

    return _controller;
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        log('Cannot launch URL: $url', name: 'MswipeService');
      }
    } catch (e) {
      log('Error launching URL: $e', name: 'MswipeService');
    }
  }

  void dispose() {
    log('Mswipe service disposed', name: 'MswipeService');
  }
}
