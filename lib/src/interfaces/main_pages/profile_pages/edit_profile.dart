import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/global_variables.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/utils/media_picker.dart';
import 'package:Annujoom/src/data/utils/validators.dart';
import 'package:Annujoom/src/data/providers/loading_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/services/image_upload.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/data/providers/location_provider.dart';
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/dropdown.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/components/modal_sheet.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final FocusNode _unfocusNode = FocusNode();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final areaController = TextEditingController();
  final pincodeController = TextEditingController();
  final dobController = TextEditingController();
  final whatsappController = TextEditingController();

  XFile? profileImage;
  String? existingImageUrl;
  String? selectedCountryCode;
  String? selectedCountryName;
  String? selectedStateCode;
  String? selectedStateName;
  String? selectedDistrictCode;
  String? selectedDistrictName;
  String? selectedGender;
  // String? whatsappCountryCode;
  final String whatsappCountryCode = '91'; // Always use India country code
  bool isSameAsPhone = true;

  final Map<String, GlobalKey> _fieldKeys = {
    'name': GlobalKey(),
    'email': GlobalKey(),
    'address': GlobalKey(),
    'area': GlobalKey(),
    'country': GlobalKey(),
    'state': GlobalKey(),
    'district': GlobalKey(),
    'pincode': GlobalKey(),
    'dob': GlobalKey(),
    'gender': GlobalKey(),
    'whatsapp': GlobalKey(),
  };

  void _scrollToFirstError() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        String? firstErrorKey;

        if (nameController.text.trim().isEmpty) {
          firstErrorKey = 'name';
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
        } else if (pincodeController.text.trim().isEmpty) {
          firstErrorKey = 'pincode';
        } else if (!isSameAsPhone && whatsappController.text.trim().isEmpty) {
          firstErrorKey = 'whatsapp';
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
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await ref.read(secureStorageServiceProvider).getUserData();
    if (userData != null && mounted) {
      setState(() {
        nameController.text = userData.name ?? '';
        emailController.text = userData.email ?? '';
        addressController.text = userData.address ?? '';
        areaController.text = userData.area ?? '';
        pincodeController.text = userData.pincode.toString() ?? '';
        selectedGender = userData.gender;
        selectedCountryCode = userData.countryCode;
        selectedCountryName = userData.country;
        selectedStateCode = userData.stateCode;
        selectedStateName = userData.state;
        selectedDistrictCode = userData.districtCode;
        selectedDistrictName = userData.district;
        // Format DateTime to dd/MM/yyyy
        if (userData.dob != null) {
          dobController.text =
              '${userData.dob!.day.toString().padLeft(2, '0')}/${userData.dob!.month.toString().padLeft(2, '0')}/${userData.dob!.year}';
        }
        existingImageUrl = userData.image;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _unfocusNode.dispose();
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    areaController.dispose();
    pincodeController.dispose();
    dobController.dispose();
    whatsappController.dispose();
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

  Future<void> _handleSaveProfile() async {
    try {
      ref.read(loadingProvider.notifier).startLoading();

      // Get current user data to preserve all fields
      final currentUser =
          await ref.read(secureStorageServiceProvider).getUserData();
      if (currentUser == null) {
        throw Exception('User data not found');
      }

      // Parse dob string (dd/MM/yyyy) to DateTime
      DateTime? parsedDob;
      final dobText = dobController.text.trim();
      if (dobText.isNotEmpty) {
        try {
          final parts = dobText.split('/');
          if (parts.length == 3) {
            parsedDob = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        } catch (e) {
          log('Error parsing dob: $e', name: 'EditProfilePage');
        }
      }

      // Build payload with only changed fields
      final userData = <String, dynamic>{};

      final newName = nameController.text.trim();
      if (newName != (currentUser.name ?? '')) {
        userData['name'] = newName;
      }

      final newEmail = emailController.text.trim();
      if (newEmail != (currentUser.email ?? '')) {
        userData['email'] = newEmail;
      }

      final newAddress = addressController.text.trim();
      if (newAddress != (currentUser.address ?? '')) {
        userData['address'] = newAddress;
      }

      final newArea = areaController.text.trim();
      if (newArea != (currentUser.area ?? '')) {
        userData['area'] = newArea;
      }

      final newPincode = pincodeController.text.trim();
      if (newPincode != (currentUser.pincode ?? '')) {
        userData['pincode'] = newPincode;
      }

      if (selectedCountryCode != currentUser.countryCode) {
        userData['country'] = selectedCountryName ?? selectedCountryCode;
      }

      if (selectedStateCode != currentUser.stateCode) {
        userData['state'] = selectedStateName ?? selectedStateCode;
      }

      if (selectedDistrictCode != currentUser.districtCode) {
        userData['district'] = selectedDistrictName ?? selectedDistrictCode;
      }

      if (selectedGender != currentUser.gender) {
        userData['gender'] = selectedGender;
      }

      if (parsedDob != currentUser.dob) {
        if (parsedDob != null) {
          userData['dob'] =
              '${parsedDob.year}-${parsedDob.month.toString().padLeft(2, '0')}-${parsedDob.day.toString().padLeft(2, '0')}';
        } else {
          userData['dob'] = null;
        }
      }

      final whatsappNumber = isSameAsPhone
          ? currentUser.mobileNumber ?? ''
          : whatsappController.text.trim();
      if (whatsappNumber != (currentUser.whatsappNo ?? '')) {
        userData['whatsapp_no'] = whatsappNumber;
      }

      // Handle profile image upload if selected
      String? profileImageUrl;
      if (profileImage != null) {
        try {
          profileImageUrl = await imageUpload(profileImage!.path);
          if (profileImageUrl.isNotEmpty) {
            userData['image'] = profileImageUrl;
          }
        } catch (e) {
          log('Error uploading profile image: $e', name: 'EditProfilePage');
          SnackbarService().showSnackBar('failedToUploadProfilePicture'.tr(),
              type: SnackbarType.error);
          ref.read(loadingProvider.notifier).stopLoading();
          return;
        }
      }

      // Update local storage with complete user data
      final updatedUser = currentUser.copyWith(
        name: newName,
        email: newEmail,
        address: newAddress,
        area: newArea,
        pincode: int.parse(newPincode),
        dob: parsedDob,
        whatsappNumber: whatsappNumber,
        gender: selectedGender,
        countryCode: selectedCountryCode,
        country: selectedCountryName,
        stateCode: selectedStateCode,
        state: selectedStateName,
        districtCode: selectedDistrictCode,
        district: selectedDistrictName,
        image: profileImageUrl ?? currentUser.image,
      );

      final result = await ref.read(updateUserProfileProvider(userData).future);

      ref.read(loadingProvider.notifier).stopLoading();

      if (result.user != null) {
        log('Profile updated successfully', name: 'EditProfilePage');

        // Update local secure storage with complete user data
        await ref.read(secureStorageServiceProvider).saveUserData(updatedUser);

        SnackbarService().showSnackBar('profileUpdated'.tr());

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        SnackbarService().showSnackBar(
            result.error ?? 'failedToUpdateProfile'.tr(),
            type: SnackbarType.error);
      }
    } catch (e) {
      ref.read(loadingProvider.notifier).stopLoading();
      SnackbarService().showSnackBar('Error: $e');
      log('Error during profile update: $e', name: 'EditProfilePage');
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
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
                    const SizedBox(height: 30),
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
                                    : existingImageUrl != null &&
                                            existingImageUrl!.isNotEmpty
                                        ? ClipOval(
                                            child: Image.network(
                                              existingImageUrl!,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const Icon(Icons.person,
                                                    color: kGreyDark, size: 50);
                                              },
                                            ),
                                          )
                                        : const Icon(Icons.person,
                                            color: kGreyDark, size: 50),
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
                      child: Text("fullName".tr(), style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 150,
                      child: InputField(
                        key: _fieldKeys['name'],
                        type: CustomFieldType.text,
                        hint: "enterFullName".tr(),
                        controller: nameController,
                        validator: (v) => v!.isEmpty ? "required".tr() : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 300,
                      child: Text("address".tr(), style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 350,
                      child: InputField(
                        key: _fieldKeys['address'],
                        type: CustomFieldType.text,
                        hint: "enterAddress".tr(),
                        controller: addressController,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 400,
                      child: Text("area".tr(), style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 450,
                      child: InputField(
                        key: _fieldKeys['area'],
                        type: CustomFieldType.text,
                        hint: "enterArea".tr(),
                        controller: areaController,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 500,
                      child: Text("country".tr(), style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 550,
                      child: Consumer(
                        builder: (context, ref, _) {
                          final countriesAsync =
                              ref.watch(getAllCountriesProvider);
                          return countriesAsync.when(
                            data: (countries) {
                              final countryMap = {
                                for (var c in countries)
                                  c.iso2 ?? '': c.name ?? ''
                              };
                              return GestureDetector(
                                onTap: () {
                                  ModalSheet<String>(
                                    context: context,
                                    title: 'selectCountry'.tr(),
                                    items: countries
                                        .map((c) => c.iso2 ?? '')
                                        .where((code) => code.isNotEmpty)
                                        .toList(),
                                    itemLabel: (code) =>
                                        countryMap[code] ?? code,
                                    onItemSelected: (code) {
                                      setState(() {
                                        selectedCountryCode = code;
                                        selectedCountryName = countryMap[code];
                                        selectedStateCode = null;
                                        selectedStateName = null;
                                        selectedDistrictCode = null;
                                        selectedDistrictName = null;
                                      });
                                    },
                                    searchFilter: (code, query) {
                                      final name = countryMap[code] ?? '';
                                      return name
                                              .toLowerCase()
                                              .contains(query.toLowerCase()) ||
                                          code
                                              .toLowerCase()
                                              .contains(query.toLowerCase());
                                    },
                                  ).show();
                                },
                                child: Container(
                                  height: 52,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        selectedCountryName ??
                                            'selectCountry'.tr(),
                                        style: TextStyle(
                                          color: selectedCountryName == null
                                              ? Colors.grey.shade600
                                              : Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loading: () => Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: LoadingAnimation(),
                                ),
                              ),
                            ),
                            error: (err, stack) => Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Center(
                                child: Text('Error: $err',
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 12)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (selectedCountryCode != null)
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromLeft,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 600,
                        child: Text("state".tr(), style: kSmallTitleR),
                      ),
                    if (selectedCountryCode != null) const SizedBox(height: 6),
                    if (selectedCountryCode != null)
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 650,
                        child: Consumer(
                          builder: (context, ref, _) {
                            final statesAsync = ref.watch(
                                getStatesByCountryProvider(
                                    selectedCountryCode!));
                            return statesAsync.when(
                              data: (states) {
                                final stateMap = {
                                  for (var s in states)
                                    s.stateCode.toString(): s.name ?? ''
                                };
                                return GestureDetector(
                                  onTap: () {
                                    ModalSheet<String>(
                                      context: context,
                                      title: 'selectState'.tr(),
                                      items: states
                                          .map((s) => s.stateCode.toString())
                                          .toList(),
                                      itemLabel: (code) =>
                                          stateMap[code] ?? code,
                                      onItemSelected: (code) {
                                        setState(() {
                                          selectedStateCode = code;
                                          selectedStateName = stateMap[code];
                                          selectedDistrictCode = null;
                                          selectedDistrictName = null;
                                        });
                                      },
                                      searchFilter: (code, query) {
                                        final name = stateMap[code] ?? '';
                                        return name.toLowerCase().contains(
                                                query.toLowerCase()) ||
                                            code
                                                .toLowerCase()
                                                .contains(query.toLowerCase());
                                      },
                                    ).show();
                                  },
                                  child: Container(
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedStateName ??
                                              'selectState'.tr(),
                                          style: TextStyle(
                                            color: selectedStateName == null
                                                ? Colors.grey.shade600
                                                : Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              loading: () => Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: LoadingAnimation(),
                                  ),
                                ),
                              ),
                              error: (err, stack) => Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Center(
                                  child: Text('Error: $err',
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (selectedCountryCode != null) const SizedBox(height: 18),
                    if (selectedStateCode != null)
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromLeft,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 700,
                        child: Text("district".tr(), style: kSmallTitleR),
                      ),
                    if (selectedStateCode != null) const SizedBox(height: 6),
                    if (selectedStateCode != null)
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 750,
                        child: Consumer(
                          builder: (context, ref, _) {
                            final citiesAsync = ref.watch(
                                getDistrictsByStateProvider(
                                    selectedCountryCode!, selectedStateCode!));
                            return citiesAsync.when(
                              data: (cities) {
                                final districtMap = {
                                  for (var c in cities)
                                    c.id.toString(): c.name ?? ''
                                };
                                return GestureDetector(
                                  onTap: () {
                                    ModalSheet<String>(
                                      context: context,
                                      title: 'selectDistrict'.tr(),
                                      items: cities
                                          .map((c) => c.id.toString())
                                          .toList(),
                                      itemLabel: (id) => districtMap[id] ?? id,
                                      onItemSelected: (id) {
                                        setState(() {
                                          selectedDistrictCode = id;
                                          selectedDistrictName =
                                              districtMap[id];
                                        });
                                      },
                                      searchFilter: (id, query) {
                                        final name = districtMap[id] ?? '';
                                        return name
                                            .toLowerCase()
                                            .contains(query.toLowerCase());
                                      },
                                    ).show();
                                  },
                                  child: Container(
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          selectedDistrictName ??
                                              'selectDistrict'.tr(),
                                          style: TextStyle(
                                            color: selectedDistrictName == null
                                                ? Colors.grey.shade600
                                                : Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: Colors.grey.shade600,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              loading: () => Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: LoadingAnimation(),
                                  ),
                                ),
                              ),
                              error: (err, stack) => Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Center(
                                  child: Text('Error: $err',
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12)),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (selectedStateCode != null) const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 800,
                      child: Text("pincode".tr(), style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 850,
                      child: InputField(
                        key: _fieldKeys['pincode'],
                        type: CustomFieldType.text,
                        hint: "enterPincode".tr(),
                        controller: pincodeController,
                        validator: (v) => v!.isEmpty ? "required".tr() : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 1000,
                      child: Text("dateOfBirth".tr(), style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 1050,
                      child: InputField(
                        key: _fieldKeys['dob'],
                        type: CustomFieldType.date,
                        hint: "ddmmyyyy".tr(),
                        controller: dobController,
                        validator: (v) =>
                            v?.isEmpty ?? true ? "required".tr() : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 1100,
                      child: Text("gender".tr(), style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 1150,
                      child: AnimatedDropdown<String>(
                        key: _fieldKeys['gender'],
                        hint: "selectGender".tr(),
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
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 1200,
                      child: Text("whatsappNumber".tr(), style: kSmallTitleR),
                    ),
                    const SizedBox(height: 12),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 1250,
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
                          Expanded(
                            child: Text(
                              "sameAsPhoneNumber".tr(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isSameAsPhone) const SizedBox(height: 12),
                    if (!isSameAsPhone)
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 1300,
                        child: Stack(
                          children: [
                            IntlPhoneField(
                              key: _fieldKeys['whatsapp'],
                              validator: (phone) {
                                if (!isSameAsPhone) {
                                  if (phone == null ||
                                      phone.number.isEmpty ||
                                      phone.number.length < 9) {
                                    return 'pleaseEnterValidPhoneNumber'.tr();
                                  }
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
                              controller: whatsappController,
                              disableLengthCheck: true,
                              showCountryFlag: true,
                              cursorColor: kBlack,
                              decoration: InputDecoration(
                                fillColor: kWhite,
                                hintText: 'enterWhatsappNumber'.tr(),
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
                              // onCountryChanged: (value) {
                              //   whatsappCountryCode = value.dialCode;
                              // },
                              initialCountryCode: 'IN',
                              flagsButtonPadding:
                                  const EdgeInsets.only(left: 10, right: 10.0),
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
                    const SizedBox(height: 30),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeScaleUp,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 1400,
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: primaryButton(
                          label: "save".tr(),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _handleSaveProfile();
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
      ),
    );
  }
}
