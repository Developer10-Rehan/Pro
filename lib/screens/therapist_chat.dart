import 'package:flutter/material.dart';

class TherapistScreen extends StatelessWidget {
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
                "If you need professional help, I can connect you with a therapist. Would you like to schedule a session or chat with someone now?",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                "We have qualified therapists available for you. You can talk to them about any concerns or emotional challenges you’re facing.",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
