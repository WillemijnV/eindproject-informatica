import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CryptoService {
  static final aes = AesGcm.with256bits();
  static final Map<String, SecretKey> _keys = {};

  static Future<SecretKey> getOrCreateAESKey(String username) async {
    if (_keys.containsKey(username)) return _keys[username]!;

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('aes_key_$username');

    SecretKey key;
    if (stored != null) {
      return SecretKey(base64Decode(stored));
    } else {
      key = await aes.newSecretKey();
      final bytes = await key.extractBytes();
      await prefs.setString('aes_key_$username', base64Encode(bytes));
    }

    _keys[username] = key;
    return key;
  }

  static Future<Map<String, String>> encrypt(String text, SecretKey key) async {
    final nonce = aes.newNonce();
    final secretBox = await aes.encrypt(
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

  static Future<String> decrypt(Map<String, String> encryptedData, SecretKey key) async {
    final secretBox = SecretBox(
      base64Decode(encryptedData['cipherText']!),
      nonce: base64Decode(encryptedData['nonce']!),
      mac: Mac(base64Decode(encryptedData['mac']!)),
    );

    final decrypted = await aes.decrypt(
      secretBox,
      secretKey: key,
    );

    return utf8.decode(decrypted);
  }
}