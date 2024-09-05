import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  Future<String> generateResponse(String prompt) async {
    final url = Uri.https('api.openai.com', '/v1/completions');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'model': 'text-davinci-003',
      'prompt': prompt,
      'max_tokens': 150,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['choices'][0]['text'].trim();
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in generateResponse: $e');
      return 'I am having trouble understanding. Can you please elaborate?';
    }
  }

  Future<String> detectEmotion(String text) async {
    final url = Uri.https('api.openai.com', '/v1/completions');
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'model': 'text-davinci-003',
      'prompt': 'Detect the emotion in the following text: "$text". Possible emotions are happy, sad, and neutral.',
      'max_tokens': 10,
      'temperature': 0.0,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        String result = jsonResponse['choices'][0]['text'].trim();
        if (['happy', 'sad', 'neutral'].contains(result.toLowerCase())) {
          return result;
        } else {
          return 'neutral';
        }
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in detectEmotion: $e');
      return 'neutral';
    }
  }
}