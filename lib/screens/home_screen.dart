import 'dart:math'; // Import for random number generation
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feeling_diary_screen.dart'; // Import the Feeling Diary screen
import 'chatbot_screen.dart'; // Import the Chatbot screen
import 'profile_screen.dart'; // Import the Profile screen
import 'music_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showYoutubeVideo = true; // Flag to toggle content
  String _userName = "User"; // Default user name

  @override
  void initState() {
    super.initState();

    _chooseContent(); // Choose content type on initialization
    _fetchUserName(); // Fetch the user's name
    getFeelingDiaryEntries();
  }

  String? _userId;

  Future<void> _fetchUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          // Cast the data() result to Map<String, dynamic>
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          setState(() {
            _userName = userData?['name'] ?? "User";
            setState(() {
              _userId = userId; // Store the userId in the state
              print(_userId);
            });
            getFeelingDiaryEntries(); 
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home screen is already displayed, no need to do anything
        break;
      case 1:
        Navigator.pushNamed(
            context, '/chatbot'); // Navigate to Feeling Diary screen
        break;
      case 2:
        Navigator.pushNamed(context, '/music'); // Navigate to Chatbot screen
        break;
      case 3:
        Navigator.pushNamed(context, '/profile'); // Navigate to Music screen
        break;
    }
  }

  Future<void> _launchURL(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _chooseContent() {
    // Randomly choose between YouTube video and recent watch content
    setState(() {
      _showYoutubeVideo = Random().nextBool();
    });
  }

String _latestSleepingTime = 'N/A';
  String _latestMood = 'N/A';
  String _latestStressLevel = 'N/A';

  Future<void> getFeelingDiaryEntries() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(_userId)
          .collection('feeling_diary')
          .orderBy('date', descending: true) // Order by date in descending order
          .limit(1) // Limit to the most recent entry
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        DateTime date = (data['date'] as Timestamp).toDate();
        String sleepingTime = data['sleeping_time'];
        String mood = data['mood'];
        String note = data['note'];
        String stressLevel = data['stress_level'].toString();

        setState(() {
          _latestSleepingTime = sleepingTime;
          _latestMood = mood;
          _latestStressLevel = stressLevel;
        });

        print(
            'Date: $date, Sleeping Time: $sleepingTime, Mood: $mood, Stress Level: $stressLevel, Note: $note');
      }
    } catch (e) {
      print('Error fetching feeling diary entries: $e');
    }
  }

   void _navigateToLoginPage() {
    Navigator.pushNamed(context, '/login'); // Navigate to the login page
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Color(
                    0xFFF0F4FF), // Light blue background for the top section
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Hi ${_userName[0].toUpperCase()}${_userName.substring(1)}!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(Icons.logout), // Use the logout icon
                          color: Colors.black,
                          iconSize: 24,
                          onPressed: () {
                            _navigateToLoginPage(); // Handle the navigation
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'How are you feeling today?',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.90,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Keep Your Mind Clear',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white, // White background for the main content
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Today overview',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _buildOverviewCard(
                                'Sleeping Time',
                                _latestSleepingTime,
                                Colors.lightGreen.shade100,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _buildOverviewCard(
                                'Mood and Emotions',
                                _latestMood,
                                Colors.pink.shade100,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _buildOverviewCard(
                                'Stress Level',
                                _latestStressLevel,
                                Colors.lightBlue.shade100,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context,
                              '/feelingDiary'); // Navigate to Feeling Diary screen
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Feeling Diary',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Icon(Icons.edit, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context,
                              '/meditationTips'); // Navigate to Meditation Tips screen
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.lightBlue.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.mic, color: Colors.black),
                              SizedBox(width: 8),
                              Text('Meditation'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      _showYoutubeVideo
                          ? GestureDetector(
                              onTap: () {
                                _launchURL(
                                    'https://www.youtube.com/watch?v=dQw4w9WgXcQ'); // Replace with the actual URL
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg', // Replace with the actual thumbnail URL
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Recent Watch Content',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  // Add recent watch content here
                                  Text('No recent content available.'),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: _buildNavItem(Icons.home, 0),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavItem(Icons.chat_bubble_outline, 1),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavItem(Icons.headset, 2),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: _buildNavItem(Icons.person_outline, 3),
              label: '',
            ),
          ],
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors
              .transparent, // Set transparent to use the parent background color
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            _selectedIndex == index ? Colors.pink.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 24),
    );
  }

  Widget _buildOverviewCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
