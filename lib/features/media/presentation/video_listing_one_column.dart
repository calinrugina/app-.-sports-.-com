import 'package:sports_config_app/l10n/app_localizations.dart';
// lib/features/media/presentation/videos_list_one_column.dart
import 'package:flutter/material.dart';
import 'package:sports_config_app/core/app_config.dart';
import 'package:sports_config_app/core/app_functions.dart';
import 'package:sports_config_app/core/theme/colors.dart';

import '../../../core/network/media_headers.dart';
import '../data/video_item.dart';
import '../data/video_service.dart';
import 'video_card.dart';

class VideosListOneColumn extends StatefulWidget {
  final String title;
  final String mpids;
  final String languageCode;
  final String? q;
  const VideosListOneColumn({
    super.key,
    required this.title,
    required this.mpids,
    required this.languageCode,
    this.q,
  });

  @override
  State<VideosListOneColumn> createState() => _VideosListOneColumnState();
}

class _VideosListOneColumnState extends State<VideosListOneColumn> {
  final VideoService _service = const VideoService();
  final List<VideoItem> _videos = [];

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  int _offset = 0;
  final int _limit = 5;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant VideosListOneColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mpids != widget.mpids ||
        oldWidget.languageCode != widget.languageCode) {
      _load(reset: true);
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _initialLoading = true;
        _loadingMore = false;
        _hasMore = true;
        _offset = 0;
        _videos.clear();
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    final list = await _service.fetchVideosForSets(
      widget.mpids,
      _offset,
      widget.languageCode,
      limit: _limit,
      q: widget.q,
    );

    if (!mounted) return;

    setState(() {
      _videos.addAll(list);
      _offset += list.length;
      if (list.length < _limit) _hasMore = false;
      _initialLoading = false;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_videos.isEmpty) {
      return  Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(AppLocalizations.of(context)!.no_videos_for_this_sport),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric( horizontal: AppConfig.appPadding),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 0,
          vertical: 2,
        ),
        itemCount: _videos.length + (_hasMore ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: AppConfig.smallSpace),
        itemBuilder: (context, index) {
          if (index < _videos.length) {
            final video = _videos[index];
            return VideoCard(
                video: video, 
                onTap: () => SportsFunction().openPlayer(video, context),
              pictureRatio: 16/9,
            );
          }

          // butonul Load more
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redSports,
                  foregroundColor: Colors.white,
                ),
                onPressed: _loadingMore ? null : () => _load(reset: false),
                child: _loadingMore
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                          backgroundColor: AppColors.redSports,
                        ),
                      )
                    : Text('Load more'.toUpperCase(), style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white, fontSize: 14),),
              ),
            ),
          );
        },
      ),
    );
  }
}
