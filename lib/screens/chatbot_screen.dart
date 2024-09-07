import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '/utils/youtube_service.dart';
import '/widgets/bottom_navbar.dart';

// Main Chat Screen
class ChatScreen extends StatefulWidget {
  final String mood;
  final String stressLevel;

  ChatScreen({this.mood = '', this.stressLevel = ''});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}



class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': "How are you feeling today?",
      'options': ["Happy", "Sad", "Angry", "Neutral"],
    },
    {
      'question': "How long have you been feeling this way?",
      'options': ["Less than a week", "1-2 weeks", "1 month", "More than a month"],
    },
    // New question added here
    {
      'question': "Have you been sleeping well recently?",
      'options': ["Yes", "No", "Sometimes"],
    },
    {
      'question': "Is there anything specific that's bothering you?",
      'options': ["Work", "Family", "Health", "Other"],
    },
    {
      'question': "Would you like some music recommendations to help you relax?",
      'options': ["Yes", "No"],
    },
    {
      'question': "Do you have any preferred music genres?",
      'options': ["Pop", "Rock", "Classical", "Jazz", "Electronic", "Hip-Hop"],
    },
    {
      'question': "Would you like to share more about your current situation?",
      'options': ["Yes", "No"],
    },
  ];

  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final YouTubeService _youTubeService = YouTubeService();
  int _selectedIndex = 1;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _sendInitialMessage();
  }

  Future<String> _detectEmotionFromOpenAI(String text) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/completions'),
        headers: {
          'Content-Type': 'application/json',
          
        },
        body: json.encode({
          'model': 'text-davinci-003',
          'prompt': 'Detect the mood in this text: "$text". Only return one word.',
          'max_tokens': 10,
          'temperature': 0.5,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['text'].trim();
      } else {
        throw Exception('Failed to detect mood with OpenAI');
      }
    } catch (e) {
      return 'neutral'; // Return neutral on error
    }
  }

  String _generateResponse(String mood, String stressLevel) {
    if (stressLevel == 'high') {
      return "It seems you're quite stressed. How about some calming instrumental music?";
    }
    switch (mood.toLowerCase()) {
      case 'happy':
        return "That's awesome! Here's some uplifting music to keep the good mood going!";
      case 'sad':
        return "I'm sorry you're feeling down. Here's some comforting music to help you relax.";
      case 'angry':
        return "It's okay to feel angry sometimes. Here's some calming music to help you cool down.";
      default:
        return "I'm here for you. How about some music to brighten your day?";
    }
  }

  String _generateYouTubeQuery(String mood, String stressLevel) {
  if (stressLevel == 'high') {
    return "calming instrumental music for stress relief";
  }
  switch (mood.toLowerCase()) {
    case 'happy':
      return "uplifting music to stay happy";
    case 'sad':
      return "comforting music for when you're feeling sad";
    case 'angry':
      return "calm music to cool down when angry";
    default:
      return "relaxing music to brighten your day";
  }
}


void _handleOptionSelection(String option) async {
  setState(() {
    _messages.add({'sender': 'user', 'text': option});
  });

  // Clear the options for the next question
  setState(() {
    _questions[_currentQuestionIndex]['selectedOption'] = option;
  });

  // Move to the next question or finalize
  if (_currentQuestionIndex >= _questions.length - 1) {
    // Generate response based on mood and stress level
    try {
      String mood = await _detectEmotionFromOpenAI(option);
      String response = _generateResponse(mood, widget.stressLevel);

      setState(() {
        _messages.add({'sender': 'bot', 'text': response});
      });

      // Fetch YouTube music recommendations based on the mood and stress level
      try {
        String query = _generateYouTubeQuery(mood, widget.stressLevel);
        List<Map<String, String>> videoRecommendations =
            await _youTubeService.getRecommendationsWithThumbnails(query);

        setState(() {
          for (var video in videoRecommendations) {
            _messages.add({
              'sender': 'bot',
              'text': video['title'] ?? '',
              'url': video['url'] ?? '',
              'thumbnail': video['thumbnail'] ?? ''
            });
          }
        });
      } catch (e) {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'text': 'Sorry, I could not fetch music recommendations at this time.',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': 'There was an error detecting the mood. Please try again.',
        });
      });
    }
  } else {
    setState(() {
      _currentQuestionIndex++;
      _sendNextQuestion();
    });
  }
}


  void _sendInitialMessage() {
    if (_questions.isNotEmpty) {
      _sendNextQuestion();
    }
  }

  void _sendNextQuestion() {
    String currentQuestion = _questions[_currentQuestionIndex]['question'];
    List<String> options = _questions[_currentQuestionIndex]['options'];

    setState(() {
      _messages.add({'sender': 'bot', 'text': currentQuestion});
      _messages.add({'sender': 'bot', 'options': options});
    });
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isUserMessage = message['sender'] == 'user';
    bool isLinkMessage = message.containsKey('url') && message['url']!.isNotEmpty;
    bool hasOptions = message.containsKey('options');

    if (hasOptions) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.blueAccent.shade100,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: (message['options'] as List<String>).map<Widget>((option) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ElevatedButton(
                onPressed: () => _handleOptionSelection(option),
                child: Text(option),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.blueAccent,
                  overlayColor: Colors.white,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    } else if (isLinkMessage) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                message['thumbnail']!,
                width: 100,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: InkWell(
                onTap: () => _launchURL(message['url']!),
                child: Text(
                  message['text'],
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isUserMessage ? Colors.lightBlue : Colors.grey.shade700,
            borderRadius: isUserMessage
                ? BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                  )
                : BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 2),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: Text(
            message['text'],
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  void _launchURL(String url) async {
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
        title: Text('ChatBot'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _messages.add({
                          'sender': 'user',
                          'text': _controller.text,
                        });
                        _controller.clear();
                      });
                    },
                  ),
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

// YouTubeService remains the same

class YouTubeService {


  Future<List<Map<String, String>>> getRecommendationsWithThumbnails(String query) async {
    final url = Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&maxResults=5&q=$query&key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Map<String, String>> recommendations = [];

      for (var item in data['items']) {
        final videoTitle = item['snippet']['title'];
        final videoId = item['id']['videoId'];
        final videoThumbnail = item['snippet']['thumbnails']['default']['url'];

        recommendations.add({
          'title': videoTitle,
          'url': 'https://www.youtube.com/watch?v=$videoId',
          'thumbnail': videoThumbnail,
        });
      }

      return recommendations;
    } else {
      throw Exception('Failed to fetch YouTube recommendations');
    }
  }
}
