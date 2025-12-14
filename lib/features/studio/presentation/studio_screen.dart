import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sports_config_app/core/app_config.dart';
import '../../../core/app_functions.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../media/data/video_item.dart';
import '../../media/data/video_service.dart';
import '../../media/presentation/video_card.dart';
import '../../media/presentation/video_listing_two_columns.dart';
import '../../media/presentation/video_player_dialog.dart';
import '../../media/presentation/videos_listing.dart';

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
  final ScrollController _scrollController = ScrollController();

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    });
  }

  @override
  Widget build(BuildContext context) {
    const String languageCode = 'en';

    final areas = _studioAreas;

    if (areas.isEmpty) {
      return Center(
          child:
              Text(AppLocalizations.of(context)!.no_sports_studios_configured));
    }

    if (_selectedIndex >= areas.length) {
      _selectedIndex = 0;
    }
    final selectedName = _currentName;
// === CALCUL DINAMIC PENTRU childAspectRatio ===
    final screenWidth = MediaQuery.of(context).size.width;
    const referenceWidth = 430.0;
    final scale = screenWidth / referenceWidth;

    return Column(
      children: [
        // carusel cu toate studiourile, similar cu bara de sporturi
        Container(
          color: AppColors.darkTabs,
          // padding: const EdgeInsets.symmetric(vertical: AppConfig.paddingInside),
          child: SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              // padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: areas.length,
              separatorBuilder: (_, __) => Container(
                color: Colors.black,
                child: SizedBox(width: 1),
              ),
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
                    width: 100,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.redSports : AppColors.darkTabs,
                      // borderRadius: BorderRadius.circular(10),
                    ),
                    // padding: const EdgeInsets.symmetric(
                    //   horizontal: 6,
                    //   vertical: 4,
                    // ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (iconUrl != null && iconUrl.isNotEmpty)
                          SizedBox(
                            height: 35,
                            child: SvgIconLoader(
                              iconUrl: iconUrl,
                              headers: mediaHeaders,
                              size: 40,
                            ),
                          )
                        else
                          const Icon(
                            Icons.sports,
                            color: Colors.white,
                            size: 35,
                          ),
                        const SizedBox(height: 2),
                        Text(name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(fontSize: 14, color: Colors.white)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
          child: SectionHeader(
            title: _currentName,
            moreLabel: AppLocalizations.of(context)!.see_more,
            titleRed: AppLocalizations.of(context)!.latest_videos,
            onMore: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VideosListing(
                    languageCode: 'en',
                    mpids: _currentMpids ?? '',
                    title: _currentName,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
            child: Scrollbar(
                controller: _scrollController,
    thickness: 4.0, // Lățime ușor crescută
    radius: const Radius.circular(10),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: VideosGridTwoColumns(
                        title: _currentName,
                        mpids: _currentMpids ?? '',
                        languageCode: languageCode,
                        shrinkWrap: true,
                        showMore: true,
                      ),
                    ),
                  ),
                )))
        // Expanded(
        //   child: SingleChildScrollView(
        //     child: Padding(
        //       padding: const EdgeInsets.symmetric(
        //           horizontal: AppConfig.appPadding,
        //           vertical: AppConfig.appPadding),
        //       child: Column(children: [
        //         GridView.builder(
        //           shrinkWrap: true,
        //           physics: const BouncingScrollPhysics(),
        //           padding: const EdgeInsets.symmetric(
        //             horizontal: 0,
        //             vertical: 2,
        //           ),
        //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //             crossAxisCount: 2,
        //             crossAxisSpacing: 12,
        //             mainAxisSpacing: 12,
        //             // joacă-te cu raportul până arată bine pe device-ul de referință
        //             childAspectRatio: 0.96 * SportsFunction().scale(context),
        //           ),
        //           itemCount: _videos.length,
        //           itemBuilder: (context, index) {
        //             final video = _videos[index];
        //             return VideoCard(
        //               video: video,
        //               onTap: () => _openPlayer(video),
        //             );
        //           },
        //         )
        //       ]),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
