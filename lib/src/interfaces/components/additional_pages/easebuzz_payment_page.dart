import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/providers/easebuzz_provider.dart';

import 'package:Annujoom/src/interfaces/components/additional_pages/payment_success_page.dart'; // [NEW]

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

    easebuzzService.setOnPaymentComplete((result) {
      if (!mounted) return;

      if (result != null) {
        // Success: Navigate to Success Page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessPage(
              amount: double.tryParse(result['amount']?.toString() ?? '0') ??
                  widget.amount,
              paymentId: result['payment_id'] ??
                  result['gateway_payment_id'] ??
                  widget.orderId,
              orderId: widget.donationId,
              receipt: result['receipt'],
            ),
          ),
        );
      } else {
        // Failure/Cancel: Just pop
        Navigator.pop(context);
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
