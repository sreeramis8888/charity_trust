import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewService {
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  static Widget buildWebView({
    required String url,
    required BuildContext context,
    bool showLoadingIndicator = true,
    bool enableJavaScript = true,
    bool enableZoom = true,
    bool enableNavigationControls = true,
    String? title,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return WebViewScreen(
      url: url,
      showLoadingIndicator: showLoadingIndicator,
      enableJavaScript: enableJavaScript,
      enableZoom: enableZoom,
      enableNavigationControls: enableNavigationControls,
      title: title,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String url;
  final bool showLoadingIndicator;
  final bool enableJavaScript;
  final bool enableZoom;
  final bool enableNavigationControls;
  final String? title;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const WebViewScreen({
    Key? key,
    required this.url,
    this.showLoadingIndicator = true,
    this.enableJavaScript = true,
    this.enableZoom = true,
    this.enableNavigationControls = true,
    this.title,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(
        widget.enableJavaScript
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.enableNavigationControls
          ? AppBar(
              title: Text(widget.title ?? 'Web View'),
              backgroundColor:
                  widget.backgroundColor ?? Theme.of(context).primaryColor,
              foregroundColor: widget.foregroundColor ?? kWhite,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    controller.reload();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () {
                    WebViewService.launchURL(widget.url);
                  },
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (widget.showLoadingIndicator && isLoading)
            const Center(
              child: LoadingAnimation(),
            ),
        ],
      ),
    );
  }
}
