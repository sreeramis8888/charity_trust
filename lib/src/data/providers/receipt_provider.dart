import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Annujoom/src/data/services/receipt_service.dart';

part 'receipt_provider.g.dart';

/// Receipt service provider
@riverpod
ReceiptService receiptService(Ref ref) {
  return ReceiptService();
}

/// Download receipt - returns file path
@riverpod
Future<String> downloadReceipt(Ref ref, String receiptUrl) async {
  final service = ref.watch(receiptServiceProvider);
  return await service.downloadReceipt(receiptUrl);
}

/// Share receipt
@riverpod
Future<void> shareReceipt(Ref ref, String receiptUrl) async {
  final service = ref.watch(receiptServiceProvider);
  return await service.shareReceipt(receiptUrl);
}
