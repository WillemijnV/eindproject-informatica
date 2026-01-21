//chat status, berichten

import 'package:flutter/material.dart';

class Message {
  final String text;
  final bool isMe;

  Message({
    required this.text,
    required this.isMe,
  });
}

class ChatState extends ChangeNotifier {
  final Map<String, List<Message>> _chats = {};

  List<Message> getMessage(String contactName) {
    return _chats[contactName] ?? [];
  }

  void sendMessage(String contactName, String text) {
    _chats.putIfAbsent(contactName, () => []);

    //berichten van gebruiker
    _chats[contactName]!.add(
      Message(text: text, isMe: true),
    );

    //contact antwoord simulatie
    _chats[contactName]!.add(
      Message(text: "Antwoord van $contactName", isMe: false),
    );

    notifyListeners();
  }

  void clearChats() {
    _chats.clear();
    notifyListeners();
  }
}