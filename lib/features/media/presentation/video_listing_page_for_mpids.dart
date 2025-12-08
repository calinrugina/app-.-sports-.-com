import 'dart:developer' as SportsAppLogger;

import 'package:flutter/material.dart';
import 'package:sports_config_app/features/media/presentation/video_item_in_listing.dart';
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
  @override
  void didUpdateWidget(covariant VideoListingPageForMpids oldWidget) {
    super.didUpdateWidget(oldWidget);
    // dacă s-a schimbat limba din setări, refacem lista pentru primul studio
    if (oldWidget.languageCode != widget.languageCode) {
      SportsAppLogger.log('VideoListingPageForMpids LANGUAGE CHANGED');
    }
  }
  // @override
  // void didUpdateWidget(covariant VideoListingPageForMpids oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   SportsAppLogger.log('PULAAAA ${oldWidget.languageCode}  ${widget.languageCode} ');
  //
  //   // dacă s-a schimbat limba sau sportul, refacem lista
  //   if (oldWidget.languageCode != widget.languageCode ||
  //       oldWidget.mpids != widget.mpids) {
  //     SportsAppLogger.log('AICI!!!!');
  //     setState(() {
  //       _loading = true;
  //
  //     });
  //     _loadMore();
  //   }
  // }
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
                return VideoListItem(
                  video: v,
                  onTap: () => _openPlayer(v),
                  headers: mediaHeaders, // Asigurați-vă că mediaHeaders este disponibil aici
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
