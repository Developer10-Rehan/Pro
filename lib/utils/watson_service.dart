import 'dart:convert';
import 'package:http/http.dart' as http;

class WatsonService {
  final String apiKey = 'HigSVB1yKD-3oI6v1tnuqU9GZP7vMPNgXB9pRdmpKxe6';
  final String url = 'https://api.au-syd.natural-language-understanding.watson.cloud.ibm.com/instances/6a9d06ad-9e16-422b-b6b7-9e4c835251ab';

  Future<String> detectEmotion(String text) async {
    final response = await http.post(
      Uri.parse('$url/v1/analyze?version=2021-03-25'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Basic ' + base64Encode(utf8.encode('apikey:$apiKey')),
      },
      body: jsonEncode({
        'text': text,
        'features': {
          'emotion': {},
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final emotions = data['emotion']['document']['emotion'];
      return emotions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    } else {
      throw Exception('Failed to analyze text');
    }
  }
}
