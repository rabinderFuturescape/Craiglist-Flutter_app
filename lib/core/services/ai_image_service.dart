import 'dart:convert';
import 'package:http/http.dart' as http;

class AIImageService {
  static const String _baseUrl = 'https://api.openai.com/v1/images/generations';
  final String _apiKey; // OpenAI API key

  AIImageService(this._apiKey);

  Future<String> generateImage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
          'response_format': 'url',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'][0]['url'];
      } else {
        throw Exception('Failed to generate image: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error generating image: $e');
    }
  }
}
