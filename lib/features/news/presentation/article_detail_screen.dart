import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/media_headers.dart';
import '../data/article_item.dart';

class ArticleDetailScreen extends StatefulWidget {
  final ArticleItem article;
  final String lang;

  const ArticleDetailScreen({
    super.key,
    required this.article,
    required this.lang,
  });

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  bool _loading = true;
  String _htmlContent = '';
  String? _fullMediaUrl;

  @override
  void initState() {
    super.initState();
    _fullMediaUrl = widget.article.mediaUrl;
    _fetchFullArticle();
  }

  Future<void> _fetchFullArticle() async {
    // poți adapta la implementarea ta existentă
    const apiKey = '0b558c74198915cd8fad9cb8fbb5951a';
    const apiSecret = '3fa2a04361d0b808e4c5560fbffaf6b3';
    final id = widget.article.id;


    final strUrl =
        'api_key=$apiKey&method=getNews&tbsec=$apiSecret&format=json'
        '&id=$id&sport_id=&limit=&offset=&lang=${widget.lang}';

    final hash = md5.convert(utf8.encode(strUrl)).toString();

    final url =
        'https://articles.ns-platforms.com/api.php?api_key=$apiKey&method=getNews&tbsec=$hash'
        '&format=json&id=$id&sport_id=&limit=&offset=&lang=${widget.lang}';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final newsItem = json['news']?['newsItem']?[0];
        if (mounted && newsItem != null) {
          setState(() {
            _htmlContent = newsItem['description']?.toString() ?? '';
            // dacă în detaliu vine un alt media_url, îl folosim
            _fullMediaUrl = newsItem['media_url']?.toString() ?? _fullMediaUrl;
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final article = widget.article;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeroHeader(context, article),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
              const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
              child: _buildMetaRow(theme, article),
            ),
          ),
          SliverToBoxAdapter(
            child: _loading
                ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
                : Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Html(
                data: _htmlContent.isNotEmpty
                    ? _htmlContent
                    : '<p>${article.description}</p>',
                style: {
                  'body': Style(
                    color: theme.textTheme.bodyMedium?.color,
                    fontSize: FontSize(16),
                    lineHeight: const LineHeight(1.4),
                  ),
                },
                // customImageRenders: {
                //   networkSourceMatcher(): (context, attributes, element) {
                //     String? src =
                //         attributes['src'] ?? attributes['data-src'] ?? '';
                //
                //     if (src == null || src.isEmpty) {
                //       return const SizedBox.shrink();
                //     }
                //
                //     // cazuri de tipul //image.assets...
                //     if (src.startsWith('//')) {
                //       src = 'https:$src';
                //     }
                //
                //     return Image.network(
                //       src,
                //       fit: BoxFit.cover,
                //       headers: mediaHeaders, // x_app_key: mobile-sports-com
                //     );
                //   },
                // },
                //
                // // (opțional) link tap
                // onLinkTap: (url, ctx, attrs, element) {
                //   // poți deschide cu url_launcher dacă vrei
                // },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, ArticleItem article) {
    final mediaUrl = _fullMediaUrl;

    return Column(
      children: [
        SizedBox(
          height: 350,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (mediaUrl != null && mediaUrl.isNotEmpty)
                Image.network(
                  mediaUrl,
                  fit: BoxFit.cover,
                  headers: mediaHeaders,
                )
              else
                Container(color: Colors.black),

              // gradient jos ca să se vadă titlul
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),

              // Back + title + meniul din dreapta
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // back row + more icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () => Navigator.of(context).pop(),
                            child: Row(
                              children: const [
                                Icon(Icons.arrow_back,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 6),
                                Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // tag + title
                      // Optional: tag „Top news” (poți adapta după API)
                      // const Padding(
                      //   padding: EdgeInsets.only(bottom: 8),
                      //   child: Chip(
                      //     label: Text(
                      //       'Top news',
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 12,
                      //       ),
                      //     ),
                      //     backgroundColor: Colors.red,
                      //   ),
                      // ),

                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top:16, left: 16, right: 12),
          child: Text(
            article.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style:Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(ThemeData theme, ArticleItem article) {
    final colorAccent = Colors.red; // poți folosi culoarea brandului
    final sport = article.sportName ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sport.isNotEmpty)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: sport,
                  style: TextStyle(
                    color: colorAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (article.publishDate.isNotEmpty) ...[
                  const TextSpan(
                    text: ' · ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextSpan(
                    text: article.publishDate,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ]
              ],
            ),
          ),
      ],
    );
  }
}