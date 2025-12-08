import 'dart:io';
import 'package:open_file/open_file.dart';

/// Service for opening files with default applications
class FileOpenerService {
  /// Open a file with the default application
  /// Returns the result of the open operation
  Future<OpenResult> openFile(String filePath) async {
    try {
      if (!await File(filePath).exists()) {
        throw Exception('File not found: $filePath');
      }

      final result = await OpenFile.open(filePath);
      return result;
    } catch (e) {
      throw Exception('Failed to open file: $e');
    }
  }

  /// Open PDF file specifically
  Future<OpenResult> openPdf(String filePath) async {
    try {
      return await openFile(filePath);
    } catch (e) {
      throw Exception('Failed to open PDF: $e');
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Get file size in bytes
  Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found: $filePath');
      }
      return await file.length();
    } catch (e) {
      throw Exception('Failed to get file size: $e');
    }
  }

  /// Delete a file
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
}
