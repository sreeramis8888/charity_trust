import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:charity_trust/src/data/services/receipt_service.dart';

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

/// Open receipt
@riverpod
Future<void> openReceipt(Ref ref, String receiptUrl) async {
  final service = ref.watch(receiptServiceProvider);
  return await service.openReceipt(receiptUrl);
}

/// Check if receipt exists locally
@riverpod
Future<bool> receiptExists(Ref ref, String receiptUrl) async {
  final service = ref.watch(receiptServiceProvider);
  return await service.receiptExists(receiptUrl);
}

/// Get local receipt path
@riverpod
Future<String?> getLocalReceiptPath(Ref ref, String receiptUrl) async {
  final service = ref.watch(receiptServiceProvider);
  return await service.getLocalReceiptPath(receiptUrl);
}
