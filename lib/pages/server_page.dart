import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/pages/channel_page.dart';

import '../services/server/channel_service.dart';

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
    return Scaffold(
      backgroundColor: _customColors.dcDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('Sunucu'),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_outlined)),
      ),
      body: Column(
        children: [
          Text(
            'Kanallar',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(child: _buildChannelList())
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: _customColors.dcGreen,
        animatedIconTheme: IconThemeData(color: Colors.white),
        children: [
          SpeedDialChild(
            child: Icon(Icons.add),
            label: 'Kanal Oluştur',
            onTap: () {
              return _showModalBottomSheet(context);
            },
          )
        ],
      ),
    );
  }

  Widget _buildChannelList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('servers')
            .doc(widget.serverId)
            .collection('channels')
            .snapshots(),
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
          var serverData = snapshot.data!;

          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildChannelListItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildChannelListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    Icon icon = Icon(Icons.emergency);
    Color color = _customColors.dcRed;

    if (data['channelType'] == 'metin') {
      icon = Icon(Icons.forum_outlined);
      color = _customColors.dcBlue;
    }

    if (data['channelType'] == 'sesli') {
      icon = Icon(Icons.record_voice_over);
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: _customColors.dcGrey,
            borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color,
            child: IconButton(
              onPressed: () {},
              icon: icon,
              color: Colors.white,
            ),
          ),
          trailing: const Icon(Icons.arrow_forward),
          title: Text(data['channelName']),
          subtitle: Text(data['channelType']),
          onTap: () {
            //* pass the clicked user's UID to the chat page
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChannelPage(
                        channelId: document.id, serverId: widget.serverId)));
          },
        ),
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return MyBottomSheet(serverId: widget.serverId);
      },
    );
  }
}

class MyBottomSheet extends StatefulWidget {
  String serverId;
  MyBottomSheet({super.key, required this.serverId});

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  final CustomColors _customColors = CustomColors();

  final ChannelService _channelService = ChannelService();
  TextEditingController channelNameController = TextEditingController();
  TextEditingController channelDescriptionController = TextEditingController();

  String selectedChannelType = 'metin';
  List<String> serverTypes = ['metin', 'sesli'];

  void createServer(userId) async {
    if (channelNameController.text.isNotEmpty) {
      await _channelService.createChannel(
          widget.serverId,
          channelNameController.text,
          channelDescriptionController.text,
          selectedChannelType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Kanal Oluştur',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              Spacer(),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.cancel,
                    color: _customColors.dcRed,
                    size: 30,
                  )),
            ],
          ),
          Divider(),
          SizedBox(height: 16.0),
          TextFormField(
            controller: channelNameController,
            decoration: InputDecoration(labelText: 'Kanal Adı'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: channelDescriptionController,
            decoration: InputDecoration(labelText: 'Kanal Açıklaması'),
          ),
          SizedBox(height: 16.0),
          DropdownButton<String>(
            value: selectedChannelType,
            onChanged: (String? newValue) {
              setState(() {
                selectedChannelType = newValue!;
              });
            },
            items: serverTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
          ),
          SizedBox(height: 16.0),
          Container(
            width: double.infinity,
            height: 40,
            child: GestureDetector(
              onTap: () {
                createServer(FirebaseAuth.instance.currentUser!.uid);
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                    color: _customColors.dcGreen,
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                  child: Text(
                    'Kanal Oluştur',
                    style: TextStyle(
                        color: Color.fromARGB(255, 17, 16, 16),
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
