import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

enum CustomFieldType {
  text,
  number,
  date,
  document,
  email
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    if (text.isEmpty) {
      return newValue;
    }

    // Extract only digits from the input
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    // Limit to 8 digits (ddmmyyyy)
    if (digitsOnly.length > 8) {
      return oldValue;
    }

    // Format with hyphens
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i == 2 || i == 4) {
        formatted += '-';
      }
      formatted += digitsOnly[i];
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class InputField extends StatelessWidget {
  final CustomFieldType type;
  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final void Function()? onUpload;
  final void Function(DateTime)? onDateSelected;
  final bool readOnly;
  final int maxLines;
  final bool allowDecimal;
  final FormFieldValidator<String>? validator;

  const InputField({
    super.key,
    required this.type,
    required this.hint,
    required this.controller,
    this.focusNode,
    this.onUpload,
    this.onDateSelected,
    this.readOnly = false,
    this.maxLines = 1,
    this.allowDecimal = false,
    this.validator,
  });

  DateTime? _parseDate(String dateStr) {
    try {
      // Remove hyphens and parse dd-mm-yyyy format
      final cleanStr = dateStr.replaceAll('-', '');
      if (cleanStr.length != 8) return null;

      final day = int.parse(cleanStr.substring(0, 2));
      final month = int.parse(cleanStr.substring(2, 4));
      final year = int.parse(cleanStr.substring(4, 8));

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final parsed = _parseDate(controller.text);
    final initialDate = parsed ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
      onDateSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isText = type == CustomFieldType.text;
    final isNumber = type == CustomFieldType.number;
    final isDate = type == CustomFieldType.date;
    final isEmail = type == CustomFieldType.email;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: isText ? maxLines : 1,
      readOnly: readOnly || type == CustomFieldType.document,
      keyboardType: isNumber
          ? TextInputType.numberWithOptions(decimal: allowDecimal)
          : isDate
              ? TextInputType.number
              : isEmail
                  ? TextInputType.emailAddress
                  : TextInputType.text,
      inputFormatters: isNumber
          ? [
              FilteringTextInputFormatter.allow(
                allowDecimal ? RegExp(r'^\d*\.?\d*$') : RegExp(r'\d+'),
              ),
            ]
          : isDate
              ? [_DateInputFormatter()]
              : null,
      validator: validator ??
          (isEmail
              ? (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }
                  return null;
                }
              : null),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: kBodyTitleR,
      cursorColor: kPrimaryColor,
      onTap: () async {
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
        suffixIcon: isDate
            ? GestureDetector(
                onTap: () => _showDatePicker(context),
                child: const Icon(Icons.calendar_today,
                    size: 20, color: Colors.grey),
              )
            : type == CustomFieldType.document
                ? const Icon(Icons.cloud_upload_outlined,
                    size: 22, color: Colors.grey)
                : isEmail
                    ? const Icon(Icons.email_outlined,
                        size: 20, color: Colors.grey)
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
