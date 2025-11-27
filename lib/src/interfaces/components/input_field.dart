import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum CustomFieldType {
  text,
  date,
  document,
}

class InputField extends StatelessWidget {
  final CustomFieldType type;
  final String hint;
  final TextEditingController controller;
  final void Function()? onUpload;
  final void Function(DateTime)? onDateSelected;
  final bool readOnly;
  final FormFieldValidator<String>? validator;

  const InputField({
    super.key,
    required this.type,
    required this.hint,
    required this.controller,
    this.onUpload,
    this.onDateSelected,
    this.readOnly = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: type != CustomFieldType.text,
      validator: validator,
      style: kBodyTitleR,
      cursorColor: kPrimaryColor,

      onTap: () async {
        if (type == CustomFieldType.date) {
          final picked = await showDatePicker(
            context: context,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            initialDate: DateTime.now(),
          );

          if (picked != null) {
            controller.text = DateFormat('dd/MM/yyyy').format(picked);
            onDateSelected?.call(picked);
          }
        }

        if (type == CustomFieldType.document) {
          onUpload?.call(); // You will pass doc-picker logic from parent
        }
      },

      decoration: InputDecoration(
        filled: true,
        fillColor: kInputFieldcolor,
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF979797),
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),

        // Icons shown based on ENUM
        suffixIcon: type == CustomFieldType.date
            ? const Icon(Icons.calendar_today, size: 20, color: Colors.grey)
            : type == CustomFieldType.document
                ? const Icon(Icons.cloud_upload_outlined,
                    size: 22, color: Colors.grey)
                : null,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: kInputFieldcolor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: kInputFieldcolor),
        ),
      ),
    );
  }
}
