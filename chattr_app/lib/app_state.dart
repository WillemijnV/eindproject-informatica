// hier wordt de status van de app opgeslagen, zoals of iemand is ingelogd of niet
// ook gegevens zoals contacten, chat-berichten

import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool isLoggedIn = false;
  String? userId;
  String? userName;

  // login simulatie
  void login(String id, String name) {
    isLoggedIn = true;
    userId = id;
    userName = name;
    notifyListeners();
  }

  void logout() {
    isLoggedIn = false;
    userId = null;
    userName = null;
    notifyListeners();
  }

    // lijst met berichten
    List<String> messages = [];

  void sendMessage(String text) {
    messages.add(text);
    notifyListeners();
  }
}