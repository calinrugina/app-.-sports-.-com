import 'package:flutter/material.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../../core/widgets/back_header.dart';
import '../data/video_item.dart';
import '../data/video_service.dart';
import '../../../core/network/media_headers.dart';
import 'video_player_dialog.dart';

class VideoListingPageForSport extends StatefulWidget {
  final Map<String, dynamic> sport;
  final String languageCode;

  const VideoListingPageForSport({
    super.key,
    required this.sport,
    required this.languageCode,
  });

  @override
  State<VideoListingPageForSport> createState() =>
      _VideoListingPageForSportState();
}

class _VideoListingPageForSportState extends State<VideoListingPageForSport> {
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

    final newItems = await _service.fetchVideos(
      widget.sport,
      _offset,
      widget.languageCode,
      limit: _limit,
    );

    if (!mounted) return;

    setState(() {
      _videos.addAll(newItems);
      // conform cerinței: offset 0, apoi 6, 12, ...
      _offset += 6;
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
      builder: (_) =>
          VideoPlayerDialog(
            videoUrl: url,
            title: v.title,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.sport['name']?.toString() ?? 'Sport';

    return Scaffold(
      appBar: const SportsAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BackHeader(title: 'Listing Videos (\$name)'),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 16 / 11,
                      ),
                      itemCount: _videos.length,
                      itemBuilder: (context, index) {
                        final v = _videos[index];
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
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
          ),
        ],
      ),
    );
  }
}