import 'dart:async';
import 'dart:developer' as SportsAppLogger;

import '../../../core/storage/local_config_cache.dart';
import 'config_service.dart';

/// Repository pentru config-ul global (/api/config),
/// cu cache local și refresh automat la 10 minute,
/// + stream pentru a notifica UI-ul la fiecare update.
class ConfigRepository {
  final ConfigService _service;

  Map<String, dynamic>? _cached; // doar nodul `config`
  Timer? _refreshTimer;
  bool _initialized = false;

  final _controller = StreamController<Map<String, dynamic>?>.broadcast();

  ConfigRepository(this._service) {
    _init();
  }

  Map<String, dynamic>? get current => _cached;
  bool get isInitialized => _initialized;

  /// Stream la care se abonează Riverpod (configProvider)
  Stream<Map<String, dynamic>?> get stream => _controller.stream;

  Future<void> _init() async {
    SportsAppLogger.log('Config _init');

    // 1. Încărcăm din cache local (dacă există)
    _cached = await LocalConfigCache.loadConfig();
    _notifyListeners();

    // 2. Primul refresh din rețea
    await refresh();

    // 3. Pornim refresh-ul automat la 10 minute
    _startAutoRefresh();
    _initialized = true;
  }

  Future<void> refresh() async {
    SportsAppLogger.log('Config refresh !!!');
    final data = await _service.fetchConfig();

    if (data['config'] is Map<String, dynamic>) {
      final cfg = data['config'] as Map<String, dynamic>;
      _cached = cfg;

      await LocalConfigCache.saveConfig(cfg);
      SportsAppLogger.log('Config saveConfig');

      _notifyListeners();
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

  void _notifyListeners() {
    _controller.add(_cached);
  }

  void dispose() {
    _refreshTimer?.cancel();
    _controller.close();
  }
}