

// utils/lastfm_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class LastFmService {
  final String apiKey = '5beb9fcfc75dc154e81b79b3d99b06ec';
  final String apiUrl = 'http://ws.audioscrobbler.com/2.0/';

  Future<Map<String, dynamic>> searchTrack(String query) async {
    final response = await http.get(Uri.parse(
        '$apiUrl?method=track.search&track=$query&api_key=$apiKey&format=json'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load tracks');
    }
  }
}
