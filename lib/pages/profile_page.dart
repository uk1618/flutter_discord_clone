import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/chat/chat_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController _aboutTextController = TextEditingController();
  bool _isEditing = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String formatDate(String originalDateString) {
    // Parse the original string to a DateTime object
    DateTime originalDateTime = DateTime.parse(originalDateString);

    // Format the DateTime object to the desired format
    String formattedDate = DateFormat('dd-MM-yyyy').format(originalDateTime);

    return formattedDate;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream(
      String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var user = _firebaseAuth.currentUser!;
    String originalDateString = user.metadata.creationTime.toString();
    String acc_creation_date = formatDate(originalDateString);

    return Scaffold(
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: getUserDataStream(user.uid),
        builder: (context, snapshot) {
          print(user.metadata.creationTime.toString());
          if (!snapshot.hasData) {
            return CircularProgressIndicator(); // Loading indicator while data is being fetched
          }

          var userData = snapshot.data!.data();
          String email = userData?['email'] ?? '';
          String photoUrl = userData?['photoUrl'] ?? '';
          String aboutText = userData?['aboutText'] ?? '';

          return Scaffold(
            appBar: AppBar(
              title: Text('Profile'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                    radius: 50,
                  ),
                  SizedBox(height: 20),
                  Text('Email: $email'),
                  SizedBox(
                    height: 20,
                  ),
                  Text("Hesap Oluşturma Tarihi: ${acc_creation_date}"),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 250,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        border: Border.all(
                          color: Colors.blueGrey, // Border color
                          width: 2.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(
                            10), // Optional: add border radius
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Hakkımda'),
                                Spacer(),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = true;
                                      _aboutTextController.text = aboutText;
                                    });
                                  },
                                  icon: Icon(Icons.edit),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            _isEditing
                                ? TextField(
                                    maxLength: 100,
                                    maxLines: 5,
                                    controller: _aboutTextController,
                                    decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _isEditing = false;

                                                updateAboutText(
                                                    _aboutTextController.text,
                                                    user.uid);
                                              });
                                            },
                                            icon: Icon(Icons.done))),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(aboutText,
                                        style: TextStyle(fontSize: 16)),
                                  ), // Show existing text when not editing
                          ],
                        ),
                      ),
                    ),
                  )
                  // Add more widgets to display other user information
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> updateAboutText(String newText, userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'aboutText': newText});

      print('About text updated successfully!');
    } catch (e) {
      print('Error updating about text: $e');
    }
  }
}
