import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/components/chat_bubble.dart';
import 'package:flutter_whatsapp_clone/components/custom_textfield.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';
import 'package:flutter_whatsapp_clone/services/chat/chat_service.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String reciverUserEmail;
  final String reciverUserID;
  const ChatPage(
      {super.key, required this.reciverUserEmail, required this.reciverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  CustomColors _customColors = CustomColors();
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    //* only send message if there is something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.reciverUserID, _messageController.text);

      //* clear the text controller after send message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _customColors.dcDark,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(widget.reciverUserEmail),
        actions: [
          CircleAvatar(
              backgroundColor: _customColors.dcBlue,
              child: Image.network('https://picsum.photos/100')),
        ],
      ),
      body: Column(
        children: [
          //* messages
          Expanded(child: _buildMessageList()),

          //* user input
          _buildMessageInput(),

          const SizedBox(
            height: 25,
          ),
        ],
      ),
    );
  }

  //* build chat room message list
  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(
          widget.reciverUserID, _firebaseAuth.currentUser!.uid),
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

  //? build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //* align the messages to the right if the sender is the current user, otherwize to the left
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start),
          children: [
            Text(data['senderEmail']),
            ChatBubble(message: data['message']),
            Text(formatTimestamp(data['timestamp'])),
          ],
        ),
      ),
    );
  }

  //* build message input
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          //* textfield
          Expanded(
              child: CmTextField(
            obscureText: false,
            hintText: 'Write a message',
            controller: _messageController,
          )),

          //* send button
          IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                size: 40,
              )),
        ],
      ),
    );
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
}
