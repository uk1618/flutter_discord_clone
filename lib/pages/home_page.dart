import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/pages/messages_page.dart';
import 'package:flutter_whatsapp_clone/pages/profile_page.dart';
import 'package:flutter_whatsapp_clone/pages/server_list_page.dart';
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

  int _currentIndex = 0;

  // Screens that will be displayed in each tab
  final List<Widget> _pages = const [
    HomeScreen(),
    MessagesPage(),
    ServerListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    CustomColors _customColors = CustomColors();
    return Scaffold(
      backgroundColor: _customColors.dcDark,
      appBar: AppBar(
        backgroundColor: _customColors.dcDark,
        elevation: 0,
        title: Text('DISCORD'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('UMUT KONAK')));
            },
            icon: Icon(Icons.question_mark_outlined)),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 28,
          backgroundColor: Colors.black,
          selectedItemColor: _customColors.dcGreen,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
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
              label: 'Profil',
            ),
          ]),
      body: _pages[_currentIndex],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    CustomColors _customColors = CustomColors();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              'Popüler Sunucular',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(
              height: 20,
            ),
            GridView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemCount: 20,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 85,
                          width: 85,
                          child: Image.asset('assets/server.png'),
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          'DENEME',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        Spacer(),
                        Container(
                          width: double.infinity,
                          height: 35,
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text('Sunucuya Katıl'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _customColors.dcBlue,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomBottomBar extends StatefulWidget {
  int currentIndex = 0;
  CustomBottomBar({
    required currentIndex,
    super.key,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (int index) {
          setState(() {
            widget.currentIndex = index;
          });
        },
        items: [
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
            label: 'Profil',
          ),
        ]);
  }
}
