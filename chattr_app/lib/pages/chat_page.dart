//herbruikbare chatpagina voor het chatten met contacten

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chattr_app/chat_state.dart';

class ChatPage extends StatefulWidget {
  final String contactName;
  ChatPage({required this.contactName});

  @override
  State<ChatPage> createState() => _ChatPageState();

}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatState = context.watch<ChatState>();
    final messages = chatState.getMessage(widget.contactName);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return Align(
                  alignment: message.isMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: message.isMe
                        ? Colors.amber
                        : Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: 
                          message.isMe ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Typ hier je bericht...",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isEmpty) return;

                    chatState.sendMessage(
                      widget.contactName,
                      _controller.text,
                    );

                    _controller.clear();
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
