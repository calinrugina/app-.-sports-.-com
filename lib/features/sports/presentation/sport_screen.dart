import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/section_header.dart';
import '../../media/presentation/video_list_for_sport.dart';
import '../../news/presentation/article_list_for_sport.dart';
import '../providers/selected_sport_provider.dart';
import '../../home/presentation/widgets/top_categories.dart';
import '../../media/presentation/video_listing_page_for_sport.dart';
import '../../news/presentation/article_listing_page_for_sport.dart';

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
        TopCategories(sports: sports),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: '$name Videos',
                  moreLabel: 'Load more',
                  onMore: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VideoListingPageForSport(
                          sport: sport,
                          languageCode: languageCode,
                        ),
                      ),
                    );
                  },
                ),
                VideoListForSport(
                  key: ValueKey('videos_$sportKey'),
                  sport: sport,
                  languageCode: languageCode,
                ),
                const SizedBox(height: 16),
                SectionHeader(
                  title: '$name News',
                  moreLabel: 'Load more',
                  onMore: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ArticleListingPageForSport(
                          sport: sport,
                          languageCode: languageCode,
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: ArticleListForSport(
                    key: ValueKey('articles_$sportKey'),
                    sport: sport,
                    languageCode: languageCode,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
