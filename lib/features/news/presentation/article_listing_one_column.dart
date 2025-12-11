import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../data/article_item.dart';
import '../data/article_service.dart';
import 'article_card.dart';
import 'article_detail_screen.dart';

class ArticlesListOneColumn extends StatefulWidget {
  final Map<String, dynamic> sport; // nodul din config
  final String languageCode;

  const ArticlesListOneColumn({
    super.key,
    required this.sport,
    required this.languageCode,
  });

  @override
  State<ArticlesListOneColumn> createState() => _ArticlesListOneColumnState();
}

class _ArticlesListOneColumnState extends State<ArticlesListOneColumn> {
  final ArticleService _service = const ArticleService();
  final List<ArticleItem> _articles = [];

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _hasMore = true;

  int _offset = 0;
  final int _limit = 5;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
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

    if (_articles.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No news for this sport.'),
        ),
      );
    }

    // 👇 Acum widgetul este direct un ListView scroll-abil
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _articles.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index < _articles.length) {
          final article = _articles[index];
          return ArticleCard(
            article: article,
            compact: false,
            onTap: () => _openDetails(article),
            pictureRatio: 16/9,
          );
        }

        // Ultimul item = butonul "Load more"
        return Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redSports,
                foregroundColor: Colors.white,
              ),
              onPressed: _loadingMore ? null : () => _load(reset: false),
              child: _loadingMore
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text('Load more'),
            ),
          ),
        );
      },
    );
  }
}