import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';

Future<dynamic> pickMedia({
  required BuildContext context,
  bool allowMultiple = false,
  bool enableCrop = false,
  CropAspectRatio? cropRatio,
  bool showDocument = true,
}) async {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _PickSourceDialog(
      allowMultiple: allowMultiple,
      enableCrop: enableCrop,
      cropRatio: cropRatio,
      showDocument: showDocument,
    ),
  );
}

class _PickSourceDialog extends StatelessWidget {
  final bool allowMultiple;
  final bool enableCrop;
  final CropAspectRatio? cropRatio;
  final bool showDocument;

  const _PickSourceDialog({
    required this.allowMultiple,
    required this.enableCrop,
    required this.cropRatio,
    required this.showDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        runSpacing: 15,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _option(
            context,
            "camera".tr(),
            Icons.camera_alt_rounded,
            () => _pickFromCamera(context),
          ),
          _option(
            context,
            "gallery".tr(),
            Icons.photo_library_rounded,
            () => _pickFromGallery(context),
          ),
          if (showDocument)
            _option(
              context,
              "document".tr(),
              Icons.insert_drive_file_rounded,
              () => _pickDocument(context),
            ),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }

  // -------------------------
  // PICK FROM CAMERA
  // -------------------------
  Future<void> _pickFromCamera(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? rawImage = await picker.pickImage(source: ImageSource.camera);

    if (rawImage == null) {
      Navigator.pop(context, null);
      return;
    }

    if (enableCrop) {
      final cropped = await _cropImage(rawImage.path);
      Navigator.pop(context, cropped);
      return;
    }

    Navigator.pop(context, rawImage);
  }

  // -------------------------
  // PICK FROM GALLERY
  // -------------------------
  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();

    if (allowMultiple) {
      final List<XFile> images = await picker.pickMultiImage();

      if (enableCrop) {
        final List<XFile> croppedImages = [];

        for (final img in images) {
          final cropped = await _cropImage(img.path);
          if (cropped != null) croppedImages.add(cropped);
        }

        Navigator.pop(context, croppedImages);
        return;
      }

      Navigator.pop(context, images);
      return;
    }

    final XFile? rawImage = await picker.pickImage(source: ImageSource.gallery);

    if (rawImage == null) {
      Navigator.pop(context, null);
      return;
    }

    if (enableCrop) {
      final cropped = await _cropImage(rawImage.path);
      Navigator.pop(context, cropped);
      return;
    }

    Navigator.pop(context, rawImage);
  }

  // -------------------------
  // PICK DOCUMENT
  // -------------------------
  Future<void> _pickDocument(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: allowMultiple,
      type: FileType.custom,
      allowedExtensions: [
        "pdf",
        "doc",
        "docx",
        "xls",
        "xlsx",
        "png",
        "jpg",
        "jpeg"
      ],
    );
    Navigator.pop(context, result);
  }

  // -------------------------
  // CROP IMAGE FUNCTION
  // -------------------------
  Future<XFile?> _cropImage(String path) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: path,
      aspectRatio: cropRatio,
      compressQuality: 95,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: "cropImage".tr(),
          hideBottomControls: false,
          lockAspectRatio: cropRatio != null,
        ),
        IOSUiSettings(title: "cropImage".tr()),
      ],
    );

    if (croppedFile == null) return null;

    return XFile(croppedFile.path);
  }
}
