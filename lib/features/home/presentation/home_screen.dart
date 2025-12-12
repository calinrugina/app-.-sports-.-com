import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sports_config_app/core/app_config.dart';
import '../../../core/widgets/custom_bottom_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/horizontal_list_placeholder.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../config/providers/config_provider.dart';
import '../../../core/language/language_provider.dart';
import '../../live/presentation/live_screen.dart';
import '../../media/presentation/videos_listing.dart';
import '../../sports/presentation/sport_screen.dart';
import '../../studio/presentation/studio_screen.dart';
import '../../more/presentation/more_screen.dart';
import '../../media/presentation/video_list_horizontal.dart';
import 'widgets/top_sports.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(configProvider);

    return configAsync.when(
      data: (config) {
        final sports = (config?['sports'] as List?) ?? [];
        final menuAreas = (config?['menu_areas'] as List?) ?? [];

        final selectedLanguage = ref.watch(languageProvider);
        final String languageCode =
        selectedLanguage.isNotEmpty ? selectedLanguage : 'en';

        // există sporturi cu livestream?
        final hasLive = sports.any((s) {
          final m = s as Map<String, dynamic>;
          final ls = m['livestreams'] as List?;
          final liveStreams = [];

          if (ls != null && ls.isNotEmpty) {
            // Iterăm prin fiecare element din lista 'ls'
            for (final item in ls) {
              final countdownActive = item["countdown_active"] == 1;
              final countdownEndStr = item["countdown_end"]?.toString();

              if (
                !countdownActive || countdownEndStr == null
              ) {
                // Dacă nu e activ sau nu are dată de sfârșit, ar trebui să poată fi redat (Live Now)
                liveStreams.add(item);
              }else{
                final countdownEnd = DateTime.parse(countdownEndStr).toLocal();
                final now = DateTime.now();

                if (countdownActive && countdownEnd.isAfter(now)){
                  liveStreams.add(item);
                }
              }
            }

          }
          return ls != null && ls.isNotEmpty && liveStreams.isNotEmpty;
        });

        final List<Widget> pages = [];

        // indexul tab-ului Sports în bottom bar:
        final int sportsTabIndex = 1 + (hasLive ? 1 : 0);

        // Home
        pages.add(
          _buildHomeBody(
            context,
            sports,
            menuAreas,
            languageCode,
                () {
              setState(() {
                _selectedIndex = sportsTabIndex;
              });
            },
          ),
        );

        // Live (optional)
        if (hasLive) {
          pages.add(const LiveScreen());
        }

        // Sports
        pages.add(SportScreen(sports: sports, languageCode: languageCode));

        // Studio
        pages.add(
          StudioScreen(menuAreas: menuAreas, languageCode: languageCode),
        );

        // More
        pages.add(const MoreScreen());

        // dacă între timp numărul de pagini s-a schimbat (ex: a apărut/dispărut Live),
        // ne asigurăm că indexul curent este valid
        if (_selectedIndex >= pages.length) {
          _selectedIndex = 0;
        }

        return Scaffold(
          appBar: const SportsAppBar(),
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: (i) {
              setState(() {
                _selectedIndex = i;
              });
            },
            hasLive: hasLive,
          ),
        );
      },
      loading: () => const Scaffold(
        appBar: SportsAppBar(),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => const Scaffold(
        appBar: SportsAppBar(),
        body: Center(child: Text('Error loading config')),
      ),
    );
  }

  Widget _buildHomeBody(
      BuildContext context,
      List<dynamic> sports,
      List<dynamic> menuAreas,
      String languageCode,
      VoidCallback goToSportsTab,
      ) {
    return Column(
      children: [
        // bara de sporturi, fixă sus, la fel ca în tabul Sports
        SportsOnTop(
          sports: sports,
          highlightSelected: false,
          onSportSelected: (_) => goToSportsTab(),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
            child: CustomScrollView(
              slivers: [
                ...menuAreas.expand((area) {
                  final map = area as Map<String, dynamic>;
                  final String name = map['name']?.toString() ?? '';

                  final List<Widget> sectionWidgets = [];

                  final areas = map['areas'] as List?;

                  if (areas != null && areas.isNotEmpty) {
                    for (final sub in areas) {
                      final subMap = sub as Map<String, dynamic>;
                      final subName = subMap['name']?.toString() ?? '';

                      final mpidsValue =
                      (subMap['mpids'] ?? subMap['mpid'])?.toString();

                      sectionWidgets.add(
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: subName,
                            moreLabel: 'See More',
                            onMore: (mpidsValue != null &&
                                mpidsValue.trim().isNotEmpty)
                                ? () {
                              SportsAppLogger.log('1-$mpidsValue');
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VideosListing(
                                    title: name,
                                    mpids: mpidsValue,
                                    languageCode: languageCode,
                                  ),
                                ),
                              );
                            }
                                : null,
                          ),
                        ),
                      );

                      if (mpidsValue != null && mpidsValue.trim().isNotEmpty) {
                        sectionWidgets.add(
                          SliverToBoxAdapter(
                            child: VideoCaruselList(
                              mpids: mpidsValue,
                              title: '',
                              languageCode: languageCode,
                            ),
                          ),
                        );
                      } else {
                        sectionWidgets.add(
                          const SliverToBoxAdapter(
                            child: HorizontalListPlaceholder(),
                          ),
                        );
                      }
                    }
                  } else {
                    final mpidsValue =
                    (map['mpids'] ?? map['mpid'])?.toString();

                    if (mpidsValue != null && mpidsValue.trim().isNotEmpty) {
                      sectionWidgets.add(
                        SliverToBoxAdapter(
                          child: SectionHeader(
                            title: name,
                            moreLabel: 'See More',
                            onMore: () {
                              SportsAppLogger.log('2-$mpidsValue');
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => VideosListing(
                                    title: name,
                                    mpids: mpidsValue,
                                    languageCode: languageCode,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                      sectionWidgets.add(
                        SliverToBoxAdapter(
                          child: VideoCaruselList(
                            title: 'two',
                            mpids: mpidsValue,
                            languageCode: languageCode,
                          ),
                        ),
                      );
                    }
                  }

                  return sectionWidgets;
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}