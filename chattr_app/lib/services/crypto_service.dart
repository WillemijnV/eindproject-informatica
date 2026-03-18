import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CryptoService {
<<<<<<< HEAD
  static final aes = AesGcm.with256bits();

  static Future<SecretKey> getOrCreateAESKey(String contactName) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('aes_key_$contactName');
=======
  static final rsa = RsaOaep(hashAlgorithm: Sha256());
  static final aes = AesGcm.with256bits();

  static Future<SimpleKeyPair> getOrCreateRSAKeyPair(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('rsa_private_$username');
    final rsa = RsaOaep(hashAlgorithm: Sha256());

    if (stored != null) {
      final privateKeyBytes = base64Decode(stored);
      final KeyPair = await rsa.newKeyPairFromSeed(privateKeyBytes);
      return keyPair;
    }

    final keyPair = await rsa.newKeyPair();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();

    await prefs.setString(
      'rsa_private_$username',
      base64Encode(privateKeyBytes),
    );

    return keyPair;
  }

  static Future<SimplePublicKey?> getUserPublicKey(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('public_key_$username');

    if (stored == null) return null;

    return SimplePublicKey(
      base64Decode(stored!),
      type: KeyPairType.rsa,
    );
  }

  static Future<void> saveUserPublicKey(String username, SimplePublicKey publicKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'public_key_$username',
      base64Encode(publicKey.bytes),
    );
  }

  static Future<SecretBox> encryptAES(String message, SecretKey key) async {
    return await aes.encrypt(
      utf8.encode(message),
      secretKey: key,
    );
  }
   
  static Future<String> decryptAES(SecretBox box, SecretKey key) async{
    final decrypted = await aes.decrypt(box, secretKey: key);
    return utf8.decode(decrypted);
  }

  static Future<SecretKey> getOrCreateAESKey(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('aes_key_$username');
>>>>>>> e56979a (End-to-end versleuteling)

    if (stored != null) {
      return SecretKey(base64Decode(stored));
    }

    final key = await aes.newSecretKey();
<<<<<<< HEAD
    final keyBytes = await key.extractBytes();
    await prefs.setString('aes_key_$contactName', base64Encode(keyBytes));
    return key;
  }

  static Future<Map<String, String>> encryptMessage(String message, SecretKey key) async {
    final secretBox = await aes.encrypt(utf8.encode(message), secretKey: key);
    return {
      'cipherText': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
    };
  }

  static Future<String> decryptMessage(Map<String, String> data, SecretKey key) async {
    final box = SecretBox(
      base64Decode(data['cipherText']!),
      nonce: base64Decode(data['nonce']!),
      mac: Mac(base64Decode(data['mac']!)),
    );

    final decrypted = await aes.decrypt(box, secretKey: key);
    return utf8.decode(decrypted);
  }
}
=======
    final bytes = await key.extractBytes();
    await prefs.setString('aes_key_$username', base64Encode(bytes));

    return key;
  }
}


  
>>>>>>> e56979a (End-to-end versleuteling)
