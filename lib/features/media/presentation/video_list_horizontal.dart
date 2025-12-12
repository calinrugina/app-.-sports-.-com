import 'package:sports_config_app/l10n/app_localizations.dart';
import 'dart:developer' as SportsAppLogger;
import 'package:flutter/material.dart';
import 'package:sports_config_app/core/app_config.dart';
import 'package:sports_config_app/features/media/presentation/video_card.dart';
import '../../../core/app_functions.dart';
import '../data/video_item.dart';
import '../data/video_service.dart';
import '../../../core/network/media_headers.dart';
import 'video_player_dialog.dart';

/// Listă orizontală de video-uri pentru un set de mpids (from_sets).
class VideoCaruselList extends StatefulWidget {
  final String title;
  final String mpids;
  final String languageCode;

  const VideoCaruselList({
    super.key,
    required this.title,
    required this.mpids,
    required this.languageCode,
  });

  @override
  State<VideoCaruselList> createState() => _VideoCaruselListState();
}

class _VideoCaruselListState extends State<VideoCaruselList> {
  final VideoService _service = const VideoService();
  List<VideoItem> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant VideoCaruselList oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Dacă s-a schimbat limba sau mpids-urile, refacem lista
    if (oldWidget.languageCode != widget.languageCode ||
        oldWidget.mpids != widget.mpids) {
      SportsAppLogger.log('VideoCaruselList – reload (lang or mpids changed)');
      _load(reset: true);
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _videos = [];
      });
    }

    final list = await _service.fetchVideosForSets(
      widget.mpids,
      0,
      widget.languageCode,
      limit: 5, // vrei 4–5 videouri în carusel
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
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_videos.isEmpty) {
      return  Padding(
        padding: EdgeInsets.all(15),
        child: Text(AppLocalizations.of(context)!.no_videos),
      );
    }

    // vrem ~4 item-uri vizibile pe ecran
    const visibleItems = 2;
    const horizontalPadding = 0.0;
    const itemSpacing = AppConfig.appPadding;

    final screenWidth = MediaQuery.of(context).size.width;
    final totalSpacing = itemSpacing * (visibleItems - 1);
    final availableWidth =
        screenWidth - horizontalPadding * 2 - totalSpacing;
    final itemWidth = availableWidth / visibleItems;


    // astea sunt OK
    // lățimea fiecărui card ~70% din ecran
    final cardWidth = screenWidth * 0.8;

    const referenceWidth = 430.0;
    final scale = cardWidth / referenceWidth;

    // înălțime aproximativă pt card + padding
    final listHeight = cardWidth * .9;

    return SizedBox(
      height: listHeight, // înălțime suficientă pentru thumb + titlu
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        itemCount: _videos.length,
        separatorBuilder: (_, __) => const SizedBox(width: itemSpacing),
        itemBuilder: (context, index) {
          final v = _videos[index];
          return SizedBox(
            width: cardWidth,
            child: VideoCard(
              video: v,
              onTap: () => SportsFunction().openPlayer(v, context),
              pictureRatio: 16/9,
            ),
          );
        },
      ),
    );
  }
}