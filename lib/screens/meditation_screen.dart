import 'package:flutter/material.dart';

class MeditationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Feeling stressed? I recommend trying a 5-minute guided meditation. Would you like me to find one for you?",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                "Taking a few deep breaths can help calm your mind. Would you like a reminder to practice mindfulness throughout the day?",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
