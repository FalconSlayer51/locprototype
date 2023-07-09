import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:locprototype/repos/chat_repo.dart';
import 'package:locprototype/screens/chat_screen.dart';
import 'package:locprototype/widgets/loader.dart';

import '../models/chat_contact_model.dart';

class ContactsScreen extends StatelessWidget {
  ContactsScreen({super.key});
  final chatRepo = ChatRepository();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChatContact>>(
      stream: chatRepo.getChatContactStream(),
      builder: (context, snapshot) {
        log(snapshot.hasData.toString());
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }
        if (snapshot.data!.isEmpty) {
          return const Center(
            child: Column(
              children: [
                Icon(Icons.no_accounts),
                SizedBox(
                  height: 20,
                ),
                Text("No contacts yet")
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            var messageData = snapshot.data![index];

            return InkWell(
              onTap: () => Navigator.of(context).push(
                ChatScreen.getRoute(
                    username: messageData.username,
                    photoUrl: messageData.profilePic,
                    recieverUid: messageData.contactId),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          messageData.profilePic,
                        ),
                        radius: 25,
                      ),
                      title: Container(
                        width: 30,
                        margin: const EdgeInsets.only(bottom: 5),
                        child: Text(
                          messageData.username,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      subtitle: Text(
                        '${messageData.contactId == FirebaseAuth.instance.currentUser!.uid ? 'You:' : ''}${messageData.lastMessage}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Text(
                        DateFormat.Hm().format(messageData.timeSent),
                      ),
                    ),
                    const Divider(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
