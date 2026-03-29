//chat status, berichten

import 'package:chattr_app/services/crypto_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class Message {
  final String? text;
  final String? image;
  final String user;
  final bool isMe;
  final DateTime timestamp;

  final String? cipherText;
  final String? nonce;
  final String? mac;

  Message({
    required this.text,
    required this.image,
    required this.user,
    required this.isMe,
    required this.timestamp,
    this.cipherText,
    this.nonce,
    this.mac,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'image': image,
        'user': user,
        'isMe': isMe,
        'timestamp': timestamp.toIso8601String(),
        'cipherText': cipherText,
        'nonce': nonce,
        'mac': mac,
      };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        text: json['text'],
        image: json['image'],
        user: json['user'],
        isMe: json['isMe'],
        timestamp: DateTime.parse(json['timestamp']),
        cipherText: json['cipherText'],
        nonce: json['nonce'],
        mac: json['mac'],
      );
}

class ChatState extends ChangeNotifier {
  final Map<String, List<Message>> _chats = {};
  final Set<String> _knownContacts = {};
  final Map<String, String> _chatPins = {};

  static const String baseUrl = 'https://729bd5b9-d330-416c-bbbf-87ce6cdd04a7-00-1kstgmc8ftol5.worf.replit.dev:5000';
  String? currentUser;

  String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    return sha256.convert(bytes).toString();  
  }

  bool hasPin(String contact) => _chatPins.containsKey(contact);

  Future<bool> checkPin(String contact, String inputPin) async {
    if (!_chatPins.containsKey(contact)) return true;     
    final hashedInput = _hashPin(inputPin);
    return _chatPins[contact] == hashedInput;
  }

  Future<void> setPin(String contact, String pin) async {
    if (currentUser == null) return;

    final hashedPin = _hashPin(pin);
    _chatPins[contact] = hashedPin;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pin_${currentUser}_$contact', hashedPin);

    final response = await http.post(
      Uri.parse('$baseUrl/pins'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': currentUser,
        'contact': contact,
        'pin': hashedPin,
      }),
    );

    if(response.statusCode != 201) {
      throw Exception("PIN kon niet opgeslagen worden");
    }

    notifyListeners();
  }

  Future<void> removePin(String contact) async {
    _chatPins.remove(contact);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pin_${currentUser}_$contact'); 

    await http.post(
      Uri.parse('$baseUrl/pins'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': currentUser,
        'contact': contact,
        'pin': null,
      }),
    );

    notifyListeners();
  }

  Future<void> loadPinsFromServer() async {
    if (currentUser == null) return;

    final response = await http.get(Uri.parse('$baseUrl/pins/$currentUser'));
    if (response.statusCode != 200) return;

    final Map<String, dynamic> data = jsonDecode(response.body);
    _chatPins.clear();

    final prefs = await SharedPreferences.getInstance();
    for (var contact in data.keys) {
      final hashedPin = data[contact].toString();
      _chatPins[contact] = hashedPin;
      await prefs.setString('pin_${currentUser}_$contact', hashedPin);
    }

    notifyListeners();
  }

  Future<void> setCurrentUser(String username) async {
    currentUser = username;
    _chats.clear();
    _chatPins.clear();

    await loadPinsFromServer();
    await loadChatsLocally();
    notifyListeners();
  }

  
  void ensureChatExists(String contactName) {
    _chats.putIfAbsent(contactName, () => []);
  }

  List<Message> getMessage(String contactName) => _chats[contactName] ?? [];

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

  void clearChats() {
    _chats.clear();
    notifyListeners();
  }

  Future<void> saveChatsLocally() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonChats = _chats.map((contact, messages) {
      return MapEntry(
        contact,
        messages.map((m) => m.toJson()).toList(),
      );
    });
    
    await prefs.setString('chats', jsonEncode(jsonChats));
  }

  Future<void> loadChatsLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('chats');
    if (stored == null) return;

    final Map<String, dynamic> jsonChats = jsonDecode(stored);
    _chats.clear();
    
    jsonChats.forEach((contact, messages) {
      _chats[contact] = (messages as List)
      .map((m) => Message.fromJson(m))
      .toList();
    });

    notifyListeners();
  }

  Future<void> sendMessage(String contactName, String text) async {
    if (currentUser == null) return;

    final key = await CryptoService.getChatKey(currentUser!, contactName);
    final encrypted = await CryptoService.encrypt(text, key);

    _knownContacts.add(contactName);
    _chats.putIfAbsent(contactName, () => []).add(
    Message(
      text: text,
      image: null,
      user: currentUser!,
      isMe: true,
      timestamp: DateTime.now(),
    ));

    await saveChatsLocally();
    notifyListeners();

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

  Future<void> fetchMessages(String contactName) async {         
    if (currentUser == null) return;

    _chats.putIfAbsent(contactName, () => []);

    final response = await http.get(Uri.parse('$baseUrl/messages/$currentUser')); 
    if (response.statusCode != 200) return;

    final data = jsonDecode(response.body) as List<dynamic>;
  
    for (final m in data) {
      if ((m['user'] == currentUser && m['to'] == contactName) ||
          (m['user'] == contactName && m['to'] == currentUser)) {
        if ((m['cipherText']?.isEmpty ?? true) && (m['image']?.isEmpty ?? true)) continue;

        final key = await CryptoService.getChatKey(currentUser!, contactName);

        final decryptedText = m['cipherText'] != null
          ? await CryptoService.decrypt({
              'cipherText': m['cipherText'],
              'nonce': m['nonce'],
              'mac': m['mac'],
            }, key)
          : null;      
            
        final exists = _chats.putIfAbsent(contactName, () => []).any((msg) =>
            msg.timestamp.toIso8601String() == m['timestamp'] && msg.user == m['user']);
        if (exists) continue;

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

  Future<String?> getPin(String contact) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pin_${currentUser}_$contact');
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
      
      final key = await CryptoService.getChatKey(currentUser!, otherUser);

      String? decryptedText;

      if (m['cipherText'] != null) {
        decryptedText = await CryptoService.decrypt({
          'cipherText': m['cipherText'],
          'nonce': m['nonce'],
          'mac': m['mac'],
        }, key);
      }

      _chats[otherUser]!.add(
        Message(
          text: decryptedText,
          image: m['image'],
          user: m['user'],
          isMe: m['user'] == currentUser,
          timestamp: DateTime.parse(m['timestamp']),
        ),
      );
    }
    notifyListeners();
  } 

  List<Message> getMessages(String contactName) => _chats[contactName] ?? [];
}
