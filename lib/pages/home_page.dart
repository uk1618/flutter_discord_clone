import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/pages/messages_page.dart';
import 'package:flutter_whatsapp_clone/pages/profile_page.dart';
import 'package:flutter_whatsapp_clone/pages/server_list_page.dart';
import 'package:flutter_whatsapp_clone/services/auth/auth_service.dart';
import 'package:flutter_whatsapp_clone/services/server/server_service.dart';
import 'package:provider/provider.dart';
import '../constants/custom_text.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
    CustomColors customColors = CustomColors();
    return Scaffold(
      backgroundColor: customColors.dcDark,
      appBar: AppBar(
        backgroundColor: customColors.dcDark,
        elevation: 0,
        title: const Text('DISCORD'),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('UMUT KONAK')));
            },
            icon: const Icon(Icons.question_mark_outlined)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications))
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          iconSize: 28,
          backgroundColor: Colors.black,
          selectedItemColor: customColors.dcGreen,
          unselectedItemColor: Colors.grey,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeText homeText = HomeText();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              homeText.popularServers,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(
              height: 20,
            ),
            StreamBuilder(
              stream: ServerService().getAllServers(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return GridView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  children: snapshot.data!.docs
                      .map((document) => _buildServerItem(document, context))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _showDialog(BuildContext context, String serverId, String serverName,
    String serverDesc, String serverType) {
  final ServerService serverService = ServerService();
  void joinAserver(String serverId, String serverName, String serverDesc,
      String serverType) async {
    await serverService.joinAserver(
      context,
      serverId,
      serverName,
      serverDesc,
      serverType,
    );
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      HomeText homeText = HomeText();

      return AlertDialog(
        title: Text(homeText.joinServer),
        content: Text(homeText.sureForJoinServer),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomColors().dcBlue,
            ),
            onPressed: () {
              joinAserver(serverId, serverName, serverDesc, serverType);
              Navigator.of(context).pop();
            },
            child: Text(homeText.join),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors().dcBlue),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(homeText.cancel),
          )
        ],
      );
    },
  );
}

Widget _buildServerItem(DocumentSnapshot document, BuildContext context) {
  Map<String, dynamic> data = document.data() as Map<String, dynamic>;
  String serverId = document.id;

  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 85,
            width: 85,
            child: Image.asset('assets/server.png'),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            data['serverName'],
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 35,
            child: ElevatedButton(
              onPressed: () {
                _showDialog(context, serverId, data['serverName'],
                    data['serverDesc'], data['serverType']);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors().dcBlue,
              ),
              child: Text(HomeText().join),
            ),
          )
        ],
      ),
    ),
  );
}

// ignore: must_be_immutable
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
    BottomNavText bottomNavText = BottomNavText();
    return BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: (int index) {
          setState(() {
            widget.currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: bottomNavText.homepage,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.message_rounded),
            label: bottomNavText.message,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.connect_without_contact),
            label: bottomNavText.server,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: bottomNavText.profile,
          ),
        ]);
  }
}
