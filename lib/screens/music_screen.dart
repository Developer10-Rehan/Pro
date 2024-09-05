import 'package:flutter/material.dart';
import '/utils/lastfm_service.dart';
import 'music_player_screen.dart';

class MusicScreen extends StatefulWidget {
  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final LastFmService _lastFmService = LastFmService();
  List<dynamic> _tracks = [];
  String _query = '';

  void _search(String query) async {
    try {
      final data = await _lastFmService.searchTrack(query);
      setState(() {
        _tracks = data['results']['trackmatches']['track'];
      });
    } catch (e) {
      print(e);
    }
  }

  void _playTrack(String trackUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerScreen(trackUrl: trackUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search for a track',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => _search(_query),
            child: Text('Search'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tracks.length,
              itemBuilder: (context, index) {
                final track = _tracks[index];
                final trackUrl = track['url']; // Replace with actual URL if available
                return ListTile(
                  title: Text(track['name']),
                  subtitle: Text(track['artist']),
                  leading: track['image'] != null ? Image.network(track['image'][2]['#text']) : null,
                  onTap: () => _playTrack(trackUrl),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
