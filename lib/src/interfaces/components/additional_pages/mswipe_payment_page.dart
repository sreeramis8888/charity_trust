import 'dart:developer';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/providers/mswipe_provider.dart';
import 'package:Annujoom/src/data/providers/donation_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/additional_pages/payment_success_page.dart';
import 'package:Annujoom/src/interfaces/components/additional_pages/payment_failed_page.dart';

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
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _setupMswipeCallbacks();
  }

  void _setupMswipeCallbacks() {
    final mswipeService = ref.read(mswipeServiceProvider);

    mswipeService.setCallbacks(
      onSuccess: (String paymentId, String rrn) async {
        log('Mswipe payment success - paymentId: $paymentId, rrn: $rrn',
            name: 'MswipePaymentPage');

        if (!mounted) return;
        setState(() => _isVerifying = true);

        try {
          final donationApi = ref.read(donationApiProvider);

          log('Verifying Mswipe payment with backend',
              name: 'MswipePaymentPage');

          final verifyResponse = await donationApi.verifyPayment(
            razorpayOrderId: widget.orderId,
            razorpayPaymentId: paymentId,
            razorpaySignature: rrn,
            donationId: widget.donationId,
            status: 'success',
          );

          log('Mswipe verification response: success=${verifyResponse.success}',
              name: 'MswipePaymentPage');

          if (verifyResponse.success) {
            log('Mswipe payment verified successfully',
                name: 'MswipePaymentPage');

            final receiptData = verifyResponse.data as Map<String, dynamic>?;
            final receipt = receiptData?['data']?['receipt'] as String?;

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PaymentSuccessPage(
                    orderId: widget.orderId,
                    paymentId: paymentId,
                    amount: widget.amount,
                    receipt: receipt,
                  ),
                ),
              );
            }
          } else {
            log('Mswipe payment verification failed: ${verifyResponse.message}',
                name: 'MswipePaymentPage');

            if (mounted) {
              SnackbarService().showSnackBar(
                'Payment verification failed',
                type: SnackbarType.error,
              );
              setState(() => _isVerifying = false);
            }
          }
        } catch (e) {
          log('Mswipe verification error: $e', name: 'MswipePaymentPage');

          if (mounted) {
            SnackbarService().showSnackBar(
              'Verification error: $e',
              type: SnackbarType.error,
            );
            setState(() => _isVerifying = false);
          }
        }
      },
      onError: (String? error) {
        log('Mswipe payment error: $error', name: 'MswipePaymentPage');

        if (mounted) {
          SnackbarService().showSnackBar(
            error ?? 'Payment failed',
            type: SnackbarType.error,
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PaymentFailurePage()),
          );
        }
      },
      onCancelled: () {
        log('Mswipe payment cancelled', name: 'MswipePaymentPage');

        if (mounted) {
          SnackbarService().showSnackBar(
            'Payment cancelled',
            type: SnackbarType.warning,
          );
          Navigator.of(context).pop();
        }
      },
    );
  }

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
        leading: _isVerifying
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: kTextColor),
                onPressed: () => Navigator.pop(context),
              ),
        title: Text(
          'Payment',
          style: kBodyTitleM,
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: webViewController),
          if (_isVerifying)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: LoadingAnimation(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    final mswipeService = ref.read(mswipeServiceProvider);
    mswipeService.dispose();
    super.dispose();
  }
}
