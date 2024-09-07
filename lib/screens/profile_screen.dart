import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/widgets/bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profileImageUrl = '/lib/assets/images/logo.png'; // Initial profile image URL
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 3;

   String _userName = "User"; // Default user name
  String _userEmail = "user@example.com"; // Default user email

      Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          setState(() {
            _userName = userData?['name'] ?? "User";
            _userEmail = userData?['email'] ?? "user@example.com";
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }
  
    @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
  }



  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profileImageUrl = image.path;
      });
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
        title: Text('Profile'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImageUrl.startsWith('http')
                          ? NetworkImage(profileImageUrl)
                          : FileImage(File(profileImageUrl)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Icon(Icons.camera_alt, color: Colors.blueAccent),
                        onPressed: _pickImage,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Text(
                  _userName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8),
              Center(
                child: Text(
                  _userEmail,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.person),
                title: Text('Name'),
                subtitle: Text(_userName),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Email'),
                subtitle: Text(_userEmail),
              ),
              ListTile(
                leading: Icon(Icons.phone),
                title: Text('Phone'),
                subtitle: Text('+1234567890'),
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('Address'),
                subtitle: Text('123 Main Street, City, Country'),
              ),
              SizedBox(height: 32),
              Text(
                'Account Settings',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Change Password'),
                onTap: () {
                  Navigator.pushNamed(context, '/changePassword'); // Navigate to Change Password screen
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notifications'),
                onTap: () {
                  // Handle notifications action
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
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
    initialRoute: '/profile',
    routes: {
      
      '/profile': (context) => ProfileScreen(),
    },
  ));
}
