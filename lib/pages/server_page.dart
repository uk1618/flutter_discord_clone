import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/services/server/server_service.dart';
import '../services/chat/chat_service.dart';

class ServerPage extends StatefulWidget {
  const ServerPage({super.key});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  final ServerService serverService = ServerService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          return _showModalBottomSheet(context);
        },
        child: Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Server List',
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
      stream: serverService.getServers(_firebaseAuth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
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
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    return Column(
      children: [
        Text(data['serverName']),
        SizedBox(
          height: 20,
        ),
        Text(data['serverDesc']),
        SizedBox(
          height: 20,
        ),
        Text(data['serverType']),
      ],
    );
  }
}

void _showModalBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return MyBottomSheet();
    },
  );
}

class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({super.key});

  @override
  State<MyBottomSheet> createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  ServerService _serverService = ServerService();
  TextEditingController serverNameController = TextEditingController();
  TextEditingController serverDescriptionController = TextEditingController();
  String selectedServerType = 'Eğitim';

  List<String> serverTypes = ['Eğitim', 'Oyun', 'Sosyal', 'Müzik'];

  void createServer() async {
    if (serverNameController.text.isNotEmpty) {
      await _serverService.createServer(serverNameController.text,
          serverDescriptionController.text, selectedServerType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sunucu Ekle',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: serverNameController,
            decoration: InputDecoration(labelText: 'Sunucu Adı'),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: serverDescriptionController,
            decoration: InputDecoration(labelText: 'Sunucu Açıklaması'),
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
          ElevatedButton(
            onPressed: () {
              String serverName = serverNameController.text;
              String serverDescription = serverDescriptionController.text;
              print('Sunucu Adı: $serverName');
              print('Sunucu Açıklaması: $serverDescription');
              print('Sunucu Türü: $selectedServerType');
              createServer();
              Navigator.pop(context);
            },
            child: Text('Sunucu Ekle'),
          ),
        ],
      ),
    );
  }
}
