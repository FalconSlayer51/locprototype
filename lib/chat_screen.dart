import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  static Route getRoute() => MaterialPageRoute(
        builder: (context) => const ChatScreen(),
      );
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatScreen'),
      ),
      body: const Center(
        child: Text(
          'Hello this is chat screen',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
