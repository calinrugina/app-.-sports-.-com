import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../data/article_item.dart';
import '../data/article_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final ArticleItem article;
  final String languageCode;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.languageCode,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ArticleService _service = const ArticleService();
  String? _htmlContent;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final html =
        await _service.fetchFullArticleHtml(widget.article.id, widget.languageCode);
    if (!mounted) return;
    setState(() {
      _htmlContent = html ?? '<p>Failed to load article.</p>';
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.title),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Html(data: _htmlContent),
            ),
    );
  }
}
