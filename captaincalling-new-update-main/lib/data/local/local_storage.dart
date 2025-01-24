import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorage {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Save a string securely
  static Future<void> saveString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Retrieve a string securely
  static Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  // Save a boolean securely
  static Future<void> saveBool(String key, bool value) async {
    await _storage.write(key: key, value: value ? 'true' : 'false');
  }

  // Retrieve a boolean securely
  static Future<bool?> getBool(String key) async {
    String? value = await _storage.read(key: key);
    return value == 'true';
  }

  // Save an integer securely
  static Future<void> saveInt(String key, int value) async {
    await _storage.write(key: key, value: value.toString());
  }

  // Retrieve an integer securely
  static Future<int?> getInt(String key) async {
    String? value = await _storage.read(key: key);
    return value != null ? int.tryParse(value) : null;
  }

  // Remove a value securely
  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all stored data securely
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
