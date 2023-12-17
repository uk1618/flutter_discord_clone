import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  //* instance of auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //* instance of firestore
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  //* sign user in
  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      //* sign user in
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //* add a new document for the user in users collection if it doesn't already exists
      var user = userCredential.user!;
      _fireStore
          .collection('users')
          .doc(user.uid)
          .set({'uid': user.uid, 'email': user.email}, SetOptions(merge: true));

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //* create a new user
  Future<UserCredential> signUpWithEmailandPassword(
      String email, String password, String? photoUrl) async {
    if (photoUrl != null) {
      photoUrl = "https://picsum.photos/200";
    }
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //* after creating the user, create a new document for the user in the user collection
      var user = userCredential.user!;
      _fireStore.collection('users').doc(user.uid).set(
          {'uid': user.uid, 'email': user.email, 'photoUrl': photoUrl});

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  //* sign user out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
