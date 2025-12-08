class VideoItem {
  final String id;
  final String title;
  final String description;
  final String? thumbUrl;
  final String? videoUrl;
  final String cDate;

  const VideoItem({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbUrl,
    required this.videoUrl,
    required this.cDate,
  });

  factory VideoItem.fromJson(
      Map<String, dynamic> json, {
        String? languageCode,
      }) {
    String title = json['title']?.toString() ?? '';
    String description = '';
    final String cDate = json['cdate']?.toString() ?? '';

    // meta.meta[lang]['1'] / ['2']
    try {
      final meta = json['meta'] as Map<String, dynamic>?;
      final metaInner = meta?['meta'] as Map<String, dynamic>?;

      if (metaInner != null && metaInner.isNotEmpty) {
        Map<String, dynamic>? langMeta;

        // 1) limba cerută (ex: 'ro', 'en', 'es' etc)
        if (languageCode != null && metaInner.containsKey(languageCode)) {
          langMeta = metaInner[languageCode] as Map<String, dynamic>?;
        }

        // 2) fallback pe 'en'
        if (langMeta == null && metaInner.containsKey('en')) {
          langMeta = metaInner['en'] as Map<String, dynamic>?;
        }

        // 3) fallback pe primul entry
        langMeta ??= metaInner.values.first as Map<String, dynamic>;

        final t = langMeta['1']?.toString();
        if (t != null && t.isNotEmpty) {
          title = t;
        }

        final d = langMeta['2']?.toString();
        if (d != null && d.isNotEmpty) {
          description = d;
        }
      }
    } catch (_) {
      // dacă se rupe ceva în parsing, rămân title / description default
    }

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
      description: description,
      thumbUrl: thumbUrl,
      videoUrl: videoUrl,
      cDate: cDate,
    );
  }
}
