import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final Timestamp timestamp;

  Comment(
      {required this.id,
      required this.postId,
      required this.authorId,
      required this.content,
      required this.timestamp});

  factory Comment.fromQueryDocumentSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> comment = doc.data();
    return Comment(
        id: doc.id,
        postId: comment["post_id"],
        authorId: comment["author_id"],
        content: comment["content"],
        timestamp: comment["timestamp"]);
  }

  Map<String, dynamic> toMap() => {
    "post_id": postId,
    "author_id": authorId,
    "content": content,
    "timestamp": timestamp
  };
}
