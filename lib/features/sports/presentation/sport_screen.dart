import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_config_app/features/media/presentation/video_listing_two_columns.dart';
import 'package:sports_config_app/features/sports/presentation/sport_banners_carousel.dart';
import '../../../core/app_config.dart';
import '../../../core/widgets/section_header.dart';
import '../../media/presentation/videos_listing.dart';
import '../../news/presentation/article_detail_screen.dart';
import '../../news/presentation/articles_listing.dart';
import '../../news/presentation/article_listing_one_column.dart';
import '../../news/presentation/article_listing_two_columns.dart';
import '../providers/selected_sport_provider.dart';
import '../../home/presentation/widgets/top_sports.dart';

class SportScreen extends ConsumerWidget {
  final List<dynamic> sports;
  final String languageCode;

  const SportScreen({
    super.key,
    required this.sports,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sports.isEmpty) {
      return const Center(child: Text('No sports configured'));
    }

    final selectedIndex = ref.watch(selectedSportIndexProvider);
    final safeIndex = selectedIndex.clamp(0, sports.length - 1);
    final sport = sports[safeIndex] as Map<String, dynamic>;
    final name = sport['name']?.toString() ?? 'Sport';
    final sportKey = (sport['id'] ?? sport['mpid'] ?? safeIndex).toString();

    return Column(
      children: [
        // lista de sporturi sus, fixa în tabul Sports
        SportsOnTop(sports: sports),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const SizedBox(height: 16),
                  SportBannersCarousel(sport: sport),
                  // const SizedBox(height: 12),
                  SectionHeader(
                    title: name,
                    titleRed: 'Latest Videos',
                    moreLabel: 'See More',
                    onMore: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VideosListing(
                            languageCode: languageCode,
                            mpids: sport['mpid'],
                            title: sport['name'],
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: VideosGridTwoColumns(
                      title: sport['name'],
                      mpids: sport['mpid'],
                      languageCode: languageCode,
                      shrinkWrap: true,
                      showMore: true,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionHeader(
                    title: name,
                    moreLabel: 'See More',
                    titleRed: 'News',
                    onMore: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ArticlesListing(
                            sport: sport,
                            languageCode: languageCode,
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: ArticlesGridTwoColumns(
                      sport: sport,
                      languageCode: languageCode,
                      shrinkWrap: true,
                      showMore: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
