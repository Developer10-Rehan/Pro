import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firebase Firestore
import 'package:shared_preferences/shared_preferences.dart';

class FeelingDiaryScreen extends StatefulWidget {
  @override
  _FeelingDiaryScreenState createState() => _FeelingDiaryScreenState();
}

class _FeelingDiaryScreenState extends State<FeelingDiaryScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _sleepingTimeController = TextEditingController();
  final TextEditingController _stressLevelController = TextEditingController();
  String _selectedMood = 'Happy';
  bool _isFormValid = false;
  bool _isStressLevelCalculated = false;

  final List<String> _moods = ['Happy', 'Sad', 'Angry', 'Excited', 'Tired'];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _noteController.addListener(_validateForm);
    _sleepingTimeController.addListener(_validateForm);
  }

  void _validateForm() {
    final sleepingTime = _sleepingTimeController.text;
    final note = _noteController.text;
    final sleepingTimeRegExp =
        RegExp(r'^\d{1,2}h \d{1,2}m$'); // More flexible regex

    setState(() {
      _isFormValid = sleepingTimeRegExp.hasMatch(sleepingTime) &&
          note.isNotEmpty &&
          _selectedMood.isNotEmpty;
    });
  }

  void _displayStressLevel() {
    if (_isFormValid) {
      final stressLevel = _calculateStressLevel();
      String stressDescription;

      // Determine stress level description
      if (stressLevel == 1) {
        stressDescription = 'Low Stress';
      } else if (stressLevel == 2) {
        stressDescription = 'Medium Stress';
      } else {
        stressDescription = 'High Stress';
      }

      _stressLevelController.text =
          '$stressLevel ($stressDescription)';
      setState(() {
        _isStressLevelCalculated = true;
      });
    }
  }

  int _calculateStressLevel() {
    final sleepingTime = _sleepingTimeController.text;
    final moodScore = _getMoodScore(_selectedMood);
    final noteScore = _getNoteScore(_noteController.text);

    // Calculate the sleep score
    final sleepingTimeParts = sleepingTime.split(' ');
    final hours = int.tryParse(sleepingTimeParts[0].replaceAll('h', '')) ?? 0;
    final minutes = int.tryParse(sleepingTimeParts[1].replaceAll('m', '')) ?? 0;
    final totalMinutes = hours * 60 + minutes;

    int sleepScore;
    if (totalMinutes >= 420) {
      // 7 hours
      sleepScore = 1; // Low stress
    } else if (totalMinutes >= 300) {
      // 5 hours
      sleepScore = 2; // Medium stress
    } else {
      sleepScore = 3; // High stress
    }

    // Average the scores for stress level
    final averageScore = (sleepScore + moodScore + noteScore) ~/ 3;

    return averageScore;
  }

  int _getMoodScore(String mood) {
    switch (mood) {
      case 'Happy':
      case 'Excited':
        return 1; // Low stress
      case 'Sad':
      case 'Tired':
        return 2; // Medium stress
      case 'Angry':
        return 3; // High stress
      default:
        return 2; // Default to medium stress
    }
  }

  int _getNoteScore(String note) {
    if (note.contains('happy') || note.contains('good')) {
      return 1; // Low stress
    } else if (note.contains('sad') || note.contains('bad')) {
      return 2; // Medium stress
    } else {
      return 3; // High stress
    }
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

        setState(() {
          _userId = userId; // Store the userId in the state
          print(_userId);
        });
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> _pickSleepingTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 7, minute: 0), // Default to 7 hours
    );

    if (picked != null) {
      setState(() {
        final sleepingTime = '${picked.hour}h ${picked.minute}m';
        _sleepingTimeController.text = sleepingTime;
        _validateForm();
      });
    }
  }

  void _saveNote() async {
    final DateTime now = DateTime.now();
    final note = _noteController.text;
    final sleepingTime = _sleepingTimeController.text;
    final stressLevel = _stressLevelController.text;

    if (_isStressLevelCalculated) {
      try {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(_userId)
            .collection('feeling_diary')
            .add({
          'date': Timestamp.fromDate(now), // Save the date as a timestamp
          'sleeping_time': sleepingTime,
          'mood': _selectedMood,
          'note': note,
          'stress_level': stressLevel,
        });

        _noteController.clear();
        _sleepingTimeController.clear();
        _stressLevelController.clear();
        setState(() {
          _isStressLevelCalculated = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note saved successfully!')),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home', // Replace with your home screen route
          (route) => false, // This removes all previous routes
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please calculate stress level before saving!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('EEEE - MMMM d, yyyy \na h:mm a');
    final String formattedDate = formatter.format(now);


void _showAllNotesDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(
          child: Text(
            'All Notes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        content: Container(
          width: double.maxFinite, // Make the container width as wide as the screen
          constraints: BoxConstraints(maxHeight: 500), // Set a maximum height for the content
          padding: EdgeInsets.all(8.0), // Add padding around the content
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('user')
                .doc(_userId) // Update this with the userId dynamically if needed
                .collection('feeling_diary')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No notes available.'));
              }

              final notes = snapshot.data!.docs;

              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  final date = (note['date'] as Timestamp).toDate();
                  final formattedDate = DateFormat('EEEE - MMMM d, yyyy \na h:mm a').format(date);

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0), // Space between cards
                    elevation: 4.0, // Add shadow for better depth
                    child: ListTile(
                      contentPadding: EdgeInsets.all(12.0), // Add padding inside the ListTile
                      title: Text(
                        'Date: $formattedDate',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 4.0), // Add spacing between lines
                          Text('Sleeping Time: ${note['sleeping_time']}'),
                          SizedBox(height: 4.0),
                          Text('Mood: ${note['mood']}'),
                          SizedBox(height: 4.0),
                          Text('Note: ${note['note']}'),
                          SizedBox(height: 4.0),
                          Text('Stress Level: ${note['stress_level']}'),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue, // Change button color
              textStyle: TextStyle(fontWeight: FontWeight.bold), // Change text style
            ),
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}




    return Scaffold(
      appBar: AppBar(
        title: Text('Feeling Diary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _showAllNotesDialog,
                child: Text('All notes'),
                
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Make a note',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _sleepingTimeController,
                    readOnly: true, // Prevent manual input
                    decoration: InputDecoration(
                      hintText: 'Enter sleeping time (e.g., 07h 25m)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onTap: _pickSleepingTime, // Open time picker on tap
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _selectedMood,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _moods.map((mood) {
                      return DropdownMenuItem<String>(
                        value: mood,
                        child: Text(mood),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMood = value ?? '';
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment:
                        Alignment.center, // Center the button horizontally
                    child: ElevatedButton(
                      onPressed: _isFormValid ? _displayStressLevel : null,
                      child: Text('Calculate Stress Level'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _stressLevelController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Stress Level',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Align(
                    alignment:
                        Alignment.centerRight, // Aligns the button to the right
                    child: ElevatedButton(
                      onPressed: _isStressLevelCalculated ? _saveNote : null,
                      child: Text('Save'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
