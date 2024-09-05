import 'package:flutter/material.dart';

// Import screens
import 'screens/chatbot_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mood_tracking_screen.dart';
import 'screens/meditation_tips_screen.dart';
import 'screens/feeling_diary_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/music_screen.dart';

// New screens
import 'screens/onboarding_screen.dart';
import 'screens/check-ins_screen.dart';

import 'screens/emergency_screen.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}




class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI-Powered Emotional Support App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/moodTracking': (context) => MoodTrackingScreen(),
        '/chatbot': (context) => ChatScreen(),
           
        '/feelingDiary': (context) => FeelingDiaryScreen(),
        '/profile': (context) => ProfileScreen(),
        '/changePassword': (context) => ChangePasswordScreen(),
        '/music': (context) => MusicScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/moodCheckin': (context) => MoodCheckinScreen(),
        
        '/tips': (context) => TipsScreen(),
        
        '/emergency': (context) => EmergencyScreen(),
        
        // Add more routes as needed
      },
    );
  }
}
