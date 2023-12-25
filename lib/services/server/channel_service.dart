import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/model/channel_message.dart';

class ChannelService extends ChangeNotifier{
  //* firebaseauth ve firebasestore'dan instance alma
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //* mesaj gönder fonkisyonu
  Future<void> sendMessage(String channelId, String message, String serverId) async {
    //* şuanki kullancının id'si
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    //* yeni mesaj oluştur
    ChannelMessage newMessage = ChannelMessage(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        channelId: channelId,
        message: message,
        timestamp: timestamp);


    //* yeni mesajı firestore'a ekle
    await _fireStore.collection('servers').doc(serverId).collection('channels').doc(channelId).collection('messages').add(newMessage.toMap());
  }

  //* mesajları getir
  Stream<QuerySnapshot> getMessages(String userId, String channelId, String serverId){
    return _fireStore.collection('servers').doc(serverId).collection('channels').doc(channelId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }




}