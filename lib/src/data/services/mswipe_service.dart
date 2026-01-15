import 'dart:developer';
import 'package:webview_flutter/webview_flutter.dart';

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

  void dispose() {
    log('Mswipe service disposed', name: 'MswipeService');
  }
}
