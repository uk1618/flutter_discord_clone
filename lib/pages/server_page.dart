import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/pages/server_list_page.dart';

class ServerPage extends StatefulWidget {
  final String serverId;

  const ServerPage({super.key, required this.serverId});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

@override
class _ServerPageState extends State<ServerPage> {
  final CustomColors _customColors = CustomColors();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //* sunucunun detaylarını getirir
  Stream<DocumentSnapshot<Map<String, dynamic>>> getServerDetail(
      String serverId) {
    return FirebaseFirestore.instance.collection('users').doc(_firebaseAuth.currentUser!.uid).collection('servers').doc(serverId).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: getServerDetail(widget.serverId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Bir Sorun Oluştu: ${snapshot.error}'),
              ),
            );
          }
          var serverData = snapshot.data!.data();

          return Scaffold(
            backgroundColor: _customColors.dcDark,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Text(''),
              leading: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ServerListPage(),
                        ));
                  },
                  icon: Icon(Icons.chevron_left_rounded)),
            ),
            body: Column(
              children: [
                Text(serverData?['serverName'] ?? ''),
                SizedBox(
                  height: 20,
                ),
                Text(serverData?['serverDesc'] ?? ''),
                SizedBox(
                  height: 20,
                ),
                Text(serverData?['serverType'] ?? ''),
              ],
            ),
          );
        });
  }
}
