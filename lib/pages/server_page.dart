import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/pages/channel_page.dart';

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
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('servers')
        .doc(serverId)
        .snapshots();
  }

  //*

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
            drawer: Drawer(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('servers')
                    .doc(widget.serverId)
                    .collection('channels')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Yükleniyor...');
                  }
                  return ListView(
                    children: snapshot.data!.docs
                        .map<Widget>((doc) => _buildChannelListItem(doc))
                        .toList(),
                  );
                },
              ),
            ),
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Text('Kanal Adı'),
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

  Widget _buildChannelListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: _customColors.dcGrey,
            borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          trailing: const Icon(Icons.send),
          title: Text(data['name']),
          subtitle: Text(data['type']),
          onTap: () {
            //* pass the clicked user's UID to the chat page
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ChannelPage(channelId: document.id, serverId: widget.serverId)));
          },
        ),
      ),
    );
  }
}
