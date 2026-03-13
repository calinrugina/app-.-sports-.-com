import 'package:flutter/material.dart';
import 'package:sports_config_app/features/asset/presentation/asset_card.dart';
import 'package:sports_config_app/features/home/presentation/home_screen.dart';

import '../core/app_config.dart';
import '../core/app_functions.dart';
import '../core/network/app_image_cache.dart';
import '../core/network/media_headers.dart';
import '../core/theme/colors.dart';
import '../core/widgets/section_header.dart';
import '../features/asset/data/media_platform_client.dart';
import '../features/asset/models/asset.dart';
import '../features/asset/presentation/listing_assets.dart';
import '../features/config/models/config_models.dart';
import '../l10n/app_localizations.dart';
import 'block_assets_section.dart';

/// Builds a section layout from [layoutType]: title + list/grid of assets.
class BlockLayoutBuilder extends StatelessWidget {
  const BlockLayoutBuilder({
    super.key,
    required this.layoutType,
    required this.title,
    required this.assets,
    this.assetBuilder,
    this.redTitle,
    this.block,
    this.hasMore,
  });

  final int layoutType;
  final String title;
  final String? redTitle;

  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset)? assetBuilder;
  final Block? block;
  final bool? hasMore;

  @override
  Widget build(BuildContext context) {
    final effectiveBuilder =
        assetBuilder ?? (context, asset) => AssetCard(asset: asset);

    switch (layoutType) {
      case 1:
        return _HighlightsCarouselLayout(
          title: title,
          redTitle: redTitle??'',
          assets: assets,
          assetBuilder: effectiveBuilder,
          block: block,
        );
      case 2:
        print('${title}');

        return _TwoColumnLayout(
          title: title,
          redTitle: redTitle??'',
          assets: assets,
          assetBuilder: effectiveBuilder,
          block: block,
          hasMore: hasMore,
        );
      case 3:
        return _ListWithGrayBackgroundLayout(
          title: title,
          redTitle: redTitle??'',
          assets: assets,
          assetBuilder: effectiveBuilder,
          block: block,
        );
      case 4:
        return _FullWidthLayout(
          title: title,
          redTitle: redTitle??'',
          assets: assets,
          assetBuilder: effectiveBuilder,
          block: block,
        );
      case 5:
        return _ListWithWhiteBackgroundLayout(
          title: title,
          redTitle: redTitle??'',
          assets: assets,
          assetBuilder: effectiveBuilder,
          block: block,
        );
      case 6:
        // 2x2 grid carousel: horizontal scroll, each page = 4 cards (2 rows x 2 cols), chevrons
        return _TwoByTwoCarouselLayout(
          title: title,
          redTitle: redTitle??'',
          assets: assets,
          assetBuilder: effectiveBuilder,
          block: block,
          hasMore: hasMore,
        );
      case 8:
      // More section: horizontal row of up to 4 cards (e.g. same category).
        return _MoreSectionLayout(
          title: title,
          assets: assets,
          assetBuilder: effectiveBuilder,
        );
      default:
        return _TwoColumnLayout(
          title: title,
          redTitle: redTitle??'',
          assets: assets,
          assetBuilder: effectiveBuilder,
        );
    }
  }
}

/// layout_type 1: : highlights carousel – header (title with first word in red + "See more"), horizontal cards, page dots.
class _HighlightsCarouselLayout extends StatefulWidget {
  const _HighlightsCarouselLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder,
    this.seeMoreText,
    this.onSeeMore,
    this.redTitle,
    this.block,
  });

  final String title;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;
  final String? seeMoreText;
  final String? redTitle;
  final VoidCallback? onSeeMore;
final Block? block;

  @override
  State<_HighlightsCarouselLayout> createState() =>
      _HighlightsCarouselLayoutState();
}

class _HighlightsCarouselLayoutState extends State<_HighlightsCarouselLayout> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

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
    if (!_scrollController.hasClients || widget.assets.isEmpty) return;
    final pos = _scrollController.offset;
    final cardWidth = 280.0 + 12; // card width + gap
    final i = (pos / cardWidth).round().clamp(0, widget.assets.length - 1);
    if (i != _currentIndex && mounted) setState(() => _currentIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final red = theme.colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotActiveColor = red;
    final dotInactiveColor =
        isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    // Split title: first word in red, rest in black
    final parts = widget.title.split(RegExp(r'\s+'));
    final firstWord = parts.isNotEmpty ? parts.first : '';
    final rest = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.title.isNotEmpty)
            SectionHeader(
              title: widget.title,
              titleRed: widget.redTitle??'',
              moreLabel: AppLocalizations.of(context)!.see_more,
              onMore: () {

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AssetsListingPage(
                      client: mediaPlatformClient,
                      block: widget.block!,
                      title:
                      widget.block!.title, // opțional; dacă lipsește se folosește block.title
                      assetBuilder: (context, asset) => AssetCard(
                        asset: asset,
                        // onTap: () => openAsset(asset),
                      ),
                    ),
                  ),
                );
              },
            ),
          // Horizontal list of cards
          SizedBox(
            height: 120,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 0),
              itemCount: widget.assets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) => AssetCard2Columns(
                asset: widget.assets[i],
                onTap: () => SportsFunction()
                    .openAssetDetails(widget.assets[i], context),
                showHighlights: widget.block?.showHighlights ?? false,
              ),
            ),
          ),
          // Page indicator dots
          if (widget.assets.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.assets.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        i == _currentIndex ? dotActiveColor : dotInactiveColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

/// Card for highlights carousel: thumbnail (left) with play overlay + title & description (right). Use as [assetBuilder] for layout_type 3.
class HighlightsCarouselCard extends StatelessWidget {
  const HighlightsCarouselCard({super.key, required this.asset, this.onTap});

  final Asset asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumb = asset.thumb;
    final hasDescription =
        asset.description != null && asset.description!.trim().isNotEmpty;

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: thumbnail + play overlay
            if (thumb != null && thumb.isNotEmpty) ...[
              SizedBox(
                width: 140,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      thumb,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, size: 32)),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow,
                          color: Colors.white, size: 36),
                    ),
                  ],
                ),
              ),
            ],
            // Right: title + description
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      asset.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (hasDescription) ...[
                      const SizedBox(height: 4),
                      Text(
                        asset.description!.trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.85)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// layout_type 2: 2 columns grid.
class _TwoColumnLayout extends StatelessWidget {
  const _TwoColumnLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder,
    this.redTitle,
    this.block,
    this.hasMore,
  });

  final String title;
  final String? redTitle;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;
  final Block? block;
  final bool? hasMore;

  @override
  Widget build(BuildContext context) {

    print('PULA: ${block!.showPublishedAt}');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            SectionHeader(
                title: title??'',
                titleRed: redTitle??'',
                moreLabel: hasMore==false?'':AppLocalizations.of(context)!.see_more,
              onMore: hasMore==false ? null: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AssetsListingPage(
                      client: mediaPlatformClient,
                      block: block!,
                      title:
                      block!.title, // opțional; dacă lipsește se folosește block.title
                      assetBuilder: (context, asset) => AssetCard(
                        asset: asset,

                      ),
                    ),
                  ),
                );
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (_) => BlockAssetsSection(
                //       block: null,
                //       client: mediaPlatformClient,),
                //   ),
                // );
              },
                ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: assets.length,
            itemBuilder: (context, i) => assetBuilder(context, assets[i]),
          ),
        ],
      ),
    );
  }
}

class _FullWidthLayout extends StatelessWidget {
  const _FullWidthLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder,
    this.redTitle,
    this.block,
  });

  final String title;
  final String? redTitle;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;
  final Block? block;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            SectionHeader(
              title: title,
              titleRed: redTitle!,
              moreLabel: AppLocalizations.of(context)!.see_more,
              onMore: () {

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AssetsListingPage(
                      client: mediaPlatformClient,
                      block: block!,
                      title:
                      block!.title, // opțional; dacă lipsește se folosește block.title
                      assetBuilder: (context, asset) => AssetCard(
                        asset: asset,
                        // onTap: () => openAsset(asset),
                      ),
                    ),
                  ),
                );
              },
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => AssetCardFull(
              asset: assets[i],
              topLabel: 'Top news',
              topLabelIcon: '🔥',
              onTap: () =>
                  SportsFunction().openAssetDetails(assets[i], context),
            ),
            // assetBuilder(context, assets[i]),
          ),
        ],
      ),
    );
  }
}

/// layout_type 3: list with gray background.
class _ListWithGrayBackgroundLayout extends StatelessWidget {
  _ListWithGrayBackgroundLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder,
    this.redTitle,
    this.block,
  });

  final String title;
  final String? redTitle;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;
  final Block? block;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.type3BackgroundDark
          : AppColors.type3BackgroundLight,
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            SectionHeader(
              title: title,
              titleRed: redTitle!,
              moreLabel: AppLocalizations.of(context)!.see_more,
              onMore: () {

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AssetsListingPage(
                      client: mediaPlatformClient,
                      block: block!,
                      title:
                      block!.title, // opțional; dacă lipsește se folosește block.title
                      assetBuilder: (context, asset) => AssetCard(
                        asset: asset,
                        // onTap: () => openAsset(asset),
                      ),
                    ),
                  ),
                );
              },
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => assetBuilder(context, assets[i]),
          ),
        ],
      ),
    );
  }
}

/// layout_type 5: list with gray background.
class _ListWithWhiteBackgroundLayout extends StatelessWidget {
  const _ListWithWhiteBackgroundLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder,
    this.redTitle,
    this.block,
  });

  final String title;
  final String? redTitle;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;
  final Block? block;
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title.isNotEmpty)
            SectionHeader(
              title: title,
              titleRed: redTitle!,
              moreLabel: AppLocalizations.of(context)!.see_more,
              onMore: () {

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AssetsListingPage(
                      client: mediaPlatformClient,
                      block: block!,
                      title:
                      block!.title, // opțional; dacă lipsește se folosește block.title
                      assetBuilder: (context, asset) => AssetCard(
                        asset: asset,
                        // onTap: () => openAsset(asset),
                      ),
                    ),
                  ),
                );
              },
            ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => assetBuilder(context, assets[i]),
          ),
        ],
      ),
    );
  }
}

/// layout_type 6: 2x2 grid carousel – header (first word red), horizontal scroll of pages (each page = 4 cards in 2x2), chevrons.
class _TwoByTwoCarouselLayout extends StatefulWidget {
  const _TwoByTwoCarouselLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder,
    this.redTitle,
    this.block,
    this.hasMore
  });

  final String title;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;
  final String? redTitle;
  final Block? block;
  final bool? hasMore;
  @override
  State<_TwoByTwoCarouselLayout> createState() =>
      _TwoByTwoCarouselLayoutState();
}

class _TwoByTwoCarouselLayoutState extends State<_TwoByTwoCarouselLayout> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const int _perPage = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int get _pageCount => (widget.assets.length / _perPage).ceil();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final parts = widget.title.split(RegExp(r'\s+'));
    final firstWord = parts.isNotEmpty ? parts.first : '';
    final rest = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    if (widget.assets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConfig.appPadding),
      color: AppColors.type6Background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: first word red, rest white/black
          if (widget.title.isNotEmpty)
            SectionHeader(
              title: widget.title,
              titleRed: widget.redTitle??'',
              forceWhite: true,
              moreLabel: widget.hasMore==false?null:AppLocalizations.of(context)!.see_more,
              onMore: () {

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AssetsListingPage(
                      client: mediaPlatformClient,
                      block: widget.block!,
                      title:
                      widget.block!.title, // opțional; dacă lipsește se folosește block.title
                      assetBuilder: (context, asset) => AssetCard(
                        asset: asset,
                        // onTap: () => openAsset(asset),
                      ),
                    ),
                  ),
                );
              },
            ),
          // Horizontal PageView: each page = 2x2 grid
          SizedBox(
            height: 420,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pageCount,
              itemBuilder: (context, pageIndex) {
                final start = pageIndex * _perPage;
                final pageAssets =
                    widget.assets.skip(start).take(_perPage).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: pageAssets.length,
                      itemBuilder: (context, i) =>
                          AssetCardDark(asset: pageAssets[i], onTap: () => SportsFunction()
                              .openAssetDetails(widget.assets[i], context),)
                      //    widget.assetBuilder(context, pageAssets[i]),

                      ),
                );
              },
            ),
          ),
          // Chevrons
          if (_pageCount > 1) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left,
                      color: AppColors.redSports, size: 32),
                  onPressed: _currentPage > 0
                      ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut)
                      : null,
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right,
                      color: AppColors.redSports, size: 32),
                  onPressed: _currentPage < _pageCount - 1
                      ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          SizedBox(height: AppConfig.appPadding,)
        ],
      ),
    );
  }
}

/// Default tile: thumb + title (and optional description).
class DefaultAssetTile extends StatelessWidget {
  const DefaultAssetTile({super.key, required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final thumb = asset.thumb;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (thumb != null && thumb.isNotEmpty)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox.expand(child: Icon(Icons.broken_image))),
              ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                asset.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _MoreSectionLayout extends StatelessWidget {
  const _MoreSectionLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder,
  });

  final String title;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) return const SizedBox.shrink();
    final list = assets.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          SectionHeader(
            title: title,
            moreLabel: AppLocalizations.of(context)!.see_more,
            // onMore: () {

            //   Navigator.of(context).push(
            //     MaterialPageRoute(
            //       builder: (_) => AssetsListingPage(
            //         client: mediaPlatformClient,
            //         block: widget.block!,
            //         title:
            //         widget.block!.title, // opțional; dacă lipsește se folosește block.title
            //         assetBuilder: (context, asset) => AssetCard(
            //           asset: asset,
            //           // onTap: () => openAsset(asset),
            //         ),
            //       ),
            //     ),
            //   );
            // },
          ),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => SizedBox(
              width: 200,
              child: assetBuilder(context, list[i]),
            ),
          ),
        ),
        SizedBox(height: 100,)
      ],
    );
  }
}