import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sports_config_app/core/app_config.dart';
import '../../../core/app_functions.dart';
import '../../../core/network/app_image_cache.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/theme/colors.dart';
import '../../asset/presentation/asset_card.dart';
import '../../config/models/config_models.dart';
import '../../../widgets/block_assets_section.dart';

class StudioScreen extends StatefulWidget {
  final List<Block> blocks;
  final String languageCode;

  const StudioScreen({
    super.key,
    required this.blocks,
    required this.languageCode,
  });

  @override
  State<StudioScreen> createState() => _StudioScreenState();
}

class _StudioScreenState extends State<StudioScreen> {
  int _selectedIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocks = widget.blocks.where((b) => b.enabled).toList();

    if (blocks.isEmpty) {
      return Center(
        child: Text(AppLocalizations.of(context)!.no_sports_studios_configured),
      );
    }

    final selectedIndex = _selectedIndex.clamp(0, blocks.length - 1);
    final selectedBlock = blocks[selectedIndex];

    const itemWidth = 120.0;
    const separatorWidth = 1.0;
    final totalContentWidth =
        blocks.length * itemWidth + (blocks.length - 1) * separatorWidth;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = totalContentWidth < screenWidth
        ? (screenWidth - totalContentWidth) / 2
        : 0.0;

    return Column(
      children: [
        // Carousel with studio logos (PNG from block.logo)
        Container(
          color: AppColors.darkTabs,
          child: SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: blocks.length,
              separatorBuilder: (_, __) => Container(
                color: Colors.black,
                child: const SizedBox(width: 1),
              ),
              itemBuilder: (context, index) {
                final block = blocks[index];
                final isSelected = index == selectedIndex;
                final logoUrl = block.logo;

                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(
                    width: itemWidth,
                    decoration: BoxDecoration(
                      color: AppColors.darkTabs,
                      border: isSelected
                          ? const Border(
                              bottom: BorderSide(color: AppColors.redSports, width: 3),
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (logoUrl != null && logoUrl.isNotEmpty)
                          SizedBox(
                            height: 40,
                            width: 60,
                            child: AppNetworkImage(
                              url: logoUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                       /*
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            block.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        */
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
          child: Scrollbar(
            controller: _scrollController,
            thickness: 4.0,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConfig.zeroPadding),
                child: BlockAssetsList(
                  key: ValueKey(selectedBlock.key),
                  blocks: [selectedBlock],
                  client: mediaPlatformClient,
                  lang: widget.languageCode,
                  redTitle: selectedBlock.title,
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
    );
  }
}
