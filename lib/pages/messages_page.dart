import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:provider/provider.dart';
import '../services/auth/auth_service.dart';
import 'chat_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  CustomColors customColors = CustomColors();
  //* instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //* sign user out
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return _buildUserList();
  }

  //? build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Hata: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Yükleniyor...');
        }

        return ListView(
          children: snapshot.data!.docs
              .map<Widget>((doc) => _buildUserListItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget _buildUserListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    if (_auth.currentUser!.email != data['email']) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: customColors.dcGrey,
              borderRadius: BorderRadius.circular(5)),
          child: ListTile(
            leading: CircleAvatar(
                  backgroundColor: customColors.dcGrey,
                  radius: 25,
                  child: ClipOval(
                    child: Image.network(
                      data['photoUrl'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                trailing: const Icon(Icons.send),
            title: Text(data['email']),
            onTap: () {
              //* pass the clicked user's UID to the chat page
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      reciverUserEmail: data['email'],
                      reciverUserID: data['uid'],
                    ),
                  ));
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}
