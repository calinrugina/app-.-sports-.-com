import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache simplu pentru nodul `config` din /api/config.
class LocalConfigCache {
  static const _key = 'cached_config_v1';

  static Future<void> saveConfig(Map<String, dynamic> config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(config));
  }

  static Future<Map<String, dynamic>?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
