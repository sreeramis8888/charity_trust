import 'package:charity_trust/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';

Widget primaryButton({
  required String label,
  required Function()? onPressed,
  Color labelColor = kWhite,
  int fontSize = 14,
  int buttonHeight = 40,
  bool isLoading = false,
  Color buttonColor = kPrimaryColor,
  Color sideColor = Colors.transparent,
  Widget? icon,
}) {
  final BorderRadius borderRadius = BorderRadius.circular(8);

  return SizedBox(
    height: buttonHeight.toDouble(),
    width: double.infinity,
    child: Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: isLoading || onPressed == null ? null : onPressed,
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: borderRadius,
            border: Border.all(color: sideColor),
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: LoadingAnimation(),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: labelColor,
                          fontSize: fontSize.toDouble(),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}
