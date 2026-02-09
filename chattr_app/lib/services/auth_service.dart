import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  return sha256.convert(bytes).toString();
}

Future<List<Map<String, dynamic>>> _readUsers() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('users');
  if (jsonString == null) return [];
  return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
}

Future<void> _writeUsers(List users) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('users', jsonEncode(users));
}

//aanpassing door Audrey
List<Map<String, dynamic>> getAllUsers() {
  final rawUsers = _readUsers();
  return rawUsers.map<Map<String, dynamic>>((u) => Map<String, dynamic>.from(u)).toList();
}

Future<String?> registerUser(String username, String password) async {
  final users = await _readUsers();

  if (users.any((u) => u['username'] == username)) {
    return 'Gebruikersnaam bestaat al';
  }

  users.add({
    'username': username,
    'password': hashPassword(password),
  });

  await _writeUsers(users);
  return null;
}

Future<bool> loginUser(String username, String password) async {
  final users = await _readUsers();

  final user = users.firstWhere(
    (u) => u['username'] == username,
    orElse: () => {},
  );

  if (user.isEmpty) return false;

  return user['password'] == hashPassword(password);
}
