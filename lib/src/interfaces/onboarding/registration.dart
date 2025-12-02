import 'dart:io';
import 'dart:developer';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/utils/media_picker.dart';
import 'package:charity_trust/src/data/notifiers/loading_notifier.dart';
import 'package:charity_trust/src/data/services/snackbar_service.dart';
import 'package:charity_trust/src/data/providers/user_provider.dart';
import 'package:charity_trust/src/interfaces/components/input_field.dart';
import 'package:charity_trust/src/interfaces/components/dropdown.dart';
import 'package:charity_trust/src/interfaces/components/primaryButton.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final FocusNode _unfocusNode = FocusNode();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final areaController = TextEditingController();
  final pincodeController = TextEditingController();
  final dobController = TextEditingController();
  final documentController = TextEditingController();
  final recommendedByController = TextEditingController();

  String? selectedDistrict;
  String? selectedCountry;
  XFile? profileImage;
  XFile? aadhaarImage;

  final Map<String, GlobalKey> _fieldKeys = {
    'name': GlobalKey(),
    'mobile': GlobalKey(),
    'email': GlobalKey(),
    'address': GlobalKey(),
    'area': GlobalKey(),
    'district': GlobalKey(),
    'country': GlobalKey(),
    'pincode': GlobalKey(),
    'aadhaar': GlobalKey(),
    'dob': GlobalKey(),
    'recommendedBy': GlobalKey(),
  };

  void _scrollToFirstError() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        String? firstErrorKey;
        
        if (nameController.text.trim().isEmpty) {
          firstErrorKey = 'name';
        }
        else if (mobileController.text.trim().length > 10) {
          firstErrorKey = 'mobile';
        }
        else if (dobController.text.trim().isEmpty) {
          firstErrorKey = 'dob';
        }
        else if (selectedDistrict == null || selectedDistrict!.isEmpty) {
          firstErrorKey = 'district';
        }
        else if (aadhaarImage == null) {
          firstErrorKey = 'aadhaar';
        }
        else if (recommendedByController.text.trim().isEmpty) {
          firstErrorKey = 'recommendedBy';
        }

        if (firstErrorKey != null) {
          final key = _fieldKeys[firstErrorKey];
          final context = key?.currentContext;
          if (context != null) {
            Scrollable.ensureVisible(
              context,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: 0.1,
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _unfocusNode.dispose();
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    addressController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    dobController.dispose();
    documentController.dispose();
    recommendedByController.dispose();
    super.dispose();
  }

  Future<void> _pickProfilePicture() async {
    FocusScope.of(context).requestFocus(_unfocusNode);

    final result = await pickMedia(
      context: context,
      enableCrop: true,
      cropRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      showDocument: false,
    );

    if (!mounted) return;

    if (result != null && result is XFile) {
      setState(() {
        profileImage = result;
      });
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(_unfocusNode);
    }
  }

  Future<void> _pickAadhaarCard() async {
    FocusScope.of(context).requestFocus(_unfocusNode);
    final result = await pickMedia(
      context: context,
      enableCrop: false,
    );

    if (!mounted) return;

    if (result != null && result is XFile) {
      setState(() {
        aadhaarImage = result;
        documentController.text = result.name;
      });
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(_unfocusNode);
    }
  }

  Future<void> _handleRegistration() async {
    try {
      ref.read(loadingProvider.notifier).startLoading();

      final userData = <String, dynamic>{
        'name': nameController.text.trim(),
        'phone': mobileController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'area': areaController.text.trim(),
        'district': selectedDistrict,
        'country': selectedCountry,
        'pincode': pincodeController.text.trim(),
        'dob': dobController.text.trim(),
        'recommended_by': recommendedByController.text.trim(),
      };

      final result = await ref.read(updateUserProfileProvider(userData).future);

      ref.read(loadingProvider.notifier).stopLoading();

      if (result != null) {
        log('User registration successful', name: 'RegistrationPage');
        SnackbarService().showSnackBar('Registration submitted successfully');

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('requestSent');
        }
      } else {
        SnackbarService().showSnackBar('Failed to submit registration');
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).stopLoading();
      SnackbarService().showSnackBar('Error: $e');
      log('Error during registration: $e', name: 'RegistrationPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
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
                const SizedBox(height: 70),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.scaleUp,
                  duration: anim.AnimationDuration.normal,
                  child: Center(
                    child: GestureDetector(
                      onTap: _pickProfilePicture,
                      child: Stack(
                        children: [
                          Container(
                            height: 110,
                            width: 110,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEAEAEA),
                            ),
                            child: profileImage != null
                                ? ClipOval(
                                    child: Image.file(
                                      File(profileImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 6,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Icon(Icons.camera_alt, size: 20),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 100,
                  child: Text("Full Name *", style: kSmallTitleR),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 150,
                  child: InputField(
                    key: _fieldKeys['name'],
                    type: CustomFieldType.text,
                    hint: "Enter full name",
                    controller: nameController,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
                const SizedBox(height: 18),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 200,
                  child: Text("Mobile Number *", style: kSmallTitleR),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 250,
                  child: IntlPhoneField(
                    key: _fieldKeys['mobile'],
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
                    controller: mobileController,
                    disableLengthCheck: true,
                    showCountryFlag: true,
                    cursorColor: kBlack,
                    decoration: InputDecoration(
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
                    initialCountryCode: 'IN',
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
                const SizedBox(height: 18),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 300,
                  child: Text("Email Address", style: kSmallTitleR),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 350,
                  child: InputField(
                    key: _fieldKeys['email'],
                    type: CustomFieldType.text,
                    hint: "Enter address",
                    controller: emailController,
                  ),
                ),
                const SizedBox(height: 18),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 400,
                  child: Text("Addresss", style: kSmallTitleR),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 450,
                  child: InputField(
                    key: _fieldKeys['address'],
                    type: CustomFieldType.text,
                    hint: "Enter address",
                    controller: addressController,
                  ),
                ),
                const SizedBox(height: 18),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 500,
                  child: Text("Area", style: kSmallTitleR),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 550,
                  child: InputField(
                    key: _fieldKeys['area'],
                    type: CustomFieldType.text,
                    hint: "Enter area",
                    controller: areaController,
                  ),
                ),
                const SizedBox(height: 18),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 600,
                  child: Text("District *", style: kSmallTitleR),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 650,
                  child: AnimatedDropdown<String>(
                    key: _fieldKeys['district'],
                    hint: "Select",
                    value: selectedDistrict,
                    items: const ["Ernakulam", "Kollam", "Thrissur"],
                    itemLabel: (item) => item,
                    onChanged: (v) => setState(() => selectedDistrict = v),
                  ),
                ),
                const SizedBox(height: 18),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 700,
                  child: Text("Country", style: kSmallTitleR),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 750,
                  child: AnimatedDropdown<String>(
                    key: _fieldKeys['country'],
                    hint: "Select",
                    value: selectedCountry,
                    items: const ["India", "USA", "UK"],
                    itemLabel: (item) => item,
                    onChanged: (v) => setState(() => selectedCountry = v),
                  ),
                ),
                const SizedBox(height: 18),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 800,
                  child: Text("Pincode", style: kSmallTitleR),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 850,
                  child: InputField(
                    key: _fieldKeys['pincode'],
                    type: CustomFieldType.text,
                    hint: "Enter pincode",
                    controller: pincodeController,
                  ),
                ),
                const SizedBox(height: 20),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 900,
                  child: Text("Upload Aadhar Card", style: kSmallTitleR),
                ),
                const SizedBox(height: 4),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 950,
                  child: Text(
                    "Image (JPG/PNG) - Recommended size: 400x400",
                    style: kSmallerTitleR.copyWith(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 1000,
                  child: FormField<void>(
                    key: _fieldKeys['aadhaar'],
                    validator: (_) {
                      // Example: make Aadhaar required; adjust if optional
                      if (aadhaarImage == null) {
                        return 'Required';
                      }
                      return null;
                    },
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _pickAadhaarCard,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: field.hasError
                                      ? Colors.red
                                      : kBorder),
                              color: kWhite,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.cloud_upload_outlined,
                                    color: kTextColor),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    aadhaarImage != null
                                        ? aadhaarImage!.name
                                        : "Upload",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: aadhaarImage != null
                                          ? kTextColor
                                          : kSecondaryTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                            child: Text(
                              field.errorText ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 1050,
                  child: Text("Date of Birth *", style: kSmallTitleR),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 1100,
                  child: InputField(
                    key: _fieldKeys['dob'],
                    type: CustomFieldType.date,
                    hint: "dd/mm/yyyy",
                    controller: dobController,
                    validator: (v) => v!.isEmpty ? "Required" : null,
                  ),
                ),
                const SizedBox(height: 20),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromLeft,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 1150,
                  child: Text("Recommended By *", style: kSmallTitleR),
                ),
                const SizedBox(height: 6),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeSlideInFromBottom,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 1200,
                  child: AnimatedDropdown<String>(
                    key: _fieldKeys['recommendedBy'],
                    hint: "Select the trustee name",
                    value: recommendedByController.text.isEmpty
                        ? null
                        : recommendedByController.text,
                    items: const ["Trustee 1", "Trustee 2", "Trustee 3"],
                    itemLabel: (item) => item,
                    onChanged: (v) =>
                        setState(() => recommendedByController.text = v ?? ""),
                  ),
                ),
                const SizedBox(height: 30),
                anim.AnimatedWidgetWrapper(
                  animationType: anim.AnimationType.fadeScaleUp,
                  duration: anim.AnimationDuration.normal,
                  delayMilliseconds: 1250,
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: primaryButton(
                      label: "Register",
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _handleRegistration();
                        } else {
                          _scrollToFirstError();
                        }
                      },
                      isLoading: ref.watch(loadingProvider),
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
    ));
  }
}
