import 'package:flutter/material.dart';
import '../data/article_item.dart';
import '../data/article_service.dart';
import 'article_detail_screen.dart';
import '../../../core/network/media_headers.dart';

class ArticleListForSport extends StatefulWidget {
  final Map<String, dynamic> sport;
  final String languageCode;

  const ArticleListForSport({
    super.key,
    required this.sport,
    required this.languageCode,
  });

  @override
  State<ArticleListForSport> createState() => _ArticleListForSportState();
}

class _ArticleListForSportState extends State<ArticleListForSport> {
  final ArticleService _service = const ArticleService();
  List<ArticleItem> _articles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list =
        await _service.fetchArticles(widget.sport, 0, widget.languageCode);
    if (!mounted) return;
    setState(() {
      _articles = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_articles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No articles for this sport.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _articles.length,
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
    );
  }
}
