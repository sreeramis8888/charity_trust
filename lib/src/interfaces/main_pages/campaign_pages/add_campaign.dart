import 'dart:io';
import 'dart:developer';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/utils/media_picker.dart';
import 'package:Annujoom/src/data/providers/loading_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/data/services/image_upload.dart';
import 'package:Annujoom/src/data/providers/campaigns_provider.dart';
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

class AddCampaignPage extends ConsumerStatefulWidget {
  const AddCampaignPage({super.key});

  @override
  ConsumerState<AddCampaignPage> createState() => _AddCampaignPageState();
}

class _AddCampaignPageState extends ConsumerState<AddCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final FocusNode _unfocusNode = FocusNode();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final targetAmountController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  String? selectedCategory;
  XFile? coverImage;

  final List<String> campaignCategories = [
    'General Campaign',
    'General Funding',
    'Zakat',
    'Orphan',
    'Widow',
    'Ghusl Mayyit',
  ];

  final Map<String, GlobalKey> _fieldKeys = {
    'category': GlobalKey(),
    'title': GlobalKey(),
    'description': GlobalKey(),
    'coverImage': GlobalKey(),
    'startDate': GlobalKey(),
    'endDate': GlobalKey(),
    'targetAmount': GlobalKey(),
  };

  bool _requiresTargetAmount() {
    return selectedCategory == 'General Campaign' ||
        selectedCategory == 'General Funding';
  }

  void _scrollToFirstError() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        String? firstErrorKey;

        if (selectedCategory == null || selectedCategory!.isEmpty) {
          firstErrorKey = 'category';
        } else if (titleController.text.trim().isEmpty) {
          firstErrorKey = 'title';
        } else if (descriptionController.text.trim().isEmpty) {
          firstErrorKey = 'description';
        } else if (coverImage == null) {
          firstErrorKey = 'coverImage';
        } else if (startDateController.text.trim().isEmpty) {
          firstErrorKey = 'startDate';
        } else if (endDateController.text.trim().isEmpty) {
          firstErrorKey = 'endDate';
        } else if (_requiresTargetAmount() &&
            targetAmountController.text.trim().isEmpty) {
          firstErrorKey = 'targetAmount';
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
    titleController.dispose();
    descriptionController.dispose();
    targetAmountController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    FocusScope.of(context).requestFocus(_unfocusNode);

    final result = await pickMedia(
      context: context,
      enableCrop: true,
      cropRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      showDocument: false,
    );

    if (!mounted) return;

    if (result != null && result is XFile) {
      setState(() {
        coverImage = result;
      });
    }
    if (mounted) {
      FocusScope.of(context).requestFocus(_unfocusNode);
    }
  }

  String _formatDateForApi(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}';
      }
    } catch (e) {
      log('Error formatting date: $e', name: 'AddCampaignPage');
    }
    return dateStr;
  }

  Future<void> _handleCreateCampaign() async {
    try {
      ref.read(loadingProvider.notifier).startLoading();

      String? coverImageUrl;
      if (coverImage != null) {
        try {
          coverImageUrl = await imageUpload(coverImage!.path);
          log('Cover image uploaded: $coverImageUrl', name: 'AddCampaignPage');
        } catch (e) {
          if (mounted) {
            ref.read(loadingProvider.notifier).stopLoading();
          }
          SnackbarService().showSnackBar('Failed to upload cover image',
              type: SnackbarType.error);
          log('Error uploading cover image: $e', name: 'AddCampaignPage');
          return;
        }
      }

      final secureStorage = ref.read(secureStorageServiceProvider);
      final user = await secureStorage.getUserData();
      final userRole = user?.role ?? '';
      final approvalStatus = userRole == 'president' ? 'approved' : 'pending';

      final campaignData = <String, dynamic>{
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'category': selectedCategory,
        'cover_image': coverImageUrl,
        'start_date': _formatDateForApi(startDateController.text.trim()),
        'target_date': _formatDateForApi(endDateController.text.trim()),
        'target_amount': int.tryParse(targetAmountController.text.trim()) ?? 0,
        'approval_status': approvalStatus,
      };

      final result = await ref.read(
        createNewCampaignProvider(campaignData).future,
      );

      if (!mounted) return;

      ref.read(loadingProvider.notifier).stopLoading();

      if (result != null) {
        log('Campaign created successfully', name: 'AddCampaignPage');
        SnackbarService().showSnackBar('Campaign created successfully');

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        SnackbarService().showSnackBar('Failed to create campaign',
            type: SnackbarType.error);
      }
    } catch (e) {
      if (mounted) {
        ref.read(loadingProvider.notifier).stopLoading();
      }
      SnackbarService().showSnackBar('Error: $e');
      log('Error during campaign creation: $e', name: 'AddCampaignPage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 20,
          ),
        ),
        title: Text('New Campaign', style: kBodyTitleM),
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
                    const SizedBox(height: 20),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 100,
                      child: Text("Type *", style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 150,
                      child: AnimatedDropdown<String>(
                        key: _fieldKeys['category'],
                        hint: "Select",
                        value: selectedCategory,
                        items: campaignCategories,
                        itemLabel: (value) => value,
                        onChanged: (v) {
                          setState(() {
                            selectedCategory = v;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 200,
                      child: Text("Campaign Name *", style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 250,
                      child: InputField(
                        key: _fieldKeys['title'],
                        type: CustomFieldType.text,
                        hint: "Enter campaign name",
                        controller: titleController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 300,
                      child: Text("Description *", style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 350,
                      child: InputField(
                        key: _fieldKeys['description'],
                        type: CustomFieldType.text,
                        hint: "Enter description",
                        controller: descriptionController,
                        maxLines: 4,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 400,
                      child: Text("Cover Image *", style: kSmallTitleR),
                    ),
                    const SizedBox(height: 4),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 450,
                      child: Text(
                        "Image (JPG/PNG) - Recommended size: 400x400",
                        style: kSmallerTitleR.copyWith(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 500,
                      child: FormField<void>(
                        key: _fieldKeys['coverImage'],
                        validator: (_) {
                          if (coverImage == null) {
                            return 'Required';
                          }
                          return null;
                        },
                        builder: (field) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: _pickCoverImage,
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
                                        coverImage != null
                                            ? coverImage!.name
                                            : "Upload",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: coverImage != null
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
                                padding:
                                    const EdgeInsets.only(top: 4.0, left: 4.0),
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
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 550,
                      child: Text("Start Date *", style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 600,
                      child: InputField(
                        key: _fieldKeys['startDate'],
                        type: CustomFieldType.date,
                        hint: "dd/mm/yyyy",
                        controller: startDateController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                    ),
                    const SizedBox(height: 18),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromLeft,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 650,
                      child: Text("End Date *", style: kSmallTitleR),
                    ),
                    const SizedBox(height: 6),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeSlideInFromBottom,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 700,
                      child: InputField(
                        key: _fieldKeys['endDate'],
                        type: CustomFieldType.date,
                        hint: "dd/mm/yyyy",
                        controller: endDateController,
                        validator: (v) => v!.isEmpty ? "Required" : null,
                      ),
                    ),
                    if (_requiresTargetAmount()) const SizedBox(height: 18),
                    if (_requiresTargetAmount())
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromLeft,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 750,
                        child: Text("Target Amount *", style: kSmallTitleR),
                      ),
                    if (_requiresTargetAmount()) const SizedBox(height: 6),
                    if (_requiresTargetAmount())
                      anim.AnimatedWidgetWrapper(
                        animationType: anim.AnimationType.fadeSlideInFromBottom,
                        duration: anim.AnimationDuration.normal,
                        delayMilliseconds: 800,
                        child: InputField(
                          key: _fieldKeys['targetAmount'],
                          type: CustomFieldType.number,
                          hint: "Enter target amount",
                          controller: targetAmountController,
                          validator: (v) {
                            if (_requiresTargetAmount() && v!.isEmpty) {
                              return "Required";
                            }
                            return null;
                          },
                        ),
                      ),
                    const SizedBox(height: 30),
                    anim.AnimatedWidgetWrapper(
                      animationType: anim.AnimationType.fadeScaleUp,
                      duration: anim.AnimationDuration.normal,
                      delayMilliseconds: 850,
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: primaryButton(
                          label: "Submit",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _handleCreateCampaign();
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
