import 'dart:io';
import 'dart:developer';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/utils/media_picker.dart';
import 'package:Annujoom/src/data/providers/loading_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/data/services/image_upload.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/data/providers/location_provider.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:Annujoom/src/interfaces/components/dropdown.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class CreateUserPage extends ConsumerStatefulWidget {
  const CreateUserPage({super.key});

  @override
  ConsumerState<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends ConsumerState<CreateUserPage> {
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

  String? selectedCountryCode;
  String? selectedStateCode;
  String? selectedDistrictCode;
  String? selectedGender;
  XFile? profileImage;
  XFile? panCardImage;

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
  };

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
  }

  Future<void> _handleCreateUser() async {
    try {
      ref.read(loadingProvider.notifier).startLoading();

      String? profilePictureUrl;
      if (profileImage != null) {
        try {
          profilePictureUrl = await imageUpload(profileImage!.path);
        } catch (e) {
          if (mounted) {
            ref.read(loadingProvider.notifier).stopLoading();
          }
          SnackbarService().showSnackBar('Failed to upload profile picture');
          return;
        }
      }

      String? panCardUrl;
      if (panCardImage != null) {
        try {
          panCardUrl = await imageUpload(panCardImage!.path);
        } catch (e) {
          if (mounted) {
            ref.read(loadingProvider.notifier).stopLoading();
          }
          SnackbarService().showSnackBar('Failed to upload PAN card');
          return;
        }
      }

      String formattedDob = dobController.text.trim();
      if (formattedDob.isNotEmpty) {
        try {
          final parts = formattedDob.split('/');
          if (parts.length == 3) {
            formattedDob = '${parts[2]}-${parts[1]}-${parts[0]}';
          }
        } catch (e) {
          log('Error formatting date: $e', name: 'CreateUserPage');
        }
      }

      // Get current user ID
      final currentUser =
          await ref.read(secureStorageServiceProvider).getUserData();
      final currentUserId = currentUser?.id;

      if (currentUserId == null) {
        if (mounted) {
          ref.read(loadingProvider.notifier).stopLoading();
        }
        SnackbarService().showSnackBar('Error: Current user ID not found');
        return;
      }

      final userData = <String, dynamic>{
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': mobileController.text.trim(),
        'address': addressController.text.trim(),
        'area': areaController.text.trim(),
        'country': selectedCountryCode,
        'state': selectedStateCode,
        'district': selectedDistrictCode,
        'pincode': pincodeController.text.trim(),
        'pan_number': panNumberController.text.trim(),
        'pan_copy': panCardUrl,
        'image': profilePictureUrl,
        'gender': selectedGender,
        'dob': formattedDob,
        'recommended_by': 'trustee',
        'under_trustee': currentUserId,
      };

      final result = await ref.read(createNewUserProvider(userData).future);

      if (!mounted) return;
      ref.read(loadingProvider.notifier).stopLoading();

      if (result != null) {
        SnackbarService().showSnackBar('User created successfully');
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        SnackbarService()
            .showSnackBar('Failed to create user', type: SnackbarType.error);
      }
    } catch (e) {
      if (mounted) {
        ref.read(loadingProvider.notifier).stopLoading();
      }
      SnackbarService().showSnackBar('Error: $e');
      log('Error during user creation: $e', name: 'CreateUserPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Add Member', style: kBodyTitleM),
      ),
      body: _buildForm(),
    );
  }

  Widget _buildForm() {
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
                  _buildProfilePicture(),
                  const SizedBox(height: 30),
                  _buildNameField(),
                  const SizedBox(height: 18),
                  _buildMobileField(),
                  const SizedBox(height: 18),
                  _buildEmailField(),
                  const SizedBox(height: 18),
                  _buildAddressField(),
                  const SizedBox(height: 18),
                  _buildAreaField(),
                  const SizedBox(height: 18),
                  _buildCountryField(),
                  const SizedBox(height: 18),
                  _buildStateField(),
                  const SizedBox(height: 18),
                  _buildDistrictField(),
                  const SizedBox(height: 18),
                  _buildPincodeField(),
                  const SizedBox(height: 20),
                  _buildPanNumberField(),
                  const SizedBox(height: 20),
                  _buildPanCardField(),
                  const SizedBox(height: 20),
                  _buildDobField(),
                  const SizedBox(height: 20),
                  _buildGenderField(),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return anim.AnimatedWidgetWrapper(
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
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildMobileField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              if (phone == null || phone.number.isEmpty) {
                return 'Required';
              }
              if (phone.number.length > 10) {
                return 'Phone number cannot exceed 10 digits';
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
              hintText: 'Enter phone number',
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
            flagsButtonPadding: const EdgeInsets.only(left: 10, right: 10.0),
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
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            hint: "Enter email",
            controller: emailController,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromLeft,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 400,
          child: Text("Address", style: kSmallTitleR),
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
      ],
    );
  }

  Widget _buildAreaField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildCountryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              final countriesAsync = ref.watch(getAllCountriesProvider);
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
      ],
    );
  }

  Widget _buildStateField() {
    if (selectedCountryCode == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromLeft,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 700,
          child: Text("State *", style: kSmallTitleR),
        ),
        const SizedBox(height: 6),
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 750,
          child: Consumer(
            builder: (context, ref, _) {
              final statesAsync =
                  ref.watch(getStatesByCountryProvider(selectedCountryCode!));
              return statesAsync.when(
                data: (states) {
                  return AnimatedDropdown<String>(
                    key: _fieldKeys['state'],
                    hint: "Select state",
                    value: selectedStateCode,
                    items: states.map((s) => s.stateCode.toString()).toList(),
                    itemLabel: (code) {
                      try {
                        return states
                                .firstWhere(
                                    (s) => s.stateCode.toString() == code)
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
      ],
    );
  }

  Widget _buildDistrictField() {
    if (selectedStateCode == null) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromLeft,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 800,
          child: Text("District *", style: kSmallTitleR),
        ),
        const SizedBox(height: 6),
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 850,
          child: Consumer(
            builder: (context, ref, _) {
              final citiesAsync = ref.watch(getDistrictsByStateProvider(
                  selectedCountryCode!, selectedStateCode!));
              return citiesAsync.when(
                data: (cities) {
                  return AnimatedDropdown<String>(
                    key: _fieldKeys['district'],
                    hint: "Select district / city",
                    value: selectedDistrictCode,
                    items: cities.map((c) => c.id.toString()).toList(),
                    itemLabel: (id) {
                      try {
                        return cities
                                .firstWhere((c) => c.id.toString() == id)
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
      ],
    );
  }

  Widget _buildPincodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildPanNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildPanCardField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                          color: field.hasError ? Colors.red : kBorder),
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
      ],
    );
  }

  Widget _buildDobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildSubmitButton() {
    return anim.AnimatedWidgetWrapper(
      animationType: anim.AnimationType.fadeScaleUp,
      duration: anim.AnimationDuration.normal,
      delayMilliseconds: 1450,
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: primaryButton(
          label: "Create User",
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _handleCreateUser();
            }
          },
          isLoading: ref.watch(loadingProvider),
        ),
      ),
    );
  }
}
