//chat status, berichten

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Message {
  final String? text;
  final String? image;
  final String user;
  final bool isMe;
  final DateTime timestamp;

  Message({
    required this.text,
    required this.image,
    required this.user,
    required this.isMe,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json, String myName) {
    return Message(
      text: json['text'],
      image: json['image'],
      user: json['user'],
      isMe: json['user'] == myName,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatState extends ChangeNotifier {
  final Map<String, List<Message>> _chats = {};
  final Set<String> _knownContacts = {};

  final Map<String, String> _chatPins = {};

  static const String baseUrl = 'https://729bd5b9-d330-416c-bbbf-87ce6cdd04a7-00-1kstgmc8ftol5.worf.replit.dev:5000';
  String? currentUser;

  Future<void> setCurrentUser(String username) async {
    currentUser = username;
    _chats.clear();

    await loadPinsLocal();
    notifyListeners();
  }

  Future<void> loadPinsLocal() async {
  final prefs = await SharedPreferences.getInstance();

  _chatPins.clear();

  for (final key in prefs.getKeys()) {
    if (key.startsWith('pin_')) {
      final contact = key.replaceFirst('pin_', '');
      final pin = prefs.getString(key);

      if (pin != null && pin.isNotEmpty) {
        _chatPins[contact] = pin;
      }
    }
  }

  notifyListeners();
}

  bool hasPin(String contact) => _chatPins.containsKey(contact);

  Future<bool> checkPin(String contact, String pin) async {
    if (!_chatPins.containsKey(contact)) return true; 

    return _chatPins[contact] == pin;
  }

  Future<void> setPin(String contact, String pin) async {
    _chatPins[contact] = pin;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin_$contact', pin); 

    notifyListeners();
  }

  Future<String?> getPin(String contact) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pin_$contact');
}

  Future<void> removePin(String contact) async {
    _chatPins.remove(contact);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pin_$contact'); 

    notifyListeners();
  }

  Future<void> loadPinsFromServer() async {
  if (currentUser == null) return;

  final response = await http.get(Uri.parse('$baseUrl/pins/$currentUser'));
  if (response.statusCode != 200) return;

  final Map<String, dynamic> data = jsonDecode(response.body);
  _chatPins.clear();
  data.forEach((contact, pin) {
    _chatPins[contact] = pin.toString();
  });

  notifyListeners();

  print("SERVER RESPONSE:   ${response.body}");
  print("LOADED PINS: $_chatPins");
}

Future<void> sendPinToServer(String contact, String pin) async {
  if (currentUser == null) return;

  await http.post(
    Uri.parse('$baseUrl/pins'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'user': currentUser,
      'contact': contact,
      'pin': pin,
    }),
  );
}

  void ensureChatExists(String contactName) {
    _chats.putIfAbsent(contactName, () => []);
  }

  List<Message> getMessage(String contactName) {
    return _chats[contactName] ?? [];
  }

  Future<void> loadAllChatsForUsers() async {
    if (currentUser == null) return;

    final response = await http.get(
      Uri.parse('$baseUrl/messages/$currentUser'),
    );

    if (response.statusCode != 200) return;

    final List data = jsonDecode(response.body);

    _chats.clear();

    for (final m in data) {
      final from = m['user'];
      final to = m['to'];

      final otherUser = from == currentUser ? to : from;

      _chats.putIfAbsent(otherUser, () => []);
      _chats[otherUser]!.add(
        Message.fromJson(m, currentUser!),
      );
    }
    notifyListeners();
  }

  //actieve contacten ophalen
  List<String> getActiveContacts() {
  final contacts = _chats.keys.toList();

  contacts.sort((a, b) {
    final aMessages = _chats[a];
    final bMessages = _chats[b];

    final aTime = (aMessages != null && aMessages.isNotEmpty)
        ? aMessages.last.timestamp
        : DateTime.fromMillisecondsSinceEpoch(0);

    final bTime = (bMessages != null && bMessages.isNotEmpty)
        ? bMessages.last.timestamp
        : DateTime.fromMillisecondsSinceEpoch(0);

    return bTime.compareTo(aTime); 
  });

  return contacts;
}

  Future<List<String>> getNewContacts() async {
    if (currentUser == null) return [];
    
    final allUsersResponse = await http.get(Uri.parse('$baseUrl/users'));
    if (allUsersResponse.statusCode != 200) return [];

    final List<String> allUsers = List<String>.from(jsonDecode(allUsersResponse.body));

    final List<String> newContacts = allUsers
      .where((u) => u != currentUser && !_chats.containsKey(u))
      .cast<String>()
      .toList();

    return newContacts;
  }

  Future<void> fetchMessages(String contactName) async {
    final response = await http.get(Uri.parse('$baseUrl/messages'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;

      _chats[contactName] = data
        .where((m) => 
          (m['user']?.toString() == currentUser && m['to']?.toString() == contactName) ||
          (m['user']?.toString() == contactName && m['to']?.toString() == currentUser))
        .map<Message>((m) => Message.fromJson(m, currentUser!))
        .toList();

      notifyListeners();
    }
  }

  Future<void> sendMessage(String contactName, String text) async {
    if (currentUser == null) return;
    
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': currentUser,
        'to': contactName,
        'text': text,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      _knownContacts.add(contactName);
      _chats.putIfAbsent(contactName, () => []);
      await fetchMessages(contactName);
    }
  }

  Future<void> sendImageWeb(String contactName, String filename, List<int> bytes) async {
    if (currentUser == null) return;

    final uri = Uri.parse('$baseUrl/images');
    final request = http.MultipartRequest('POST', uri);

    request.fields['user'] = currentUser!;
    request.fields['to'] = contactName;
    request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename));

    final response = await request.send();

    if (response.statusCode == 201) {
      _chats.putIfAbsent(contactName, () => []);
      await fetchMessages(contactName);
    }
  }

  void clearChats() {
    _chats.clear();
    notifyListeners();
  }
}