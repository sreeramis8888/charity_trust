import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:charity_trust/src/data/utils/globals.dart';
import 'package:path_provider/path_provider.dart';

Future<String> imageUpload(String imagePath) async {
  File imageFile = File(imagePath);
  Uint8List imageBytes = await imageFile.readAsBytes();
  print("Original image size: ${imageBytes.lengthInBytes / 1024} KB");

  // Check if the image is larger than 2 MB
  if (imageBytes.lengthInBytes > 2 * 1024 * 1024) {
    img.Image? image = img.decodeImage(imageBytes);
    if (image != null) {
      img.Image resizedImage =
          img.copyResize(image, width: (image.width * 0.5).toInt());
      imageBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: 80));
      print("Compressed image size: ${imageBytes.lengthInBytes / 1024} KB");

      // Save compressed image
      imageFile = await File(imagePath).writeAsBytes(imageBytes);
    }
  }

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final String apiKey = dotenv.env['API_KEY'] ?? '';

  var request = http.MultipartRequest(
    'POST',
    Uri.parse('$baseUrl/upload'),
  );

  request.headers['x-api-key'] = apiKey;

  request.headers['Authorization'] = 'Bearer $token';

  request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    var responseBody = await response.stream.bytesToString();
    return extractImageUrl(responseBody);
  } else {
    var responseBody = await response.stream.bytesToString();
    log(responseBody.toString());
    throw Exception('Failed to upload image');
  }
}

String extractImageUrl(String responseBody) {
  final responseJson = jsonDecode(responseBody);
  log(name: "image upload response", responseJson.toString());
  return responseJson['data'];
}

Future<String> saveUint8ListToFile(Uint8List bytes, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}
