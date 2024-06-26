import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clone/constants/custom_color.dart';

import '../../model/server.dart';

class ServerService extends ChangeNotifier {
  //* get instance of firestore
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> createServer2(
      String serverName, String serverDesc, String serverType) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    //* servers collection ref
    CollectionReference serverCollection = _fireStore.collection('servers');

    //* users collection ref
    CollectionReference usersCollection = _fireStore.collection('users');
    //* create a new server

//? Benzersiz bir ID ile sunucu koleksiyonuna doküman ekle
    DocumentReference serverDocRef = await serverCollection.add({
      serverName: serverName,
      serverDesc: serverDesc,
      serverType: serverType,
      timestamp: timestamp,
      // Diğer sunucu verileri buraya eklenebilir
    });

    // Aynı ID ile kullanıcı koleksiyonuna doküman ekle
    try {
      await usersCollection
          .doc(currentUserId)
          .collection('servers')
          .doc(serverDocRef.id)
          .set({
        'serverName': serverName,
        'serverDesc': serverDesc,
        'serverType': serverType,
        'timestamp': timestamp,
      });

      // Handle the completion of the set operation here
      print('Server document set successfully!');
    } catch (error) {
      // Handle errors here
      print('Error setting server document: $error');
    }
  }

  Future<void> createServer(
      String serverName, String serverDesc, String serverType) async {
    //* get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();

    Server newServer = Server(
      creator: currentUserId,
      serverName: serverName,
      serverDesc: serverDesc,
      serverType: serverType,
      timestamp: timestamp,
    );

    //* add new server to user -> database
    await _fireStore
        .collection('users')
        .doc(currentUserId)
        .collection('servers')
        .add(newServer.toMap());

    //* add new server to  server -> database
    await _fireStore.collection('servers').add(newServer.toMap());
  }

  //* kullanıcın üye olduğu sunucuları listele
  Stream<QuerySnapshot> getServers(String userId) {
    return _fireStore
        .collection('users')
        .doc(userId)
        .collection('servers')
        .snapshots();
  }

  //* get all servers
  Stream<QuerySnapshot> getAllServers() {
    return _fireStore.collection('servers').snapshots();
  }

  Future<void> createServerWithDefaultChannel(String currentUserId,
      String serverName, String serverDesc, String serverType) async {
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
        transaction.set(newUserChannelRef, {
          'channelName': 'Ana Kanal',
          'channelDesc': '',
          'channelType': 'metin'
        });

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

//* Sunucu Oluşturma

  Future<void> createServerWithDefaultChannel2(
    String currentUserId,
    String serverName,
    String serverDesc,
    String serverType,
  ) async {
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

    // Generate a single ID for both user's server document and general server document
    String serverId = FirebaseFirestore.instance.collection('dummy').doc().id;

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Create a new server (user) with the same ID
        DocumentReference newUserServerRef =
            userServersCollection.doc(serverId);
        transaction.set(newUserServerRef, newServer.toMap());

        // Create a new server with the same ID
        DocumentReference newServerRef = serverCollection.doc(serverId);
        transaction.set(newServerRef, newServer.toMap());

        // Create a default channel for the server (user)
        DocumentReference newUserChannelRef =
            newUserServerRef.collection('channels').doc();
        transaction.set(newUserChannelRef, {
          'channelName': 'Ana Kanal',
          'channelDesc': '',
          'channelType': 'metin'
        });

        // Create a default channel for the server
        DocumentReference newChannelRef =
            newServerRef.collection('channels').doc();
        transaction.set(newChannelRef, {
          'channelName': 'Ana Kanal',
          'channelDesc': '',
          'channelType': 'metin'
        });
      });

      print('Sunucu başlangıç kanalı ile birlikte başarıyla oluşturuldu');
    } catch (e) {
      print('Sunucu oluşturulrken bir hata meydana geldi: $e');
    }
  }

  Future<void> joinAserver(BuildContext context, String serverId,
      String serverName, String serverDesc, String serverType) async {
    //* get current user info
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    bool isMember;
    // Firestore bağlantısını başlat
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Koleksiyon ve belge referanslarını tanımla
    CollectionReference collectionReference =
        firestore.collection('users').doc(currentUserId).collection('servers');
    DocumentReference documentReference = collectionReference.doc(serverId);

    // Belgenin varlığını kontrol et
    DocumentSnapshot documentSnapshot = await documentReference.get();
    isMember = documentSnapshot.exists;
    //! dokuman olup olmadığı kontrol ediilecek
    if (!isMember) {
      Server newServer = Server(
        creator: serverId,
        serverName: serverName,
        serverDesc: serverDesc,
        serverType: serverType,
        timestamp: timestamp,
      );

      //* add new server to user -> database
      await _fireStore
          .collection('users')
          .doc(currentUserId)
          .collection('servers')
          .doc(serverId)
          .set(newServer.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: CustomColors().dcGreen,
              borderRadius:
                  BorderRadius.circular(8.0), // Optional: Add border radius
            ),
            child: Text(
              "${newServer.serverName} adlı sunucuya katıldınız!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white, // Set the text color to white
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: CustomColors().dcGrey,
              borderRadius:
                  BorderRadius.circular(8.0), // Optional: Add border radius
            ),
            child: Text(
              "Bu sunucuya zaten üyesiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CustomColors().dcRed, // Set the text color to white
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      );
    }
  }
}

Future<bool> userIsMember(String serverId) async {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final String currentUserId = _firebaseAuth.currentUser!.uid;
  bool isMember;
  // Firestore bağlantısını başlat
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Koleksiyon ve belge referanslarını tanımla
  CollectionReference collectionReference =
      firestore.collection('users').doc(currentUserId).collection('servers');
  DocumentReference documentReference = collectionReference.doc(serverId);

  // Belgenin varlığını kontrol et
  DocumentSnapshot documentSnapshot = await documentReference.get();
  isMember = documentSnapshot.exists;
  return isMember;
}

//* get channels
Stream<QuerySnapshot> getChannels(String userId, String otherUserId) {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  List<String> ids = [userId, otherUserId];
  ids.sort();
  String chatRoomId = ids.join("_");

  return _fireStore
      .collection('chat_rooms')
      .doc(chatRoomId)
      .collection('messages')
      .orderBy('timestamp', descending: false)
      .snapshots();
}
