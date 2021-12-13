import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  searchByName(String searchField) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: searchField)
        .get();
  }

  createChatRoom(chatRoomMap, String chatRoomId) {
    FirebaseFirestore.instance
        .collection('chat_room')
        .doc(chatRoomId)
        .set(chatRoomMap);
  }

  // TODO: исправить добавление пустых бесед
  // Future<void> deleteChatRoom(String chatRoomId) {
  //   FirebaseFirestore.instance.collection('chat_room').doc(chatRoomId).delete();
  // }

  getChats(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('chats')
        .orderBy('time', descending: false)
        .snapshots();
  }

  addMessage(String chatRoomId, messageMap) {
    FirebaseFirestore.instance
        .collection('chat_room')
        .doc(chatRoomId)
        .collection('chats')
        .add(messageMap);
  }

  getUserChats(String userName) async {
    return await FirebaseFirestore.instance
        .collection('chat_room')
        .where('users', arrayContains: userName)
        .snapshots();
  }
}
