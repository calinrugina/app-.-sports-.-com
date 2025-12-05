import 'package:flutter/material.dart';
import '../data/article_item.dart';
import '../data/article_service.dart';
import '../../../core/network/media_headers.dart';
import 'article_detail_screen.dart';

class ArticleListingPageForSport extends StatefulWidget {
  final Map<String, dynamic> sport;
  final String languageCode;

  const ArticleListingPageForSport({
    super.key,
    required this.sport,
    required this.languageCode,
  });

  @override
  State<ArticleListingPageForSport> createState() =>
      _ArticleListingPageForSportState();
}

class _ArticleListingPageForSportState
    extends State<ArticleListingPageForSport> {
  final ArticleService _service = const ArticleService();
  final List<ArticleItem> _articles = [];
  bool _loading = false;
  bool _endReached = false;
  int _offset = 0;
  static const int _limit = 5;

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || _endReached) return;
    setState(() {
      _loading = true;
    });

    final newItems = await _service.fetchArticles(
      widget.sport,
      _offset,
      widget.languageCode,
      limit: _limit,
    );

    if (!mounted) return;

    setState(() {
      _articles.addAll(newItems);
      _offset += 6; // conform cerinței
      if (newItems.length < _limit) {
        _endReached = true;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.sport['name']?.toString() ?? 'Sport';

    return Scaffold(
      appBar: AppBar(
        title: Text('Listing Articles ($name)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _articles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final a = _articles[index];
                return ListTile(
                  leading: a.mediaUrl != null
                      ? SizedBox(
                          width: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                a.mediaUrl!,
                                fit: BoxFit.cover,
                                headers: mediaHeaders,
                              ),
                            ),
                          ),
                        )
                      : const Icon(Icons.article),
                  title: Text(
                    a.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    a.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailScreen(
                          article: a,
                          languageCode: widget.languageCode,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (!_loading && !_endReached)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _loadMore,
                child: const Text('Load more'),
              ),
            ),
          if (_endReached)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No more articles'),
            ),
        ],
      ),
    );
  }
}
