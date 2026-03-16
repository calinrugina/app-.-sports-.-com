import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sports_config_app/core/app_config.dart';
import '../../../core/app_functions.dart';
import '../../../core/widgets/custom_bottom_bar.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../../core/network/media_headers.dart';
import '../../config/providers/config_provider.dart';
import '../../config/models/config_models.dart';
import '../../../core/language/language_provider.dart';
import '../../live/presentation/live_screen.dart';
import '../../sports/presentation/sport_screen.dart';
import '../../sports/providers/selected_sport_provider.dart';
import '../../studio/presentation/studio_screen.dart';
import '../../more/presentation/more_screen.dart';
import '../../asset/presentation/asset_card.dart';
import '../../../widgets/block_assets_section.dart';
import 'widgets/top_sports.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  static const double _backToTopThreshold = 400;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.hasClients &&
        _scrollController.offset > _backToTopThreshold;
    if (show != _showBackToTop && mounted) {
      setState(() => _showBackToTop = show);
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final configAsync = ref.watch(configProvider);

    return configAsync.when(
      data: (config) {
        final sports = (config?['sports'] as List?) ?? [];

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

        // Dacă s-a cerut navigare la Sports cu un sport (ex: din dropdown Asset Details)
        final goToSportsIndex = ref.watch(goToSportsWithIndexProvider);
        if (goToSportsIndex != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref.read(goToSportsWithIndexProvider.notifier).state = null;
            ref.read(selectedSportIndexProvider.notifier).state =
                goToSportsIndex.clamp(0, sports.length - 1);
            setState(() => _selectedIndex = sportsTabIndex);
          });
        }

        // Home: use blocks from config['homepage'] (same pattern as Sports tab).
        // Homepage blocks may omit "id" (Block.fromJson treats missing id as 0).
        final homepage = config?['homepage'] as Map<String, dynamic>?;
        final homepageBlocks = <Block>[];
        if (homepage != null) {
          final blocksRaw = homepage['blocks'] as List<dynamic>? ?? [];
          for (final e in blocksRaw) {
            if (e is Map) {
              homepageBlocks.add(Block.fromJson(Map<String, dynamic>.from(e)));
            }
          }
        }

        pages.add(
          _buildHomeBody(
            context,
            sports,
            languageCode,
            homepageBlocks,
            () {
              setState(() {
                _selectedIndex = sportsTabIndex;
              });
            },
          ),
        );

        // Live (optional)
        if (hasLive) {
          pages.add( LiveScreen());
        }

        // Sports
        pages.add(SportScreen(sports: sports, languageCode: languageCode));

        // Studio: use blocks from config['studios']['blocks'] (like home config['homepage'], sports config['sports'])
        final studios = config?['studios'] as Map<String, dynamic>?;
        final studioBlocks = <Block>[];
        if (studios != null) {
          final blocksRaw = studios['blocks'] as List<dynamic>? ?? [];
          for (final e in blocksRaw) {
            if (e is Map) {
              studioBlocks.add(Block.fromJson(Map<String, dynamic>.from(e)));
            }
          }
        }
        pages.add(
          StudioScreen(blocks: studioBlocks, languageCode: languageCode),
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
      loading: () => Scaffold(
        appBar: const SportsAppBar(),
        body: SportsFunction().customLoading(),
      ),
      error: (e, st) =>  Scaffold(
        appBar: const  SportsAppBar(),
        body: Center(child: Text(AppLocalizations.of(context)!.error_loading_config)),
      ),
    );
  }

  Widget _buildHomeBody(
    BuildContext context,
    List<dynamic> sports,
    String languageCode,
    List<Block> homepageBlocks,
    VoidCallback goToSportsTab,
  ) {
    return Stack(
      children: [
        Column(
          children: [
            SportsOnTop(
              sports: sports,
              highlightSelected: false,
              onSportSelected: (_) => goToSportsTab(),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConfig.zeroPadding),
                child: Scrollbar(
                  controller: _scrollController,
                  thickness: 4.0,
                  radius: const Radius.circular(10),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: BlockAssetsList(
                      blocks: homepageBlocks,
                      client: mediaPlatformClient,
                      lang: languageCode,
                      assetBuilder: (context, asset) => AssetCard(
                        asset: asset,
                        onTap: () => SportsFunction().openAssetDetails(asset, context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_showBackToTop)
          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton.small(
              onPressed: _scrollToTop,
              heroTag: 'home_back_to_top',
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
      ],
    );
  }
}