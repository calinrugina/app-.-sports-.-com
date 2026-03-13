import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../providers/selected_sport_provider.dart';
import '../../home/presentation/widgets/top_sports.dart';

class SportScreen extends ConsumerStatefulWidget {
  final List<dynamic> sports;
  final String languageCode;
  final int? initialIndex;

  const SportScreen({
    super.key,
    required this.sports,
    required this.languageCode,
    this.initialIndex,
  });

  @override
  ConsumerState<SportScreen> createState() => _SportScreenState();
}

class _SportScreenState extends ConsumerState<SportScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _initialIndexSynced = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null && widget.sports.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final index = widget.initialIndex!.clamp(0, widget.sports.length - 1);
        ref.read(selectedSportIndexProvider.notifier).state = index;
        setState(() => _initialIndexSynced = true);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final sports = widget.sports;
    final languageCode = widget.languageCode;

    if (sports.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)!.no_sports_configured));
    }

    // Use initialIndex for first frame so correct sport shows before provider is synced
    final selectedIndex = (widget.initialIndex != null && !_initialIndexSynced)
        ? widget.initialIndex!.clamp(0, sports.length - 1)
        : ref.watch(selectedSportIndexProvider);
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
                                onTap: () => SportsFunction()
                                    .openAssetDetails(assets, context),
                              )
                      ),
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
