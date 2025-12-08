import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoadingAnimation extends StatelessWidget {
  final double size;
  final Color? loadingColor;
  const LoadingAnimation({super.key, this.size = 30, this.loadingColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: LoadingIndicator(
        indicatorType: Indicator.lineSpinFadeLoader,
        colors: [loadingColor ?? kPrimaryColor],
        strokeWidth: 2,
      ),
    );
  }
}
