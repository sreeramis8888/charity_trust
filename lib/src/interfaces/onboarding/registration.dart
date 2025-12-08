import 'dart:io';
import 'dart:developer';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/data/utils/media_picker.dart';
import 'package:charity_trust/src/data/notifiers/loading_notifier.dart';
import 'package:charity_trust/src/data/services/snackbar_service.dart';
import 'package:charity_trust/src/data/services/image_upload.dart';
import 'package:charity_trust/src/data/providers/user_provider.dart';
import 'package:charity_trust/src/data/providers/location_provider.dart';
import 'package:charity_trust/src/data/models/user_model.dart';
import 'package:charity_trust/src/interfaces/components/input_field.dart';
import 'package:charity_trust/src/interfaces/components/dropdown.dart';
import 'package:charity_trust/src/interfaces/components/loading_indicator.dart';
import 'package:charity_trust/src/interfaces/components/searchable_dropdown.dart';
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
  final panNumberController = TextEditingController();
  final dobController = TextEditingController();
  final recommendedByController = TextEditingController();

  String? selectedCountryCode;
  String? selectedStateCode;
  String? selectedDistrictCode;
  String? selectedGender;
  XFile? profileImage;
  XFile? panCardImage;
  String? recommendedByType = 'trustee';
  UserModel? selectedRecommendedBy;
  bool isSameAsPhone = true;
  String? whatsappCountryCode;
  final whatsappController = TextEditingController();

  final Map<String, GlobalKey> _fieldKeys = {
    'name': GlobalKey(),
    'mobile': GlobalKey(),
    'email': GlobalKey(),
    'address': GlobalKey(),
    'area': GlobalKey(),
    'country': GlobalKey(),
    'state': GlobalKey(),
    'district': GlobalKey(),
    'pincode': GlobalKey(),
    'panNumber': GlobalKey(),
    'panCard': GlobalKey(),
    'dob': GlobalKey(),
    'gender': GlobalKey(),
    'whatsapp': GlobalKey(),
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
        } else if (mobileController.text.trim().length > 10) {
          firstErrorKey = 'mobile';
        } else if (dobController.text.trim().isEmpty) {
          firstErrorKey = 'dob';
        } else if (selectedGender == null || selectedGender!.isEmpty) {
          firstErrorKey = 'gender';
        } else if (selectedCountryCode == null ||
            selectedCountryCode!.isEmpty) {
          firstErrorKey = 'country';
        } else if (selectedStateCode == null || selectedStateCode!.isEmpty) {
          firstErrorKey = 'state';
        } else if (selectedDistrictCode == null ||
            selectedDistrictCode!.isEmpty) {
          firstErrorKey = 'district';
        } else if (panNumberController.text.trim().isEmpty) {
          firstErrorKey = 'panNumber';
        } else if (panCardImage == null) {
          firstErrorKey = 'panCard';
        } else if (!isSameAsPhone && whatsappController.text.trim().isEmpty) {
          firstErrorKey = 'whatsapp';
        } else if (selectedRecommendedBy == null) {
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
    panNumberController.dispose();
    dobController.dispose();
    whatsappController.dispose();
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

  Future<void> _pickPanCard() async {
    FocusScope.of(context).requestFocus(_unfocusNode);
    final result = await pickMedia(
      context: context,
      enableCrop: false,
    );

    if (!mounted) return;

    if (result != null && result is XFile) {
      setState(() {
        panCardImage = result;
      });
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(_unfocusNode);
    }
  }

  Future<void> _handleRegistration() async {
    try {
      ref.read(loadingProvider.notifier).startLoading();

      // Upload profile picture if available
      String? profilePictureUrl;
      if (profileImage != null) {
        try {
          profilePictureUrl = await imageUpload(profileImage!.path);
          log('Profile picture uploaded: $profilePictureUrl',
              name: 'RegistrationPage');
        } catch (e) {
          if (mounted) {
            ref.read(loadingProvider.notifier).stopLoading();
          }
          SnackbarService().showSnackBar('Failed to upload profile picture');
          log('Error uploading profile picture: $e', name: 'RegistrationPage');
          return;
        }
      }

      // Upload PAN card if available
      String? panCardUrl;
      if (panCardImage != null) {
        try {
          panCardUrl = await imageUpload(panCardImage!.path);
          log('PAN card uploaded: $panCardUrl', name: 'RegistrationPage');
        } catch (e) {
          if (mounted) {
            ref.read(loadingProvider.notifier).stopLoading();
          }
          SnackbarService().showSnackBar('Failed to upload PAN card');
          log('Error uploading PAN card: $e', name: 'RegistrationPage');
          return;
        }
      }

      // Convert date from dd/mm/yyyy to yyyy-mm-dd format
      String formattedDob = dobController.text.trim();
      if (formattedDob.isNotEmpty) {
        try {
          final parts = formattedDob.split('/');
          if (parts.length == 3) {
            formattedDob = '${parts[2]}-${parts[1]}-${parts[0]}';
          }
        } catch (e) {
          log('Error formatting date: $e', name: 'RegistrationPage');
        }
      }

      final whatsappNumber = isSameAsPhone
          ? mobileController.text.trim()
          : whatsappController.text.trim();

      final userData = <String, dynamic>{
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'address': addressController.text.trim(),
        'area': areaController.text.trim(),
        'country': selectedCountryCode,
        'state': selectedStateCode,
        'district': selectedDistrictCode,
        'pincode': pincodeController.text.trim(),
        'pan_number': panNumberController.text.trim(),
        'pan_copy': panCardUrl,
        'profile_picture': profilePictureUrl,
        'gender': selectedGender,
        'whatsapp_number': whatsappNumber,
        'dob': formattedDob,
        'recommended_by': recommendedByType == 'trustee' ? 'trustee' : 'charity-member',
        if (recommendedByType == 'trustee')
          'under_trustee': selectedRecommendedBy?.id
        else
          'under_charity_member': selectedRecommendedBy?.id,
        'status': recommendedByType == 'charity_member' ? 'inactive' : 'pending'
      };

      final result = await ref.read(updateUserProfileProvider(userData).future);

      // Check if widget is still mounted before using ref
      if (!mounted) return;

      ref.read(loadingProvider.notifier).stopLoading();

      if (result != null) {
        log('User registration successful', name: 'RegistrationPage');
        SnackbarService().showSnackBar('Registration submitted successfully');

        if (mounted) {
          // If recommended by charity member, navigate to OTP verification
          if (recommendedByType == 'charity_member' &&
              selectedRecommendedBy != null) {
            Navigator.of(context).pushReplacementNamed(
              'charityMemberOtpVerification',
              arguments: {
                'charityMemberId': selectedRecommendedBy!.id,
                'charityMemberName': selectedRecommendedBy!.name,
              },
            );
          } else {
            Navigator.of(context).pushReplacementNamed('requestSent');
          }
        }
      } else {
        SnackbarService().showSnackBar('Failed to submit registration',
            type: SnackbarType.error);
      }
    } catch (e) {
      // Check if widget is still mounted before using ref
      if (mounted) {
        ref.read(loadingProvider.notifier).stopLoading();
      }
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
                                    child:
                                        const Icon(Icons.camera_alt, size: 20),
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
                      // const SizedBox(height: 18),
                      // anim.AnimatedWidgetWrapper(
                      //   animationType: anim.AnimationType.fadeSlideInFromLeft,
                      //   duration: anim.AnimationDuration.normal,
                      //   delayMilliseconds: 200,
                      //   child: Text("Mobile Number *", style: kSmallTitleR),
                      // ),
                      // const SizedBox(height: 6),
                      // anim.AnimatedWidgetWrapper(
                      //   animationType: anim.AnimationType.fadeSlideInFromBottom,
                      //   duration: anim.AnimationDuration.normal,
                      //   delayMilliseconds: 250,
                      //   child: IntlPhoneField(
                      //     key: _fieldKeys['mobile'],
                      //     validator: (phone) {
                      //       if (phone!.number.length > 9) {
                      //         if (phone.number.length > 10) {
                      //           return 'Phone number cannot exceed 10 digits';
                      //         }
                      //       }
                      //       return null;
                      //     },
                      //     style: const TextStyle(
                      //       color: kTextColor,
                      //       letterSpacing: 3,
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      //     controller: mobileController,
                      //     disableLengthCheck: true,
                      //     showCountryFlag: true,
                      //     cursorColor: kBlack,
                      //     decoration: InputDecoration(
                      //       fillColor: kWhite,
                      //       hintText: 'Enter your phone number',
                      //       hintStyle: TextStyle(
                      //         fontSize: 14,
                      //         letterSpacing: .2,
                      //         fontWeight: FontWeight.w200,
                      //         color: kTextColor,
                      //       ),
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(8.0),
                      //         borderSide: BorderSide(color: kBorder),
                      //       ),
                      //       enabledBorder: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(8.0),
                      //         borderSide: BorderSide(color: kBorder),
                      //       ),
                      //       focusedBorder: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(8.0),
                      //         borderSide: const BorderSide(color: kBorder),
                      //       ),
                      //       contentPadding: const EdgeInsets.symmetric(
                      //         vertical: 16.0,
                      //         horizontal: 10.0,
                      //       ),
                      //     ),
                      //     initialCountryCode: 'IN',
                      //     flagsButtonPadding:
                      //         const EdgeInsets.only(left: 10, right: 10.0),
                      //     showDropdownIcon: true,
                      //     dropdownIcon: const Icon(
                      //       Icons.arrow_drop_down_outlined,
                      //       color: kTextColor,
                      //     ),
                      //     dropdownIconPosition: IconPosition.trailing,
                      //     dropdownTextStyle: const TextStyle(
                      //       color: kTextColor,
                      //       fontSize: 15,
                      //       fontWeight: FontWeight.w400,
                      //     ),
                      //   ),
                      // ),
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
                        child: Text("Country *", style: kSmallTitleR),
                      ),
                      const SizedBox(height: 6),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 650,
                        child: Consumer(
                          builder: (context, ref, _) {
                            final countriesAsync =
                                ref.watch(getAllCountriesProvider);
                            return countriesAsync.when(
                              data: (countries) {
                                return AnimatedDropdown<String>(
                                  key: _fieldKeys['country'],
                                  hint: "Select country",
                                  value: selectedCountryCode,
                                  items: countries
                                      .map((c) => c.iso2 ?? '')
                                      .cast<String>()
                                      .where((code) => code.isNotEmpty)
                                      .toList(),
                                  itemLabel: (code) {
                                    try {
                                      return countries
                                              .firstWhere((c) => c.iso2 == code)
                                              .name ??
                                          'Unknown';
                                    } catch (e) {
                                      return code;
                                    }
                                  },
                                  onChanged: (v) {
                                    setState(() {
                                      selectedCountryCode = v;
                                      selectedStateCode = null;
                                      selectedDistrictCode = null;
                                    });
                                  },
                                );
                              },
                              loading: () => const Center(
                                child: LoadingAnimation(),
                              ),
                              error: (err, stack) => Text('Error: $err'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (selectedCountryCode != null)
                        anim.AnimatedWidgetWrapper(
                          animationType: anim.AnimationType.fadeSlideInFromLeft,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 700,
                          child: Text("State *", style: kSmallTitleR),
                        ),
                      if (selectedCountryCode != null)
                        const SizedBox(height: 6),
                      if (selectedCountryCode != null)
                        anim.AnimatedWidgetWrapper(
                          animationType:
                              anim.AnimationType.fadeSlideInFromBottom,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 750,
                          child: Consumer(
                            builder: (context, ref, _) {
                              final statesAsync = ref.watch(
                                  getStatesByCountryProvider(
                                      selectedCountryCode!));
                              return statesAsync.when(
                                data: (states) {
                                  return AnimatedDropdown<String>(
                                    key: _fieldKeys['state'],
                                    hint: "Select state",
                                    value: selectedStateCode,
                                    items: states
                                        .map((s) => s.stateCode.toString())
                                        .toList(),
                                    itemLabel: (code) {
                                      try {
                                        return states
                                                .firstWhere((s) =>
                                                    s.stateCode.toString() ==
                                                    code)
                                                .name ??
                                            'Unknown';
                                      } catch (e) {
                                        return code;
                                      }
                                    },
                                    onChanged: (v) {
                                      setState(() {
                                        selectedStateCode = v;
                                        selectedDistrictCode = null;
                                      });
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: LoadingAnimation(),
                                ),
                                error: (err, stack) => Text('Error: $err'),
                              );
                            },
                          ),
                        ),
                      if (selectedCountryCode != null)
                        const SizedBox(height: 18),
                      if (selectedStateCode != null)
                        anim.AnimatedWidgetWrapper(
                          animationType: anim.AnimationType.fadeSlideInFromLeft,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 800,
                          child: Text("District *", style: kSmallTitleR),
                        ),
                      if (selectedStateCode != null) const SizedBox(height: 6),
                      if (selectedStateCode != null)
                        anim.AnimatedWidgetWrapper(
                          animationType:
                              anim.AnimationType.fadeSlideInFromBottom,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 850,
                          child: Consumer(
                            builder: (context, ref, _) {
                              final citiesAsync = ref.watch(
                                  getDistrictsByStateProvider(
                                      selectedCountryCode!,
                                      selectedStateCode!));
                              return citiesAsync.when(
                                data: (cities) {
                                  return AnimatedDropdown<String>(
                                    key: _fieldKeys['district'],
                                    hint: "Select district / city",
                                    value: selectedDistrictCode,
                                    items: cities
                                        .map((c) => c.id.toString())
                                        .toList(),
                                    itemLabel: (id) {
                                      try {
                                        return cities
                                                .firstWhere((c) =>
                                                    c.id.toString() == id)
                                                .name ??
                                            'Unknown';
                                      } catch (e) {
                                        return id;
                                      }
                                    },
                                    onChanged: (v) {
                                      setState(() {
                                        selectedDistrictCode = v;
                                      });
                                    },
                                  );
                                },
                                loading: () => const Center(
                                  child: LoadingAnimation(),
                                ),
                                error: (err, stack) => Text('Error: $err'),
                              );
                            },
                          ),
                        ),
                      if (selectedStateCode != null) const SizedBox(height: 18),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromLeft,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 900,
                        child: Text("Pincode", style: kSmallTitleR),
                      ),
                      const SizedBox(height: 6),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 950,
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
                        delayMilliseconds: 1000,
                        child: Text("PAN Number *", style: kSmallTitleR),
                      ),
                      const SizedBox(height: 6),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1050,
                        child: InputField(
                          key: _fieldKeys['panNumber'],
                          type: CustomFieldType.text,
                          hint: "Enter PAN number",
                          controller: panNumberController,
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(height: 20),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromLeft,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1100,
                        child: Text("Upload PAN Card", style: kSmallTitleR),
                      ),
                      const SizedBox(height: 4),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromLeft,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1150,
                        child: Text(
                          "Image (JPG/PNG) - Recommended size: 400x400",
                          style: kSmallerTitleR.copyWith(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 6),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1200,
                        child: FormField<void>(
                          key: _fieldKeys['panCard'],
                          validator: (_) {
                            if (panCardImage == null) {
                              return 'Required';
                            }
                            return null;
                          },
                          builder: (field) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: _pickPanCard,
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
                                          panCardImage != null
                                              ? panCardImage!.name
                                              : "Upload",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: panCardImage != null
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
                                  padding: const EdgeInsets.only(
                                      top: 4.0, left: 4.0),
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
                        delayMilliseconds: 1250,
                        child: Text("Date of Birth *", style: kSmallTitleR),
                      ),
                      const SizedBox(height: 6),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1300,
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
                        delayMilliseconds: 1350,
                        child: Text("Gender *", style: kSmallTitleR),
                      ),
                      const SizedBox(height: 6),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1400,
                        child: AnimatedDropdown<String>(
                          key: _fieldKeys['gender'],
                          hint: "Select gender",
                          value: selectedGender,
                          items: const ['Male', 'Female', 'Other'],
                          itemLabel: (value) => value,
                          onChanged: (v) {
                            setState(() {
                              selectedGender = v;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromLeft,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1450,
                        child: Text("WhatsApp Number *", style: kSmallTitleR),
                      ),
                      const SizedBox(height: 12),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1500,
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSameAsPhone,
                              onChanged: (value) {
                                setState(() {
                                  isSameAsPhone = value ?? true;
                                  if (isSameAsPhone) {
                                    whatsappController.clear();
                                  }
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                "Same as phone number",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isSameAsPhone)
                        const SizedBox(height: 12),
                      if (!isSameAsPhone)
                        anim.AnimatedWidgetWrapper(
                          animationType:
                              anim.AnimationType.fadeSlideInFromBottom,
                          duration: anim.AnimationDuration.normal,
                          delayMilliseconds: 1550,
                          child: IntlPhoneField(
                            key: _fieldKeys['whatsapp'],
                            validator: (phone) {
                              if (!isSameAsPhone) {
                                if (phone == null ||
                                    phone.number.isEmpty ||
                                    phone.number.length < 9) {
                                  return 'Please enter a valid phone number';
                                }
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
                            controller: whatsappController,
                            disableLengthCheck: true,
                            showCountryFlag: true,
                            cursorColor: kBlack,
                            decoration: InputDecoration(
                              fillColor: kWhite,
                              hintText: 'Enter WhatsApp number',
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
                              whatsappCountryCode = value.dialCode;
                            },
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
                      const SizedBox(height: 20),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromLeft,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1600,
                        child: Text("Recommended By *", style: kSmallTitleR),
                      ),
                      const SizedBox(height: 12),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1650,
                        child: Row(
                          children: [
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'trustee',
                                  groupValue: recommendedByType,
                                  onChanged: (value) {
                                    setState(() {
                                      recommendedByType = value;
                                      selectedRecommendedBy = null;
                                    });
                                  },
                                ),
                                const Text("Trustee"),
                              ],
                            ),
                            Row(
                              children: [
                                Radio<String>(
                                  value: 'charity_member',
                                  groupValue: recommendedByType,
                                  onChanged: (value) {
                                    setState(() {
                                      recommendedByType = value;
                                      selectedRecommendedBy = null;
                                    });
                                  },
                                ),
                                const Text("Charity Member"),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1700,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendedByType == 'trustee'
                                  ? "Choose Trustee *"
                                  : "Choose Charity Member *",
                              style: kSmallTitleR,
                            ),
                            const SizedBox(height: 6),
                            SearchableDropdown<UserModel>(
                              key: _fieldKeys['recommendedBy'],
                              hint: recommendedByType == 'trustee'
                                  ? "Search trustee"
                                  : "Search charity member",
                              value: selectedRecommendedBy,
                              itemLabel: (user) => user.name ?? 'Unknown',
                              onChanged: (user) {
                                setState(() {
                                  selectedRecommendedBy = user;
                                });
                              },
                              onFetch: (search, page) async {
                                final params = UsersListParams(
                                  role: recommendedByType == 'trustee'
                                      ? 'trustee'
                                      : 'member',
                                  pageNo: page,
                                  search: search.isEmpty ? null : search,
                                );
                                return ref.read(
                                  fetchUsersByRoleProvider(params).future,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeScaleUp,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1750,
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
