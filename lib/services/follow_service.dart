import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> followUser(String targetUserId) async {
    final String currentUserId = _auth.currentUser!.uid;
    // Add target user to current user following list
    try {
      await _firestore
          .collection("users")
          .doc(currentUserId)
          .collection("following")
          .doc(targetUserId)
          .set({});
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }

    // Add current user to target user followers list
    try {
      await _firestore
          .collection("users")
          .doc(targetUserId)
          .collection("followers")
          .doc(currentUserId)
          .set({});
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> unfollowUser(String targetUserId) async {
    final String currentUserId = _auth.currentUser!.uid;
    // Remove target user from current user following list
    try {
      await _firestore
          .collection("users")
          .doc(currentUserId)
          .collection("following")
          .doc(targetUserId)
          .delete();
    } on FirebaseException {
      rethrow;
    }

    // Remove current user from target user followers list
    try {
      await _firestore
          .collection("users")
          .doc(targetUserId)
          .collection("followers")
          .doc(currentUserId)
          .delete();
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<int> getFollowersCount(String userId) {
    try {
      return _firestore
          .collection("users")
          .doc(userId)
          .collection("followers")
          .snapshots()
          .map((snapshot) => snapshot.size);
    } on FirebaseException catch (e) {
      throw Exception(e.message);
    }
  }

  Stream<int> getFollowingCount(String userId) {
    try {
      return _firestore
          .collection("users")
          .doc(userId)
          .collection("following")
          .snapshots()
          .map((snapshot) => snapshot.size);
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> isFollowing(String userId) {
    final String currentUserId = _auth.currentUser!.uid;
    try {
     return _firestore
          .collection("users")
          .doc(currentUserId)
          .collection("following")
          .doc(userId)
          .snapshots();
    } catch (e) {
      rethrow;
    }
  }
}
