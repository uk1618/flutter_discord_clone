import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/model/message.dart';

class ChatService extends ChangeNotifier {
  //* firebaseauth ve firebasestore'dan instance alma
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //* mesaj gönder fonkisyonu
  Future<void> sendMessage(String reciverId, String message) async {
    //* şuanki kullancının id'si
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    //* yeni mesaj oluştur
    Message newMessage = Message(
        senderId: currentUserId,
        senderEmail: currentUserEmail,
        reciverId: reciverId,
        message: message,
        timestamp: timestamp);

    //* construct chat room id from current user id and recevier id
    List<String> ids = [currentUserId, reciverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    //*     //* yeni mesajı firestore'a ekle
    await _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());
  }

  //* mesajları getir
  Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
     //* construct chat room id from current user id and recevier otherUserId
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }




}

