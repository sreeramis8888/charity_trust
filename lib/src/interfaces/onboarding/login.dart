import 'dart:async';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/notifiers/loading_notifier.dart';
import 'package:charity_trust/src/data/services/navigation_service.dart';
import 'package:charity_trust/src/interfaces/components/primaryButton.dart';
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
        backgroundColor: const Color(0xFF1D09CD),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 70),
                Center(
                  child: Image.asset(
                    'assets/png/annujoom_logo.png',
                  ),
                ),
                const SizedBox(height: 70),
                Text(
                  'Verify your Phone Number',
                  style: kHeadTitleB,
                ),
                SizedBox(
                  height: 56,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomInset),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Please enter your mobile number',
                              style: kBodyTitleL.copyWith(color: kWhite)),
                          const SizedBox(height: 20),
                          Theme(
                            data: Theme.of(context).copyWith(
                              textTheme: Theme.of(context).textTheme.apply(
                                    bodyColor:
                                        Colors.white, // search text color
                                    displayColor: Colors.white,
                                  ),
                              inputDecorationTheme: const InputDecorationTheme(
                                hintStyle: TextStyle(
                                    color: Colors.white70), // search hint color
                              ),
                            ),
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
                                color: kWhite,
                                letterSpacing: 8,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                              controller: _mobileController,
                              disableLengthCheck: true,
                              showCountryFlag: true,
                              cursorColor: kWhite,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: kInputFieldcolor,
                                hintText: 'Enter your phone number',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  letterSpacing: .2,
                                  fontWeight: FontWeight.w200,
                                  color: kSecondaryTextColor,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                      BorderSide(color: kInputFieldcolor),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                      BorderSide(color: kInputFieldcolor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide:
                                      const BorderSide(color: kInputFieldcolor),
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
                              initialCountryCode: 'AE',
                              onChanged: (phone) {
                                print(phone.completeNumber);
                              },
                              flagsButtonPadding:
                                  const EdgeInsets.only(left: 10, right: 10.0),
                              showDropdownIcon: true,
                              dropdownIcon: const Icon(
                                Icons.arrow_drop_down_outlined,
                                color: kWhite,
                              ),
                              dropdownIconPosition: IconPosition.trailing,
                              dropdownTextStyle: const TextStyle(
                                color: kWhite,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('A 6 digit verification code will be sent',
                              style: TextStyle(
                                  color: kSecondaryTextColor,
                                  fontWeight: FontWeight.w300)),
                          Padding(
                            padding: const EdgeInsets.only(top: 36),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: primaryButton(
                                label: 'Send OTP',
                                onPressed: isLoading
                                    ? null
                                    : () => _handleOtpGeneration(context, ref),
                                isLoading: isLoading,
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
    // TODO: Implement OTP generation logic
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
    // TODO: Implement resend OTP logic
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loadingProvider);
    NavigationService navigationService = NavigationService();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor:
          const Color(0xFF1D09CD), // Fallback color matching the theme
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1D09CD),
              const Color.fromARGB(255, 33, 16, 73),
              const Color.fromARGB(255, 14, 11, 78),
            ],
          ),
          image: DecorationImage(
            image: const AssetImage('assets/pngs/subcription_bg.png'),
            fit: BoxFit.cover,
            opacity: 0.9,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Add back button
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                      onTap: () => navigationService.pushNamed('PhoneNumber'),
                      child: Icon(Icons.arrow_back_ios)),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Image.asset(
                    'assets/png/annujoom_logo.png',
                  ),
                ),
                const SizedBox(height: 70),
                Text(
                  'Verify OTP',
                  style: kHeadTitleB.copyWith(color: kWhite),
                ),
                SizedBox(
                  height: 56,
                ),
                Text('Enter the OTP to verify',
                    style: kBodyTitleR.copyWith(
                        fontSize: 16, color: kSecondaryTextColor)),
                const SizedBox(height: 10),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: false,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  textStyle: const TextStyle(
                    color: kWhite,
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 5.0,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 55,
                    fieldWidth: 50,
                    selectedColor: kPrimaryColor,
                    activeColor: const Color.fromARGB(255, 232, 226, 226),
                    inactiveColor: kInputFieldcolor,
                    activeFillColor: kInputFieldcolor,
                    selectedFillColor: kInputFieldcolor,
                    inactiveFillColor: kInputFieldcolor,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  controller: _otpController,
                  onChanged: (value) {},
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isButtonDisabled
                          ? 'Resend OTP in $_start seconds'
                          : 'Enter your OTP',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color:
                              _isButtonDisabled ? kGrey : kSecondaryTextColor),
                    ),
                    GestureDetector(
                      onTap: _isButtonDisabled ? null : resendCode,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Text(
                          _isButtonDisabled ? '' : 'Resend Code',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _isButtonDisabled ? kGrey : kRed),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 36),
                  child: SizedBox(
                    height: 47,
                    width: double.infinity,
                    child: primaryButton(
                      label: 'Verify',
                      onPressed: isLoading
                          ? null
                          : () => _handleOtpVerification(context, ref),
                      fontSize: 16,
                      isLoading: isLoading,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleOtpVerification(
      BuildContext context, WidgetRef ref) async {
    // TODO: Implement OTP verification logic
  }
}
