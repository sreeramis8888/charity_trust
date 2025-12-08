import 'package:charity_trust/src/data/constants/color_constants.dart';
import 'package:charity_trust/src/data/constants/style_constants.dart';
import 'package:charity_trust/src/interfaces/components/text_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:charity_trust/src/data/providers/receipt_provider.dart';
import 'package:charity_trust/src/data/providers/file_opener_provider.dart';
import 'package:charity_trust/src/data/services/snackbar_service.dart';

class TransactionCard extends ConsumerWidget {
  final String id;
  final String type;
  final String date;
  final String amount;
  final String status;
  final String receipt;
  const TransactionCard({
    super.key,
    required this.id,
    required this.type,
    required this.date,
    required this.amount,
    required this.status,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBackgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextPill(
                color: Color(0xFFDBDBDB),
                text: "Transaction ID: $id",
                textStyle: kSmallerTitleR.copyWith(
                  fontSize: 10,
                ),
              ),
              if (receipt.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    try {
                      final filePath = await ref
                          .read(downloadReceiptProvider(receipt).future);
                      await ref.read(openPdfProvider(filePath).future);
                    } catch (e) {
                      SnackbarService().showSnackBar(
                        'Failed to open receipt: $e',
                        type: SnackbarType.error,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.download,
                      color: kWhite,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _row("Type", type),
          const Divider(),
          _row("Date & time", date),
          const Divider(),
          _row("Amount paid", amount),
          const Divider(),
          _row("Status", status, isStatus: true),
        ],
      ),
    );
  }

  Widget _row(String l, String r, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: kSmallerTitleL),
        isStatus
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(r, style: kSmallTitleSB.copyWith(color: kWhite)),
              )
            : Text(r, style: kSmallerTitleM),
      ],
    );
  }
}
