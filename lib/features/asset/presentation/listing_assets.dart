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
    if (!_hasMore || _loadingMore || _error != null) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      _loadPage(_page + 1);
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
      final source = ContentSource.fromString(widget.block.source) ?? ContentSource.latest;
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
        lang: widget.lang,
        country: widget.country,
      ));

      print(
        {
          "source": source,
          "contentType": contentType,
          "filters": filters.toJson(),
          "perPage": widget.perPage,
          "page": page,
          "lang": widget.lang,
          "country": widget.country,
        }
      );
      print('Lungime: ${res.assets.length}');

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
      return Scaffold(
        appBar: const SportsAppBar(),
        body: const Center(child: CircularProgressIndicator()),
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