import '../models/asset.dart';

/// Response from fetchAssets: list of assets and whether more pages exist.
class AssetsResponse {
  const AssetsResponse({
    required this.assets,
    required this.hasMore,
    this.total,
    this.currentPage,
  });

  final List<Asset> assets;
  final bool hasMore;
  /// Total count (when available from API).
  final int? total;
  /// Current page (latest/trending).
  final int? currentPage;
}
