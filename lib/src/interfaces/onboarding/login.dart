import 'dart:async';
import 'dart:developer';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/notifiers/loading_notifier.dart';
import 'package:charity_trust/src/data/services/secure_storage_service.dart';
import 'package:charity_trust/src/data/services/snackbar_service.dart';
import 'package:charity_trust/src/data/providers/auth_login_provider.dart';
import 'package:charity_trust/src/data/providers/user_provider.dart';
import 'package:charity_trust/src/data/models/user_model.dart';
import 'package:charity_trust/src/interfaces/components/primaryButton.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

final countryCodeProvider = StateProvider<String?>((ref) => '91');

class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({
    super.key,
  });

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  late TextEditingController _mobileController;

  @override
  void initState() {
    super.initState();
    _mobileController = TextEditingController();
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
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
                    'Phone Number',
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
                            animationType:
                                anim.AnimationType.fadeSlideInFromLeft,
                            duration: anim.AnimationDuration.normal,
                            delayMilliseconds: 100,
                            child: Text('Please enter your mobile number',
                                style: kSmallTitleR.copyWith(
                                    color: kSecondaryTextColor)),
                          ),
                          const SizedBox(height: 20),
                          anim.AnimatedWidgetWrapper(
                            animationType:
                                anim.AnimationType.fadeSlideInFromBottom,
                            duration: anim.AnimationDuration.normal,
                            delayMilliseconds: 200,
                            child: IntlPhoneField(
                              validator: (phone) {
                                if (phone!.number.length > 9) {
                                  if (phone.number.length > 10) {
                                    return 'Phone number cannot exceed 10 digits';
                                  }
                                }
                                return null;
                              },
                              style: const TextStyle(
                                color: kTextColor,
                                letterSpacing: 3,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              controller: _mobileController,
                              disableLengthCheck: true,
                              showCountryFlag: true,
                              cursorColor: kBlack,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: kWhite,
                                hintText: 'Enter your phone number',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: .2,
                                  fontWeight: FontWeight.w200,
                                  color: kTextColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: kBorder),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(color: kBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(color: kBorder),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                  horizontal: 10.0,
                                ),
                              ),
                              onCountryChanged: (value) {
                                ref.read(countryCodeProvider.notifier).state =
                                    value.dialCode;
                              },
                              initialCountryCode: 'IN',
                              onChanged: (phone) {
                                print(phone.completeNumber);
                              },
                              flagsButtonPadding:
                                  const EdgeInsets.only(left: 10, right: 10.0),
                              showDropdownIcon: true,
                              dropdownIcon: const Icon(
                                Icons.arrow_drop_down_outlined,
                                color: kTextColor,
                              ),
                              dropdownIconPosition: IconPosition.trailing,
                              dropdownTextStyle: const TextStyle(
                                color: kTextColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          anim.AnimatedWidgetWrapper(
                            animationType:
                                anim.AnimationType.fadeSlideInFromLeft,
                            duration: anim.AnimationDuration.normal,
                            delayMilliseconds: 300,
                            child: Text(
                                'A 6 digit verification code will be sent',
                                style: TextStyle(
                                    color: kSecondaryTextColor,
                                    fontWeight: FontWeight.w300)),
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
                                  label: 'Send OTP',
                                  onPressed: isLoading
                                      ? null
                                      : () =>
                                          _handleOtpGeneration(context, ref),
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
        ));
  }

  Future<void> _handleOtpGeneration(BuildContext context, WidgetRef ref) async {
    final countryCode = ref.read(countryCodeProvider);
    final phoneNumber = _mobileController.text;

    if (phoneNumber.isEmpty) {
      SnackbarService snackbarService = SnackbarService();
      snackbarService.showSnackBar('Please enter a phone number');
      return;
    }

    try {
      // Show loading
      ref.read(loadingProvider.notifier).startLoading();

      final authLoginApi = ref.read(authLoginApiProvider);
      final response = await authLoginApi.sendOtp("+$countryCode$phoneNumber");

      ref.read(loadingProvider.notifier).stopLoading();

      if (response.success && response.data != null) {
        final otp = response.data!['data'] as String?;
        if (otp != null) {
          log('OTP: $otp', name: 'PhoneNumberScreen');
          SnackbarService().showSnackBar('OTP sent successfully');

          if (context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  fullPhone: "+$countryCode$phoneNumber",
                  resendToken: '',
                  countryCode: countryCode ?? '91',
                  verificationId: '',
                ),
              ),
            );
          }
        }
      } else {
        SnackbarService().showSnackBar(
          response.message ?? 'Failed to send OTP',
        );
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).stopLoading();
      SnackbarService().showSnackBar('Error: $e');
      log('Error sending OTP: $e', name: 'PhoneNumberScreen');
    }
  }
}

class OTPScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String resendToken;
  final String fullPhone;
  final String countryCode;
  const OTPScreen({
    required this.fullPhone,
    required this.resendToken,
    required this.countryCode,
    super.key,
    required this.verificationId,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
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
    _resendOtp();
  }

  Future<void> _resendOtp() async {
    try {
      final authLoginApi = ref.read(authLoginApiProvider);
      final response = await authLoginApi.sendOtp(widget.fullPhone);

      if (response.success && response.data != null) {
        final otp = response.data!['data'] as String?;
        if (otp != null) {
          log('OTP (Resend): $otp', name: 'OTPScreen');
          SnackbarService().showSnackBar('OTP resent successfully');
        }
      } else {
        SnackbarService().showSnackBar(
          response.message ?? 'Failed to resend OTP',
        );
      }
    } catch (e) {
      SnackbarService().showSnackBar('Error: $e');
      log('Error resending OTP: $e', name: 'OTPScreen');
    }
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
                  'Enter Code',
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
                              'Enter the 6-digit code sent to ${widget.fullPhone}',
                              style: kSmallTitleR.copyWith(
                                  color: kSecondaryTextColor)),
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
                                    color: _isButtonDisabled
                                        ? kSecondaryTextColor
                                        : kSecondaryTextColor),
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
                                          : kPrimaryColor),
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
                                    : () =>
                                        _handleOtpVerification(context, ref),
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
      BuildContext context, WidgetRef ref) async {
    final otp = _otpController.text;

    if (otp.isEmpty || otp.length != 6) {
      SnackbarService().showSnackBar('Please enter a valid 6-digit OTP');
      return;
    }

    try {
      ref.read(loadingProvider.notifier).startLoading();
      SecureStorageService secureStorage = SecureStorageService();
      // Get FCM token
      final fcmToken = await secureStorage.getFcmToken();

      final authLoginApi = ref.read(authLoginApiProvider);
      final response =
          await authLoginApi.verifyOtp(widget.fullPhone, otp, fcmToken ?? '');

      ref.read(loadingProvider.notifier).stopLoading();

      if (response.success && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) {
          final userData = data['user'] as Map<String, dynamic>?;
          if (userData != null) {
            final user = UserModel.fromJson(userData);

            // Store user in provider and secure storage
            ref.read(userProvider.notifier).setUser(user);

            log('OTP verified successfully', name: 'OTPScreen');
            SnackbarService().showSnackBar('Login successful');

            if (context.mounted) {
              // Navigate based on user status
              switch (user.status) {
                case 'active':
                  Navigator.of(context).pushReplacementNamed('navbar');
                  break;
                case 'inactive':
                  Navigator.of(context).pushReplacementNamed('registration');
                  break;
                case 'pending':
                  Navigator.of(context).pushReplacementNamed('requestSent');
                  break;
                case 'rejected':
                  Navigator.of(context).pushReplacementNamed('requestRejected');
                  break;
                case 'suspended':
                  Navigator.of(context)
                      .pushReplacementNamed('accountSuspended');
                  break;
                default:
                  Navigator.of(context).pushReplacementNamed('navbar');
              }
            }
          }
        }
      } else {
        SnackbarService().showSnackBar(
          response.message ?? 'Failed to verify OTP',
        );
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).stopLoading();
      SnackbarService().showSnackBar('Error: $e');
      log('Error verifying OTP: $e', name: 'OTPScreen');
    }
  }
}
