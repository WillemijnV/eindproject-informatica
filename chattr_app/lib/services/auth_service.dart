import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl =
  'https://729bd5b9-d330-416c-bbbf-87ce6cdd04a7-00-1kstgmc8ftol5.worf.replit.dev:5000';

Future<String?> registerUser(String username, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/register'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'password': password,
    }),
  );

  if (response.statusCode == 201) {
    return null;
  } else {
    final data = jsonDecode(response.body);
    return data['error'];
  }
}

Future<bool> loginUser(String username, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'username': username,
      'password': password,
    }),
  );

  return response.statusCode == 200;
}

Future<List<String>> fetchAllUsernames() async {
  final response = await http.get(
    Uri.parse('$baseUrl/users'),
  );

  if (response.statusCode == 200) {
    return List<String>.from(jsonDecode(response.body));
  } else {
    return [];
  }
}