import 'package:flutter/material.dart';

import '../core/network/app_image_cache.dart';
import '../core/theme/colors.dart';
import '../core/widgets/section_header.dart';
import '../features/asset/models/asset.dart';
import '../l10n/app_localizations.dart';

/// Builds a section layout from [layoutType]: title + list/grid of assets.
class BlockLayoutBuilder extends StatelessWidget {
  const BlockLayoutBuilder({
    super.key,
    required this.layoutType,
    required this.title,
    required this.assets,
    this.assetBuilder,
    this.redTitle,
  });

  final int layoutType;
  final String title;
  final String? redTitle;

  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset)? assetBuilder;

  @override
  Widget build(BuildContext context) {
    final effectiveBuilder =
        assetBuilder ?? (context, asset) => DefaultAssetTile(asset: asset);

    switch (layoutType) {
      case 1:
        return _HighlightsCarouselLayout(
          title: title,
          redTitle: redTitle,
          assets: assets,
          assetBuilder: effectiveBuilder,
        );
      case 2:
        return _TwoColumnLayout(
          title: title,
          redTitle: redTitle,
          assets: assets,
          assetBuilder: effectiveBuilder,
        );
      case 3:
        return _ListWithGrayBackgroundLayout(
          title: title,
          redTitle: redTitle,
          assets: assets,
          assetBuilder: effectiveBuilder,
        );
      case 4:
        return _FullWidthLayout(
          title: title,
          redTitle: redTitle,
          assets: assets,
          assetBuilder: effectiveBuilder,
        );
      case 5:
        return _ListWithWhiteBackgroundLayout(
          title: title,
          redTitle: redTitle,
          assets: assets,
          assetBuilder: effectiveBuilder,
        );
      case 6:
        // 2x2 grid carousel: horizontal scroll, each page = 4 cards (2 rows x 2 cols), chevrons
        return _TwoByTwoCarouselLayout(
          title: title,
          redTitle: redTitle,
          assets: assets,
          assetBuilder: effectiveBuilder,
        );
      default:
        return _DefaultListLayout(
          title: title,
          redTitle: redTitle,
          assets: assets,
          assetBuilder: effectiveBuilder,
        );
    }
  }
}

class _DefaultListLayout extends StatelessWidget {
  const _DefaultListLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder,
    this.redTitle,
  });

  final String title;
  final String? redTitle;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          SectionHeader(title: title, moreLabel: '',
            titleRed: redTitle!,),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => assetBuilder(context, assets[i]),
        ),
      ],
    );
  }
}

/// layout_type 1: : highlights carousel – header (title with first word in red + "See more"), horizontal cards, page dots.
class _HighlightsCarouselLayout extends StatefulWidget {
  const _HighlightsCarouselLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder,
    this.seeMoreText,
    this.onSeeMore, this.redTitle,
  });

  final String title;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;
  final String? seeMoreText;
  final String? redTitle;
  final VoidCallback? onSeeMore;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title.isNotEmpty)
          SectionHeader(
            title: widget.title,
            titleRed: widget.redTitle!,
            moreLabel: AppLocalizations.of(context)!.see_more,
              onMore:null
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
            itemBuilder: (context, i) => SizedBox(
              width: 280,
              child: InkWell(
                onTap: () {},
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.assets[i].thumb != null &&
                        widget.assets[i].thumb!.isNotEmpty)
                      AppNetworkImage(
                        url: widget.assets[i].thumb!,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.assets[i].title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
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
                  color: i == _currentIndex ? dotActiveColor : dotInactiveColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
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
    required this.assetBuilder, this.redTitle,
  });

  final String title;
  final String? redTitle;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          SectionHeader(
              title: title,
              titleRed: redTitle!,
              moreLabel: AppLocalizations.of(context)!.see_more,
              onMore:null
          ),
        Padding(
          padding: const EdgeInsets.all(0),
          child: GridView.builder(
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
        ),
      ],
    );
  }
}

class _FullWidthLayout extends StatelessWidget {
  const _FullWidthLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder, this.redTitle,
  });

  final String title;
  final String? redTitle;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          SectionHeader(title: title, moreLabel: '', titleRed: redTitle!,),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => assetBuilder(context, assets[i]),
        ),
      ],
    );
  }
}

/// layout_type 3: list with gray background.
class _ListWithGrayBackgroundLayout extends StatelessWidget {
  const _ListWithGrayBackgroundLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder, this.redTitle,
  });

  final String title;
  final String? redTitle;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          SectionHeader(title: title, moreLabel: '', titleRed: redTitle!,),
        Container(
          color: Colors.green,
          padding: const EdgeInsets.all(0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => assetBuilder(context, assets[i]),
          ),
        ),
      ],
    );
  }
}

/// layout_type 5: list with gray background.
class _ListWithWhiteBackgroundLayout extends StatelessWidget {
  const _ListWithWhiteBackgroundLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder, this.redTitle,
  });

  final String title;
  final String? redTitle;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title.isNotEmpty)
          SectionHeader(title: title, moreLabel: '', titleRed: redTitle!,),
        Container(
          color: Colors.red,
          padding: const EdgeInsets.all(0),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => assetBuilder(context, assets[i]),
          ),
        ),
      ],
    );
  }
}

/// layout_type 6: 2x2 grid carousel – header (first word red), horizontal scroll of pages (each page = 4 cards in 2x2), chevrons.
class _TwoByTwoCarouselLayout extends StatefulWidget {
  const _TwoByTwoCarouselLayout({
    required this.title,
    required this.assets,
    required this.assetBuilder, String? redTitle,
  });

  final String title;
  final List<Asset> assets;
  final Widget Function(BuildContext context, Asset asset) assetBuilder;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header: first word red, rest white/black
        if (widget.title.isNotEmpty)
          SectionHeader(title: widget.title, moreLabel: ''),
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: pageAssets.length,
                  itemBuilder: (context, i) =>
                      widget.assetBuilder(context, pageAssets[i]),
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
                icon: Icon(Icons.chevron_left, color: AppColors.redSports, size: 32),
                onPressed: _currentPage > 0
                    ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut)
                    : null,
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: AppColors.redSports, size: 32),
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
      ],
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
