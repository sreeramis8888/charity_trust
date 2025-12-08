import 'package:flutter/material.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';

class TextPill extends StatelessWidget {
  final String text;
  final Color color;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final TextStyle? textStyle;
  final Widget? icon;
  final int? maxLines;
  final double? width;
  final double? height;

  const TextPill({
    super.key,
    required this.text,
    required this.color,
    this.borderColor,
    this.padding,
    this.borderRadius,
    this.textStyle,
    this.icon,
    this.maxLines,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: textStyle ??
                  kSmallTitleSB.copyWith(
                    color: borderColor ?? Colors.white,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
