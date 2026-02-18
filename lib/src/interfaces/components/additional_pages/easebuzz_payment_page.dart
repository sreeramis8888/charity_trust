import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/providers/easebuzz_provider.dart';

class EasebuzzPaymentPage extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String donationId;
  final String orderId;
  final double amount;
  final Map<String, dynamic>? paymentData; // [NEW] Accept full payment data

  const EasebuzzPaymentPage({
    Key? key,
    required this.paymentUrl,
    required this.donationId,
    required this.orderId,
    required this.amount,
    this.paymentData, // [NEW]
  }) : super(key: key);

  @override
  ConsumerState<EasebuzzPaymentPage> createState() =>
      _EasebuzzPaymentPageState();
}

class _EasebuzzPaymentPageState extends ConsumerState<EasebuzzPaymentPage> {
  @override
  Widget build(BuildContext context) {
    final easebuzzService = ref.watch(easebuzzServiceProvider);
    final webViewController = easebuzzService.initializeWebView(
      paymentUrl: widget.paymentUrl,
      donationId: widget.donationId,
      paymentData: widget.paymentData,
    );

    easebuzzService.setOnPaymentComplete(() {
      if (mounted) {
        Navigator.pop(context);
        // Optional: Navigate to transaction success page if desired
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Payment', style: kBodyTitleM),
      ),
      body: WebViewWidget(controller: webViewController),
    );
  }

  @override
  void dispose() {
    // Avoid using ref.read in dispose as it might be unmounted
    super.dispose();
  }
}
