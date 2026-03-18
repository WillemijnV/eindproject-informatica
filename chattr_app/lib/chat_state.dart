import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chattr_app/services/crypto_service.dart';

class Message {
  final String text;
  final String user;
  final bool isMe;

  Message({
    required this.text,
    required this.user,
    required this.isMe,
  });

  factory Message.fromJson(Map<String, dynamic> json, String myName) {
    return Message(
      text: json['text'],
      user: json['user'],
      isMe: json['user'] == myName,
    );
  }
}

class ChatState extends ChangeNotifier {
  final Map<String, List<Message>> _chats = {};
  final Set<String> _knownContacts = {};

  static const String baseUrl = 'https://729bd5b9-d330-416c-bbbf-87ce6cdd04a7-00-1kstgmc8ftol5.worf.replit.dev:5000';
  String? currentUser;

  void setCurrentUser(String username) {
    currentUser = username;
    _chats.clear();
    notifyListeners();
  }

  void ensureChatExists(String contactName) {
    _chats.putIfAbsent(contactName, () => []);
  }

  List<Message> getMessages(String contactName) {
    return _chats[contactName] ?? [];
  }

  Future<void> loadAllChatsForUsers() async {
    if (currentUser == null) return;

    final response = await http.get(
      Uri.parse('$baseUrl/messages/$currentUser'),
    );

    if (response.statusCode != 200) return;

  final Map<String, List<EncryptedMessage>> _chats = {};

  List<EncryptedMessage> getMessages(String contactName) {
    return _chats[contactName] ?? [];
  }

  Future<void> sendMessage(
    String contactName,
    String text,
    String currentUser,
  ) async {

    final SimplePublicKey? receiverPublicKey =
      await CryptoService.getUserPublicKey(contactName);

    final senderPublicKey = await CryptoService.getUserPublicKey(currentUser);

    if (receiverPublicKey == null || senderPublicKey == null) {
      throw Exception("Public key van niet gevonden");
    }

    final aesKey = await CryptoService.aes.newSecretKey();

    final encryptedMessage =
        await CryptoService.aes.encrypt(
      utf8.encode(text),
      secretKey: aesKey,
    );

    final aesKeyBytes = await aesKey.extractBytes();

    final encryptedKeyBytes = 
        await CryptoService.rsa.encrypt(
      aesKeyBytes,
      publicKey: senderPublicKey,
    );

    _chats.putIfAbsent(contactName, () => []);

    _chats[contactName]!.add(
      EncryptedMessage(
        encryptedData: encryptedMessage,
        encryptedKey: encryptedKeyBytes,
        isMe: true,
      ),
    );

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
    return _chats.keys.toList();
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

  Future<void> sendMessage(
    String contactName, 
    String text,
  ) async {
    if (currentUser == null || currentUser!.isEmpty) return;

    final key = await CryptoService.getOrCreateAESKey(contactName);
    
    final encryptedData = await CryptoService.encryptMessage(text, key);

    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user': currentUser,
        'to': contactName,
        'text': jsonEncode(encryptedData),
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      _knownContacts.add(contactName);
      _chats.putIfAbsent(contactName, () => []);
      await fetchMessages(contactName);
    }
  }

  Future<String> decryptMessage(Message message) async {
    if (currentUser == null || currentUser!.isEmpty) return "Geen gebruiker";

    final contactName = message.isMe ? message.user : message.user;
    final key = await CryptoService.getOrCreateAESKey(contactName);

    try {
      final Map<String, String> encryptedData =
          Map<String, String>.from(jsonDecode(message.text));
      final decrypted = await CryptoService.decryptMessage(encryptedData, key);
      return decrypted;
    } catch (e) {
      return "Decryptie fout";
    }
  }

  void clearChats() {
    _chats.clear();
    notifyListeners();
  Future<String> decryptMessage(
    EncryptedMessage message,
    String currentUser,
  ) async {

    final keyPair = 
        await CryptoService.getOrCreateRSAKeyPair(currentUser);

    final privateKeyBytes = 
        await keyPair.extractPrivateKeyBytes();

    final publicKey =
        await keyPair.extractPublicKey();
    
    final aesKeyBytes = 
        await CryptoService.rsa.decrypt(
      message.encryptedKey,
      privateKey: SimpleKeyPairData(
          privateKeyBytes,
          publicKey: publicKey,
          type: KeyPairType.rsa,
        ),
      );

    final aesKey = SecretKey(aesKeyBytes);

    final decrypted = 
        await CryptoService.aes.decrypt(
      message.encryptedData,
      secretKey: aesKey,
    );

    return utf8.decode(decrypted);
  }
}