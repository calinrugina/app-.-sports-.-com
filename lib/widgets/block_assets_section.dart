import 'package:flutter/material.dart';


import '../core/widgets/section_header.dart';
import '../features/asset/data/api_response.dart';
import '../features/asset/data/media_platform_client.dart';
import '../features/asset/models/asset.dart';
import '../features/config/models/config_models.dart';
import 'block_layouts.dart';

/// Fetches assets for one [Block] and displays them with the layout given by [layoutType].
class BlockAssetsSection extends StatefulWidget {
  const BlockAssetsSection({
    super.key,
    required this.block,
    required this.client,
    this.lang,
    this.country,
    this.assetBuilder,
    this.redTitle,
  });

  final Block block;
  final MediaPlatformClient client;
  final String? lang;
  final String? country;
  final String? redTitle;
  /// Custom tile for each asset. If null, [DefaultAssetTile] is used.
  final Widget Function(BuildContext context, Asset asset)? assetBuilder;

  @override
  State<BlockAssetsSection> createState() => _BlockAssetsSectionState();
}

class _BlockAssetsSectionState extends State<BlockAssetsSection> {
  AssetsResponse? _response;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(BlockAssetsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block.id != widget.block.id ||
        oldWidget.block.limit != widget.block.limit ||
        oldWidget.block.source != widget.block.source ||
        oldWidget.block.contentType != widget.block.contentType) {
      _load();
    }
  }

  Future<void> _load() async {
    if (!widget.block.enabled) {
      setState(() {
        _loading = false;
        _response = AssetsResponse(assets: [], hasMore: false);
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final source = ContentSource.fromString(widget.block.source) ?? ContentSource.latest;
      final contentType = ContentType.fromString(widget.block.contentType) ?? ContentType.video;
      final filters = AssetFilters(
        categories: widget.block.filters.categories,
        tags: widget.block.filters.tags,
        excludeCategories: widget.block.filters.excludeCategories,
        excludeTags: widget.block.filters.excludeTags,
        excludeIds: widget.block.filters.excludeIds,
      );
      final res = await widget.client.fetchAssets(FetchAssetsParams(
        source: source,
        contentType: contentType,
        filters: filters,
        perPage: widget.block.limit,
        page: 1,
        lang: widget.lang,
        country: widget.country,
        sectionName: widget.block.title,
      ));



      if (mounted) {
        setState(() {
          _response = res;
          _loading = false;
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.block.enabled) return const SizedBox.shrink();


    if (_loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.block.title.isNotEmpty)
            SectionHeader(title: widget.block.title, moreLabel: ''),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.block.title.isNotEmpty)
            SectionHeader(title: widget.block.title, moreLabel: ''),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Error: $_error', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      );
    }

    final assets = _response?.assets ?? [];
    if (assets.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.block.title.isNotEmpty)
            SectionHeader(title: widget.block.title, moreLabel: ''),
        ],
      );
    }

    final layout = BlockLayoutBuilder(
      layoutType: widget.block.layoutType,
      title: widget.block.title,
      redTitle: widget.redTitle,
      assets: assets,
      assetBuilder: widget.assetBuilder,
    );
    return layout;
  }
}

/// Renders a list of blocks, each as a [BlockAssetsSection].
class BlockAssetsList extends StatelessWidget {
  const BlockAssetsList({
    super.key,
    required this.blocks,
    required this.client,
    this.lang,
    this.country,
    this.assetBuilder,
    this.redTitle,
  });

  final List<Block> blocks;
  final MediaPlatformClient client;
  final String? lang;
  final String? country;
  final Widget Function(BuildContext context, Asset asset)? assetBuilder;
  final String? redTitle;

  @override
  Widget build(BuildContext context) {
    final enabled = blocks.where((b) => b.enabled).toList();
    if (enabled.isEmpty) return const SizedBox.shrink();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: enabled.length,
      itemBuilder: (context, i) {
        return BlockAssetsSection(
          block: enabled[i],
          client: client,
          lang: lang,
          country: country,
          redTitle: redTitle,
          assetBuilder: assetBuilder,
        );
      },
    );
  }
}
