import 'dart:async';
import '../../../core/storage/local_config_cache.dart';
import 'config_service.dart';

/// Repository pentru config-ul global (/api/config),
/// cu cache local și refresh automat la 10 minute.
class ConfigRepository {
  final ConfigService _service;

  Map<String, dynamic>? _cached; // doar nodul `config`
  Timer? _refreshTimer;
  bool _initialized = false;

  ConfigRepository(this._service) {
    _init();
  }

  Future<void> _init() async {
    _cached = await LocalConfigCache.loadConfig();
    refresh();
    _startAutoRefresh();
    _initialized = true;
  }

  Map<String, dynamic>? get current => _cached;
  bool get isInitialized => _initialized;

  Future<void> refresh() async {
    final data = await _service.fetchConfig();
    if (data['config'] is Map<String, dynamic>) {
      final cfg = data['config'] as Map<String, dynamic>;
      _cached = cfg;
      await LocalConfigCache.saveConfig(cfg);
    } else {
      throw Exception('Missing `config` node in response');
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => refresh(),
    );
  }

  void dispose() {
    _refreshTimer?.cancel();
  }
}
