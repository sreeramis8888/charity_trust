import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:flutter_svg/svg.dart';

class PaymentMethodPage extends ConsumerStatefulWidget {
  final String campaignTitle;
  final double amount;
  final VoidCallback onRazorpaySelected;
  final Function() onMswipeSelected;
  final Function() onEasebuzzSelected;

  const PaymentMethodPage({
    Key? key,
    required this.campaignTitle,
    required this.amount,
    required this.onRazorpaySelected,
    required this.onMswipeSelected,
    required this.onEasebuzzSelected,
  }) : super(key: key);

  @override
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage> {
  String _selectedGateway = 'razorpay';
  // bool _showEmailInput = true;
  // final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    // _emailController.dispose();
    super.dispose();
  }

  // bool _isValidEmail(String email) {
  //   final emailRegex = RegExp(
  //     r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  //   );
  //   return emailRegex.hasMatch(email);
  // }

  void _handleContinue() {
    if (_selectedGateway == 'razorpay') {
      log('Selected Razorpay', name: 'PaymentMethodPage');
      widget.onRazorpaySelected();
    } else if (_selectedGateway == 'easebuzz') {
      // else if (_selectedGateway == 'mswipe') {

      // final email = _emailController.text.trim();
      // if (email.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('pleaseEnterEmail'.tr()),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }
      // if (!_isValidEmail(email)) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('pleaseEnterValidEmail'.tr()),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      //   return;
      // }
      log('Selected Easebuzz with email: ', name: 'PaymentMethodPage');
      // widget.onMswipeSelected();
      widget.onEasebuzzSelected();
    }
    // else if (_selectedGateway == 'mswipe') {
    //   // final email = _emailController.text.trim();
    //   // if (email.isEmpty) {
    //   //   ScaffoldMessenger.of(context).showSnackBar(
    //   //     SnackBar(
    //   //       content: Text('pleaseEnterEmail'.tr()),
    //   //       backgroundColor: Colors.red,
    //   //     ),
    //   //   );
    //   //   return;
    //   // }
    //   // if (!_isValidEmail(email)) {
    //   //   ScaffoldMessenger.of(context).showSnackBar(
    //   //     SnackBar(
    //   //       content: Text('pleaseEnterValidEmail'.tr()),
    //   //       backgroundColor: Colors.red,
    //   //     ),
    //   //   );
    //   //   return;
    //   // }
    //   log('Selected Msipe with email: ', name: 'PaymentMethodPage');
    //   widget.onMswipeSelected();
    //   // widget.onEasebuzzSelected();
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('paymentMethod'.tr(), style: kBodyTitleM),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mswipe Option
                  _buildPaymentOption(
                    gateway: 'easebuzz',
                    title: 'Easebuzz',
                    subtitle: 'No additional charges',
                    icon: 'assets/svg/mswipe_logo.svg',
                    isSelected: _selectedGateway == 'easebuzz',
                    onTap: () {
                      setState(() {
                        _selectedGateway = 'easebuzz';
                        // _showEmailInput = true;
                      });
                    },
                  ),

                  // //mswipe
                  // _buildPaymentOption(
                  //   gateway: 'mswipe',
                  //   title: 'Mswipe',
                  //   subtitle: 'No additional charges',
                  //   icon: 'assets/svg/mswipe_logo.svg',
                  //   isSelected: _selectedGateway == 'mswipe',
                  //   onTap: () {
                  //     setState(() {
                  //       _selectedGateway = 'mswipe';
                  //       // _showEmailInput = true;
                  //     });
                  //   },
                  // ),

                  const SizedBox(height: 16),
                  // Razorpay Option
                  _buildPaymentOption(
                    gateway: 'razorpay',
                    title: 'Razorpay',
                    subtitle: '2% convenience fee applicable',
                    icon:
                        'assets/svg/razorpay_logo.svg', // You can use Image.asset or Icon
                    isSelected: _selectedGateway == 'razorpay',
                    onTap: () {
                      setState(() {
                        _selectedGateway = 'razorpay';
                        // _showEmailInput = false;
                      });
                    },
                  ),
                  // const SizedBox(height: 16),

                  // Email Input for Mswipe
                  // if (_showEmailInput) ...[
                  //   const SizedBox(height: 24),
                  //   Text(
                  //     'emailRequired'.tr(),
                  //     style: kSmallTitleB.copyWith(color: kTextColor),
                  //   ),
                  //   const SizedBox(height: 8),
                  //   InputField(
                  //     type: CustomFieldType.email,
                  //     hint: 'enterEmail'.tr(),
                  //     controller: _emailController,
                  //     validator: (value) {
                  //       if (value == null || value.isEmpty) {
                  //         return 'pleaseEnterEmail'.tr();
                  //       }
                  //       if (!_isValidEmail(value)) {
                  //         return 'pleaseEnterValidEmail'.tr();
                  //       }
                  //       return null;
                  //     },
                  //   ),
                  // ],
                ],
              ),
            ),
          ),

          // Amount Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: _buildAmountSummary(),
          ),

          // Continue Button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: primaryButton(
                label: 'continuePayment'.tr(),
                onPressed: _handleContinue,
                buttonColor: kPrimaryColor,
                buttonHeight: 56,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String gateway,
    required String title,
    required String subtitle,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 242, 242, 242),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFF0088FF) : kBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Logo/Icon
                Container(
                  width: 60,
                  height: 60,
                  child: gateway == 'razorpay'
                      ? Image.asset('assets/png/razorpay.png')
                      : Image.asset('assets/png/union_bank.png'),
                ),
                const SizedBox(width: 16),

                // Title and Subtitle
                Expanded(
                  child: Text(
                    title,
                    style: kBodyTitleM.copyWith(color: kTextColor),
                  ),
                ),

                // Radio Button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Color(0xFF0088FF) : kBorder,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF0088FF),
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            Text(
              subtitle,
              style: kSmallerTitleR.copyWith(
                fontStyle: FontStyle.italic,
                color: gateway == 'razorpay'
                    ? const Color(0xFFFF9500)
                    : kSecondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSummary() {
    final convenienceFeePercentage = _selectedGateway == 'razorpay' ? 2.0 : 0.0;
    final convenienceFee = (widget.amount * convenienceFeePercentage) / 100;
    final totalAmount = widget.amount + convenienceFee;

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'donationAmount'.tr() + ' :',
                style: kSmallTitleL.copyWith(color: kTextColor),
              ),
              Text(
                '₹${widget.amount.toStringAsFixed(0)}',
                style: kSmallTitleL.copyWith(color: kTextColor),
              ),
            ],
          ),
          if (convenienceFee > 0) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'convenienceFee'.tr() + ' :',
                  style: kSmallTitleL.copyWith(color: kTextColor),
                ),
                Text(
                  '₹${convenienceFee.toStringAsFixed(2)}',
                  style: kSmallTitleL.copyWith(color: kTextColor),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'totalPayable'.tr() + ' :',
                style: kSmallTitleM.copyWith(color: kTextColor),
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(2)}',
                style: kSmallTitleM.copyWith(color: kTextColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
