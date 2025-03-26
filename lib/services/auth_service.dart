import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

class AuthService {
  //instance of firebase auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      //sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  //register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String firstName, String lastName) async {
    try {
      //register with email and password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (user != null) {
        _firestore.collection("users").doc(user.uid).set(AppUser(
                id: user.uid,
                email: user.email!,
                firstName: firstName.trim(),
                lastName: lastName.trim(),
                timestamp: Timestamp.now())
            .toMap());
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  //sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<AppUser?> getUser(String? id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> user =
          await _firestore.collection("users").doc(id).get();
      Map<String, dynamic>? data = user.data();
      return data != null ? AppUser.fromMap(data) : Future.value(null);
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> editUser(String firstName, String lastName, String? bio,
      String? profilePhotoUrl) async {
    try {
      await _firestore.collection("users").doc(_auth.currentUser!.uid).update({
        "first_name": firstName,
        "last_name": lastName,
        "bio": bio,
        "profile_photo_url": profilePhotoUrl
      });
    } on FirebaseException {
      rethrow;
    }
  }
}
