import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_saver/file_saver.dart';
import 'package:share_plus/share_plus.dart';

/// Receipt service for downloading and sharing PDF receipts
/// Uses file_saver for cross-platform Downloads folder access

class ReceiptService {
  final Dio _dio;

  ReceiptService({Dio? dio}) : _dio = dio ?? Dio();

  /// Download receipt PDF from URL to Downloads folder
  /// Returns the file path if successful
  Future<String> downloadReceipt(String receiptUrl) async {
    try {
      final fileName = _extractFileName(receiptUrl);
      
      // Download file to bytes
      final response = await _dio.get<List<int>>(
        receiptUrl,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $progress%');
          }
        },
      );

      if (response.data == null) {
        throw Exception('Failed to download receipt data');
      }

      // Save using file_saver
      final path = await FileSaver.instance.saveFile(
        name: fileName,
        bytes: response.data!,
        ext: 'pdf',
        mimeType: MimeType.pdf,
      );

      return path;
    } catch (e) {
      throw Exception('Failed to download receipt: $e');
    }
  }

  /// Share receipt PDF
  /// Downloads and shares via native share sheet
  Future<void> shareReceipt(String receiptUrl) async {
    try {
      final fileName = _extractFileName(receiptUrl);
      
      // Download file to bytes
      final response = await _dio.get<List<int>>(
        receiptUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data == null) {
        throw Exception('Failed to download receipt data');
      }

      // Create temporary file for sharing
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(response.data!);

      final file = XFile(tempFile.path);

      await Share.shareXFiles(
        [file],
        subject: 'Donation Receipt',
        text: 'Please find my donation receipt attached.',
      );
    } catch (e) {
      throw Exception('Failed to share receipt: $e');
    }
  }

  /// Extract filename from URL
  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.path.split('/');
      return pathSegments.last.isNotEmpty
          ? pathSegments.last
          : 'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';
    } catch (e) {
      return 'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';
    }
  }


}
