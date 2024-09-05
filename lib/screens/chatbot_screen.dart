import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '/utils/youtube_service.dart';
import '/widgets/bottom_navbar.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final YouTubeService _youTubeService = YouTubeService();
  int _selectedIndex = 1;

  Future<String> _detectEmotion(String text) async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/detect_emotion'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'text': text}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['emotion'] ?? 'neutral';
    } else {
      throw Exception('Failed to detect emotion');
    }
  }

  String _generateResponse(String emotion) {
    switch (emotion) {
      case 'happy':
        return "That's great to hear! Keep up the positive vibes!";
      case 'sad':
        return "I'm sorry to hear that. It's okay to feel sad sometimes. I'm here for you.";
      case 'angry':
        return "It's alright to feel angry. Let's take a deep breath together.";
      default:
        return "I'm here to listen. How can I help you today?";
    }
  }

  void _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });

    _controller.clear();

    try {
      // Detect emotion via API
      String emotion = await _detectEmotion(text);

      // Generate response based on detected emotion
      String response = _generateResponse(emotion);

      setState(() {
        _messages.add({'sender': 'bot', 'text': response});
      });

      // Only get video recommendation if emotion is detected and not neutral
      if (emotion != 'neutral') {
        try {
          Map<String, String> videoRecommendation =
              await _youTubeService.getRecommendationWithThumbnail(emotion);

          setState(() {
            _messages.add({
              'sender': 'bot',
              'text': videoRecommendation['title'] ?? '',
              'url': videoRecommendation['url'] ?? '',
              'thumbnail': videoRecommendation['thumbnail'] ?? ''
            });
          });
        } catch (e) {
          setState(() {
            _messages.add({
              'sender': 'bot',
              'text': 'Sorry, I could not fetch a video recommendation at this time.',
            });
          });
        }
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': 'There was an error detecting emotion. Please try again.',
        });
      });
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isUserMessage = message['sender'] == 'user';
    bool isLinkMessage = message.containsKey('url') && message['url']!.isNotEmpty;

    if (isLinkMessage) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent.shade100,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Image.network(
              message['thumbnail']!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => _launchURL(message['url']!),
                child: Text(
                  message['text']!,
                  style: TextStyle(decoration: TextDecoration.underline, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.greenAccent.shade100 : Colors.redAccent.shade100,
          borderRadius: isUserMessage
              ? BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0))
              : BorderRadius.only(
                  topRight: Radius.circular(15.0),
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0)),
        ),
        child: Text(message['text'] ?? ''),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/chatbot');
        break;
      case 2:
        Navigator.pushNamed(context, '/music');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ChatBot Assistant',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    initialRoute: '/chatbot',
    routes: {
      '/chatbot': (context) => ChatScreen(),
    },
  ));
}
