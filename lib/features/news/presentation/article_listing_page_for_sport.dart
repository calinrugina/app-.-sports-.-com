import 'package:flutter/material.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../media/presentation/article_item_in_listing.dart';
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
  static const int _limit = 8;

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
    return Scaffold(
      appBar: const SportsAppBar(),

      body: Column(
        children: [
          BackHeader(title: 'Listing Articles (${widget.sport['name']})'),
          Expanded(child: Column(
            children: [
              Expanded(child: Padding(
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
              ))
            ],
          ),),
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
