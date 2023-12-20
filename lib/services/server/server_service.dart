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
    List<String> ids = [serverName[5], '59021',serverDesc[2], '0'];
    ids.sort();
    String serverId = ids.join("_");

    //* add new server to user -> database
    await _fireStore.collection('users').doc(currentUserId).collection('servers').add(newServer.toMap());

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
}
