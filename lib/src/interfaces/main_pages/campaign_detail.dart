import 'package:flutter/material.dart';
import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/components/primaryButton.dart';
import 'package:charity_trust/src/interfaces/components/input_field.dart';
import 'package:charity_trust/src/interfaces/animations/index.dart' as anim;

class CampaignDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String category;
  final String date;
  final String? image;
  final int raised;
  final int goal;

  const CampaignDetailPage({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.raised,
    required this.goal,
    this.image,
  }) : super(key: key);

  @override
  State<CampaignDetailPage> createState() => _CampaignDetailPageState();
}

class _CampaignDetailPageState extends State<CampaignDetailPage> {
  final TextEditingController _donationController = TextEditingController();

  @override
  void dispose() {
    _donationController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.raised / widget.goal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhite,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: kTextColor,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Campaign Details', style: kBodyTitleM),
      ),
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromLeft,
              duration: anim.AnimationDuration.normal,
              child: Text(
                widget.title,
                style: kHeadTitleSB,
              ),
            ),
            const SizedBox(height: 16),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeScaleUp,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    widget.image ?? 'https://placehold.co/400x225',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 150,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFCFCFCF),
                color: const Color(0xFFFFD400),
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹${widget.raised} raised of ₹${widget.goal} goal',
                    style: kBodyTitleM.copyWith(color: const Color(0xFF009000)),
                  ),
                  Text(
                    '$percentage%',
                    style: kSmallTitleR,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromRight,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 250,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DUE DATE',
                    style: kSmallerTitleB.copyWith(
                      color: kSecondaryTextColor,
                      fontSize: 10,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF001F4D),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: kWhite, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          widget.date.toUpperCase(),
                          style: kSmallerTitleB.copyWith(color: kWhite),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromLeft,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 300,
              child: Text(
                widget.description,
                style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
              ),
            ),
            const SizedBox(height: 20),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromLeft,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 350,
              child: Text(
                'Lorem ipsum dolor sit amet consectetur. Vestibulum arcu nec dolor gravida vel diam nulla. Diam nullam tincidunt interdum aliquet porta risus amet. Neque ipsum iaculis suspendisse lacus dictumst. Lectus mauris dapibus velit ultrices amet in at. Sit purus leo turpis ac malesuada in eu platea quam. Sagittis vestibulum placerat et vel vel. Diam id et nisl lectus elementum duis vel. U',
                style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
              ),
            ),
            const SizedBox(height: 28),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromLeft,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 400,
              child: Text('Enter Donation Amount', style: kSmallTitleB),
            ),
            const SizedBox(height: 12),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 450,
              child: InputField(
                type: CustomFieldType.text,
                hint: '₹ Enter amount',
                controller: _donationController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 24),
            anim.AnimatedWidgetWrapper(
              animationType: anim.AnimationType.fadeSlideInFromBottom,
              duration: anim.AnimationDuration.normal,
              delayMilliseconds: 500,
              child: Row(
                children: [
                  Expanded(
                    child: primaryButton(
                      label: "Share",
                      onPressed: () {
                        _showSnackBar("Share functionality coming soon");
                      },
                      buttonColor: kWhite,
                      labelColor: kTextColor,
                      sideColor: kTertiary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: primaryButton(
                      label: "Donate Now",
                      onPressed: () {
                        final amountText = _donationController.text.trim();
                        final amount = double.tryParse(amountText);
                        if (amount == null || amount <= 0) {
                          _showSnackBar("Please enter a valid amount");
                          return;
                        }
                        _showSnackBar("Donation of ₹$amount initiated");
                        _donationController.clear();
                      },
                      buttonColor: kPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
