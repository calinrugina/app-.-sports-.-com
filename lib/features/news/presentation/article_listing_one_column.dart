import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/app_config.dart';
import '../../../core/app_functions.dart';
import '../../../core/theme/colors.dart';
import '../../asset/data/media_platform_client.dart';
import '../../asset/models/asset.dart';
import '../../asset/presentation/asset_card.dart';
import '../data/article_item.dart';
import '../data/article_service.dart';
import 'article_card.dart';
import 'article_detail_screen.dart';

class ArticlesListOneColumn extends StatefulWidget {
  final Map<String, dynamic> sport; // nodul din config
  final String languageCode;
  final String? q;
  const ArticlesListOneColumn({
    super.key,
    required this.sport,
    required this.languageCode,
    this.q,
  });

  @override
  State<ArticlesListOneColumn> createState() => _ArticlesListOneColumnState();
}

class _ArticlesListOneColumnState extends State<ArticlesListOneColumn> {

  final client = MediaPlatformClient(
    baseUrl: 'https://platforms.alpha.sports.com/api',
    apiKey: 'demo_api_key_a__',
  );
  final List<Asset> _newArticles = [];


  // final ArticleService _service = const ArticleService();
  // final List<ArticleItem> _articles = [];

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  int _offset = 0;
  final int _limit = 5;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ArticlesListOneColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sport['id'] != widget.sport['id'] ||
        oldWidget.languageCode != widget.languageCode) {
      _load(reset: true);
    }
  }

  Future<void> _load({bool reset = false}) async {

    if (reset) {
      setState(() {
        _initialLoading = true;
        _loadingMore = false;
        _hasMore = true;
        _offset = 0;
        _newArticles.clear();
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    final newList = await client.fetchAssets(
        FetchAssetsParams(
          source: ContentSource.latest,
          contentType: ContentType.article,
          filters: AssetFilters(categories: ['${widget.sport}']),
          query: widget.q,
          perPage: _limit,
          page: _offset,
        )
    );



    if (!mounted) return;

    setState(() {
      _newArticles.addAll(newList.assets);
      _offset += newList.assets.length;
      if (newList.assets.length < _limit) _hasMore = false;
      _initialLoading = false;
      _loadingMore = false;
    });
  }

  void _openDetails(ArticleItem article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(
          article: article,
          lang: widget.languageCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_newArticles.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(AppLocalizations.of(context)!.no_news_for_this_sport),
        ),
      );
    }

    // 👇 Acum widgetul este direct un ListView scroll-abil
    return Scrollbar(
        controller: _scrollController,
        thickness: 4.0, // Lățime ușor crescută
        radius: const Radius.circular(10),
        child: Padding(
            padding: const EdgeInsets.symmetric( horizontal: AppConfig.appPadding),
            child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: _newArticles.length + (_hasMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index < _newArticles.length) {
              final article = _newArticles[index];
              return AssetCard(
                asset: article,
                compact: false,
                // onTap: () => _openDetails(as),
                pictureRatio: 16 / 9,
              );
            }

            // Ultimul item = butonul "Load more"
            return _loadingMore
                ? SportsFunction().customLoading()
                : Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redSports,
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                  _loadingMore ? null : () => _load(reset: false),
                  child: Text(
                    AppLocalizations.of(context)!.load_more,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        )),);
  }
}
