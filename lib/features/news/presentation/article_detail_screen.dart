import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:sports_config_app/core/app_config.dart';
import 'package:sports_config_app/core/network/media_headers.dart';
import 'package:sports_config_app/core/theme/colors.dart';
import 'package:sports_config_app/core/widgets/sports_app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:html/dom.dart' as dom;

import '../data/article_item.dart';

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;

import '../../../core/widgets/sports_app_bar.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/language/language_provider.dart';
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
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  bool _loading = true;
  String _htmlContent = '';
  String? _imageUrl;
  String? _publishDate;
  String? _category;
String? _fullTitle;

  @override
  void initState() {
    super.initState();
    _fetchFullArticle();
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
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final newsItem = json['news']?['newsItem']?[0];

        if (newsItem != null) {
          setState(() {
            _htmlContent = newsItem['description'] ?? '';
            _fullTitle = newsItem['title']?.toString();
            _publishDate = newsItem['publishedDate']?.toString();
            _category = newsItem['sport']?['name']?.toString();
            _loading = false;
          });
        } else {
          setState(() {
            _htmlContent = '<p>Article not found.</p>';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _htmlContent =
          '<p>Failed to load article (HTTP ${response.statusCode}).</p>';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _htmlContent = '<p>Failed to load article.</p>';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(theme),
          ),
        ],
      ),
    );
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
  Widget _buildContent(ThemeData theme) {
    final textTheme = theme.textTheme;
    final bodyColor = textTheme.bodyMedium?.color ?? Colors.white;
    final heroTitle = widget.article.title;
    final heroImage = widget.article.mediaUrl;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Imaginea mare de sus (media_url)
          _ArticleHero(
            imageUrl: heroImage,
            // title: heroTitle,
            headers: mediaHeaders,
          ),

          Container(
            color: theme.scaffoldBackgroundColor,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // 2. Titlul articolului
                Text(
                  widget.article.title,
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 22,
                  ),
                ),

                const SizedBox(height: 8),

                // categorie + dată
                if (_category != null || _publishDate != null)
                  Padding(
                    padding:
                    const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        if (_category != null)
                          Text(
                            _category!,
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.redSports,
                            ),
                          ),
                        if (_category != null &&
                            _publishDate != null)
                          Text(
                            ' · ',
                            style: textTheme.labelSmall,
                          ),
                        if (_publishDate != null)
                          Text(
                            _formatDate(_publishDate),
                            style: textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ),


                const SizedBox(height: 16),

                // 4. Conținut HTML complet (paragrafe + imagini inline)
                Html(
                  data: _htmlContent,
                  shrinkWrap: true,
                  style: {
                    "body": Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      color: bodyColor,
                      fontStyle: textTheme.bodyMedium!.fontStyle,
                      fontSize: FontSize(textTheme.bodyMedium?.fontSize ?? 14),
                      // lineHeight: LineHeight.number(1.4),
                    ),
                    "p": Style(
                      // margin: Margins.only(bottom: Margin(12, Unit.px)),
                      fontStyle: textTheme.bodyMedium!.fontStyle,
                      fontSize: FontSize(textTheme.bodyMedium?.fontSize ?? 14),
                    ),
                    "figure": Style(
                      margin: Margins.symmetric(
                        // vertical: Margin(12, Unit.px),
                      ),
                    ),
                    "img": Style(
                      margin: Margins.symmetric(
                        // vertical: Margin(8, Unit.px),
                      ),
                      width: Width(100, Unit.percent),
                      height: Height.auto(),
                    ),
                  },
                  extensions: [
                    // Render special pentru <img>, ca să prindem și src de tip //image...
                    TagExtension(
                      tagsToExtend: {"img"},
                      builder: (ctx) {
                        var src = ctx.attributes['src'] ?? '';
                        if (src.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        // dacă vine //image.assets..., prefixăm cu https:
                        if (src.startsWith('//')) {
                          src = 'https:$src';
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Image.network(
                            src,
                            fit: BoxFit.cover,
                            headers: mediaHeaders, // ok și pt host-urile tale
                            errorBuilder: (_, __, ___) => Container(
                              height: 180,
                              color: AppColors.gray60,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 32),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ArticleHero extends StatelessWidget {
  final String? imageUrl;
  // final String title;
  final Map<String, String> headers;

  const _ArticleHero({
    required this.imageUrl,
    // required this.title,
    required this.headers,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AspectRatio(
      aspectRatio: 16 / 16,
      child: Stack(
        fit: StackFit.expand,
        children: [

          // imaginea de fundal
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              headers: headers,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.black26);
              },
            )
          else
            Container(color: Colors.black26),

          // gradient de jos în sus
          Container(
            decoration: const BoxDecoration(
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

          // buton Back + titlu
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_back,
                            color: Colors.white, size: 20),
                        SizedBox(width: 4),
                        Text(
                          'Back',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const Spacer(),
                  // // Titlu peste imagine
                  // Padding(
                  //   padding: const EdgeInsets.only(bottom: 12.0, right: 8),
                  //   child: AutoSizeText(
                  //     title,
                  //     maxLines: 3,
                  //     minFontSize: 14,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: textTheme.headlineLarge?.copyWith(
                  //       color: Colors.white,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}