import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class YouTubeService {
  final String apiKey = 'AIzaSyA8Eo8R0_kHQ8H4gVReEB68K2Upe63kha8'; 

  Future<Map<String, String>> getRecommendationWithThumbnail(String emotion) async {
    List<String> queries = [];
    switch (emotion) {
      case 'happy':
        queries = ['happy music', 'upbeat songs', 'feel good music'];
        break;
      case 'sad':
        queries = ['comforting music', 'sad songs', 'soothing tunes'];
        break;
      case 'angry':
        queries = ['calming music', 'relaxing sounds', 'stress relief music'];
        break;
      default:
        queries = ['uplifting music', 'motivational songs', 'positive vibes'];
    }

    // Randomly select a query
    String query = queries[Random().nextInt(queries.length)];

    final response = await http.get(
      Uri.parse('https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final items = data['items'] as List;
      
      if (items.isEmpty) {
        throw Exception('No results found');
      }

      // Randomly select one item from the results
      final item = items[Random().nextInt(items.length)];
      final videoId = item['id']['videoId'];
      final title = item['snippet']['title'];
      final thumbnail = item['snippet']['thumbnails']['default']['url'];
      return {
        'title': title,
        'url': 'https://www.youtube.com/watch?v=$videoId',
        'thumbnail': thumbnail,
      };
    } else {
      throw Exception('Failed to fetch video');
    }
  }
}
