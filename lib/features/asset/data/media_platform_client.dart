import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/asset.dart';
import 'api_response.dart';

/// Which API endpoint to call.
enum ContentSource {
  latest,
  trending,
  search;

  static ContentSource? fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'latest':
        return ContentSource.latest;
      case 'trending':
        return ContentSource.trending;
      case 'search':
        return ContentSource.search;
      default:
        return null;
    }
  }
}

/// Video or article.
enum ContentType {
  video,
  article;

  static ContentType? fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'video':
        return ContentType.video;
      case 'article':
        return ContentType.article;
      default:
        return null;
    }
  }
}

/// Filters for API calls: include (categories, tags) and exclude (categories, tags, ids).
class AssetFilters {
  const AssetFilters({
    this.categories = const [],
    this.tags = const [],
    this.period = const [],
    this.excludeCategories = const [],
    this.excludeTags = const [],
    this.excludeIds = const [],
  });

  /// From map e.g. {"categories": "football", "tags": "highlights", "exclude": [{"tags": "a,b"}]}.
  factory AssetFilters.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AssetFilters();
    final cat = map['categories'];
    final tag = map['tags'];
    final period = map['period'];
    List<String> excCat = [];
    List<String> excTag = [];
    List<int> excId = [];
    final excludeRaw = map['exclude'];
    if (excludeRaw is List) {
      for (final item in excludeRaw) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);
        if (m['categories'] != null) excCat.addAll(_parseList(m['categories']));
        if (m['tags'] != null) excTag.addAll(_parseList(m['tags']));
        if (m['id'] != null) excId.addAll(_parseIds(m['id']));
        if (m['ids'] != null) excId.addAll(_parseIds(m['ids']));
      }
    }
    return AssetFilters(
      categories: _parseList(cat),
      tags: _parseList(tag),
      period: _parseList(period),
      excludeCategories: excCat.toSet().toList(),
      excludeTags: excTag.toSet().toList(),
      excludeIds: excId.toSet().toList(),
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
  final List<String> period;
  final List<String> excludeCategories;
  final List<String> excludeTags;
  final List<int> excludeIds;

  bool get hasFilters => categories.isNotEmpty || tags.isNotEmpty || period.isNotEmpty;
  bool get hasExclude => excludeCategories.isNotEmpty || excludeTags.isNotEmpty || excludeIds.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'categories': categories,
    'tags': tags,
    'period': period,
    'excludeCategories': excludeCategories,
    'excludeTags': excludeTags,
    'excludeIds': excludeIds,
  };

  @override
  String toString() => 'AssetFilters(${toJson()})';
}

/// Request params for [MediaPlatformClient.fetchAssets].
class FetchAssetsParams {
  const FetchAssetsParams({
    required this.source,
    required this.contentType,
    this.filters = const AssetFilters(),
    this.perPage = 20,
    this.page = 1,
    this.query,
    this.lang,
    this.country,
    this.sectionName,
  });

  /// Endpoint: latest, trending, or search.
  final ContentSource source;

  /// video or article.
  final ContentType contentType;

  /// Categories and tags (slug lists).
  final AssetFilters filters;

  /// Number of records per page (limit for search).
  final int perPage;

  /// Page number (used for latest and trending; search has no page).
  final int page;

  /// Search query (required when source is [ContentSource.search]).
  final String? query;

  /// Optional lang/country for API.
  final String? lang;
  final String? country;
  final String? sectionName;

  Map<String, dynamic> toJson() => {
    'source': source.name,
    'contentType': contentType.name,
    'filters': filters.toJson(),
    'perPage': perPage,
    'page': page,
    if (query != null) 'query': query,
    if (lang != null) 'lang': lang,
    if (country != null) 'country': country,
  };

  @override
  String toString() => 'FetchAssetsParams(${toJson()})';
}

/// Flutter client for Media Platform API: /v1/latest, /v1/trending, /v1/search.
class MediaPlatformClient {
  MediaPlatformClient({
    required this.baseUrl,
    required this.apiKey,
    this.headers = const {},
  }) : _client = http.Client();

  final String baseUrl;
  final String apiKey;
  final Map<String, String> headers;
  final http.Client _client;

  String get _base => baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';

  /// Fetches assets from the chosen endpoint.
  ///
  /// Returns [AssetsResponse] with [Asset] list and [AssetsResponse.hasMore].
  Future<AssetsResponse> fetchAssets(FetchAssetsParams params) async {
    // print('Sectiunea: ${params.sectionName}');

    switch (params.source) {
      case ContentSource.latest:
        return _fetchLatest(params);
      case ContentSource.trending:
        return _fetchTrending(params);
      case ContentSource.search:
        return _fetchSearch(params);
    }
  }

  Future<AssetsResponse> _fetchLatest(FetchAssetsParams params) async {
    final type = params.contentType == ContentType.video ? 'video' : 'article';
    final q = <String, String>{
      'type': type,
      'page': params.page.toString(),
      'per_page': params.perPage.toString(),
    };
    if (params.filters.categories.isNotEmpty) {
      q['categories'] = params.filters.categories.join(',');
    }
    if (params.filters.tags.isNotEmpty) {
      q['tags'] = params.filters.tags.join(',');
    }
    if (params.filters.excludeCategories.isNotEmpty) {
      q['exclude[categories]'] = params.filters.excludeCategories.join(',');
    }
    if (params.filters.excludeTags.isNotEmpty) {
      q['exclude[tags]'] = params.filters.excludeTags.join(',');
    }
    if (params.filters.excludeIds.isNotEmpty) {
      q['exclude[id]'] = params.filters.excludeIds.join(',');
    }
    if (params.lang != null && params.lang!.isNotEmpty) q['lang'] = params.lang!;
    if (params.country != null && params.country!.isNotEmpty) q['country'] = params.country!;

    // print('_fetchLatest ${params.toJson()}');

    final uri = Uri.parse('${_base}v1/latest').replace(queryParameters: q);
    final res = await _get(uri);
    return _parsePaginated(res, params.page, params.perPage);
  }

  Future<AssetsResponse> _fetchTrending(FetchAssetsParams params) async {
    final type = params.contentType == ContentType.video ? 'video' : 'article';
    final q = <String, String>{
      'type': type,
      'page': params.page.toString(),
      'per_page': params.perPage.toString(),
    };
    if (params.filters.categories.isNotEmpty) {
      q['categories'] = params.filters.categories.join(',');
    }
    if (params.filters.period.isNotEmpty) {
      q['period'] = params.filters.period.join(',');
    }
    if (params.filters.excludeCategories.isNotEmpty) {
      q['exclude[categories]'] = params.filters.excludeCategories.join(',');
    }
    if (params.filters.excludeTags.isNotEmpty) {
      q['exclude[tags]'] = params.filters.excludeTags.join(',');
    }
    if (params.filters.excludeIds.isNotEmpty) {
      q['exclude[id]'] = params.filters.excludeIds.join(',');
    }
    if (params.lang != null && params.lang!.isNotEmpty) q['lang'] = params.lang!;
    if (params.country != null && params.country!.isNotEmpty) q['country'] = params.country!;

    // print('_fetchTrending ${params.toJson()}');

    final uri = Uri.parse('${_base}v1/trending').replace(queryParameters: q);
    final res = await _get(uri);
    return _parsePaginated(res, params.page, params.perPage);
  }

  Future<AssetsResponse> _fetchSearch(FetchAssetsParams params) async {
    final q = params.query?.trim() ?? '';
    final type = params.contentType == ContentType.video ? 'video' : 'article';
    final queryParams = <String, String>{
      'q': q,
      'type': type,
      'limit': params.perPage.toString(),
    };
    if (params.filters.categories.isNotEmpty) {
      queryParams['categories'] = params.filters.categories.join(',');
    }
    if (params.filters.tags.isNotEmpty) {
      queryParams['tags'] = params.filters.tags.join(',');
    }
    if (params.filters.excludeCategories.isNotEmpty) {
      queryParams['exclude[categories]'] = params.filters.excludeCategories.join(',');
    }
    if (params.filters.excludeTags.isNotEmpty) {
      queryParams['exclude[tags]'] = params.filters.excludeTags.join(',');
    }
    if (params.filters.excludeIds.isNotEmpty) {
      queryParams['exclude[id]'] = params.filters.excludeIds.join(',');
    }
    if (params.lang != null && params.lang!.isNotEmpty) queryParams['lang'] = params.lang!;
    if (params.country != null && params.country!.isNotEmpty) queryParams['country'] = params.country!;

    final uri = Uri.parse('${_base}v1/search').replace(queryParameters: queryParams);
    final res = await _get(uri);
    return _parseSearch(res, params.perPage);
  }

  /// Records a view for the asset. Call when the user opens the asset details.
  /// POST /v1/assets/{id}/view
  Future<void> recordAssetView(int assetId) async {
    final uri = Uri.parse('${_base}v1/assets/$assetId/view');
    await _post(uri);
  }
  Future<Map<String, dynamic>> _post(Uri uri) async {
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'X-API-Key': apiKey,
      ...headers,
    };
    final u = uri.replace(
      queryParameters: {...uri.queryParameters, 'api_key': apiKey},
    );
    final r = await _client.post(u, headers: requestHeaders, body: '{}');
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw MediaPlatformException(
        statusCode: r.statusCode,
        body: r.body,
      );
    }
    if (r.body.isEmpty) return {};
    final decoded = json.decode(r.body) as Map<String, dynamic>?;
    return decoded ?? {};
  }
  Future<Map<String, dynamic>> _get(Uri uri) async {
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      'X-API-Key': apiKey,
      ...headers,
    };
    final u = uri.replace(
      queryParameters: {...uri.queryParameters, 'api_key': apiKey},
    );
    final r = await _client.get(u, headers: requestHeaders);
    if (r.statusCode != 200) {
      throw MediaPlatformException(
        statusCode: r.statusCode,
        body: r.body,
      );
    }
    final decoded = json.decode(r.body) as Map<String, dynamic>?;
    return decoded ?? {};
  }

  AssetsResponse _parsePaginated(Map<String, dynamic> json, int page, int perPage) {
    final data = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>?;
    final currentPage = (meta?['current_page'] as num?)?.toInt() ?? page;
    final lastPage = (meta?['last_page'] as num?)?.toInt();
    final total = (meta?['total'] as num?)?.toInt();

    final hasMore = lastPage != null
        ? currentPage < lastPage
        : (total != null && (currentPage * perPage) < total);

    final assets = data
        .map((e) => Asset.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return AssetsResponse(
      assets: assets,
      hasMore: hasMore,
      total: total,
      currentPage: currentPage,
    );
  }

  AssetsResponse _parseSearch(Map<String, dynamic> json, int limit) {
    final data = json['data'] as List<dynamic>? ?? [];
    final total = (json['total'] as num?)?.toInt() ?? 0;
    final assets = data
        .map((e) => Asset.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final hasMore = total > assets.length;

    return AssetsResponse(
      assets: assets,
      hasMore: hasMore,
      total: total,
    );
  }

  void close() {
    _client.close();
  }
}

class MediaPlatformException implements Exception {
  MediaPlatformException({required this.statusCode, this.body});
  final int statusCode;
  final String? body;
  @override
  String toString() => 'MediaPlatformException($statusCode): $body';
}
