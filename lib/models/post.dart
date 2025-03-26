import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String authorId;
  final String content;
  final Timestamp timestamp;

  Post(
      {required this.id,
      required this.authorId,
      required this.content,
      required this.timestamp});

  Map<String, dynamic> toMap() =>
      {"author_id": authorId, "content": content, "timestamp": timestamp};

  factory Post.fromQueryDocumentSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> post = doc.data();
    return Post(
        id: doc.id,
        authorId: post["author_id"],
        content: post["content"],
        timestamp: post["timestamp"]);
  }
}
