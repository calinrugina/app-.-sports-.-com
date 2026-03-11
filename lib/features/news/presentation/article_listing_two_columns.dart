import 'package:sports_config_app/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/app_functions.dart';
import '../../../core/theme/colors.dart';
import '../data/article_item.dart';
import '../data/article_service.dart';
import 'article_card.dart';
import 'article_detail_screen.dart';
class ArticlesGridTwoColumns extends StatefulWidget {
  final Map<String, dynamic> sport;
  final String languageCode;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool showMore;

  const ArticlesGridTwoColumns({
    super.key,
    required this.sport,
    required this.languageCode,
    this.shrinkWrap = false,
    this.physics,
    this.showMore = false,

  });

  @override
  State<ArticlesGridTwoColumns> createState() =>
      _ArticlesGridTwoColumnsState();
}

class _ArticlesGridTwoColumnsState extends State<ArticlesGridTwoColumns> {
  final ArticleService _service = const ArticleService();
  final List<ArticleItem> _articles = [];

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  int _offset = 0;
  final int _limit = 6;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant ArticlesGridTwoColumns oldWidget) {
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
        _articles.clear();
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    final list = await _service.fetchArticles(
      widget.sport,
      _offset,
      widget.languageCode,
      limit: _limit,
    );

    if (!mounted) return;

    setState(() {
      _articles.addAll(list);
      _offset += list.length;
      if (list.length < _limit) _hasMore = false;
      _initialLoading = false;
      _loadingMore = false;
    });
  }

  void _openDetails(ArticleItem article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(article: article, lang: '',),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_articles.isEmpty) {
      return  Padding(
        padding: EdgeInsets.all(24),
        child: Text(AppLocalizations.of(context)!.no_news_for_this_sport),
      );
    }

    final scale = SportsFunction().scale(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        GridView.builder(
          // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics ?? const NeverScrollableScrollPhysics(),
          itemCount: _articles.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.87 * scale,
          ),
          itemBuilder: (context, index) {
            final article = _articles[index];
            return ArticleCard(
              pictureRatio: 16/9* (screenWidth>800?2:1),
              article: article,
              compact: true,
              onTap: () => _openDetails(article),
            );
          },
        ),
        if (widget.showMore && _hasMore)
          _loadingMore
              ? SportsFunction().customLoading()
              : Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redSports,
                foregroundColor: Colors.white,
              ),
              onPressed: _loadingMore ? null : () => _load(reset: false),
              child: Text('Load more'.toUpperCase(), style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Colors.white, fontSize: 14),),
            ),
          ),
      ],
    );
  }
}