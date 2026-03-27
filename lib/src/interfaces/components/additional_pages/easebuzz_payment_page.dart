import 'dart:developer';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';

import 'package:url_launcher/url_launcher.dart';

class EasebuzzPaymentPage extends StatefulWidget {
  final String paymentUrl;

  const EasebuzzPaymentPage({
    Key? key,
    required this.paymentUrl,
  }) : super(key: key);

  @override
  State<EasebuzzPaymentPage> createState() => _EasebuzzPaymentPageState();
}

class _EasebuzzPaymentPageState extends State<EasebuzzPaymentPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            log('Easebuzz WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) async {
            final url = request.url;
            final uri = Uri.parse(url);
            log('Easebuzz WebView: navigating to $url, scheme: ${uri.scheme}');

            // Handle common UPI and payment schemes
            if (uri.scheme == 'upi' ||
                uri.scheme == 'phonepe' ||
                uri.scheme == 'paytm' ||
                uri.scheme == 'paytmmp' ||
                uri.scheme == 'tez' ||
                uri.scheme == 'gpay' ||
                uri.scheme == 'intent' ||
                uri.scheme == 'cred' ||
                uri.scheme == 'credpay') {
              try {
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                  return NavigationDecision.prevent;
                }
              } catch (e) {
                log('Error launching UPI app: $e');
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));

    log('EasebuzzPaymentPage: loading URL: ${widget.paymentUrl}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment', style: kBodyTitleM),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
