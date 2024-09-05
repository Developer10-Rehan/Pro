import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
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
                "Taking care of yourself is important. Here are a few self-care tips you might find helpful today.",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              Text(
                "Remember, you are strong and capable. Here's a positive affirmation for you: 'I am in control of my feelings and my future.'",
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
