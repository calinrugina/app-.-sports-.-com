class VideoItem {
  final String id;
  final String title;
  final String? thumbUrl;
  final String? videoUrl;

  VideoItem({
    required this.id,
    required this.title,
    this.thumbUrl,
    this.videoUrl,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    String title = json['title']?.toString() ?? '';

    // meta.meta[lang]['1']
    try {
      final meta = json['meta'] as Map<String, dynamic>?;
      final metaInner = meta?['meta'] as Map<String, dynamic>?;
      if (metaInner != null && metaInner.isNotEmpty) {
        final firstLang = metaInner.values.first as Map<String, dynamic>;
        final t = firstLang['1']?.toString();
        if (t != null && t.isNotEmpty) {
          title = t;
        }
      }
    } catch (_) {}

    String? thumbUrl;
    final thumbs = json['thumbs'] as List?;
    if (thumbs != null && thumbs.isNotEmpty) {
      final first = thumbs.first as Map<String, dynamic>;
      thumbUrl = first['link']?.toString();
    }

    String? videoUrl;
    final formats = json['formats'] as List?;
    if (formats != null && formats.isNotEmpty) {
      final first = formats.first as Map<String, dynamic>;
      videoUrl = first['link']?.toString();
    }

    return VideoItem(
      id: json['id']?.toString() ?? '',
      title: title,
      thumbUrl: thumbUrl,
      videoUrl: videoUrl,
    );
  }
}
