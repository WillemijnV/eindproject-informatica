//chat status, berichten

import 'package:chattr_app/services/crypto_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cryptography/cryptography.dart';

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

  Map<String, dynamic> toJson() => {
      'text': text,
      'image': image,
      'user': user,
      'isMe': isMe,
      'timestamp': timestamp.toIso8601String(),
    };

  static Message fromJson(Map<String, dynamic> json) => Message(
        text: json['text'],
        image: json['image'],
        user: json['user'],
        isMe: json['isMe'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}

class ChatState extends ChangeNotifier {
  final Map<String, List<Message>> _chats = {};
  final Set<String> _knownContacts = {};

  final Map<String, String> _chatPins = {};

  static const String baseUrl = 'https://729bd5b9-d330-416c-bbbf-87ce6cdd04a7-00-1kstgmc8ftol5.worf.replit.dev:5000';
  String? currentUser;

  Future<void> saveChatsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    for (var contact in _chats.keys) {
      final messages = _chats[contact]!.map((m) => m.toJson()).toList();
      await prefs.setString('chat_${currentUser}_$contact', jsonEncode(messages));
    }
  }

  Future<void> loadChatsLocally() async {
    if (currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    for (var key in prefs.getKeys()) {
      if (key.startsWith('chat_${currentUser}_')) {
        final contact = key.replaceFirst('chat_${currentUser}_', '');
        final stored = prefs.getString(key);
        if (stored != null) {
          final List data = jsonDecode(stored);
          _chats[contact] = data.map((m) => Message.fromJson(m)).toList();
        }
      }
    }
    notifyListeners();
  }

  Future<void> setCurrentUser(String username) async {
    currentUser = username;
    _chats.clear();
    _chatPins.clear();

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('pin_${currentUser}_')) {
        final contact = key.replaceFirst('pin_${currentUser}_', '');
        _chatPins[contact] = prefs.getString(key)!;
      }
    }

    await loadChatsLocally();
    notifyListeners();
  }

  Future<void> loadPins() async {
  if (currentUser == null) return;

  final prefs = await SharedPreferences.getInstance();
  _chatPins.clear();

  for (final key in prefs.getKeys()) {
    if (key.startsWith('pin_$currentUser!_')) {
      final contact = key.split('_')[2];
      _chatPins[contact] = prefs.getString(key)!;
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
    if (currentUser == null) return;

    _chatPins[contact] = pin;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin_${currentUser}_$contact', pin); 

    notifyListeners();
  }

  Future<String?> getPin(String contact) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('pin_$contact');
}

  Future<void> removePin(String contact) async {
    _chatPins.remove(contact);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pin_${currentUser}_$contact'); 

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
        Message.fromJson(m),
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
    if (currentUser == null) return;

    final response = await http.get(Uri.parse('$baseUrl/messages/$currentUser'));
    if (response.statusCode != 200) return;

    final List data = jsonDecode(response.body);

    _chats[contactName]?.clear();

    for (final m in data) {
      if ((m['user'] == currentUser && m['to'] == contactName) ||
          (m['user'] == contactName && m['to'] == currentUser)) {

        SecretKey key;
        if (m['user'] == currentUser) {
          key = await CryptoService.getAESKey(currentUser!);
        } else {
          key = await CryptoService.getAESKey(m['user']);
        }

        final decryptedText = await CryptoService.decrypt({
          'cipherText': m['cipherText'],
          'nonce': m['nonce'],
          'mac': m['mac'],
        }, key);

        final exists = _chats[contactName]!.any((msg) =>
          msg.timestamp.toIso8601String() == m['timestamp'] &&
          msg.user == m['user']
        );
        if (exists) continue;

        _chats.putIfAbsent(contactName, () => []);          
        _chats[contactName]!.add(Message(
          text: decryptedText,
          image: m['image'],
          user: m['user'],
          isMe: m['user'] == currentUser,
          timestamp: DateTime.parse(m['timestamp']),
        ));
      }
    }
    
    await saveChatsLocally();
    notifyListeners();
  }

  void clearChats() {
    _chats.clear();
    notifyListeners();
  }

  Future<void> sendMessage(String contactName, String text) async {
    if (currentUser == null) return;

    final key = await CryptoService.getAESKey(currentUser!);
    final encrypted = await CryptoService.encrypt(text, key);

    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': currentUser,
        'to': contactName,
        'cipherText': encrypted['cipherText'],
        'nonce': encrypted['nonce'],
        'mac': encrypted['mac'],
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception("Bericht kan niet worden verzonden");
    }

    _knownContacts.add(contactName);
    _chats.putIfAbsent(contactName, () => []);
    _chats[contactName]!.add(Message(
      text: text,
      image: null,
      user: currentUser!,
      isMe: true,
      timestamp: DateTime.now(),
    ));

    await saveChatsLocally();
    notifyListeners();
  }

  List<Message> getMessages(String contactName) => _chats[contactName] ?? [];


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
}