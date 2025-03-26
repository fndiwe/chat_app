import 'package:chat_app/models/chat_room.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<AppUser>> getUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> users =
          await _firestore.collection("users").get();
      return users.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<List<ChatRoom>> getChats() {
    final User currentUser = _auth.currentUser!;
    try {
      return _firestore
          .collection("chats")
          .where("user_ids", arrayContains: currentUser.uid)
          .orderBy("last_message_timestamp", descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ChatRoom.fromQueryDocumentSnapshot(doc))
              .toList());
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> sendMessage(String recieverId, String message) async {
    final User currentUser = _auth.currentUser!;
    final String id = currentUser.uid;
    final Timestamp timestamp = Timestamp.now();
    List<String> ids = [id, recieverId];
    ids.sort();
    String chatId = ids.join("_");
    DocumentSnapshot chatRoom;

    try {
      chatRoom = await _firestore.collection("chats").doc(chatId).get();
    } on FirebaseException {
      rethrow;
    }

    bool isFirstMessage = !chatRoom.exists;

    if (isFirstMessage) {
      // Create chat room
      try {
        await _firestore.collection("chats").doc(chatId).set(ChatRoom(
              id: chatId,
              userIds: ids,
              lastMessageTimestamp: timestamp,
            ).toMap());
      } on FirebaseException {
        rethrow;
      }
    } else {
      // Update the timestamp and lastMessage content
      try {
        await _firestore
            .collection("chats")
            .doc(chatId)
            .update({"last_message_timestamp": timestamp});
      } on FirebaseException {
        rethrow;
      }
    }

    Message newMessage = Message(
        id: "",
        chatId: chatId,
        senderId: id,
        recieverId: recieverId,
        text: message,
        read: false,
        timestamp: timestamp);

    try {
      await _firestore.collection("messages").add(newMessage.toMap());
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<List<Message>> getMessages(String currentUserId, String otherId) {
    List ids = [currentUserId, otherId];
    ids.sort();
    String chatRoomId = ids.join("_");
    try {
      return _firestore
          .collection("messages")
          .where("chat_id", isEqualTo: chatRoomId)
          .orderBy("timestamp")
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Message.fromQueryDocumentSnapshot(doc))
              .toList());
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<int> getUnreadMessagesCount(String currentUserId, String otherId) {
    List ids = [currentUserId, otherId];
    ids.sort();
    String chatRoomId = ids.join("_");

    try {
      return _firestore
          .collection("messages")
          .where("chat_id", isEqualTo: chatRoomId)
          .where("reciever_id",
              isEqualTo:
                  currentUserId) // Get only messages from the other users
          .where("read", isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.size);
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<int> getAllUnreadMessagesCount(String currentUserId) {
    try {
      return _firestore
          .collection("messages")
          .where("reciever_id",
              isEqualTo:
                  currentUserId) // Get only messages from the other users
          .where("read", isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.size);
    } on FirebaseException {
      rethrow;
    }
  }

  Future<void> setMessagesAsRead(String currentUserId, String otherId) async {
    List ids = [currentUserId, otherId];
    ids.sort();
    String chatRoomId = ids.join("_");
    try {
      final QuerySnapshot unreadMessages = await _firestore
          .collection("messages")
          .where("chat_id", isEqualTo: chatRoomId)
          .where("reciever_id",
              isEqualTo:
                  currentUserId) // Get only messages from the other users
          .where("read", isEqualTo: false)
          .get();
      for (final message in unreadMessages.docs) {
        await _firestore
            .collection("messages")
            .doc(message.id)
            .update({"read": true});
      }
    } on FirebaseException {
      rethrow;
    }
  }

  Stream<Message> getLatestMessage(String currentUserId, String otherId) {
    List ids = [currentUserId, otherId];
    ids.sort();
    String chatRoomId = ids.join("_");

    try {
      return _firestore
          .collection("messages")
          .where("chat_id", isEqualTo: chatRoomId)
          .orderBy("timestamp", descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Message.fromQueryDocumentSnapshot(doc))
              .first);
    } on FirebaseException {
      rethrow;
    }
  }
}
