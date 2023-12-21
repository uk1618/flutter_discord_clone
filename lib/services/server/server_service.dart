
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../model/server.dart';

class ServerService extends ChangeNotifier {
  //* get instance of firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> createServer(
      String serverName, String serverDesc, String serverType) async {
    //* get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    //* create a new server

    Server newServer = Server(
      creator: currentUserId,
      serverName: serverName,
      serverDesc: serverDesc,
      serverType: serverType,
      timestamp: timestamp,
    );

    //* construct unique serverID combine userID and timestamp
    //! bu iyi bir yöntem değil değiştirelecek
    List<String> ids = [serverName[5], '59021', serverDesc[2], '0'];
    ids.sort();
    String serverId = ids.join("_");

    //* add new server to user -> database
    await _fireStore
        .collection('users')
        .doc(currentUserId)
        .collection('servers')
        .add(newServer.toMap());

    //* add new server to  server -> database
    await _fireStore.collection('servers').add(newServer.toMap());
  }

  //* get user member of servers
  Stream<QuerySnapshot> getServers(String userId) {
    return _fireStore
        .collection('users')
        .doc(userId)
        .collection('servers')
        .snapshots();
  }

  Future<void> createServerWithDefaultChannel(
      String currentUserId,
      String serverName,
      String serverDesc,
      String serverType) async {
   
    final CollectionReference userServersCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('servers');
    final CollectionReference serverCollection =
        FirebaseFirestore.instance.collection('servers');
    final Timestamp timestamp = Timestamp.now();

    Server newServer = Server(
      creator: currentUserId,
      serverName: serverName,
      serverDesc: serverDesc,
      serverType: serverType,
      timestamp: timestamp,
    );

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Create  a new server (user)
        DocumentReference newUserServerRef = userServersCollection.doc();
        transaction.set(newUserServerRef, newServer.toMap());

        // Create a new server
        DocumentReference newServerRef = serverCollection.doc();
        transaction.set(newServerRef, newServer.toMap());

        // Create a default channel for the server (user)
        DocumentReference newUserChannelRef =
            newUserServerRef.collection('channels').doc();
        transaction.set(newUserChannelRef,
            {'name': 'Ana Kanal', 'desc': '', 'type': 'metin'});

        // Create a default channel for the server
        DocumentReference newChannelRef =
            newServerRef.collection('channels').doc();
        transaction.set(
            newChannelRef, {'name': 'Ana Kanal', 'desc': '', 'type': 'metin'});
      });

      print('Sunucu başlangıç kanalı ile birlikte başarıyla oluşturuldu');
    } catch (e) {
      print('Sunucu oluşturulrken bir hata meydana geldi: $e');
    }
  }



    //* get channels
  Stream<QuerySnapshot> getChannels(String userId, String otherUserId){
     
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }
}
