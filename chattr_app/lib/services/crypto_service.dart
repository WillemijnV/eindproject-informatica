import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CryptoService {
  static final aes = AesGcm.with256bits();

  static Future<SecretKey> getOrCreateAESKey(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('aes_key_$username');

    if (stored != null) {
      return SecretKey(base64Decode(stored));
    }

    final key = await aes.newSecretKey();
    final bytes = await key.extractBytes();

    await prefs.setString(
      'aes_key_$username',
      base64Encode(bytes),
    );

    return key;
  }

  static Future<Map<String, String>> encrypt(
      String message, SecretKey key) async {
    final secretBox = await aes.encrypt(
      utf8.encode(message),
      secretKey: key,
    );

    return {
      'cipherText': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  static Future<String> decrypt(
      Map<String, String> encryptedData, SecretKey key) async {
    final secretBox = SecretBox(
      base64Decode(encryptedData['cipherText']!),
      nonce: base64Decode(encryptedData['nonce']!),
      mac: Mac(base64Decode(encryptedData['mac']!)),
    );

    final clearText = await aes.decrypt(
      secretBox,
      secretKey: key,
    );

    return utf8.decode(clearText);
  }
}