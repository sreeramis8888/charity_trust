import 'dart:async';
import 'dart:developer';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/providers/loading_provider.dart';
import 'package:charity_trust/src/data/services/snackbar_service.dart';
import 'package:charity_trust/src/data/providers/user_provider.dart';
import 'package:charity_trust/src/interfaces/components/primaryButton.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CharityMemberOtpVerificationScreen extends ConsumerStatefulWidget {
  final String charityMemberId;
  final String charityMemberName;

  const CharityMemberOtpVerificationScreen({
    required this.charityMemberId,
    required this.charityMemberName,
    super.key,
  });

  @override
  ConsumerState<CharityMemberOtpVerificationScreen> createState() =>
      _CharityMemberOtpVerificationScreenState();
}

class _CharityMemberOtpVerificationScreenState
    extends ConsumerState<CharityMemberOtpVerificationScreen> {
  Timer? _timer;
  int _start = 59;
  bool _isButtonDisabled = true;
  late TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    _isButtonDisabled = true;
    _start = 59;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isButtonDisabled = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void resendCode() {
    startTimer();
    // TODO: Implement resend OTP logic if needed
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70),
              anim.AnimatedWidgetWrapper(
                animationType: anim.AnimationType.fadeSlideInFromLeft,
                duration: anim.AnimationDuration.normal,
                child: Text(
                  'Verify Recommendation',
                  style: kHeadTitleM.copyWith(fontSize: 25),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        anim.AnimatedWidgetWrapper(
                          animationType: anim.AnimationType.fadeSlideInFromLeft,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 100,
                          child: Text(
                            'Enter the 6-digit code sent to ${widget.charityMemberName}',
                            style: kSmallTitleR.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        anim.AnimatedWidgetWrapper(
                          animationType:
                              anim.AnimationType.fadeSlideInFromBottom,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 200,
                          child: PinCodeTextField(
                            appContext: context,
                            length: 6,
                            obscureText: false,
                            keyboardType: TextInputType.number,
                            animationType: AnimationType.fade,
                            textStyle: const TextStyle(
                              color: kTextColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w300,
                            ),
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.circle,
                              borderRadius: BorderRadius.circular(50),
                              fieldHeight: 45,
                              fieldWidth: 45,
                              selectedColor: kPrimaryColor,
                              activeColor: kBorder,
                              inactiveColor: kBorder,
                              activeFillColor: kWhite,
                              selectedFillColor: kWhite,
                              inactiveFillColor: kWhite,
                            ),
                            animationDuration:
                                const Duration(milliseconds: 300),
                            backgroundColor: Colors.transparent,
                            enableActiveFill: true,
                            controller: _otpController,
                            onChanged: (value) {},
                          ),
                        ),
                        const SizedBox(height: 20),
                        anim.AnimatedWidgetWrapper(
                          animationType: anim.AnimationType.fadeSlideInFromLeft,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 300,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isButtonDisabled
                                    ? 'Resend OTP in $_start seconds'
                                    : 'Didn\'t receive code?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: kSecondaryTextColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: _isButtonDisabled ? null : resendCode,
                                child: Text(
                                  _isButtonDisabled ? '' : 'Resend Code',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: _isButtonDisabled
                                        ? kSecondaryTextColor
                                        : kPrimaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 36),
                          child: anim.AnimatedWidgetWrapper(
                            animationType: anim.AnimationType.fadeScaleUp,
                            duration: anim.AnimationDuration.normal,
                            delayMilliseconds: 400,
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: primaryButton(
                                label: 'Verify',
                                onPressed: isLoading
                                    ? null
                                    : () => _handleOtpVerification(context, ref),
                                isLoading: isLoading,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleOtpVerification(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final otp = _otpController.text;

    if (otp.isEmpty || otp.length != 6) {
      SnackbarService().showSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    try {
      ref.read(loadingProvider.notifier).startLoading();

      final result = await ref.read(
        verifyOtpForCharityMemberProvider(widget.charityMemberId, otp).future,
      );

      ref.read(loadingProvider.notifier).stopLoading();

      if (result != null) {
        log('OTP verified for charity member', name: 'CharityMemberOtpVerification');
        SnackbarService().showSnackBar('Verification successful');

        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('navbar');
        }
      } else {
        SnackbarService().showSnackBar('Failed to verify OTP');
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).stopLoading();
      SnackbarService().showSnackBar('Error: $e');
      log('Error verifying OTP: $e', name: 'CharityMemberOtpVerification');
    }
  }
}
