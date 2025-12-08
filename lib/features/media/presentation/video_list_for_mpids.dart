import 'dart:developer' as SportsAppLogger;

import 'package:flutter/material.dart';
import 'package:sports_config_app/features/media/presentation/video_item_in_listing.dart';
import '../data/video_item.dart';
import '../data/video_service.dart';
import '../../../core/network/media_headers.dart';
import 'video_player_dialog.dart';

/// Listă orizontală de video-uri pentru un set de mpids (from_sets).
class VideoListForMpids extends StatefulWidget {
  final String mpids;
  final String languageCode;

  const VideoListForMpids({
    super.key,
    required this.mpids,
    required this.languageCode,
  });

  @override
  State<VideoListForMpids> createState() => _VideoListForMpidsState();
}

class _VideoListForMpidsState extends State<VideoListForMpids> {
  final VideoService _service = const VideoService();
  List<VideoItem> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }
  @override
  void didUpdateWidget(covariant VideoListForMpids oldWidget) {
    super.didUpdateWidget(oldWidget);
    // dacă s-a schimbat limba din setări, refacem lista pentru primul studio
    if (oldWidget.languageCode != widget.languageCode) {
      SportsAppLogger.log('VideoListForMpids LANGUAGE CHANGED');
    }
  }

  Future<void> _load() async {
    final list = await _service.fetchVideosForSets(
      widget.mpids,
      0,
      widget.languageCode,
    );
    if (!mounted) return;
    setState(() {
      _videos = list;
      _loading = false;
    });
  }

  void _openPlayer(VideoItem v) {
    final url = v.videoUrl;
    if (url == null || url.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => VideoPlayerDialog(
        videoUrl: url,
        title: v.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_videos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No videos.'),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _videos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final v = _videos[index];
          return VideoListItem(
            sizeWidth: 280,
            video: v,
            onTap: () => _openPlayer(v),
            headers: mediaHeaders, // Asigurați-vă că mediaHeaders este disponibil aici
          );
        },
      ),
    );
  }
}
