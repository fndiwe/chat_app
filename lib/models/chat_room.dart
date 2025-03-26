import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List userIds;
  final Timestamp lastMessageTimestamp;

  ChatRoom(
      {required this.id,
      required this.userIds,
      required this.lastMessageTimestamp});

  factory ChatRoom.fromQueryDocumentSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> chatRoom = doc.data();
    return ChatRoom(
        id: doc.id,
        userIds: chatRoom["user_ids"],
        lastMessageTimestamp: chatRoom["last_message_timestamp"]);
  }

  Map<String, dynamic> toMap() => {
    "user_ids": userIds,
    "last_message_timestamp": lastMessageTimestamp
  };
}
