import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sports_config_app/core/app_functions.dart';
import 'package:sports_config_app/features/media/presentation/video_card.dart';
import '../../../core/theme/colors.dart';
import '../data/video_item.dart';
import '../data/video_service.dart';

class VideosGridTwoColumns extends StatefulWidget {
  final String title;
  final String mpids;

  final String languageCode;

  /// IMPORTANT pentru când este folosit într-un SingleChildScrollView (ex: SportScreen)
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  final bool showMore;

  const VideosGridTwoColumns({
    super.key,
    required this.title,
    required this.mpids,
    required this.languageCode,
    this.shrinkWrap = false,
    this.physics,
    this.showMore = false,
  });

  @override
  State<VideosGridTwoColumns> createState() => _VideosGridTwoColumnsState();
}

class _VideosGridTwoColumnsState extends State<VideosGridTwoColumns> {
  final VideoService _service = const VideoService();
  final List<VideoItem> _videos = [];

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  int _offset = 0;
  final int _limit = 6; // 2 coloane x 3 rânduri

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant VideosGridTwoColumns oldWidget) {
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

  void _openPlayer(VideoItem video) {
    // aici folosești dialogul tău de player
    // showDialog( ... );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_videos.isEmpty) {
      return  Padding(
        padding: EdgeInsets.all(24),
        child: Text(AppLocalizations.of(context)!.no_videos_for_this_sport),
      );
    }
    final scale = SportsFunction().scale(context);

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics ?? const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 2,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            // joacă-te cu raportul până arată bine pe device-ul de referință
            childAspectRatio: 0.87 * scale,
          ),
          itemCount: _videos.length,
          itemBuilder: (context, index) {
            final video = _videos[index];
            return VideoCard(
              video: video,
                onTap: () => SportsFunction().openPlayer(video, context),
            );
          },
        ),
        if ( widget.showMore && _hasMore)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
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
      ],
    );
  }
}