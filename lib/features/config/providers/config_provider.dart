import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/config_repository.dart';
import '../data/config_service.dart';

final configRepositoryProvider = Provider<ConfigRepository>((ref) {
  final repo = ConfigRepository(ConfigService());
  ref.onDispose(() => repo.dispose());
  return repo;
});

/// FutureProvider care expune nodul `config`.
final configProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final repo = ref.watch(configRepositoryProvider);
  if (repo.current != null) return repo.current;
  await repo.refresh();
  return repo.current;
});
