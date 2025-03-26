import 'package:chat_app/models/comment.dart';
import 'package:chat_app/models/post.dart';
import 'package:chat_app/models/reply.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Post>> getPostsFromFollowing() async {
    final String currentUserId = _auth.currentUser!.uid;
    QuerySnapshot followingSnapshot = await _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .get();
    List<String> followedUserIds =
        followingSnapshot.docs.map((doc) => doc.id).toList();

    followedUserIds.add(currentUserId); // For showing user's own posts

    // if (followedUserIds.isEmpty) {
    //   return []; // No followed users
    // }
    //Query the posts collection for posts from followed users
      QuerySnapshot<Map<String, dynamic>> query = await _firestore
          .collection("posts")
          .where("author_id", whereIn: followedUserIds)
          .orderBy("timestamp", descending: true)
          .get();

      List<Post> posts =
          query.docs.map((doc) => Post.fromQueryDocumentSnapshot(doc)).toList();

    return posts;
  }

  Future<List<Post>> getUserPosts(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection("posts")
          .where("author_id", isEqualTo: userId)
          .orderBy("timestamp", descending: true)
          .get();
      return snapshot.docs
          .map((doc) => Post.fromQueryDocumentSnapshot(doc))
          .toList();
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<int> getPostsCount(String userId) {
    try {
      return _firestore
          .collection("posts")
          .where("author_id", isEqualTo: userId)
          .snapshots()
          .map((snapshot) => snapshot.size);
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getLikes(String postId) {
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("likes")
          .snapshots();
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<int> getPostLikesCount(String postId) {
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("likes")
          .snapshots()
          .map((snapshot) => snapshot.size);
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<int> getCommentLikesCount(String postId, String commentId) {
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("likes")
          .snapshots()
          .map((snapshot) => snapshot.size);
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<int> getReplyLikesCount(
      String postId, String commentId, String replyId) {
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .doc(replyId)
          .collection("likes")
          .snapshots()
          .map((snapshot) => snapshot.size);
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<List<Comment>> getComments(String postId) {
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .orderBy("timestamp", descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Comment.fromQueryDocumentSnapshot(doc))
              .toList());
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<int> getCommentsCount(String postId) {
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .snapshots()
          .map((snapshot) => snapshot.size);
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> sendPost(String content) async {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      await _firestore.collection("posts").add(Post(
              id: "",
              authorId: currentUserId,
              content: content,
              timestamp: Timestamp.now())
          .toMap());
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection("posts").doc(postId).delete();
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> likePost(String postId) async {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("likes")
          .doc(currentUserId)
          .set({});
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> unlikePost(String postId) async {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("likes")
          .doc(currentUserId)
          .delete();
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<DocumentSnapshot> isPostLiked(String postId) {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("likes")
          .doc(currentUserId)
          .snapshots();
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<List<Reply>> getReplies(String postId, String commentId) {
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .orderBy("timestamp", descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Reply.fromQueryDocumentSnapshot(doc))
              .toList());
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<int> getRepliesCount(String postId, String commentId) {
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .snapshots()
          .map((snapshot) => snapshot.size);
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> sendComment(String postId, String comment) async {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .add(Comment(
                  id: "",
                  postId: postId,
                  authorId: currentUserId,
                  content: comment,
                  timestamp: Timestamp.now())
              .toMap());
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      return await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .delete();
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> sendReply(String postId, String commentId, String reply) async {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .add(Reply(
                  id: "",
                  commentId: commentId,
                  authorId: currentUserId,
                  content: reply,
                  timestamp: Timestamp.now())
              .toMap());
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> deleteReply(
      String postId, String commentId, String replyId) async {
    try {
      return await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .doc(replyId)
          .delete();
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> likeComment(String postId, String commentId) async {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("likes")
          .doc(currentUserId)
          .set({});
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> unlikeComment(String postId, String commentId) async {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("likes")
          .doc(currentUserId)
          .delete();
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<DocumentSnapshot> isCommentLiked(String postId, String commentId) {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("likes")
          .doc(currentUserId)
          .snapshots();
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> likeReply(
      String postId, String commentId, String replyId) async {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .doc(replyId)
          .collection("likes")
          .doc(currentUserId)
          .set({});
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> unlikeReply(
      String postId, String commentId, String replyId) async {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      await _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .doc(replyId)
          .collection("likes")
          .doc(currentUserId)
          .delete();
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<DocumentSnapshot> isReplyLiked(
      String postId, String commentId, String replyId) {
    final String currentUserId = _auth.currentUser!.uid;
    try {
      return _firestore
          .collection("posts")
          .doc(postId)
          .collection("comments")
          .doc(commentId)
          .collection("replies")
          .doc(replyId)
          .collection("likes")
          .doc(currentUserId)
          .snapshots();
    } on FirebaseException {
      rethrow;
    }
  }
}
