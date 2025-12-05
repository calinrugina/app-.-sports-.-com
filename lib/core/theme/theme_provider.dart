import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _load();
  }

  static const _key = 'themeMode';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    switch (value) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      case 'system':
      default:
        state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      case ThemeMode.system:
      default:
        value = 'system';
    }
    await prefs.setString(_key, value);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

// 1. Definim un FutureProvider care va returna un obiect PackageInfo
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  // Aici facem apelul asincron pentru a obține informațiile
  return PackageInfo.fromPlatform();
});

// 2. Definim un Provider derivat pentru a returna doar string-ul de versiune formatat
final appVersionProvider = Provider<AsyncValue<String>>((ref) {
  // Observăm (watch) packageInfoProvider
  final packageInfoAsync = ref.watch(packageInfoProvider);

  // Mappăm rezultatul pentru a returna un string formatat
  return packageInfoAsync.whenData((info) {
    // Returnează string-ul în formatul dorit: "vX.Y.Z (+B)"
    return 'v${info.version} (${info.buildNumber})';
  });
});