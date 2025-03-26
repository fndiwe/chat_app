import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String recieverId;
  final String text;
  final bool read;
  final Timestamp timestamp;

  Message(
      {required this.id,
      required this.chatId,
      required this.senderId,
      required this.recieverId,
      required this.text,
      required this.read,
      required this.timestamp});

  Map<String, dynamic> toMap() => {
        "chat_id": chatId,
        "sender_id": senderId,
        "reciever_id": recieverId,
        "message": text,
        "read": read,
        "timestamp": timestamp
      };

  factory Message.fromQueryDocumentSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> map = doc.data();
    return Message(
        id: doc.id,
        chatId: map["chat_id"],
        senderId: map["sender_id"],
        recieverId: map["reciever_id"],
        text: map["message"],
        read: map["read"],
        timestamp: map["timestamp"]);
  }
}
