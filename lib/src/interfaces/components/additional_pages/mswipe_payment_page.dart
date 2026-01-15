import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/providers/mswipe_provider.dart';

class MswipePaymentPage extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String donationId;
  final String orderId;
  final double amount;

  const MswipePaymentPage({
    Key? key,
    required this.paymentUrl,
    required this.donationId,
    required this.orderId,
    required this.amount,
  }) : super(key: key);

  @override
  ConsumerState<MswipePaymentPage> createState() => _MswipePaymentPageState();
}

class _MswipePaymentPageState extends ConsumerState<MswipePaymentPage> {
  @override
  Widget build(BuildContext context) {
    final mswipeService = ref.watch(mswipeServiceProvider);
    final webViewController = mswipeService.initializeWebView(
      paymentUrl: widget.paymentUrl,
      donationId: widget.donationId,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: kBodyTitleM,
        ),
      ),
      body: WebViewWidget(controller: webViewController),
    );
  }

  @override
  void dispose() {
    final mswipeService = ref.read(mswipeServiceProvider);
    mswipeService.dispose();
    super.dispose();
  }
}
