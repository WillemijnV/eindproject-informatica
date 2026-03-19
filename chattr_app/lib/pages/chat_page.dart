//herbruikbare chatpagina voor het chatten met contacten

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chattr_app/chat_state.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String contactName;
  const ChatPage({required this.contactName, super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  Timer? _pollingTimer;

  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    final chatState = context.read<ChatState>();

    chatState.ensureChatExists(widget.contactName);
    chatState.fetchMessages(widget.contactName);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmojiPicker = false;
        });
      }
    });
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => chatState.fetchMessages(widget.contactName),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEmojiSelected(Category? category, Emoji emoji) {
    _controller
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
  }

  void _sendMessage(ChatState chatState) {
    if (_controller.text.trim().isEmpty) return;

    chatState.sendMessage(
      widget.contactName,
      _controller.text,
    );

    _controller.clear();
  }

  Future<void> _sendImage(ChatState chatState) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final filename = image.name;

    await chatState.sendImageWeb(
      widget.contactName,
      filename,
      bytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = context.watch<ChatState>();
    final messages = chatState.getMessages(widget.contactName);

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
                    child: FutureBuilder<String>(
                      future: chatState.decryptMessage(
                        message,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text("Decrypting...");
                        }

                        return Text(
                          snapshot.data!,
                          style: TextStyle(
                            color: message.isMe
                                ? Colors.black
                                : Colors.white,
                          ),
                        );
                      },
                    ),
                    child: message.text != null
                        ? Text(message.text!)
                        : (message.image != null
                            ? Image.network(
                                '${ChatState.baseUrl}/uploads/${message.image}',
                                width: 300,
                                height: 200,
                                fit: BoxFit.cover,
                            )
                            : const SizedBox()
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
          const Divider(height: 1),

          // Invoer veld
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Color.fromARGB(255, 19, 18, 75),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions, color: Colors.amber),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _showEmojiPicker = !_showEmojiPicker;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.photo_camera, color: Colors.amber),
                  onPressed: () => _sendImage(chatState),
                ),
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
                  onPressed: () async {
                    if (_controller.text.trim().isEmpty) return;

                    await chatState.sendMessage(
                      widget.contactName,
                      _controller.text.trim(),
                    );

                    _controller.clear();
                  },
                  child: const Icon(Icons.send),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.amber),
                  onPressed: () => _sendMessage(chatState),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
    