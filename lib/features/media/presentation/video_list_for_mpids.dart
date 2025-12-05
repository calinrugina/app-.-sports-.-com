import 'package:flutter/material.dart';
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
          return InkWell(
            onTap: () => _openPlayer(v),
            child: SizedBox(
              width: 260,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (v.thumbUrl != null)
                            Image.network(
                              v.thumbUrl!,
                              fit: BoxFit.cover,
                              headers: mediaHeaders,
                            )
                          else
                            Container(color: Colors.grey.shade300),
                          const Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    v.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
