import 'package:cloud_firestore/cloud_firestore.dart';

class Reply {
  final String id;
  final String commentId;
  final String authorId;
  final String content;
  final Timestamp timestamp;

  Reply(
      {required this.id,
      required this.commentId,
      required this.authorId,
      required this.content,
      required this.timestamp});

  factory Reply.fromQueryDocumentSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> reply = doc.data();
    return Reply(
        id: doc.id,
        commentId: reply["comment_id"],
        authorId: reply["author_id"],
        content: reply["content"],
        timestamp: reply["timestamp"]);
  }

  Map<String, dynamic> toMap() => {
        "comment_id": commentId,
        "author_id": authorId,
        "content": content,
        "timestamp": timestamp
      };
}
