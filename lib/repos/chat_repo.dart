import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../common/message_enum.dart';
import '../models/chat_contact_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class ChatRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void saveLastMessage({
    required BuildContext context,
    required String contactId,
    required String contactName,
    required String contactProfilePic,
    required String lastMessage,
    required String timeSent,
  }) async {
    try {
      await _firestore.collection('users').doc(_auth.currentUser!.uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  void _saveContactData({
    required String senderId,
    required String recieverId,
    required String lastMessage,
    required DateTime timeSent,
  }) async {
    final recieverData =
        await _firestore.collection('users').doc(recieverId).get();
    var recieverModel = UserModel(
      username: recieverData['username'],
      uid: recieverData['uid'],
      profilePhoto: recieverData['profilePhoto'],
    );

    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverId)
        .set({
      'contactId': recieverModel.uid,
      'username': recieverModel.username,
      'profilePic': recieverModel.profilePhoto,
      'lastMessage': lastMessage,
      'timeSent': timeSent.millisecondsSinceEpoch,
    });

    final senderData =
        await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
    var senderModel = UserModel(
      username: senderData['username'],
      uid: senderData['uid'],
      profilePhoto: senderData['profilePhoto'],
    );

    await _firestore
        .collection('users')
        .doc(recieverId)
        .collection('chats')
        .doc(_auth.currentUser!.uid)
        .set({
      'contactId': senderModel.uid,
      'username': senderModel.username,
      'profilePic': senderModel.profilePhoto,
      'lastMessage': lastMessage,
      'timeSent': timeSent.millisecondsSinceEpoch,
    });
  }

  void saveMessageToMessageSubCollection({
    required MessageModel messageModel,
    required BuildContext context,
    required String senderId,
    required String recieverId,
  }) async {
    try {
      _saveContactData(
        lastMessage: messageModel.text,
        recieverId: recieverId,
        senderId: senderId,
        timeSent: messageModel.timeSent,
      );
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverId)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(
            messageModel.toMap(),
          );
      await _firestore
          .collection('users')
          .doc(recieverId)
          .collection('chats')
          .doc(_auth.currentUser!.uid)
          .collection('messages')
          .doc(messageModel.messageId)
          .set(messageModel.toMap());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Stream<List<ChatContact>> getChatContactStream() {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('chats')
        .snapshots()
        .asyncMap((event) async {
      List<ChatContact> contacts = [];
      for (var document in event.docs) {
        var contact = ChatContact.fromMap(document.data());
        contacts.add(contact);
      }

      return contacts;
    });
  }

  Stream<List<MessageModel>> getChatStream({required String recieverUid}) {
    return _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .collection('chats')
        .doc(recieverUid)
        .collection('messages')
        .orderBy('timeSent', descending: true)
        .snapshots()
        .map((event) {
      List<MessageModel> messages = [];
      for (var element in event.docs) {
        final message = MessageModel.fromMap(element.data());
        messages.add(message);
      }
      return messages;
    });
  }

  void setChatMessageSeen(
    BuildContext context,
    String recieverUserId,
    String messageId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('chats')
          .doc(recieverUserId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});

      //  showSnackBar(context: context, content: messageId);
      await _firestore
          .collection('users')
          .doc(recieverUserId)
          .collection('chats')
          .doc(_auth.currentUser!.uid)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}
