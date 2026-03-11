/// Config from api/config: category/sport with blocks to display.
class CategoryConfig {
  const CategoryConfig({
    required this.id,
    required this.name,
    required this.slug,
    this.inHeader = false,
    this.icon,
    this.image,
    this.blocks = const [],
    this.tournaments = const [],
  });

  factory CategoryConfig.fromJson(Map<String, dynamic> json) {
    final blocks = json['blocks'] as List<dynamic>? ?? [];
    final tournaments = json['tournaments'] as List<dynamic>? ?? [];
    return CategoryConfig(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      inHeader: json['in_header'] as bool? ?? false,
      icon: json['icon'] as String?,
      image: json['image'] is Map ? BlockImage.fromJson(Map<String, dynamic>.from(json['image'] as Map)) : null,
      blocks: blocks.map((e) => Block.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      tournaments: tournaments.map((e) => e is Map ? Map<String, dynamic>.from(e) : null).whereType<Map<String, dynamic>>().toList(),
    );
  }

  final int id;
  final String name;
  final String slug;
  final bool inHeader;
  final String? icon;
  final BlockImage? image;
  final List<Block> blocks;
  final List<Map<String, dynamic>> tournaments;
}

/// Image set with @1x, @2x, @3x URLs.
class BlockImage {
  const BlockImage({this.iconImage = const {}});

  factory BlockImage.fromJson(Map<String, dynamic> json) {
    final iconImage = json['icon_image'] as Map<String, dynamic>?;
    return BlockImage(
      iconImage: iconImage != null ? Map<String, String>.from(iconImage.map((k, v) => MapEntry(k, v?.toString() ?? ''))) : {},
    );
  }

  final Map<String, String> iconImage;

  String? get url1x => iconImage['@1x'];
  String? get url2x => iconImage['@2x'];
  String? get url3x => iconImage['@3x'];
}

/// One block in the config: section title, source, filters, layout.
class Block {
  const Block({
    required this.id,
    required this.sportId,
    required this.key,
    required this.title,
    this.layoutType = 0,
    this.contentType = 'video',
    this.source = 'latest',
    this.filters = const BlockFilters(),
    this.limit = 4,
    this.enabled = true,
    this.sortOrder = 0,
    this.cacheTtl = 120,
    this.createdAt,
    this.updatedAt,
  });

  factory Block.fromJson(Map<String, dynamic> json) {
    final filters = json['filters'];
    return Block(
      id: (json['id'] as num).toInt(),
      sportId: (json['sport_id'] as num?)?.toInt() ?? 0,
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      layoutType: (json['layout_type'] as num?)?.toInt() ?? 0,
      contentType: json['content_type'] as String? ?? 'video',
      source: json['source'] as String? ?? 'latest',
      filters: filters is Map ? BlockFilters.fromMap(Map<String, dynamic>.from(filters)) : const BlockFilters(),
      limit: (json['limit'] as num?)?.toInt() ?? 4,
      enabled: json['enabled'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      cacheTtl: (json['cache_ttl'] as num?)?.toInt() ?? 120,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  final int id;
  final int sportId;
  final String key;
  final String title;
  /// Determines widget layout: e.g. 2 = 2 columns, 5 = list with gray background.
  final int layoutType;
  final String contentType;
  final String source;
  final BlockFilters filters;
  final int limit;
  final bool enabled;
  final int sortOrder;
  final int cacheTtl;
  final String? createdAt;
  final String? updatedAt;
}

/// Filters for a block: include (categories, tags) and exclude (from "exclude" array).
///
/// Example JSON:
/// ```json
/// "filters": {
///   "exclude": [ { "tags": "highlights,interviews" } ],
///   "categories": "tennis"
/// }
/// ```
class BlockFilters {
  const BlockFilters({
    this.categories = const [],
    this.tags = const [],
    this.excludeCategories = const [],
    this.excludeTags = const [],
    this.excludeIds = const [],
  });

  factory BlockFilters.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const BlockFilters();
    final cat = map['categories'];
    final tag = map['tags'];
    final excludeRaw = map['exclude'];
    List<String> excludeCat = [];
    List<String> excludeTag = [];
    List<int> excludeId = [];
    if (excludeRaw is List) {
      for (final item in excludeRaw) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);
        if (m['categories'] != null) excludeCat.addAll(_parseList(m['categories']));
        if (m['tags'] != null) excludeTag.addAll(_parseList(m['tags']));
        if (m['id'] != null) excludeId.addAll(_parseIds(m['id']));
        if (m['ids'] != null) excludeId.addAll(_parseIds(m['ids']));
      }
      excludeCat = excludeCat.toSet().toList();
      excludeTag = excludeTag.toSet().toList();
      excludeId = excludeId.toSet().toList();
    }
    return BlockFilters(
      categories: _parseList(cat),
      tags: _parseList(tag),
      excludeCategories: excludeCat,
      excludeTags: excludeTag,
      excludeIds: excludeId,
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList();
    final s = value.toString().trim();
    if (s.isEmpty) return const [];
    return s.split(',').map((e) => e.trim()).where((s) => s.isNotEmpty).toList();
  }

  static List<int> _parseIds(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => int.tryParse(e.toString())).whereType<int>().where((i) => i > 0).toList();
    }
    return value.toString().split(',').map((e) => int.tryParse(e.trim())).whereType<int>().where((i) => i > 0).toList();
  }

  final List<String> categories;
  final List<String> tags;
  /// Merged from filters.exclude[].categories.
  final List<String> excludeCategories;
  /// Merged from filters.exclude[].tags.
  final List<String> excludeTags;
  /// Merged from filters.exclude[].id / exclude[].ids.
  final List<int> excludeIds;
}
