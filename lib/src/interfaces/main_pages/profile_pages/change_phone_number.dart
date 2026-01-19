import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/providers/loading_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/data/providers/auth_provider.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/components/confirmation_dialog.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ChangePhoneNumberPage extends ConsumerStatefulWidget {
  const ChangePhoneNumberPage({super.key});

  @override
  ConsumerState<ChangePhoneNumberPage> createState() =>
      _ChangePhoneNumberPageState();
}

class _ChangePhoneNumberPageState extends ConsumerState<ChangePhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final FocusNode _unfocusNode = FocusNode();
  final newPhoneController = TextEditingController();
  // String? phoneCountryCode='91';
  final String phoneCountryCode = '91'; // Always use India country code
  @override
  void dispose() {
    _scrollController.dispose();
    _unfocusNode.dispose();
    newPhoneController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePhoneNumber() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      ref.read(loadingProvider.notifier).startLoading();

      final newPhoneNumber = newPhoneController.text.trim();

      // Call update API to change phone number
      final userData = <String, dynamic>{
        'phone': "+$phoneCountryCode${newPhoneNumber}",
      };

      final response =
          await ref.read(updateUserProfileProvider(userData).future);

      ref.read(loadingProvider.notifier).stopLoading();

      if (response.user == null) {
        SnackbarService().showSnackBar(
          response.error ?? 'failedToChangePhoneNumber'.tr(),
          type: SnackbarType.error,
        );
        return;
      }

      // Show confirmation dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => ConfirmationDialog(
            title: 'phoneNumberChanged'.tr(),
            message: 'youNeedToLoginAgain'.tr(),
            confirmButtonText: 'logout'.tr(),
            onConfirm: () {
              Navigator.of(dialogContext).pop();
              _performLogout();
            },
          ),
        );
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).stopLoading();
      SnackbarService().showSnackBar('Error: $e');
      log('Error changing phone number: $e', name: 'ChangePhoneNumberPage');
    }
  }

  Future<void> _performLogout() async {
    try {
      final authProvider = ref.read(authProviderProvider);

      // Clear local storage
      await authProvider.clearAllData();

      if (mounted) {
        // Navigate to Phone screen and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil(
          'Phone',
          (route) => false,
        );
      }
    } catch (e) {
      // Clear local storage even if there's an error
      try {
        final authProvider = ref.read(authProviderProvider);
        await authProvider.clearAllData();
      } catch (_) {}

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'logoutFailed'.tr()}: $e')),
        );
        // Still navigate to login even if there was an error
        Navigator.of(context).pushNamedAndRemoveUntil(
          'Phone',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(fetchUserProfileProvider);
    final isLoading = ref.watch(loadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kWhite,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("changePhoneNumber".tr(), style: kSubHeadingM),
      ),
      body: userDataAsync.when(
        data: (userData) {
          if (userData == null) {
            return Center(
              child: Text(
                'Unable to load profile data',
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
              ),
            );
          }

          final currentPhone = userData.mobileNumber ?? '';

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(_unfocusNode);
            },
            child: Focus(
              focusNode: _unfocusNode,
              child: Form(
                key: _formKey,
                child: ScrollConfiguration(
                  behavior: ScrollBehavior().copyWith(scrollbars: false),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        anim.AnimatedWidgetWrapper(
                          animationType: anim.AnimationType.fadeSlideInFromLeft,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 100,
                          child: Text(
                            "currentPhoneNumber".tr(),
                            style: kSmallTitleR,
                          ),
                        ),
                        const SizedBox(height: 12),
                        anim.AnimatedWidgetWrapper(
                          animationType:
                              anim.AnimationType.fadeSlideInFromBottom,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 150,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              currentPhone,
                              style: kBodyTitleR.copyWith(
                                color: kTextColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        anim.AnimatedWidgetWrapper(
                          animationType: anim.AnimationType.fadeSlideInFromLeft,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 200,
                          child: Text(
                            "newPhoneNumber".tr(),
                            style: kSmallTitleR,
                          ),
                        ),
                        const SizedBox(height: 12),
                        anim.AnimatedWidgetWrapper(
                          animationType:
                              anim.AnimationType.fadeSlideInFromBottom,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 250,
                          child: Stack(
                            children: [
                              IntlPhoneField(
                                validator: (phone) {
                                  if (phone == null || phone.number.isEmpty) {
                                    return "required".tr();
                                  }
                                  if (phone.number.length < 9) {
                                    return "pleaseEnterValidPhoneNumber".tr();
                                  }
                                  if (phone.number.length > 10) {
                                    return "phoneNumberCannotExceed".tr();
                                  }
                                  return null;
                                },
                                style: const TextStyle(
                                  color: kTextColor,
                                  letterSpacing: 3,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                                controller: newPhoneController,
                                disableLengthCheck: true,
                                showCountryFlag: true,
                                cursorColor: kBlack,
                                decoration: InputDecoration(
                                  fillColor: kWhite,
                                  hintText: 'enterNewPhoneNumber'.tr(),
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
                                    borderSide:
                                        const BorderSide(color: kBorder),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                    horizontal: 10.0,
                                  ),
                                ),
                                // onCountryChanged: (value) {
                                //   phoneCountryCode = value.dialCode;
                                // },
                                initialCountryCode: 'IN',
                                flagsButtonPadding: const EdgeInsets.only(
                                    left: 10, right: 10.0),
                                showDropdownIcon: false,
                                // dropdownIcon: const Icon(
                                //   Icons.arrow_drop_down_outlined,
                                //   color: kTextColor,
                                // ),
                                // dropdownIconPosition: IconPosition.trailing,
                                // dropdownTextStyle: const TextStyle(
                                //   color: kTextColor,
                                //   fontSize: 15,
                                //   fontWeight: FontWeight.w400,
                                // ),
                              ),
                              // Overlay to block taps on flag area (prevents country dropdown)
                              Positioned(
                                left: 0,
                                top: 0,
                                width:
                                    100, // Approximate width of flag + country code area
                                height: 50, // Height of the input field
                                child: GestureDetector(
                                  onTap: () {
                                    // Do nothing - block the tap
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        anim.AnimatedWidgetWrapper(
                          animationType: anim.AnimationType.fadeScaleUp,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 300,
                          child: SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: primaryButton(
                              label: "changePhoneNumber".tr(),
                              onPressed:
                                  isLoading ? null : _handleChangePhoneNumber,
                              isLoading: isLoading,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Error loading profile: $error'),
        ),
      ),
    );
  }
}
