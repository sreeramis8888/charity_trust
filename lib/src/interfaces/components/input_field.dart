import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum CustomFieldType {
  text,
  number,
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
  final int maxLines;
  final bool allowDecimal; // ✅ For number input
  final FormFieldValidator<String>? validator;

  const InputField({
    super.key,
    required this.type,
    required this.hint,
    required this.controller,
    this.onUpload,
    this.onDateSelected,
    this.readOnly = false,
    this.maxLines = 1,
    this.allowDecimal = false, // ✅ Default = only integers
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final isText = type == CustomFieldType.text;
    final isNumber = type == CustomFieldType.number;

    return TextFormField(
      controller: controller,
      maxLines: isText ? maxLines : 1,
      readOnly: readOnly ||
          type == CustomFieldType.date ||
          type == CustomFieldType.document,
      keyboardType: isNumber
          ? TextInputType.numberWithOptions(decimal: allowDecimal)
          : TextInputType.text,
      inputFormatters: isNumber
          ? [
              FilteringTextInputFormatter.allow(
                allowDecimal ? RegExp(r'^\d*\.?\d*$') : RegExp(r'\d+'),
              ),
            ]
          : null,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: kBodyTitleR,
      cursorColor: kPrimaryColor,
      onTap: () async {
        if (type == CustomFieldType.date) {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                ),
                child: child!,
              );
            },
          );

          if (picked != null) {
            controller.text = DateFormat('dd/MM/yyyy').format(picked);
            onDateSelected?.call(picked);
          }
        }

        if (type == CustomFieldType.document) {
          onUpload?.call();
        }
      },
      decoration: InputDecoration(
        fillColor: kWhite,
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF9B9B9B),
          fontSize: 14,
        ),
        errorStyle: const TextStyle(height: 0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        suffixIcon: type == CustomFieldType.date
            ? const Icon(Icons.calendar_today, size: 20, color: Colors.grey)
            : type == CustomFieldType.document
                ? const Icon(Icons.cloud_upload_outlined,
                    size: 22, color: Colors.grey)
                : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
