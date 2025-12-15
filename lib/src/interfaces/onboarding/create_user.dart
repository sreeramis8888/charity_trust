import 'dart:io';
import 'dart:developer';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/models/user_model.dart';
import 'package:Annujoom/src/data/utils/media_picker.dart';
import 'package:Annujoom/src/data/utils/validators.dart';
import 'package:Annujoom/src/data/providers/loading_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/data/services/image_upload.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/data/providers/location_provider.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:Annujoom/src/interfaces/components/dropdown.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/modal_sheet.dart';
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
  final aadharNumberController = TextEditingController();
  final dobController = TextEditingController();

  String? selectedCountryCode;
  String? selectedCountryName;
  String? selectedStateCode;
  String? selectedStateName;
  String? selectedDistrictCode;
  String? selectedDistrictName;
  String? selectedGender;
  XFile? profileImage;

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
    'aadharNumber': GlobalKey(),
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
    aadharNumberController.dispose();
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
        'country': selectedCountryName ?? selectedCountryCode,
        'state': selectedStateName ?? selectedStateCode,
        'district': selectedDistrictName ?? selectedDistrictCode,
        'pincode': pincodeController.text.trim(),
        'aadhar_number': int.parse(aadharNumberController.text.trim()),
        'image': profilePictureUrl,
        'gender': selectedGender,
        'dob': formattedDob,
        'recommended_by': 'trustee',
        'under_trustee': currentUserId,
      };

      final result = await ref.read(createNewUserProvider(userData).future);

      if (!mounted) return;
      ref.read(loadingProvider.notifier).stopLoading();

      if (result.user != null) {
        SnackbarService().showSnackBar('User created successfully');
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        final errorMessage = result.error ?? 'Failed to create user';
        SnackbarService()
            .showSnackBar(errorMessage, type: SnackbarType.error);
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
                  _buildCountryField(),
                  const SizedBox(height: 18),
                  _buildStateField(),
                  if (selectedStateName != null) const SizedBox(height: 18),
                  _buildDistrictField(),
                  if (selectedDistrictName != null) const SizedBox(height: 18),
                  _buildAreaField(),
                  const SizedBox(height: 18),
                  _buildPincodeField(),
                  const SizedBox(height: 20),
                  _buildAadharNumberField(),
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
          child: Text("Email Address *", style: kSmallTitleR),
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
            validator: Validators.validateEmail,
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
                  final countryMap = {
                    for (var c in countries) c.iso2 ?? '': c.name ?? ''
                  };
                  return GestureDetector(
                    onTap: () {
                      ModalSheet<String>(
                        context: context,
                        title: 'Select Country',
                        items: countries
                            .map((c) => c.iso2 ?? '')
                            .where((code) => code.isNotEmpty)
                            .toList(),
                        itemLabel: (code) => countryMap[code] ?? code,
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
                              code.toLowerCase().contains(query.toLowerCase());
                        },
                      ).show();
                    },
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedCountryName ?? 'Select country',
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
                      child: CircularProgressIndicator(strokeWidth: 2),
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
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ),
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
                  final stateMap = {
                    for (var s in states) s.stateCode.toString(): s.name ?? ''
                  };
                  return GestureDetector(
                    onTap: () {
                      ModalSheet<String>(
                        context: context,
                        title: 'Select State',
                        items:
                            states.map((s) => s.stateCode.toString()).toList(),
                        itemLabel: (code) => stateMap[code] ?? code,
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
                          return name
                                  .toLowerCase()
                                  .contains(query.toLowerCase()) ||
                              code.toLowerCase().contains(query.toLowerCase());
                        },
                      ).show();
                    },
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedStateName ?? 'Select state',
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
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ),
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
                  final districtMap = {
                    for (var c in cities) c.id.toString(): c.name ?? ''
                  };
                  return GestureDetector(
                    onTap: () {
                      ModalSheet<String>(
                        context: context,
                        title: 'Select District',
                        items: cities.map((c) => c.id.toString()).toList(),
                        itemLabel: (id) => districtMap[id] ?? id,
                        onItemSelected: (id) {
                          setState(() {
                            selectedDistrictCode = id;
                            selectedDistrictName = districtMap[id];
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
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            selectedDistrictName ?? 'Select district / city',
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
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
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
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12)),
                  ),
                ),
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
          child: Text("Pincode *", style: kSmallTitleR),
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
            validator: (v) => v!.isEmpty ? "Required" : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAadharNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromLeft,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 1000,
          child: Text("Aadhar Number *", style: kSmallTitleR),
        ),
        const SizedBox(height: 6),
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 1050,
          child: InputField(
            key: _fieldKeys['aadharNumber'],
            type: CustomFieldType.number,
            hint: "Enter Aadhar number",
            controller: aadharNumberController,
            validator: Validators.validateAadharNumber,
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
          delayMilliseconds: 1100,
          child: Text("Date of Birth *", style: kSmallTitleR),
        ),
        const SizedBox(height: 6),
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 1150,
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
          delayMilliseconds: 1200,
          child: Text("Gender *", style: kSmallTitleR),
        ),
        const SizedBox(height: 6),
        anim.AnimatedWidgetWrapper(
          animationType: anim.AnimationType.fadeSlideInFromBottom,
          duration: anim.AnimationDuration.normal,
          delayMilliseconds: 1250,
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
      delayMilliseconds: 1300,
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
