import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

class StorageService {
  final String baseUrl;
  final http.Client _client;

  StorageService({
    this.baseUrl =
        'https://storage.example.com', // Replace with your actual storage URL
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<String> uploadImage(File imageFile) async {
    try {
      // Create multipart request
      final uri = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', uri);

      // Add file to request
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final filename = path.basename(imageFile.path);

      final multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: filename,
      );
      request.files.add(multipartFile);

      // Send request
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return responseData; // Should return the URL of the uploaded file
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      final response = await _client.delete(
        Uri.parse(imageUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
