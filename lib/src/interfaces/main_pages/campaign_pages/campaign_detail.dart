import 'dart:developer';
import 'package:Annujoom/src/interfaces/components/additional_pages/mswipe_payment_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:Annujoom/src/data/providers/donation_provider.dart';
import 'package:Annujoom/src/data/providers/razorpay_provider.dart';
import 'package:Annujoom/src/data/providers/mswipe_provider.dart';
import 'package:Annujoom/src/data/providers/campaigns_provider.dart'
    show generalCampaignsProvider, participatedCampaignsProvider;
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/interfaces/components/additional_pages/payment_success_page.dart';
import 'package:Annujoom/src/interfaces/components/additional_pages/payment_failed_page.dart';
import 'package:Annujoom/src/interfaces/components/additional_pages/payment_method_page.dart';

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
  late FocusNode _donationFocusNode;
  bool _isProcessing = false;
  bool _isDemoAccount = false;
  late Future<void> _campaignLoadFuture;
  String _userPhone = '+919876543210';
  String _userEmail = 'user@example.com';
  String _selectedGateway = 'razorpay';

  @override
  void initState() {
    super.initState();
    _donationFocusNode = FocusNode();
    _checkDemoAccount();
    _loadUserData();
    if (widget.isDirectCategory && widget.category != null) {
      _campaignLoadFuture = _loadCategoryCampaign();
    }
  }

  Future<void> _loadUserData() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    try {
      final userData = await secureStorage.getUserData();
      if (userData != null && mounted) {
        setState(() {
          _userPhone = userData.phone ?? '';
          _userEmail = userData.email ?? '';
        });
      }
    } catch (e) {
      log("Error loading user data: $e");
    }
  }

  Future<void> _checkDemoAccount() async {
    final secureStorage = ref.read(secureStorageServiceProvider);
    final isDemoAccount = await secureStorage.isDemoAccount();
    if (mounted) {
      setState(() {
        _isDemoAccount = isDemoAccount;
      });
    }
  }

  Future<void> _loadCategoryCampaign() async {
    // This will be handled by the build method with FutureBuilder
  }

  @override
  void dispose() {
    _donationController.dispose();
    _donationFocusNode.dispose();
    // Don't use ref in dispose - it's unsafe when widget is unmounted
    super.dispose();
  }

  void _showSnackBar(String message, {SnackbarType type = SnackbarType.info}) {
    if (!mounted) return;
    SnackbarService().showSnackBar(message, type: type);
  }

  Future<void> _verifyFailedPayment(String? orderId, String? donationId) async {
    if (orderId == null || donationId == null) return;

    try {
      final donationApi = ref.read(donationApiProvider);
      log("Verifying failed payment with backend");
      await donationApi.verifyPayment(
        razorpayOrderId: orderId,
        razorpayPaymentId: '',
        razorpaySignature: '',
        donationId: donationId,
        status: 'failed',
      );
      log("Failed payment recorded successfully");
    } catch (e) {
      log("Error recording failed payment: $e");
    }
  }

  void _showExceedsGoalDialog(double donationAmount, double remainingGoal) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: kWhite,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with background
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: kPrimaryColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'exceedsGoal'.tr(),
                  style: kHeadTitleSB.copyWith(
                    color: kTextColor,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  'donationAmountExceeds'.tr(),
                  style: kBodyTitleR.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                // Amount comparison cards
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kBorder,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Remaining goal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'remainingGoal'.tr(),
                            style: kSmallerTitleR.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                          Text(
                            '₹${remainingGoal.toStringAsFixed(0)}',
                            style: kSmallTitleB.copyWith(
                              color: const Color(0xFF009000),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: kBorder,
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      // Your amount
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'yourAmount'.tr(),
                            style: kSmallerTitleR.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                          Text(
                            '₹${donationAmount.toStringAsFixed(0)}',
                            style: kSmallTitleB.copyWith(
                              color: kRed,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                // Action buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _donationController.text =
                              remainingGoal.toStringAsFixed(0);
                          _donationController.selection =
                              TextSelection.fromPosition(
                            TextPosition(
                              offset: _donationController.text.length,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                        ),
                        child: Text(
                          'adjustToMax'.tr(),
                          style: kSmallTitleB.copyWith(
                            color: kWhite,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(
                            color: kBorder,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                        ),
                        child: Text(
                          'cancel'.tr(),
                          style: kSmallTitleB.copyWith(
                            color: kTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDonation() async {
    final amountText = _donationController.text.trim();
    final amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showSnackBar('pleaseEnterValidAmount'.tr(), type: SnackbarType.warning);
      return;
    }

    final remaining = ((widget.goal ?? 0) - (widget.raised ?? 0)).toDouble();
    if (amount > remaining &&
        widget.category == 'General Campaign' &&
        (widget.goal ?? 0) > 0) {
      _showExceedsGoalDialog(amount, remaining);
      return;
    }

    // Show payment method page
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentMethodPage(
            campaignTitle: widget.title ?? '',
            amount: amount,
            onRazorpaySelected: () {
              Navigator.pop(context);
              setState(() => _selectedGateway = 'razorpay');
              _processPayment(amount);
            },
            onMswipeSelected: () {
              Navigator.pop(context);
              setState(() {
                _selectedGateway = 'mswipe';
                // _userEmail = email;
              });
              _processPayment(amount);
            },
          ),
        ),
      );
    }
  }

  Future<void> _processPayment(double amount) async {
    setState(() => _isProcessing = true);
    _donationFocusNode.unfocus();

    try {
      final donationApi = ref.read(donationApiProvider);

      log("Creating donation for campaign: ${widget.id} with amount: $amount, gateway: $_selectedGateway");

      // Step 1: Create donation with selected gateway
      final response = await donationApi.createDonation(
        campaignId: widget.id ?? '',
        amount: amount,
        gateway: _selectedGateway,
        // email: _userEmail,
        phone: _userPhone,
      );

      if (!response.success || response.data == null) {
        log("Donation creation failed: ${response.message}");
        _showSnackBar('failedToCreateDonation'.tr(), type: SnackbarType.error);
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
        _showSnackBar('failedToGetOrderId'.tr(), type: SnackbarType.error);
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        return;
      }

      if (_selectedGateway == 'mswipe') {
        if (data != null && donationId != null) {
          await _processMswipePayment(orderId, donationId, amount, data);
        } else {
          log("Missing data or donationId for Mswipe payment");
          _showSnackBar('failedToProcessPayment'.tr(),
              type: SnackbarType.error);
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      } else {
        if (donationId != null) {
          await _processRazorpayPayment(orderId, donationId, amount);
        } else {
          log("Missing donationId for Razorpay payment");
          _showSnackBar('failedToProcessPayment'.tr(),
              type: SnackbarType.error);
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      }
    } catch (e, stack) {
      log("Error in donation: $e\n$stack");
      _showSnackBar('Error: $e', type: SnackbarType.error);
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processMswipePayment(
    String orderId,
    String donationId,
    double amount,
    Map<String, dynamic> data,
  ) async {
    final paymentUrl = data['payment_url'] as String?;

    if (paymentUrl == null) {
      log("Payment URL is null for Mswipe");
      _showSnackBar('failedToGetPaymentUrl'.tr(), type: SnackbarType.error);
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      return;
    }

    log("Opening Mswipe payment page with URL: $paymentUrl");

    if (mounted) {
      _donationController.clear();
      _donationFocusNode.unfocus();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MswipePaymentPage(
            paymentUrl: paymentUrl,
            donationId: donationId,
            orderId: orderId,
            amount: amount,
          ),
        ),
      );
    }
  }

  Future<void> _processRazorpayPayment(
    String orderId,
    String donationId,
    double amount,
  ) async {
    final razorpayService = ref.read(razorpayServiceProvider);
    final donationApi = ref.read(donationApiProvider);

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
            donationId: donationId,
            status: 'success',
          );

          log("Verification response: success=${verifyResponse.success}");

          if (verifyResponse.success) {
            log("Payment verified successfully - navigating to success page");
            log("Payment verification data ${verifyResponse.data}");

            // Extract receipt URL from verification response
            final receiptData = verifyResponse.data as Map<String, dynamic>?;
            final receipt = receiptData?['data']?['receipt'] as String?;

            _donationController.clear();
            _donationFocusNode.unfocus();

            if (mounted) {
              // Invalidate campaign providers to refresh data
              ref.invalidate(generalCampaignsProvider);
              ref.invalidate(participatedCampaignsProvider);

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
            _showSnackBar('paymentVerificationFailed'.tr(),
                type: SnackbarType.error);
            if (mounted) {
              setState(() => _isProcessing = false);
            }
          }
        } catch (e) {
          log("Verification error: $e");
          _showSnackBar('${'verificationError'.tr()}: $e',
              type: SnackbarType.error);
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      },
      onError: (PaymentFailureResponse response) {
        log("ERROR CALLBACK: Payment error - code=${response.code}, message=${response.message}");
        _donationFocusNode.unfocus();

        // Call verify payment API with failed status
        _verifyFailedPayment(orderId, donationId);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const PaymentFailurePage()),
          );
        }
      },
      onExternalWallet: (ExternalWalletResponse response) {
        log("EXTERNAL WALLET CALLBACK: ${response.walletName}");
        _showSnackBar(
          '${'externalWalletSelected'.tr()}: ${response.walletName}',
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
      email: _userEmail,
      phone: _userPhone,
      description: 'Donation to ${widget.title}',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isDemoAccount) {
      return _buildDemoAccountPage(context);
    }
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
        title: Text('campaignDetails'.tr(), style: kBodyTitleM),
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
        title: Text('campaignDetails'.tr(), style: kBodyTitleM),
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
          widget.title ?? 'campaignDetails'.tr(),
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
                '₹${widget.raised} ${'raisedOf'.tr()} ₹${widget.goal} ${'goal'.tr()}',
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
                'dueDate'.tr(),
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
      const SizedBox(height: 28),
      anim.AnimatedWidgetWrapper(
        animationType: anim.AnimationType.fadeSlideInFromLeft,
        duration: anim.AnimationDuration.normal,
        delayMilliseconds: 400,
        child: Text('enterDonationAmount'.tr(), style: kSmallTitleB),
      ),
      const SizedBox(height: 12),
      anim.AnimatedWidgetWrapper(
        animationType: anim.AnimationType.fadeSlideInFromBottom,
        duration: anim.AnimationDuration.normal,
        delayMilliseconds: 450,
        child: InputField(
          type: CustomFieldType.number,
          hint: 'enterAmount'.tr(),
          controller: _donationController,
          focusNode: _donationFocusNode,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'pleaseEnterAmount'.tr();
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'pleaseEnterValidAmount'.tr();
            }
            return null;
          },
        ),
      ),
      const SizedBox(height: 20),
      // anim.AnimatedWidgetWrapper(
      //   animationType: anim.AnimationType.fadeSlideInFromBottom,
      //   duration: anim.AnimationDuration.normal,
      //   delayMilliseconds: 475,
      // child: Column(
      //   crossAxisAlignment: CrossAxisAlignment.start,
      //   children: [
      // Text(
      //   'recommended'.tr(),
      //   style: kSmallerTitleL.copyWith(
      //       color: kSecondaryTextColor, fontSize: 16),
      // ),
      // const SizedBox(height: 12),
      // ValueListenableBuilder<TextEditingValue>(
      //   valueListenable: _donationController,
      //   builder: (context, value, child) {
      //     final amounts = [1000, 2500, 5000];
      //     return Row(
      //       mainAxisAlignment: MainAxisAlignment.start,
      //       children: amounts.asMap().entries.map((entry) {
      //         final idx = entry.key;
      //         final amount = entry.value;
      //         final isSelected = value.text == amount.toString();

      //         return Padding(
      //           padding: EdgeInsets.only(
      //             right: idx == amounts.length - 1 ? 0 : 10,
      //           ),
      //           child: InkWell(
      //             onTap: () {
      //               _donationController.text = amount.toString();
      //               _donationController.selection =
      //                   TextSelection.fromPosition(
      //                 TextPosition(
      //                     offset: _donationController.text.length),
      //               );
      //             },
      //             borderRadius: BorderRadius.circular(10),
      //             child: Container(
      //               padding: const EdgeInsets.symmetric(
      //                 horizontal: 14,
      //                 vertical: 8,
      //               ),
      //               decoration: BoxDecoration(
      //                 color: isSelected
      //                     ? kPrimaryColor.withOpacity(0.05)
      //                     : Colors.transparent,
      //                 borderRadius: BorderRadius.circular(10),
      //                 border: Border.all(color: kPrimaryColor),
      //               ),
      //               child: Text(
      //                 '₹ ${NumberFormat.decimalPattern('en_IN').format(amount)}',
      //                 style: kSmallTitleL.copyWith(
      //                   color: kPrimaryColor,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         );
      //       }).toList(),
      //     );
      //   },
      // ),
      //   ],
      // ),
      // ),
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
                label: _isProcessing ? "processing".tr() : "donateNow".tr(),
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

  Widget _buildDemoAccountPage(BuildContext context) {
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
        title: Text('campaignDetails'.tr(), style: kBodyTitleM),
      ),
      backgroundColor: kBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: kPrimaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'donationsViaApp'.tr(),
                style: kHeadTitleR,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'donationWebsiteMessage'.tr(),
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              primaryButton(
                label: 'donateOnWebsite'.tr(),
                onPressed: () async {
                  const url = 'https://annujoomcharitabletrust.com/';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                buttonHeight: 48,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
