import 'dart:async';
import 'dart:developer';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/providers/loading_provider.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
// import 'package:Annujoom/src/data/services/firebase_auth_service.dart'; // TODO: Not needed for backend OTP
import 'package:Annujoom/src/data/providers/auth_login_provider.dart';
// import 'package:Annujoom/src/data/providers/firebase_auth_provider.dart'; // TODO: Not needed for backend OTP
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/data/models/user_model.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:Annujoom/src/data/services/notification_service/get_fcm.dart';
import 'package:easy_localization/easy_localization.dart';
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
                    'phoneNumber'.tr(),
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
                            child: Text('pleaseEnterMobileNumber'.tr(),
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
                                    return 'phoneNumberCannotExceed'.tr();
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
                                hintText: 'enterYourPhoneNumber'.tr(),
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
                            child: Text('aVerificationCodeWillBeSent'.tr(),
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
                                  label: 'sendOTP'.tr(),
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
      SnackbarService().showSnackBar('pleaseEnterPhoneNumber'.tr());
      return;
    }

    try {
      ref.read(loadingProvider.notifier).startLoading();

      // Request FCM token only if not already saved
      final secureStorage = ref.read(secureStorageServiceProvider);
      String? fcmToken;
      final existingFcmToken = await secureStorage.getFcmToken();
      if (existingFcmToken == null || existingFcmToken.isEmpty) {
        await getFcmToken(context, ref);
        fcmToken = await secureStorage.getFcmToken();
      } else {
        fcmToken = existingFcmToken;
      }

      // TODO: Using backend API for OTP generation instead of Firebase
      // final firebaseAuthService = ref.read(firebaseAuthServiceProvider);
      final fullPhone = "+$countryCode$phoneNumber";

      // Call backend Login function to generate OTP
      final authLoginApi = ref.read(authLoginApiProvider);
      final response = await authLoginApi.Login(fullPhone, fcmToken ?? '');

      ref.read(loadingProvider.notifier).stopLoading();

      if (!response.success) {
        SnackbarService()
            .showSnackBar(response.message ?? 'failedToSendOTP'.tr());
        return;
      }

      // SnackbarService().showSnackBar('OTP sent successfully');

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              fullPhone: fullPhone,
              countryCode: countryCode ?? '91',
              // verificationId: verificationId, // Not needed for backend OTP
              // resendToken: resendToken, // Not needed for backend OTP
            ),
          ),
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
  final String fullPhone;
  final String countryCode;
  // final String verificationId; // Not needed for backend OTP
  // final String resendToken; // Not needed for backend OTP

  const OTPScreen({
    required this.fullPhone,
    required this.countryCode,
    // this.verificationId, // Not needed for backend OTP
    // this.resendToken, // Not needed for backend OTP
    super.key,
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
      // TODO: Using backend API for OTP resend instead of Firebase
      final secureStorage = ref.read(secureStorageServiceProvider);
      String? fcmToken;
      final existingFcmToken = await secureStorage.getFcmToken();
      if (existingFcmToken == null || existingFcmToken.isEmpty) {
        await getFcmToken(context, ref);
        fcmToken = await secureStorage.getFcmToken();
      } else {
        fcmToken = existingFcmToken;
      }

      // Call backend Login function to resend OTP
      final authLoginApi = ref.read(authLoginApiProvider);
      final response =
          await authLoginApi.Login(widget.fullPhone, fcmToken ?? '');

      if (response.success) {
        SnackbarService().showSnackBar('OTP resent successfully');
        log('OTP resent successfully', name: 'OTPScreen');
      } else {
        SnackbarService()
            .showSnackBar(response.message ?? 'Failed to resend OTP');
        log('Error resending OTP: ${response.message}', name: 'OTPScreen');
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
                  'enterCode'.tr(),
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
                              'enterThe6DigitCode'.tr() +
                                  ' ${widget.fullPhone}',
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
                                    ? 'resendOTPIn'.tr() +
                                        ' $_start ' +
                                        'seconds'.tr()
                                    : 'didntReceiveCode'.tr(),
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
                                  _isButtonDisabled ? '' : 'resendCode'.tr(),
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
                                label: 'verify'.tr(),
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
      SnackbarService().showSnackBar('pleaseEnterValid6DigitOTP'.tr());
      return;
    }

    try {
      ref.read(loadingProvider.notifier).startLoading();

      // Step 1: Verify OTP with backend API
      final authLoginApi = ref.read(authLoginApiProvider);

      // Debug: Log the request data
      log('Sending verifyOtp request with data:', name: 'OTPScreen');
      log('Phone: ${widget.fullPhone}', name: 'OTPScreen');
      log('OTP: $otp', name: 'OTPScreen');

      final response = await authLoginApi.verifyOtp(
        widget.fullPhone,
        otp,
      );

      ref.read(loadingProvider.notifier).stopLoading();

      if (response.success && response.data != null) {
        final data = response.data!;
        log('Response data received: $data', name: 'OTPScreen');

        // Extract the nested data object (backend wraps response in data key)
        final nestedData = data['data'] as Map<String, dynamic>?;
        if (nestedData == null) {
          log('No nested data found', name: 'OTPScreen');
          SnackbarService().showSnackBar('invalidResponseData'.tr());
          return;
        }

        final token = nestedData['token'] as String?;
        final userData = nestedData['user'] as Map<String, dynamic>?;

        log('Token extracted: ${token != null ? "YES" : "NO"}',
            name: 'OTPScreen');
        log('User data extracted: ${userData != null ? "YES" : "NO"}',
            name: 'OTPScreen');

        if (token != null && userData != null) {
          final user = UserModel.fromJson(userData);
          final secureStorage = SecureStorageService();

          // Save bearer token to secure storage
          await secureStorage.saveBearerToken(token);
          if (user.id != null) {
            await secureStorage.saveUserId(user.id!);
          }

          // Store user in provider
          ref.read(userProvider.notifier).setUser(user);

          log('OTP verified and login successful', name: 'OTPScreen');

          if (context.mounted) {
            // Navigate based on user status from API response, removing all previous routes
            final userStatus = userData['status'] as String?;
            String routeName;
            switch (userStatus) {
              case 'active':
                routeName = 'navbar';
                break;
              case 'inactive':
                routeName = 'registration';
                break;
              case 'pending':
                routeName = 'requestSent';
                break;
              case 'rejected':
                routeName = 'requestRejected';
                break;
              case 'suspended':
                routeName = 'accountSuspended';
                break;
              default:
                routeName = 'navbar';
            }
            Navigator.of(context).pushNamedAndRemoveUntil(
              routeName,
              (route) => false,
            );
          }
        } else {
          SnackbarService().showSnackBar('invalidResponseData'.tr());
        }
      } else {
        SnackbarService().showSnackBar(
          response.message ?? 'failedToSendOTP'.tr(),
        );
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).stopLoading();
      SnackbarService().showSnackBar('Error: $e');
      log('Error verifying OTP: $e', name: 'OTPScreen');
    }
  }
}
