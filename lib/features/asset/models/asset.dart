/// Asset model (video or article) as returned by latest, trending, and search.
class Asset {
  const Asset({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    this.categories = const [],
    this.tags = const [],
    this.publishedAt,
    this.rawThumb,
    this.thumbnails = const [],
    this.content = const [],
    this.author,
    this.articleUrl,
    this.viewCount,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    final List<dynamic> cat = json['categories'] as List<dynamic>? ?? [];
    final List<dynamic> tag = json['tags'] as List<dynamic>? ?? [];
    final List<dynamic> thumbs = json['thumbnails'] as List<dynamic>? ?? [];
    final List<dynamic> cont = json['content'] as List<dynamic>? ?? [];

    return Asset(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'video',
      categories: cat.map((e) => e.toString()).toList(),
      tags: tag.map((e) => e.toString()).toList(),
      publishedAt: json['published_at'] as String?,
      rawThumb: json['thumb'] as String?,
      thumbnails: thumbs
          .map((e) => e is Map ? Thumbnail.fromJson(Map<String, dynamic>.from(e)) : null)
          .whereType<Thumbnail>()
          .toList(),
      content: cont
          .map((e) => e is Map ? ContentItem.fromJson(Map<String, dynamic>.from(e)) : null)
          .whereType<ContentItem>()
          .toList(),
      author: json['author'] as String?,
      articleUrl: json['article_url'] as String?,
      viewCount: json['view_count'] != null ? (json['view_count'] as num).toInt() : null,
    );
  }

  final int id;
  final String title;
  final String? description;
  /// `video` or `article`
  final String type;
  final List<String> categories;
  final List<String> tags;
  final String? publishedAt;
  /// Raw thumb URL from API (e.g. search response when no thumbnails list).
  final String? rawThumb;
  /// Thumbnails with dimensions (latest/trending).
  final List<Thumbnail> thumbnails;
  /// Video renditions or article content (latest/trending).
  final List<ContentItem> content;
  final String? author;
  /// Article HTML URL for given lang (latest/trending, article only).
  final String? articleUrl;
  /// Present only on trending.
  final int? viewCount;

  bool get isVideo => type == 'video';
  bool get isArticle => type == 'article';

  /// Thumb URL: thumbnail with smallest width from [thumbnails], or [rawThumb] when no thumbnails.
  String? get thumb {
    if (thumbnails.isEmpty) return rawThumb;
    final withWidth = thumbnails.where((t) => t.w != null).toList();
    if (withWidth.isEmpty) return thumbnails.first.url;
    final smallest = withWidth.reduce((a, b) => (a.w! <= b.w!) ? a : b);
    return smallest.url;
  }

  /// First content URL (video or article media).
  String? get media => content.isNotEmpty ? content.first.url : null;

  /// Alias for [thumb] (smallest thumbnail or raw).
  String? get bestThumbUrl => thumb;

  /// Sentinel to allow [copyWith(publishedAt: null)] to clear the field.
  static const _undefined = Object();

  Asset copyWith({
    int? id,
    String? title,
    String? description,
    String? type,
    List<String>? categories,
    List<String>? tags,
    Object? publishedAt = _undefined,
    String? rawThumb,
    List<Thumbnail>? thumbnails,
    List<ContentItem>? content,
    String? author,
    String? articleUrl,
    int? viewCount,
  }) {
    return Asset(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      categories: categories ?? this.categories,
      tags: tags ?? this.tags,
      publishedAt: publishedAt == _undefined ? this.publishedAt : publishedAt as String?,
      rawThumb: rawThumb ?? this.rawThumb,
      thumbnails: thumbnails ?? this.thumbnails,
      content: content ?? this.content,
      author: author ?? this.author,
      articleUrl: articleUrl ?? this.articleUrl,
      viewCount: viewCount ?? this.viewCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'categories': categories,
      'tags': tags,
      'published_at': publishedAt,
      'thumb': thumb,
      'thumbnails': thumbnails.map((e) => e.toJson()).toList(),
      'content': content.map((e) => e.toJson()).toList(),
      if (author != null) 'author': author,
      if (articleUrl != null) 'article_url': articleUrl,
      if (viewCount != null) 'view_count': viewCount,
    };
  }
}

class Thumbnail {
  const Thumbnail({required this.url, this.w, this.h});

  factory Thumbnail.fromJson(Map<String, dynamic> json) {
    return Thumbnail(
      url: json['url'] as String? ?? '',
      w: (json['w'] as num?)?.toInt(),
      h: (json['h'] as num?)?.toInt(),
    );
  }

  final String url;
  final int? w;
  final int? h;

  Map<String, dynamic> toJson() => {'url': url, 'w': w, 'h': h};
}

class ContentItem {
  const ContentItem({this.lang, this.profile, required this.url});

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      lang: json['lang'] as String?,
      profile: json['profile'] as String?,
      url: json['url'] as String? ?? '',
    );
  }

  final String? lang;
  final String? profile;
  final String url;

  Map<String, dynamic> toJson() => {'lang': lang, 'profile': profile, 'url': url};
}