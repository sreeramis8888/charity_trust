import 'dart:developer';

import 'package:Annujoom/src/data/constants/color_constants.dart';
import 'package:Annujoom/src/data/constants/style_constants.dart';
import 'package:Annujoom/src/data/providers/zakat_provider.dart';
import 'package:Annujoom/src/data/services/snackbar_service.dart';
import 'package:Annujoom/src/interfaces/components/input_field.dart';
import 'package:Annujoom/src/interfaces/components/primaryButton.dart';
import 'package:Annujoom/src/interfaces/components/loading_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ZakatCalculatorPage extends ConsumerStatefulWidget {
  const ZakatCalculatorPage({super.key});

  @override
  ConsumerState<ZakatCalculatorPage> createState() =>
      _ZakatCalculatorPageState();
}

class _ZakatCalculatorPageState extends ConsumerState<ZakatCalculatorPage> {
  late TextEditingController _cashController;
  late TextEditingController _savingsController;
  late TextEditingController _loansGivenController;
  late TextEditingController _investmentsController;
  late TextEditingController _goldController;
  late TextEditingController _silverController;
  late TextEditingController _tradeGoodsController;
  late TextEditingController _borrowedMoneyController;
  late TextEditingController _wagesDueController;
  late TextEditingController _billsDueController;

  String _selectedNisab = 'gold';
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    _cashController = TextEditingController();
    _savingsController = TextEditingController();
    _loansGivenController = TextEditingController();
    _investmentsController = TextEditingController();
    _goldController = TextEditingController();
    _silverController = TextEditingController();
    _tradeGoodsController = TextEditingController();
    _borrowedMoneyController = TextEditingController();
    _wagesDueController = TextEditingController();
    _billsDueController = TextEditingController();
  }

  @override
  void dispose() {
    _cashController.dispose();
    _savingsController.dispose();
    _loansGivenController.dispose();
    _investmentsController.dispose();
    _goldController.dispose();
    _silverController.dispose();
    _tradeGoodsController.dispose();
    _borrowedMoneyController.dispose();
    _wagesDueController.dispose();
    _billsDueController.dispose();
    super.dispose();
  }

  double _parseDouble(String value) {
    return double.tryParse(value) ?? 0.0;
  }

  Future<void> _calculateZakat() async {
    setState(() => _isCalculating = true);

    try {
      final assets = {
        'cash': _parseDouble(_cashController.text),
        'savings': _parseDouble(_savingsController.text),
        'loans_given': _parseDouble(_loansGivenController.text),
        'investments': _parseDouble(_investmentsController.text),
        'gold': _parseDouble(_goldController.text),
        'silver': _parseDouble(_silverController.text),
        'trade_goods': _parseDouble(_tradeGoodsController.text),
      };

      final liabilities = {
        'borrowed_money': _parseDouble(_borrowedMoneyController.text),
        'wages_due': _parseDouble(_wagesDueController.text),
        'bills_due': _parseDouble(_billsDueController.text),
      };

      // Get the notifier and API before any async operations
      final notifier = ref.read(zakatCalculatorProvider.notifier);
      final zakatApi = ref.read(zakatApiProvider);

      final request = ZakatCalculatorRequest(
        nisabType: _selectedNisab,
        assets: assets,
        liabilities: liabilities,
      );

      final response = await zakatApi.calculateZakat(request);

      // Check if widget is still mounted after async operation
      if (!mounted) return;

      if (response.success && response.data != null) {
        final data = response.data!['data'] as Map<String, dynamic>?;
        if (data != null) {
          final result = ZakatCalculatorResponse.fromJson(data);
          _showResultDialog(result);
        }
      } else {
        throw Exception(response.message ?? 'Failed to calculate zakat');
      }
    } catch (e) {
      log(e.toString());
      if (mounted) {
        SnackbarService().showSnackBar(
          e.toString(),
          type: SnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }

  void _showResultDialog(ZakatCalculatorResponse result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kWhite, const Color(0xFFFAFAFA)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kPrimaryColor.withOpacity(0.2),
                        kPrimaryColor.withOpacity(0.1),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: kPrimaryColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'zakatCalculationResult'.tr(),
                  style: kHeadTitleSB.copyWith(
                    color: kTextColor,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Your zakat calculation is complete',
                  style: kBodyTitleR.copyWith(
                    color: kSecondaryTextColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Net Worth Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kPrimaryColor.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'netWorth'.tr(),
                            style: kBodyTitleR.copyWith(
                              color: kSecondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₹${result.netWorth.toStringAsFixed(2)}',
                            style: kBodyTitleSB.copyWith(
                              color: kTextColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Zakat Payable Card (Highlighted)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        kPrimaryColor.withOpacity(0.1),
                        kPrimaryColor.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kPrimaryColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'zakatPayable'.tr(),
                            style: kBodyTitleR.copyWith(
                              color: kSecondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '₹${result.zakatPayable.toStringAsFixed(2)}',
                            style: kBodyTitleSB.copyWith(
                              color: kPrimaryColor,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: kBorder,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Text(
                          'close'.tr(),
                          style: kBodyTitleSB.copyWith(
                            color: kTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              kPrimaryColor,
                              kPrimaryColor.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Done',
                            style: kBodyTitleSB.copyWith(
                              color: kWhite,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: kWhite,
        elevation: 0,
        title: Text('zakatCalculator'.tr(), style: kSubHeadingM),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nisab Type Selection
              Text('nisabThreshold'.tr(), style: kBodyTitleM),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  children: [
                    _nisabOption('gold', 'valueOfGold'.tr()),
                    const SizedBox(height: 12),
                    _nisabOption('silver', 'valueOfSilver'.tr()),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Assets Section
              Text('assets'.tr(), style: kBodyTitleM),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('cash'.tr(), style: kBodyTitleR),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'Rs',
                      controller: _cashController,
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 16),
                    Text('savings'.tr(), style: kBodyTitleR),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'Rs',
                      controller: _savingsController,
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 16),
                    Text('loansGiven'.tr(), style: kBodyTitleR),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'Rs',
                      controller: _loansGivenController,
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 16),
                    Text('investments'.tr(), style: kBodyTitleR),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'Rs',
                      controller: _investmentsController,
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 16),
                    Text('gold'.tr(), style: kBodyTitleR),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'Rs',
                      controller: _goldController,
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 16),
                    Text('silver'.tr(), style: kBodyTitleR),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'Rs',
                      controller: _silverController,
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 16),
                    Text('tradeGoods'.tr(), style: kBodyTitleR),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'Rs',
                      controller: _tradeGoodsController,
                      allowDecimal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Liabilities Section
              Text('liabilities'.tr(), style: kBodyTitleM),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('borrowedMoney'.tr(), style: kBodyTitleR),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'Rs',
                      controller: _borrowedMoneyController,
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 16),
                    Text('wagesDue'.tr(), style: kBodyTitleR),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'Rs',
                      controller: _wagesDueController,
                      allowDecimal: true,
                    ),
                    const SizedBox(height: 16),
                    Text('billsDue'.tr(), style: kBodyTitleR),
                    const SizedBox(height: 8),
                    InputField(
                      type: CustomFieldType.number,
                      hint: 'Rs',
                      controller: _billsDueController,
                      allowDecimal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Calculate Button
              primaryButton(
                label: 'calculateZakat'.tr(),
                onPressed: _calculateZakat,
                isLoading: _isCalculating,
                buttonHeight: 48,
                fontSize: 16,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nisabOption(String value, String label) {
    final isSelected = _selectedNisab == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedNisab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorder),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedNisab,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedNisab = val);
                }
              },
              activeColor: kPrimaryColor,
            ),
            Text(
              label,
              style: kBodyTitleR.copyWith(
                color: kTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
