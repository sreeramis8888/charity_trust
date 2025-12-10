import 'dart:developer';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:Annujoom/src/data/providers/donation_provider.dart';
import 'package:Annujoom/src/data/providers/razorpay_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/interfaces/components/additional_pages/payment_success_page.dart';
import 'package:Annujoom/src/interfaces/components/additional_pages/payment_failed_page.dart';

class CampaignDetailPage extends ConsumerStatefulWidget {
  final String? id;
  final String? title;
  final String? description;
  final String? category;
  final String? date;
  final String? image;
  final int? raised;
  final int? goal;
  final bool isDirectCategory;

  const CampaignDetailPage({
    Key? key,
    this.id,
    this.title,
    this.description,
    this.category,
    this.date,
    this.image,
    this.raised,
    this.goal,
    this.isDirectCategory = false,
  }) : super(key: key);

  @override
  ConsumerState<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends ConsumerState<CampaignDetailPage> {
  final TextEditingController _donationController = TextEditingController();
  bool _isProcessing = false;
  late Future<void> _campaignLoadFuture;

  @override
  void initState() {
    super.initState();
    if (widget.isDirectCategory && widget.category != null) {
      _campaignLoadFuture = _loadCategoryCampaign();
    }
  }

  Future<void> _loadCategoryCampaign() async {
    // This will be handled by the build method with FutureBuilder
  }

  @override
  void dispose() {
    _donationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {SnackbarType type = SnackbarType.info}) {
    if (!mounted) return;
    SnackbarService().showSnackBar(message, type: type);
  }

  Future<void> _handleDonation() async {
    final amountText = _donationController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showSnackBar('Please enter a valid amount', type: SnackbarType.warning);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final razorpayService = ref.read(razorpayServiceProvider);
      final donationApi = ref.read(donationApiProvider);

      log("Creating donation for campaign: ${widget.id} with amount: $amount");

      // Step 1: Create donation and get order ID
      final response = await donationApi.createDonation(
        campaignId: widget.id ?? '',
        amount: amount,
      );

      if (!response.success || response.data == null) {
        log("Donation creation failed: ${response.message}");
        _showSnackBar('Failed to create donation', type: SnackbarType.error);
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        return;
      }

      final data = response.data!['data'] as Map<String, dynamic>?;
      final orderId = data?['payment_id'] as String?;
      final donationId = data?['_id'] as String?;

      log("Order ID received: $orderId, Donation ID: $donationId");

      if (orderId == null) {
        log("Order ID is null");
        _showSnackBar('Failed to get order ID', type: SnackbarType.error);
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        return;
      }

      // Step 2: Setup Razorpay callbacks BEFORE opening checkout
      log("Setting up Razorpay callbacks");
      razorpayService.setCallbacks(
        onSuccess: (PaymentSuccessResponse response) async {
          log("SUCCESS CALLBACK: Payment success - paymentId=${response.paymentId}, orderId=${response.orderId}");

          try {
            // Step 3: Verify payment on backend
            log("Verifying payment with backend");
            final verifyResponse = await donationApi.verifyPayment(
              razorpayOrderId: orderId,
              razorpayPaymentId: response.paymentId ?? '',
              razorpaySignature: response.signature ?? '',
              donationId: donationId ?? '',
            );

            log("Verification response: success=${verifyResponse.success}");

            if (verifyResponse.success) {
              log("Payment verified successfully - navigating to success page");
              log("Payment verification data ${verifyResponse.data}");

              // Extract receipt URL from verification response
              final receiptData = verifyResponse.data as Map<String, dynamic>?;
              final receipt = receiptData?['data']?['receipt'] as String?;

              _donationController.clear();

              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => PaymentSuccessPage(
                      orderId: orderId,
                      paymentId: response.paymentId,
                      amount: amount,
                      receipt: receipt,
                    ),
                  ),
                );
              }
            } else {
              log("Payment verification failed: ${verifyResponse.message}");
              _showSnackBar('Payment verification failed',
                  type: SnackbarType.error);
              if (mounted) {
                setState(() => _isProcessing = false);
              }
            }
          } catch (e) {
            log("Verification error: $e");
            _showSnackBar('Verification error: $e', type: SnackbarType.error);
            if (mounted) {
              setState(() => _isProcessing = false);
            }
          }
        },
        onError: (PaymentFailureResponse response) {
          log("ERROR CALLBACK: Payment error - code=${response.code}, message=${response.message}");

          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const PaymentFailurePage()),
            );
          }
        },
        onExternalWallet: (ExternalWalletResponse response) {
          log("EXTERNAL WALLET CALLBACK: ${response.walletName}");
          _showSnackBar(
            'External wallet selected: ${response.walletName}',
            type: SnackbarType.info,
          );
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        },
      );

      // Step 4: Open Razorpay checkout
      log("Opening Razorpay checkout with order: $orderId, amount: $amount");
      razorpayService.openCheckout(
        orderId: orderId,
        amount: amount,
        email: 'user@example.com',
        phone: '+919876543210',
        description: 'Donation to ${widget.title}',
      );
    } catch (e, stack) {
      log("Error in donation: $e\n$stack");
      _showSnackBar('Error: $e', type: SnackbarType.error);
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDirectCategory && widget.category != null) {
      return _buildCategoryDetailPage(context);
    }
    return _buildRegularDetailPage(context);
  }

  Widget _buildCategoryDetailPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
        ),
        title: Text('Campaign Details', style: kBodyTitleM),
      ),
      backgroundColor: kBackgroundColor,
      body: FutureBuilder<void>(
        future: _campaignLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingAnimation());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildDetailContent(context),
          );
        },
      ),
    );
  }

  Widget _buildRegularDetailPage(BuildContext context) {
    final progress =
        ((widget.raised ?? 0) / (widget.goal ?? 1)).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Campaign Details', style: kBodyTitleM),
      ),
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: _buildDetailContent(context),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context) {
    final progress =
        ((widget.raised ?? 0) / (widget.goal ?? 1)).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 16),
      anim.AnimatedWidgetWrapper(
        animationType: anim.AnimationType.fadeSlideInFromLeft,
        duration: anim.AnimationDuration.normal,
        child: Text(
          widget.title ?? 'Campaign',
          style: kHeadTitleSB,
        ),
      ),
      const SizedBox(height: 16),
      anim.AnimatedWidgetWrapper(
        animationType: anim.AnimationType.fadeScaleUp,
        duration: anim.AnimationDuration.normal,
        delayMilliseconds: 100,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              widget.image ?? 'https://placehold.co/400x225',
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      if (widget.category == 'General Campaign' &&
          widget.raised != null &&
          widget.goal != null)
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 150,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFCFCFCF),
            color: const Color(0xFFFFD400),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      if (widget.category == 'General Campaign' &&
          widget.raised != null &&
          widget.goal != null)
        const SizedBox(height: 12),
      if (widget.category == 'General Campaign' &&
          widget.raised != null &&
          widget.goal != null)
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${widget.raised} raised of ₹${widget.goal} goal',
                style: kBodyTitleM.copyWith(color: const Color(0xFF009000)),
              ),
              Text(
                '$percentage%',
                style: kSmallTitleR,
              ),
            ],
          ),
        ),
      if (widget.category == 'General Campaign' && widget.date != null)
        const SizedBox(height: 16),
      if (widget.category == 'General Campaign' && widget.date != null)
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromRight,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 250,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DUE DATE',
                style: kSmallerTitleB.copyWith(
                  color: kSecondaryTextColor,
                  fontSize: 10,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF001F4D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: kWhite, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      (widget.date ?? '').toUpperCase(),
                      style: kSmallerTitleB.copyWith(color: kWhite),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 20),
      if (widget.description != null)
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromLeft,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 300,
          child: Text(
            widget.description ?? '',
            style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
          ),
        ),
      const SizedBox(height: 20),
      anim.AnimatedWidgetWrapper(
        animationType: anim.AnimationType.fadeSlideInFromLeft,
        duration: anim.AnimationDuration.normal,
        delayMilliseconds: 350,
        child: Text(
          'Lorem ipsum dolor sit amet consectetur. Vestibulum arcu nec dolor gravida vel diam nulla. Diam nullam tincidunt interdum aliquet porta risus amet. Neque ipsum iaculis suspendisse lacus dictumst. Lectus mauris dapibus velit ultrices amet in at. Sit purus leo turpis ac malesuada in eu platea quam. Sagittis vestibulum placerat et vel vel. Diam id et nisl lectus elementum duis vel. U',
          style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
        ),
      ),
      const SizedBox(height: 28),
      anim.AnimatedWidgetWrapper(
        animationType: anim.AnimationType.fadeSlideInFromLeft,
        duration: anim.AnimationDuration.normal,
        delayMilliseconds: 400,
        child: Text('Enter Donation Amount', style: kSmallTitleB),
      ),
      const SizedBox(height: 12),
      anim.AnimatedWidgetWrapper(
        animationType: anim.AnimationType.fadeSlideInFromBottom,
        duration: anim.AnimationDuration.normal,
        delayMilliseconds: 450,
        child: InputField(
          type: CustomFieldType.number,
          hint: '₹ Enter amount',
          controller: _donationController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 24),
      anim.AnimatedWidgetWrapper(
        animationType: anim.AnimationType.fadeSlideInFromBottom,
        duration: anim.AnimationDuration.normal,
        delayMilliseconds: 500,
        child: Row(
          children: [
            // Expanded(
            //   child: primaryButton(
            //     label: "Share",
            //     onPressed: () {
            //       _showSnackBar("Share functionality coming soon", type: SnackbarType.info);
            //     },
            //     buttonColor: kWhite,
            //     labelColor: kTextColor,
            //     sideColor: kTertiary,
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              child: primaryButton(
                label: _isProcessing ? "Processing..." : "Donate Now",
                onPressed: _isProcessing ? null : _handleDonation,
                buttonColor: kPrimaryColor,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
    ]);
  }
}
