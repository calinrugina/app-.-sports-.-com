import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sports_config_app/core/app_config.dart';
import 'package:sports_config_app/core/app_functions.dart';

import '../../../core/language/language_provider.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/theme/colors.dart';
import '../data/article_item.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final ArticleItem article;
  final String lang;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.lang,
  });

  @override
  ConsumerState<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  String _htmlContent = '';
  String? _publishDate;
  String? _category;
  String? _fullTitle;

  bool _showToTop = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchFullArticle();
  }

  void _onScroll() {
    final shouldShow = _scrollController.offset > 420;
    if (shouldShow != _showToTop) {
      setState(() => _showToTop = shouldShow);
    }
  }

  Future<void> _fetchFullArticle() async {
    const apiKey = '0b558c74198915cd8fad9cb8fbb5951a';
    const apiSecret = '3fa2a04361d0b808e4c5560fbffaf6b3';

    final id = widget.article.id;
    final lang = ref.read(languageProvider);

    final baseStr =
        'api_key=$apiKey&method=getNews&tbsec=$apiSecret&format=json&id=$id&sport_id=&limit=&offset=&lang=$lang';
    final hash = md5.convert(utf8.encode(baseStr)).toString();

    final url =
        'https://articles.ns-platforms.com/api.php'
        '?api_key=$apiKey&method=getNews&tbsec=$hash'
        '&format=json&id=$id&sport_id=&limit=&offset=&lang=$lang';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final newsItem = json['news']?['newsItem']?[0];

        if (newsItem != null) {
          final safeHtml = SportsFunction().sanitizeArticleHtml( (newsItem['description'] ?? '').toString());

          setState(() {
            _htmlContent = safeHtml;
            _fullTitle = newsItem['title']?.toString();
            _publishDate = newsItem['publishedDate']?.toString();
            _category = newsItem['sport']?['name']?.toString();
            _loading = false;
            _error = null;
          });
        } else {
          setState(() {
            _htmlContent = '<p>Article not found.</p>';
            _loading = false;
            _error = null;
          });
        }
      } else {
        setState(() {
          _htmlContent = '<p>Failed to load article (HTTP ${response.statusCode}).</p>';
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _htmlContent = '<p>Failed to load article.</p>';
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      final date = DateFormat('EEE dd/MM').format(dt);
      final time = DateFormat('h:mm a').format(dt);
      return '$date · $time';
    } catch (_) {
      return raw;
    }
  }

  Future<void> _scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final heroImage = widget.article.mediaUrl;
    final title = _fullTitle ?? widget.article.title;

    return Scaffold(
      // backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _showToTop ? 1 : 0,
        child: _showToTop
            ? FloatingActionButton.small(

          backgroundColor: AppColors.redSports,
          onPressed: _scrollToTop,
          child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
        )
            : const SizedBox.shrink(),
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(

          controller: _scrollController,
          slivers: [
            SliverAppBar(
              pinned: true,
              stretch: true,
              backgroundColor: Colors.black, //AppColors.darkTabs,
              expandedHeight: 280,
              collapsedHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              systemOverlayStyle: SystemUiOverlayStyle.light,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  // poți folosi asta dacă vrei să ajustezi overlay/gradient în funcție de cât e colapsat
                  final t = (constraints.maxHeight - (kToolbarHeight + MediaQuery.of(context).padding.top)) /
                      (280 - (kToolbarHeight + MediaQuery.of(context).padding.top));
                  final collapseFactor = t.clamp(0.0, 1.0);

                  return FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    titlePadding: const EdgeInsetsDirectional.only(start: AppConfig.bigSpace, bottom: AppConfig.bigSpace, end: AppConfig.bigSpace),
                    title: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (heroImage != null && heroImage.isNotEmpty)
                          Image.network(
                            heroImage,
                            fit: BoxFit.cover,
                            headers: mediaHeaders,
                            errorBuilder: (_, __, ___) => Container(color: Colors.black26),
                          )
                        else
                          Container(color: Colors.black26),

                        // gradient
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black87,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // titlul mare peste imagine (în expanded)
                        // Positioned(
                        //   left: 16,
                        //   right: 16,
                        //   bottom: 18,
                        //   child: Opacity(
                        //     opacity: collapseFactor,
                        //     child: Text(
                        //       title,
                        //       maxLines: 3,
                        //       overflow: TextOverflow.ellipsis,
                        //       style: textTheme.headlineSmall?.copyWith(
                        //         color: Colors.white,
                        //         fontWeight: FontWeight.w700,
                        //         height: 1.12,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  );
                },
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: _loading
                    ? const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // categorie + dată
                    if (_category != null || _publishDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            if (_category != null)
                              Flexible(
                                child: Text(
                                  _category!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: AppColors.redSports,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            if (_category != null && _publishDate != null)
                              Text(' · ', style: textTheme.labelSmall),
                            if (_publishDate != null)
                              Text(
                                _formatDate(_publishDate),
                                style: textTheme.labelSmall,
                              ),
                          ],
                        ),
                      ),

                    // titlu în body (sub hero)
                    Text(
                      title,
                      style: textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _error!,
                          style: textTheme.bodySmall?.copyWith(color: Colors.redAccent),
                        ),
                      ),

                    // IMPORTANT:
                    // Fix pentru flutter_html 3 când ajunge în constrângeri ciudate:
                    // forțăm lățime >= 1 și exact maxWidth din layout.
                    LayoutBuilder(
                      builder: (context, c) {
                        final maxW = c.maxWidth.isFinite ? c.maxWidth : MediaQuery.of(context).size.width;
                        final safeW = maxW <= 0 ? 1.0 : maxW;

                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: safeW,
                            maxWidth: safeW,
                          ),
                          child: SizedBox(
                            width: safeW,
                            child: Html(
                              data: _htmlContent,
                              style: {
                                "body": Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.zero,
                                  fontSize: FontSize((textTheme.bodyMedium?.fontSize ?? 14)),
                                  lineHeight: LineHeight.number(1.35),
                                ),
                                "p": Style(
                                  margin: Margins.only(bottom: 12),
                                ),
                                "img": Style(
                                  width: Width(100, Unit.percent),
                                  height: Height.auto(),
                                  display: Display.block,
                                  margin: Margins.symmetric(vertical: 10),
                                ),
                                "figure": Style(
                                  margin: Margins.symmetric(vertical: 10),
                                ),
                                "table": Style(
                                  width: Width(100, Unit.percent),
                                ),
                              },
                              extensions: [
                                // img src inline (inclusiv //...)
                                TagExtension(
                                  tagsToExtend: {"img"},
                                  builder: (ctx) {
                                    var src = (ctx.attributes['src'] ?? '').trim();
                                    if (src.isEmpty) return const SizedBox.shrink();
                                    if (src.startsWith('//')) src = 'https:$src';

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          src,
                                          fit: BoxFit.cover,
                                          headers: mediaHeaders,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 180,
                                            color: AppColors.gray60,
                                            child: const Center(
                                              child: Icon(Icons.broken_image, size: 32, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // tables: wrap horizontal scroll (evită layout “weird”)
                                TagExtension(
                                  tagsToExtend: {"table"},
                                  builder: (ctx) {
                                    // reconstruim doar table-ul ca HTML separat
                                    final tableHtml = ctx.element?.outerHtml;
                                    if (tableHtml == null || tableHtml.isEmpty) {
                                      return const SizedBox.shrink();
                                    }

                                    return SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(minWidth: 420),
                                        child: Html(
                                          data: tableHtml,
                                          // IMPORTANT: ca să evităm recursion / extensii din nou pe table
                                          extensions: const [],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}