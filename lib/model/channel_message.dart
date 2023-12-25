import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelMessage {
  final String senderId;
  final String senderEmail;
  final String channelId;
  final String message;
  final Timestamp timestamp;

  ChannelMessage(
      {required this.senderId,
      required this.senderEmail,
      required this.channelId,
      required this.message,
      required this.timestamp});

  //* convert to a map
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': channelId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
