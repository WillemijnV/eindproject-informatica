import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'https://729bd5b9-d330-416c-bbbf-87ce6cdd04a7-00-1kstgmc8ftol5.worf.replit.dev:5000';

class CryptoService {
  static final _aes = AesGcm.with256bits();

  // Lokaal sleutel ophalen of aanmaken
  static Future<SecretKey> getChatKey(String user1, String user2) async {
    final prefs = await SharedPreferences.getInstance();

    final chatId = [user1,user2]..sort();
    final keyId = chatId.join("-");

    final storedKey = prefs.getString('key_$keyId');

    if (storedKey != null) {
      return SecretKey(base64Decode(storedKey));
    }

    final response = await http.get(Uri.parse('$baseUrl/chat-key/$user1/$user2'));

    if (response.statusCode != 200) {
      throw Exception("Kan chat key niet ophalen van server");
    }

    final keyBase64 = jsonDecode(response.body)['aesKey'];

    await prefs.setString('key_$keyId', keyBase64);

    return SecretKey(base64Decode(keyBase64));
  }

  // Encrypt een bericht
  static Future<Map<String, String>> encrypt(String text, SecretKey key) async {
    final nonce = _aes.newNonce();
    final secretBox = await _aes.encrypt(
      utf8.encode(text),
      secretKey: key,
      nonce: nonce,
    );

    return {
      'cipherText': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  // Decrypt een bericht
  static Future<String> decrypt(Map<String, String> encryptedData, SecretKey key) async {
    try {
      final secretBox = SecretBox(
        base64Decode(encryptedData['cipherText']!),
        nonce: base64Decode(encryptedData['nonce']!),
        mac: Mac(base64Decode(encryptedData['mac']!)),
      );

      final decrypted = await _aes.decrypt(secretBox, secretKey: key);
      return utf8.decode(decrypted);  
    } catch (e) {
      print("Decrypt failed: $e");
      return "Bericht niet beschikbaar";
    }
  }
}
