import 'dart:io';
import 'dart:developer';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/utils/media_picker.dart';
import 'package:Annujoom/src/data/providers/loading_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/data/services/secure_storage_service.dart';
import 'package:Annujoom/src/data/providers/user_provider.dart';
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/animations/index.dart' as anim;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

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
  final dobController = TextEditingController();
  final recommendedByController = TextEditingController();

  XFile? profileImage;

  final Map<String, GlobalKey> _fieldKeys = {
    'name': GlobalKey(),
    'email': GlobalKey(),
    'address': GlobalKey(),
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
        } else if (emailController.text.trim().isEmpty) {
          firstErrorKey = 'email';
        } else if (addressController.text.trim().isEmpty) {
          firstErrorKey = 'address';
        } else if (dobController.text.trim().isEmpty) {
          firstErrorKey = 'dob';
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
        // Format DateTime to dd/MM/yyyy
        if (userData.dob != null) {
          dobController.text =
              '${userData.dob!.day.toString().padLeft(2, '0')}/${userData.dob!.month.toString().padLeft(2, '0')}/${userData.dob!.year}';
        }
        recommendedByController.text = userData.recommendedBy ?? '';
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
    dobController.dispose();
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

      if (parsedDob != currentUser.dob) {
        if (parsedDob != null) {
          userData['dob'] =
              '${parsedDob.year}-${parsedDob.month.toString().padLeft(2, '0')}-${parsedDob.day.toString().padLeft(2, '0')}';
        } else {
          userData['dob'] = null;
        }
      }

      // Update local storage with complete user data
      final updatedUser = currentUser.copyWith(
        name: newName,
        email: newEmail,
        address: newAddress,
        dob: parsedDob,
      );

      final result = await ref.read(updateUserProfileProvider(userData).future);

      ref.read(loadingProvider.notifier).stopLoading();

      if (result != null) {
        log('Profile updated successfully', name: 'EditProfilePage');

        // Update local secure storage with complete user data
        await ref.read(secureStorageServiceProvider).saveUserData(updatedUser);

        SnackbarService().showSnackBar('Profile updated successfully');

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        SnackbarService()
            .showSnackBar('Failed to update profile', type: SnackbarType.error);
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
                      child: Text("Full Name", style: kSmallTitleR),
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
                      child: Text("Email Address", style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 250,
                      child: InputField(
                        key: _fieldKeys['email'],
                        type: CustomFieldType.text,
                        hint: "Enter email address",
                        controller: emailController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 300,
                      child: Text("Address", style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 350,
                      child: InputField(
                        key: _fieldKeys['address'],
                        type: CustomFieldType.text,
                        hint: "Enter address",
                        controller: addressController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 400,
                      child: Text("Date of Birth", style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 450,
                      child: InputField(
                        key: _fieldKeys['dob'],
                        type: CustomFieldType.date,
                        hint: "dd/mm/yyyy",
                        controller: dobController,
                        validator: (v) =>
                            v?.isEmpty ?? true ? "Required" : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 500,
                      child: Text("Recommended By", style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 550,
                      child: InputField(
                        key: _fieldKeys['recommendedBy'],
                        type: CustomFieldType.text,
                        hint: "Recommended by",
                        controller: recommendedByController,
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(height: 30),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeScaleUp,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 600,
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: primaryButton(
                          label: "Save",
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
