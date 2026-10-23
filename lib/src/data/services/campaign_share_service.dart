import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareCampaignContent({
  required String title,
  required String text,
  String? imageUrl,
}) async {
  final url = imageUrl?.trim() ?? '';
  if (url.isNotEmpty) {
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final bytes = response.data;
      if (bytes != null && bytes.isNotEmpty) {
        final path = Uri.tryParse(url)?.path ?? '';
        final candidate = path.split('/').last.split('.').last.toLowerCase();
        final extension =
            {'jpg', 'jpeg', 'png', 'webp', 'gif'}.contains(candidate)
                ? candidate
                : 'jpg';
        final mimeType = switch (extension) {
          'png' => 'image/png',
          'webp' => 'image/webp',
          'gif' => 'image/gif',
          _ => 'image/jpeg',
        };

        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                Uint8List.fromList(bytes),
                name: 'campaign.$extension',
                mimeType: mimeType,
              ),
            ],
            subject: title,
            text: text,
          ),
        );
        return;
      }
    } catch (error) {
      log('Unable to attach campaign image: $error');
    }
  }

  await SharePlus.instance.share(
    ShareParams(subject: title, text: text),
  );
}
