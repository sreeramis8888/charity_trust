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

  Future<bool> _launchUpiUrl(Uri uri) async {
    try {
      log('Attempting to launch UPI URL: $uri');
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      log('Launch result for $uri: $success');
      return success;
    } catch (e) {
      log('Error launching UPI URL $uri: $e');
      return false;
    }
  }

  Future<void> _handleDeepLink(String url) async {
    Uri? targetUri;

    if (url.startsWith('intent://')) {
      try {
        final parts = url.split('#Intent;');
        if (parts.isNotEmpty) {
          final dataPart = parts[0]; // e.g. intent://pay?pa=...
          final intentPart = parts.length > 1 ? parts[1] : '';

          // Find scheme and package in the intent part
          String scheme = 'upi';
          final schemeMatch = RegExp(r'scheme=([^;]+)').firstMatch(intentPart);
          if (schemeMatch != null && schemeMatch.groupCount >= 1) {
            scheme = schemeMatch.group(1)!;
          }

          String? packageName;
          final packageMatch = RegExp(r'package=([^;]+)').firstMatch(intentPart);
          if (packageMatch != null && packageMatch.groupCount >= 1) {
            packageName = packageMatch.group(1);
          }

          // Try app-specific scheme first if package is recognized
          Uri? appSpecificUri;
          if (packageName != null) {
            if (packageName == 'com.phonepe.app') {
              appSpecificUri = Uri.parse(dataPart.replaceFirst('intent://', 'phonepe://'));
            } else if (packageName == 'net.one97.paytm') {
              appSpecificUri = Uri.parse(dataPart.replaceFirst('intent://', 'paytmmp://'));
            } else if (packageName == 'com.google.android.apps.nbu.paisa.user') {
              appSpecificUri = Uri.parse(dataPart.replaceFirst('intent://', 'tez://upi/'));
            } else if (packageName == 'com.dreamplug.androidapp') {
              appSpecificUri = Uri.parse(dataPart.replaceFirst('intent://', 'credpay://'));
            }
          }

          if (appSpecificUri != null) {
            final launched = await _launchUpiUrl(appSpecificUri);
            if (launched) return;
          }

          // Fallback to standard scheme (usually upi://)
          targetUri = Uri.parse(dataPart.replaceFirst('intent://', '$scheme://'));
        }
      } catch (e) {
        log('Error parsing intent URL: $e');
      }
    } else {
      targetUri = Uri.parse(url);
    }

    if (targetUri != null) {
      final launched = await _launchUpiUrl(targetUri);
      if (!launched) {
        // Fallback: try canLaunchUrl/launchUrl standard flow
        try {
          if (await canLaunchUrl(targetUri)) {
            await launchUrl(targetUri, mode: LaunchMode.externalApplication);
          }
        } catch (e) {
          log('Fallback launch failed: $e');
        }
      }
    }
  }

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

            final scheme = uri.scheme.toLowerCase();
            if (scheme == 'http' ||
                scheme == 'https' ||
                scheme == 'about' ||
                scheme == 'javascript' ||
                scheme == 'data') {
              return NavigationDecision.navigate;
            }

            // For all custom schemes and intent URLs (UPI deep links),
            // prevent webview navigation and launch the external app instead.
            _handleDeepLink(url);
            return NavigationDecision.prevent;
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
