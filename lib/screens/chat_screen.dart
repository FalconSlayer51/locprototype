import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:locprototype/common/message_enum.dart';
import 'package:locprototype/models/message_model.dart';
import 'package:locprototype/repos/chat_repo.dart';
import 'package:uuid/uuid.dart';
import '../widgets/loader.dart';

class ChatScreen extends StatefulWidget {
  static Route getRoute(
          {required String username,
          required String photoUrl,
          required String recieverUid}) =>
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          username: username,
          photoUrl: photoUrl,
          recieverUid: recieverUid,
        ),
      );
  const ChatScreen(
      {super.key,
      required this.username,
      required this.photoUrl,
      required this.recieverUid});

  final String username;
  final String photoUrl;
  final String recieverUid;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.photoUrl),
          ),
          title: Text(widget.username),
        ),
      ),
      body: MessageCard(
        controller: _controller,
        recieverId: widget.recieverUid,
        recieverUsername: widget.username,
        photoUrl: widget.photoUrl,
      ),
    );
  }
}

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required TextEditingController controller,
    required this.recieverId,
    required this.recieverUsername,
    required this.photoUrl,
  }) : _controller = controller;

  final TextEditingController _controller;
  final String recieverId;
  final String recieverUsername;
  final String photoUrl;
  @override
  Widget build(BuildContext context) {
    final ChatRepository chatRepository = ChatRepository();
    final ScrollController controller = ScrollController();
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: chatRepository.getChatStream(recieverUid: recieverId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Loader();
                }
                if (snapshot.hasData) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    controller.jumpTo(controller.position.maxScrollExtent);
                  });
                  return MessageList(
                    messageData: snapshot.data!,
                    controller: controller,
                  );
                } else {
                  return const Center(child: Text('so empty'));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  onPressed: () async {
                    final text = _controller.text;

                    var message = MessageModel(
                      senderId: FirebaseAuth.instance.currentUser!.uid,
                      recieverId: recieverId,
                      text: text,
                      type: MessageEnum.text,
                      timeSent: DateTime.now(),
                      messageId: const Uuid().v1(),
                      isSeen: false,
                    );
                    final chatRepo = ChatRepository();

                    chatRepo.saveMessageToMessageSubCollection(
                      messageModel: message,
                      context: context,
                      senderId: FirebaseAuth.instance.currentUser!.uid,
                      recieverId: recieverId,
                    );
                    _controller.text = '';
                  },
                  child: const Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  const MessageList({
    super.key,
    required this.messageData,
    required this.controller,
  });
  final ScrollController controller;
  final List<MessageModel> messageData;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      controller: controller,
      itemCount: messageData.length,
      itemBuilder: (context, index) {
        var message = messageData[index];
        return Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 45,
            ),
            child: Align(
              alignment:
                  message.senderId == FirebaseAuth.instance.currentUser!.uid
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: const Color.fromARGB(255, 234, 152, 249),
                margin: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(message.text),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.done_all,
                            size: 20,
                            color: message.isSeen ? Colors.blue : Colors.black,
                          ),
                          Text(
                            DateFormat.Hm().format(message.timeSent),
                            style: const TextStyle(fontSize: 13),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
