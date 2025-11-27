import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:charity_trust/src/data/services/snackbar_service.dart';

Future<void> downloadImage(String imageUrl) async {
  try {
    final response = await Dio().get(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    final result = await ImageGallerySaverPlus.saveImage(
      Uint8List.fromList(response.data),
      quality: 100,
      name: 'image_${DateTime.now().millisecondsSinceEpoch}',
    );

    SnackbarService snackbarService = SnackbarService();
    snackbarService.showSnackBar('Image saved to gallery');
  } catch (e) {
    SnackbarService snackbarService = SnackbarService();
    snackbarService.showSnackBar('Failed to download image');
  }
}
