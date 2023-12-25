import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:intl/intl.dart';
import '../services/server/channel_service.dart';

class ChannelPage extends StatefulWidget {
  String channelId;
  String serverId;
  ChannelPage({super.key, required this.channelId, required this.serverId});

  @override
  State<ChannelPage> createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  CustomColors _customColors = CustomColors();
  TextEditingController _messageController = TextEditingController();
  final ChannelService _channelService = ChannelService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    //* only send message if there is something to send
    if (_messageController.text.isNotEmpty) {
      await _channelService.sendMessage(
          widget.channelId, _messageController.text, widget.serverId);

      //* clear the text controller after send message
      _messageController.clear();
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    // Convert the Firebase timestamp to a Dart DateTime object
    DateTime dateTime = timestamp.toDate();

    // Add a duration of +3 hours to adjust the timezone
    DateTime adjustedDateTime = dateTime.add(Duration(hours: 3));

    // Format the adjusted DateTime object to HH:MM
    String formattedTime = DateFormat.Hm().format(adjustedDateTime);

    return formattedTime;
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getChannelMessages(
      String serverId, String channelId) {
    return FirebaseFirestore.instance
        .collection('servers')
        .doc(serverId)
        .collection('channels')
        .doc(channelId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: getChannelMessages(widget.serverId, widget.channelId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Loading indicator while data is being fetched
        }

        return Scaffold(
          backgroundColor: _customColors.dcDark,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text('KANAL ID: ${widget.channelId}'),
          ),
          body: Column(
            children: [
              Expanded(
                child: _buildMessageList(),
              ),
              SizedBox(
                height: 20,
              ),
              _buildMessageInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _channelService.getMessages(
          widget.channelId, _firebaseAuth.currentUser!.uid, widget.serverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: snapshot.data!.docs
              .map((document) => _buildMessageItem(document))
              .toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    bool me =
        (data['senderId'] == _firebaseAuth.currentUser!.uid) ? true : false;
    return ListTile(
      selected: me,
      selectedColor: _customColors.dcGreen,
      title: Text('@test123'),
      subtitle: Text('data'),
      trailing: Text('13:13'),
      leading: CircleAvatar(
        backgroundColor: Colors.green,
        child: Text('1'),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Row(
      children: [
        //* mesaj yaz textfield
        Expanded(
          child: TextField(
            controller: _messageController,
            decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade700),
                    borderRadius: BorderRadius.circular(10)),
                hintText: 'Mesaj Yaz',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: _customColors.dcDark),
          ),
        ),

        //* gönder butonu
        IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send,
              size: 40,
            )),
      ],
    );
  }
}
