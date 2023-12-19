import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/constants/custom_text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth/auth_service.dart';

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
    String formattedDate = DateFormat('dd.MM.yyyy').format(originalDateTime);

    return formattedDate;
  }

 //* kulanıcının bilgilerini getirir
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserDataStream(
      String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots();
  }

  //* kullancıya çıkış yaptıran fonksiyon
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    CustomColors _customColors = CustomColors();
    ProfileText _profileText = ProfileText();
    var user = _firebaseAuth.currentUser!;
    String originalDateString = user.metadata.creationTime.toString();
    String acc_creation_date = formatDate(originalDateString);

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: getUserDataStream(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(); // Loading indicator while data is being fetched
        }

        var userData = snapshot.data!.data();
        String email = userData?['email'] ?? '';
        String photoUrl = userData?['photoUrl'] ?? '';
        String aboutText = userData?['aboutText'] ?? '';
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: _customColors.dcDark,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 80,
                  ),
                  CircleAvatar(
                    backgroundImage: NetworkImage(photoUrl),
                    radius: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    email,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(
                    height: 16,
                  ),

                  Text(
                    "${_profileText.creationDate}: ${acc_creation_date}",
                    style: TextStyle(color: Colors.grey),
                  ),

                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _customColors.dcGrey,
                      border: Border.all(
                        color: _customColors.dcGrey, // Border color
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
                              Text(_profileText.aboutMe),
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
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    width: double.infinity,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                            color: _customColors.dcRed,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                          child: Text(
                            _profileText.signOut,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Add more widgets to display other user information
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> updateAboutText(String newText, userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'aboutText': newText});
    } catch (e) {
      print('Hakkında kısmı güncellenirken bir sorun oluştu: $e');
    }
  }
}
