import 'package:flutter/material.dart';
import '../../media/presentation/article_item_in_listing.dart';
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16, // Spațiu vertical (între rânduri)
          crossAxisSpacing: 12, // Spațiu orizontal (între coloane)
          // CALCUL childAspectRatio:
          // Un thumbnail 16:9 + 4 linii de text + spațiere necesită un raport
          // mai mic de 1.77. Alegem 16/17 (~0.94) pentru a ne asigura că textul de 3 linii încape.
          childAspectRatio: 16 / 17,
        ),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          final a = _articles[index];

          // Folosim noul widget ArticleGridItem
          return ArticleGridItem(
            article: a,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ArticleDetailScreen(
                    article: a,
                    lang: widget.languageCode,
                  ),
                ),
              );
            },
            headers: mediaHeaders,
          );
        },
      ),
    );
  }
}
