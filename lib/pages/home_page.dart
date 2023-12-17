import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/pages/profile_page.dart';
import 'package:flutter_whatsapp_clone/services/auth/auth_service.dart';
import 'package:provider/provider.dart';

import 'chat_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //* instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //* sign user out
  void signOut() {
    final authService = Provider.of<AuthService>(context, listen: false);

    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors().dcDark,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()));
            },
            icon: Icon(Icons.person)),
        actions: [IconButton(onPressed: signOut, icon: Icon(Icons.logout))],
      ),
      bottomNavigationBar: CustomBottomBar(),
      body: _buildUserList(),
    );
  }

  //? build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('loading...');
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
      return ListTile(
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
      );
    } else {
      return Container();
    }
  }
}

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Anasayfa',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.message_rounded),
        label: 'Mesaj',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.connect_without_contact),
        label: 'Sunucu',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Sunucu',
      ),
    ]);
  }
}
