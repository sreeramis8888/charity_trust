import 'package:flutter/material.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';

class ChoiceChipFilter extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelectionChanged;
  final EdgeInsets padding;
  final bool isScrollable;

  const ChoiceChipFilter({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelectionChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isScrollable) {
      return Padding(
        padding: padding,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              options.length,
              (index) {
                final option = options[index];
                final isSelected = selectedOption == option;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < options.length - 1 ? 8 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => onSelectionChanged(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? kPrimaryColor : kBorder,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          color: kBackgroundColor),
                      child: Center(
                        child: Text(
                          option,
                          style: kSmallerTitleL.copyWith(
                            color: isSelected ? kPrimaryColor : Color(0xFF9B9B9B),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        children: List.generate(
          options.length,
          (index) {
            final option = options[index];
            final isSelected = selectedOption == option;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < options.length - 1 ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => onSelectionChanged(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? kPrimaryColor : kBorder,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        color: kBackgroundColor),
                    child: Center(
                      child: Text(
                        option,
                        style: kSmallerTitleL.copyWith(
                          color: isSelected ? kPrimaryColor : Color(0xFF9B9B9B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
