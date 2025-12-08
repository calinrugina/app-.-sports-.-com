import 'dart:developer' as SportsAppLogger;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/app_functions.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../media/data/video_item.dart';
import '../../media/data/video_service.dart';
import '../../media/presentation/video_item_in_listing.dart';
import '../../media/presentation/video_player_dialog.dart';

class StudioScreen extends StatefulWidget {
  final List<dynamic> menuAreas;
  final String languageCode;

  const StudioScreen({
    super.key,
    required this.menuAreas,
    required this.languageCode,
  });

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  int _selectedIndex = 0;

  final VideoService _videoService = const VideoService();
  final List<VideoItem> _videos = [];
  bool _loadingVideos = false;
  bool _endReached = false;
  int _offset = 0;
  final int _limit = 6;

  /// Returnează lista de areas de sub "Sports Studios".
  List<Map<String, dynamic>> get _studioAreas {
    for (final area in widget.menuAreas) {
      final m = area as Map<String, dynamic>;
      if (m['name']?.toString() == 'Sports Studios') {
        final list = m['areas'] as List? ?? [];
        return list.cast<Map<String, dynamic>>();
      }
    }
    return const [];
  }

  String? get _currentMpids {
    final areas = _studioAreas;
    if (areas.isEmpty || _selectedIndex >= areas.length) return null;
    final selected = areas[_selectedIndex];
    return (selected['mpids'] ?? selected['mpid'])?.toString();
  }

  String get _currentName {
    final areas = _studioAreas;
    if (areas.isEmpty || _selectedIndex >= areas.length) return '';
    return areas[_selectedIndex]['name']?.toString() ?? '';
  }

  @override
  void initState() {
    super.initState();
    // implicit: primul tab (ex: Goats)
    _resetAndLoadForIndex(0);
  }
  @override
  void didUpdateWidget(covariant StudioScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // dacă s-a schimbat limba din setări, refacem lista pentru primul studio
    if (oldWidget.languageCode != widget.languageCode) {
      SportsAppLogger.log('STUDIO LANGUAGE CHANGED');
      _resetAndLoadForIndex(0);
    }
  }
  Future<void> _resetAndLoadForIndex(int index) async {
    setState(() {
      _selectedIndex = index;
      _videos.clear();
      _offset = 0;
      _endReached = false;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loadingVideos || _endReached) return;
    final mpids = _currentMpids;
    if (mpids == null || mpids.trim().isEmpty) {
      setState(() {
        _loadingVideos = false;
        _endReached = true;
      });
      return;
    }

    setState(() {
      _loadingVideos = true;
    });

    final newItems = await _videoService.fetchVideosForSets(
      mpids,
      _offset,
      widget.languageCode,
      limit: _limit,
    );

    if (!mounted) return;

    setState(() {
      _videos.addAll(newItems);
      _offset += _limit;
      if (newItems.length < _limit) {
        _endReached = true;
      }
      _loadingVideos = false;
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
    final areas = _studioAreas;

    if (areas.isEmpty) {
      return const Center(child: Text('No Sports Studios configured'));
    }

    if (_selectedIndex >= areas.length) {
      _selectedIndex = 0;
    }

    final selectedName = _currentName;

    return Column(
      children: [
        // carusel cu toate studiourile, similar cu bara de sporturi
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: areas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final area = areas[index];
                final name = area['name']?.toString() ?? '';
                final iconUrl = area['icon']?.toString();
                final isSelected = index == _selectedIndex;

                return GestureDetector(
                  onTap: () {
                    _resetAndLoadForIndex(index);
                  },
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.red : Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (iconUrl != null && iconUrl.isNotEmpty)
                          SizedBox(
                            height: 28,
                            child: SvgIconLoader(
                              iconUrl: iconUrl,
                              headers: mediaHeaders,
                            ),
                          )
                        else
                          const Icon(
                            Icons.tv,
                            color: Colors.white,
                            size: 22,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SectionHeader(title: selectedName),
              ),
              if (_videos.isEmpty && _loadingVideos)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (_videos.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No videos configured for this studio.'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 16 / 11,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final v = _videos[index];
                        return VideoListItem(
                          video: v,
                          onTap: () => _openPlayer(v),
                          headers: mediaHeaders, // Asigurați-vă că mediaHeaders este disponibil aici
                        );
                      },
                      childCount: _videos.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    if (_videos.isNotEmpty && !_endReached)
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
