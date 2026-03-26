import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://729bd5b9-d330-416c-bbbf-87ce6cdd04a7-00-1kstgmc8ftol5.worf.replit.dev:5000';

class CryptoService {
  static final _aes = AesGcm.with256bits();

  // Lokaal sleutel ophalen of aanmaken
  static Future<SecretKey> getAESKey(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/key/$username'));

    if (response.statusCode != 200) throw Exception("Kan sleutel niet ophalen");

    final keyBase64 = jsonDecode(response.body)['aesKey'];
    final keyBytes = base64Decode(keyBase64);
    return SecretKey(keyBytes);
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
    final secretBox = SecretBox(
      base64Decode(encryptedData['cipherText']!),
      nonce: base64Decode(encryptedData['nonce']!),
      mac: Mac(base64Decode(encryptedData['mac']!)),
    );

    final decrypted = await _aes.decrypt(secretBox, secretKey: key);
    return utf8.decode(decrypted);  
  }
}
