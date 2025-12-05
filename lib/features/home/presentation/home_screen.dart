import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/horizontal_list_placeholder.dart';
import '../../../core/widgets/vertical_list_placeholder.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../config/providers/config_provider.dart';
import '../../../core/language/language_provider.dart';
import '../../live/presentation/live_screen.dart';
import '../../sports/presentation/sport_screen.dart';
import '../../studio/presentation/studio_screen.dart';
import '../../more/presentation/more_screen.dart';
import '../../media/presentation/video_list_for_mpids.dart';
import '../../media/presentation/video_listing_page_for_mpids.dart';
import 'widgets/top_categories.dart';

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

        final hasLive = sports.any((s) {
          final m = s as Map<String, dynamic>;
          final ls = m['livestreams'] as List?;
          return ls != null && ls.isNotEmpty;
        });

        final List<Widget> pages = [];
        final List<BottomNavigationBarItem> items = [];

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
        items.add(
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/tab_home.svg',
              height: 22,
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/tab_home.svg',
              height: 22,
              colorFilter: const ColorFilter.mode(
                AppColors.red,
                BlendMode.srcIn,
              ),
            ),
            label: 'Home',
          ),
        );

        // Live (optional)
        if (hasLive) {
          pages.add(const LiveScreen());
          items.add(
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                'assets/images/tab_livescores.svg',
                height: 22,
              ),
              activeIcon: SvgPicture.asset(
                'assets/images/tab_livescores.svg',
                height: 22,
                colorFilter: const ColorFilter.mode(
                  AppColors.red,
                  BlendMode.srcIn,
                ),
              ),
              label: 'Livescores',
            ),
          );
        }

        // Sports
        pages.add(SportScreen(sports: sports, languageCode: languageCode));
        items.add(
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/tab_sports.svg',
              height: 22,
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/tab_sports.svg',
              height: 22,
              colorFilter: const ColorFilter.mode(
                AppColors.red,
                BlendMode.srcIn,
              ),
            ),
            label: 'Sports',
          ),
        );

        // Studio
        pages.add(
          StudioScreen(menuAreas: menuAreas, languageCode: languageCode),
        );
        items.add(
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/tab_studios.svg',
              height: 22,
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/tab_studios.svg',
              height: 22,
              colorFilter: const ColorFilter.mode(
                AppColors.red,
                BlendMode.srcIn,
              ),
            ),
            label: 'Studios',
          ),
        );

        // More
        pages.add(const MoreScreen());
        items.add(
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/images/tab_more.svg',
              height: 22,
            ),
            activeIcon: SvgPicture.asset(
              'assets/images/tab_more.svg',
              height: 22,
              colorFilter: const ColorFilter.mode(
                AppColors.red,
                BlendMode.srcIn,
              ),
            ),
            label: 'More',
          ),
        );

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
            backgroundColor: Colors.black,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (i) {
              setState(() {
                _selectedIndex = i;
              });
            },
            selectedItemColor: AppColors.red,
            unselectedItemColor: Colors.white,
            showUnselectedLabels: true,
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
    VoidCallback goToSportsTab,
  ) {
    return Column(
      children: [
        // bara de sporturi, fixă sus, la fel ca în tabul Sports
        TopCategories(
          sports: sports,
          highlightSelected: false,
          onSportSelected: (_) => goToSportsTab(),
        ),
        const Divider(height: 1),
        Expanded(
          child: CustomScrollView(
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
                  final mpidsValue =
                      (map['mpids'] ?? map['mpid'])?.toString();

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
          ),
        ),
      ],
    );
  }
}
