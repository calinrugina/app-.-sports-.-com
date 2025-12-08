import 'package:flutter/material.dart';
import 'package:sports_config_app/features/media/presentation/video_item_in_listing.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../../core/widgets/back_header.dart';
import '../data/video_item.dart';
import '../data/video_service.dart';
import '../../../core/network/media_headers.dart';
import 'video_player_dialog.dart';

class VideoListingPage extends StatefulWidget {
  // final Map<String, dynamic> sport;
  final String languageCode;
  final String fromSets;
  final String title;

  const VideoListingPage({
    super.key,
    // required this.sport,
    required this.languageCode,
    required this.fromSets,
    required this.title,
  });

  @override
  State<VideoListingPage> createState() =>
      _VideoListingPageState();
}

class _VideoListingPageState extends State<VideoListingPage> {
  final VideoService _service = const VideoService();
  final List<VideoItem> _videos = [];
  bool _loading = false;
  bool _endReached = false;
  int _offset = 0;
  static const int _limit = 8;

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
      widget.fromSets,
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

    return Scaffold(
      appBar: const SportsAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BackHeader(title: 'Listing Videos (${widget.title})'),
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
                        childAspectRatio: 16 / 15,
                      ),
                      itemCount: _videos.length,
                      itemBuilder: (context, index) {
                        final v = _videos[index];
                        return VideoListItem(
                          video: v,
                          onTap: () => _openPlayer(v),
                          headers: mediaHeaders, // Asigurați-vă că mediaHeaders este disponibil aici
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