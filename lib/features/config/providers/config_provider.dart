import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/config_repository.dart';
import '../data/config_service.dart';


/// Provider pentru service-ul de rețea
final configServiceProvider = Provider<ConfigService>((ref) {
  return ConfigService();
});

/// Provider pentru ConfigRepository (un singur instance în aplicație)
final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  final repo = ConfigRepository(ref.read(configServiceProvider));

  // Când nu mai e folosit, curățăm timerul și stream-ul
  ref.onDispose(repo.dispose);

  return repo;
});

/// Provider reactiv: UI-ul se rebuild la fiecare schimbare de config
final configProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final repo = ref.watch(configRepositoryProvider);
  return repo.stream;
});