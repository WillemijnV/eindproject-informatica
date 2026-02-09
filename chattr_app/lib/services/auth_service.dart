import 'dart:convert';
import 'dart:html';  // << belangrijk voor web
import 'package:crypto/crypto.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

List _readUsers() {
  final jsonString = window.localStorage['users'];
  if (jsonString == null) return [];
  return jsonDecode(jsonString);
}

void _writeUsers(List users) {
  window.localStorage['users'] = jsonEncode(users);
}

//aanpassing door Audrey
List<Map<String, dynamic>> getAllUsers() {
  final rawUsers = _readUsers();
  return rawUsers.map<Map<String, dynamic>>((u) => Map<String, dynamic>.from(u)).toList();
}

Future<String?> registerUser(String username, String password) async {
  List users = _readUsers();

  if (users.any((u) => u['username'] == username)) {
    return 'Gebruikersnaam bestaat al';
  }

  users.add({
    'username': username,
    'password': hashPassword(password),
  });

  _writeUsers(users);
  return null;
}

Future<bool> loginUser(String username, String password) async {
  List users = _readUsers();

  final user = users.firstWhere(
    (u) => u['username'] == username,
    orElse: () => null,
  );

  if (user == null) return false;

  return user['password'] == hashPassword(password);
}
