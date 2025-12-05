import 'package:flutter/material.dart';
import '../data/video_item.dart';
import '../data/video_service.dart';
import '../../../core/network/media_headers.dart';
import 'video_player_dialog.dart';

class VideoListForSport extends StatefulWidget {
  final Map<String, dynamic> sport;
  final String languageCode;

  const VideoListForSport({
    super.key,
    required this.sport,
    required this.languageCode,
  });

  @override
  State<VideoListForSport> createState() => _VideoListForSportState();
}

class _VideoListForSportState extends State<VideoListForSport> {
  final VideoService _service = const VideoService();
  List<VideoItem> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // limit inițial 6 (2 coloane x 3 rânduri)
    final list = await _service.fetchVideos(
      widget.sport,
      0,
      widget.languageCode,
      limit: 6,
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
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_videos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No videos for this sport.'),
      );
    }

    // Grid 2 coloane, max 3 rânduri (primele 6 elemente)
    final displayVideos = _videos.length > 6 ? _videos.sublist(0, 6) : _videos;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          // 16:9 + text; aproximăm un raport
          childAspectRatio: 16 / 11,
        ),
        itemCount: displayVideos.length,
        itemBuilder: (context, index) {
          final v = displayVideos[index];
          return InkWell(
            onTap: () => _openPlayer(v),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
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
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  v.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
