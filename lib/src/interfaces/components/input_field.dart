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
      readOnly: readOnly || type != CustomFieldType.text,
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
                    primary: Colors.black, // Header background
                    onPrimary: Colors.white, // Header text
                    onSurface: Colors.black, // Body text color
                  ),
                  datePickerTheme: DatePickerThemeData(
                    backgroundColor: Colors.white,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),

                    // Header
                    headerBackgroundColor: Colors.white,
                    headerHeadlineStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    headerHelpStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),

                    // Calendar day styles
                    dayStyle: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    dayOverlayColor: MaterialStatePropertyAll(Colors.black12),

                    todayForegroundColor:
                        const MaterialStatePropertyAll(Colors.black),
                    todayBackgroundColor:
                        const MaterialStatePropertyAll(Colors.black12),

                    yearStyle: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
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
        errorStyle:
            const TextStyle(height: 0), // 👈 hides error text when typing
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
