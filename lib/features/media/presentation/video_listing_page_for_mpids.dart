import 'package:flutter/material.dart';
import '../data/video_item.dart';
import '../data/video_service.dart';
import '../../../core/network/media_headers.dart';
import 'video_player_dialog.dart';

class VideoListingPageForMpids extends StatefulWidget {
  final String title;
  final String mpids;
  final String languageCode;

  const VideoListingPageForMpids({
    super.key,
    required this.title,
    required this.mpids,
    required this.languageCode,
  });

  @override
  State<VideoListingPageForMpids> createState() =>
      _VideoListingPageForMpidsState();
}

class _VideoListingPageForMpidsState extends State<VideoListingPageForMpids> {
  final VideoService _service = const VideoService();
  final List<VideoItem> _videos = [];
  bool _loading = false;
  bool _endReached = false;
  int _offset = 0;
  static const int _limit = 5;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || _endReached) return;
    setState(() {
      _loading = true;
    });

    final newItems = await _service.fetchVideosForSets(
      widget.mpids,
      _offset,
      widget.languageCode,
      limit: _limit,
    );

    if (!mounted) return;

    setState(() {
      _videos.addAll(newItems);
      _offset += 6; // conform cerinței
      if (newItems.length < _limit) {
        _endReached = true;
      }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Listing Videos (${widget.title})'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _videos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final v = _videos[index];
                return InkWell(
                  onTap: () => _openPlayer(v),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (!_loading && !_endReached)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _loadMore,
                child: const Text('Load more'),
              ),
            ),
          if (_endReached)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No more videos'),
            ),
        ],
      ),
    );
  }
}
