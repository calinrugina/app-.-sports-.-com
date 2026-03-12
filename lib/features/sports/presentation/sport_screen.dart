import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sports_config_app/features/media/presentation/video_listing_two_columns.dart';
import 'package:sports_config_app/features/sports/presentation/sport_banners_carousel.dart';
import '../../../core/app_config.dart';
import '../../../core/app_functions.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/widgets/section_header.dart';
import '../../../widgets/block_assets_section.dart';
import '../../asset/data/media_platform_client.dart';
import '../../asset/models/asset.dart';
import '../../asset/presentation/asset_card.dart';
import '../../config/models/config_models.dart';
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

  SportScreen({
    super.key,
    required this.sports,
    required this.languageCode,
  });
  final ScrollController _scrollController = ScrollController();




  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sports.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_sports_configured));
    }

    final selectedIndex = ref.watch(selectedSportIndexProvider);
    final safeIndex = selectedIndex.clamp(0, sports.length - 1);
    final sport = sports[safeIndex] as Map<String, dynamic>;
    final name = sport['name']?.toString() ?? 'Sport';
    final sportKey = (sport['id'] ?? sport['mpid'] ?? safeIndex).toString();

    final config = CategoryConfig.fromJson(sport);

    return Column(
      children: [
        // lista de sporturi sus, fixa în tabul Sports
        SportsOnTop(sports: sports),
        const Divider(height: 1),
        Expanded(
          child: Scrollbar(
              controller: _scrollController,
              thickness: 4.0, // Lățime ușor crescută
              radius: const Radius.circular(10), // Colțuri mai rotunjite
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppConfig.zeroPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const SizedBox(height: 16),
                      SportBannersCarousel(sport: sport),

                      BlockAssetsList(
                          blocks: config.blocks,
                          client: mediaPlatformClient,
                          lang: 'en',
                          // country: 'GB',
                          redTitle: name,
                          assetBuilder: (context, assets) => AssetCard(
                                asset: assets,
                            onTap: () => SportsFunction().openAssetDetails(assets, context),
                              )),

                      // const SizedBox(height: 12),
                      // if (sport['mpid'] != null && sport['mpid'].toString().isNotEmpty)
                      //   SectionHeader(
                      //   title: name,
                      //   titleRed: AppLocalizations.of(context)!.latest_videos,
                      //   moreLabel: AppLocalizations.of(context)!.see_more,
                      //   onMore: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (_) => VideosListing(
                      //           languageCode: languageCode,
                      //           mpids: sport['mpid'],
                      //           title: sport['name'],
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                      // if (sport['mpid'] != null && sport['mpid'].toString().isNotEmpty)
                      //   Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 0),
                      //   child: VideosGridTwoColumns(
                      //     title: sport['name'],
                      //     mpids: sport['mpid'],
                      //     languageCode: languageCode,
                      //     shrinkWrap: true,
                      //     showMore: true,
                      //   ),
                      // ),
                      // const SizedBox(height: 16),
                      // if (sport['lpid'] != null && sport['lpid'].toString().isNotEmpty)
                      //   SectionHeader(
                      //   title: name,
                      //   moreLabel: AppLocalizations.of(context)!.see_more,
                      //   titleRed: AppLocalizations.of(context)!.news,
                      //   onMore: () {
                      //     Navigator.of(context).push(
                      //       MaterialPageRoute(
                      //         builder: (_) => ArticlesListing(
                      //           sport: sport,
                      //           languageCode: languageCode,
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                      // if (sport['lpid'] != null && sport['lpid'].toString().isNotEmpty)
                      //   Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 0),
                      //   child: ArticlesGridTwoColumns(
                      //     sport: sport,
                      //     languageCode: languageCode,
                      //     shrinkWrap: true,
                      //     showMore: true,
                      //   ),
                      // ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              )),
        ),
      ],
    );
  }
}
