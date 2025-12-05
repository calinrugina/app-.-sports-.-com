import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/horizontal_list_placeholder.dart';
import '../../../core/widgets/vertical_list_placeholder.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../config/providers/config_provider.dart';
import '../../live/presentation/live_screen.dart';
import '../../sports/presentation/sport_screen.dart';
import '../../media/presentation/video_list_for_mpids.dart';
import '../../media/presentation/video_listing_page_for_mpids.dart';

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
        final languages = (config?['language'] as List?) ?? [];

        String languageCode = 'en';
        if (languages.isNotEmpty) {
          final first = languages.first as Map<String, dynamic>;
          languageCode = first['code']?.toString() ?? 'en';
        }

        final hasLive = sports.any((s) {
          final m = s as Map<String, dynamic>;
          final ls = m['livestreams'] as List?;
          return ls != null && ls.isNotEmpty;
        });

        final pages = <Widget>[
          _buildHomeBody(context, sports, menuAreas, languageCode),
          if (hasLive) const LiveScreen(),
          SportScreen(sports: sports, languageCode: languageCode),
          const Center(child: Text('Profile screen (TODO)')),
        ];

        final items = <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          if (hasLive)
            const BottomNavigationBarItem(
              icon: Icon(Icons.live_tv),
              label: 'Live',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Sports',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];

        if (_selectedIndex >= items.length) {
          _selectedIndex = 0;
        }

        return Scaffold(
          appBar: const SportsAppBar(),
          body: SafeArea(
            child: IndexedStack(
              index: _selectedIndex,
              children: pages.take(items.length).toList(),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (i) {
              setState(() {
                _selectedIndex = i;
              });
            },
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            items: items,
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
  ) {
    return CustomScrollView(
      slivers: [
        ...menuAreas.expand((area) {
          final map = area as Map<String, dynamic>;
          final String name = map['name']?.toString() ?? '';

          final List<Widget> sectionWidgets = [];

          sectionWidgets.add(
            SliverToBoxAdapter(
              child: SectionHeader(title: name),
            ),
          );

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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => VideoListingPageForMpids(
                                  title: subName,
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
                    child: VideoListForMpids(
                      mpids: mpidsValue,
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
            final mpidsValue = (map['mpids'] ?? map['mpid'])?.toString();

            if (mpidsValue != null && mpidsValue.trim().isNotEmpty) {
              sectionWidgets.add(
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: name,
                    moreLabel: 'See More',
                    onMore: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VideoListingPageForMpids(
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
                  child: VideoListForMpids(
                    mpids: mpidsValue,
                    languageCode: languageCode,
                  ),
                ),
              );
            } else {
              sectionWidgets.add(
                const SliverToBoxAdapter(
                  child: VerticalListPlaceholder(),
                ),
              );
            }
          }

          return sectionWidgets;
        }),
      ],
    );
  }
}
