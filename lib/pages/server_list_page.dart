import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/constants/custom_text.dart';
import 'package:flutter_whatsapp_clone/pages/server_page.dart';
import 'package:flutter_whatsapp_clone/services/server/server_service.dart';

class ServerListPage extends StatefulWidget {
  const ServerListPage({super.key});

  @override
  State<ServerListPage> createState() => _ServerListPageState();
}

class _ServerListPageState extends State<ServerListPage> {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  late String serverId;
  final CustomColors _customColors = CustomColors();

  final ServerService serverService = ServerService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _customColors.dcDark,
      floatingActionButton: FloatingActionButton(
        backgroundColor: _customColors.dcGreen,
        onPressed: () {
          return _showModalBottomSheet(context);
        },
        child: Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Sunucular',
              style: TextStyle(fontSize: 36),
            ),
            SizedBox(
              height: 20,
            ),
            _buildServerList()
          ],
        ),
      ),
    );
  }

  Widget _buildServerList() {
    return StreamBuilder(
      stream: serverService.getServers(firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return Expanded(
          child: ListView(
            children: snapshot.data!.docs
                .map((document) => _buildServerItem(document))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildServerItem(DocumentSnapshot document) {
    serverId = document.id;
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String serverType = data['serverType'];

    Color labelColor = Colors.green;

    if (serverType.toString() == 'Oyun') {
      labelColor = _customColors.dcRed;
    }
    if (serverType.toString() == 'Sosyal') {
      labelColor = _customColors.dcGreen;
    }

    if (serverType.toString() == 'Eğitim') {
      labelColor = _customColors.dcBlue;
    }

    if (serverType.toString() == 'Müzik') {
      labelColor = Colors.pinkAccent;
    }

    return GestureDetector(
      onTap: () {
        print(document.id);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServerPage(serverId: document.id),
            ));
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _customColors.dcGrey, // Set the background color
          border: Border.all(
            color: _customColors.dcGrey, // Set the border color
            width: 2.0, // Set the border width
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(data['serverName']),
          subtitle: Text(data['serverDesc']),
          leading: CircleAvatar(
            backgroundColor: _customColors.dcBlue,
            child: Text(
              data['serverName'][0],
              style: TextStyle(fontSize: 36),
            ),
          ),
          trailing: Container(
            height: 25,
            width: 70,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10), color: labelColor),
            child: Center(
                child: Text(
              data['serverType'],
              style: TextStyle(fontSize: 16),
            )),
          ),
        ),
      ),
    );
  }
}

void _showModalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return const MyBottomSheet();
    },
  );
}

class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({super.key});

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  final ServerText _serverText = ServerText();
  final CustomColors _customColors = CustomColors();

  final ServerService _serverService = ServerService();
  TextEditingController serverNameController = TextEditingController();
  TextEditingController serverDescriptionController = TextEditingController();

  String selectedServerType = 'Eğitim';
  List<String> serverTypes = ['Eğitim', 'Oyun', 'Sosyal', 'Müzik'];

  void createServer(userId) async {
    if (serverNameController.text.isNotEmpty) {
      //* await _serverService.createServer(serverNameController.text,
       //*   serverDescriptionController.text, selectedServerType); 
          //*

      await _serverService.createServerWithDefaultChannel2(
          userId,
          serverNameController.text,
          serverDescriptionController.text,
          selectedServerType);
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
                _serverText.createServer,
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
            controller: serverNameController,
            decoration: InputDecoration(labelText: _serverText.serverName),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: serverDescriptionController,
            decoration: InputDecoration(labelText: _serverText.serverDesc),
          ),
          SizedBox(height: 16.0),
          DropdownButton<String>(
            value: selectedServerType,
            onChanged: (String? newValue) {
              setState(() {
                selectedServerType = newValue!;
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
                    _serverText.createServer,
                    style: TextStyle(
                        color: Colors.white,
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
