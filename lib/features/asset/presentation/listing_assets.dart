import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports_config_app/features/asset/presentation/asset_card.dart';

import '../../../core/app_functions.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/block_layouts.dart';
import '../../config/models/config_models.dart';
import '../data/media_platform_client.dart';
import '../models/asset.dart';

/// Minimal block for search listing (source: search).
Block createSearchBlock(String query, {String contentType = 'video'}) {
  return Block(
    id: 0,
    sportId: 0,
    key: 'search',
    title: query,
    layoutType: 2,
    contentType: contentType,
    source: 'search',
    filters: const BlockFilters(),
    limit: 20,
    enabled: true,
    sortOrder: 0,
    cacheTtl: 0,
  );
}

class AssetsListingPage extends StatefulWidget {
  const AssetsListingPage({
    super.key,
    required this.client,
    required this.block,
    this.title,
    this.perPage = 20,
    this.lang,
    this.country,
    this.assetBuilder,
    /// When set, uses [ContentSource.search] and this query; [block.source] should be 'search'.
    this.searchQuery,
    /// When true with [searchQuery], fetches both video and article results and merges them.
    this.searchBothTypes = false,
  });

  final MediaPlatformClient client;
  final Block block;
  /// Override the app bar title (defaults to [Block.title]).
  final String? title;
  /// Assets per page (default 20).
  final int perPage;
  final String? lang;
  final String? country;
  /// Custom tile for each asset. If null, [DefaultAssetTile] is used.
  final Widget Function(BuildContext context, Asset asset)? assetBuilder;
  /// Search query (use with block.source == 'search').
  final String? searchQuery;
  /// Search in both video and article; results are merged and sorted by date.
  final bool searchBothTypes;

  @override
  State<AssetsListingPage> createState() => _AssetsListingPageState();
}

class _AssetsListingPageState extends State<AssetsListingPage> {
  final List<Asset> _assets = [];
  bool _hasMore = true;
  int _page = 0;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  static const double _backToTopThreshold = 400;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPage(1);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final show = _scrollController.offset > _backToTopThreshold;
      if (show != _showBackToTop && mounted) {
        setState(() => _showBackToTop = show);
      }
    }
    if (!_hasMore || _loadingMore || _error != null) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadPage(_page + 1);
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

  Future<void> _loadPage(int page) async {
    if (page == 1) {
      setState(() {
        _loading = true;
        _error = null;
        _assets.clear();
        _page = 0;
        _hasMore = true;
      });
    } else {
      if (!_hasMore || _loadingMore) return;
      setState(() => _loadingMore = true);
    }

    try {
      final useSearch = widget.searchQuery != null && widget.searchQuery!.trim().isNotEmpty;
      final fetchBoth = useSearch && widget.searchBothTypes;

      if (fetchBoth) {
        final filters = AssetFilters(
          categories: widget.block.filters.categories,
          tags: widget.block.filters.tags,
          period: widget.block.filters.period,
          excludeCategories: widget.block.filters.excludeCategories,
          excludeTags: widget.block.filters.excludeTags,
          excludeIds: widget.block.filters.excludeIds,
        );
        final q = widget.searchQuery!.trim();
        final resVideo = widget.client.fetchAssets(FetchAssetsParams(
          source: ContentSource.search,
          contentType: ContentType.video,
          filters: filters,
          perPage: widget.perPage,
          page: page,
          query: q,
          lang: widget.lang,
          country: widget.country,
        ));
        final resArticle = widget.client.fetchAssets(FetchAssetsParams(
          source: ContentSource.search,
          contentType: ContentType.article,
          filters: filters,
          perPage: widget.perPage,
          page: page,
          query: q,
          lang: widget.lang,
          country: widget.country,
        ));
        final results = await Future.wait([resVideo, resArticle]);
        final res1 = results[0];
        final res2 = results[1];
        final merged = <Asset>[...res1.assets, ...res2.assets];
        final seenIds = <int>{};
        merged.removeWhere((a) => !seenIds.add(a.id));
        merged.sort((a, b) {
          final da = a.publishedAt ?? '';
          final db = b.publishedAt ?? '';
          return db.compareTo(da);
        });
        if (!mounted) return;
        setState(() {
          if (page == 1) {
            _assets.clear();
            _loading = false;
          } else {
            _loadingMore = false;
          }
          _assets.addAll(merged);
          _hasMore = res1.hasMore || res2.hasMore;
          _page = page;
        });
      } else {
        final source = useSearch
            ? ContentSource.search
            : (ContentSource.fromString(widget.block.source) ?? ContentSource.latest);
        final contentType = ContentType.fromString(widget.block.contentType) ?? ContentType.video;
        final filters = AssetFilters(
          categories: widget.block.filters.categories,
          tags: widget.block.filters.tags,
          period: widget.block.filters.period,
          excludeCategories: widget.block.filters.excludeCategories,
          excludeTags: widget.block.filters.excludeTags,
          excludeIds: widget.block.filters.excludeIds,
        );
        final res = await widget.client.fetchAssets(FetchAssetsParams(
          source: source,
          contentType: contentType,
          filters: filters,
          perPage: widget.perPage,
          page: page,
          query: useSearch ? widget.searchQuery!.trim() : null,
          lang: widget.lang,
          country: widget.country,
        ));

        if (!mounted) return;
        setState(() {
          if (page == 1) {
            _assets.clear();
            _loading = false;
          } else {
            _loadingMore = false;
          }
          _assets.addAll(res.assets);
          _hasMore = res.hasMore;
          _page = page;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? widget.block.title;

    if (_loading && _assets.isEmpty) {
      return const Scaffold(
        appBar: SportsAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null && _assets.isEmpty) {
      return Scaffold(
        appBar: const SportsAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error: $_error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => _loadPage(1),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    AssetCard effectiveBuilder(context, asset) => AssetCard(
      asset: asset,
      onTap: () => SportsFunction()
        .openAssetDetails(asset, context),);

    return Scaffold(
      appBar: const SportsAppBar(),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              heroTag: 'listing_back_to_top',
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BackHeader(title: title),
          Expanded(child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // BackHeader(title: AppLocalizations.of(context)!.listing_videos_title(title)),
              SliverToBoxAdapter(
                child: BlockLayoutBuilder(
                  layoutType: 2,
                  title: widget.block.title,
                  assets: _assets,
                  assetBuilder: effectiveBuilder,
                  hasMore: false
                ),
              ),
              if (_loadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              if (!_hasMore && _assets.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No more contents',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                ),
              if (_assets.isEmpty && !_loading)
                 SliverFillRemaining(
                  child: Center(
                      child: Text('No assets',style: Theme.of(context).textTheme.titleSmall,)
                  ),
                ),
            ],
          ))
        ],
        
      ),
    );
  }
}