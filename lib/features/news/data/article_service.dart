import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'article_item.dart';

class ArticleService {
  final String apiKey;
  final String apiSecret;

  const ArticleService({
    this.apiKey = '0b558c74198915cd8fad9cb8fbb5951a',
    this.apiSecret = '3fa2a04361d0b808e4c5560fbffaf6b3',
  });

  Future<List<ArticleItem>> fetchArticles(
    Map<String, dynamic> sport,
    int offset,
    String languageCode, {
    int limit = 5,
  }) async {
    final int sportId = int.tryParse(sport['lpid']?.toString() ?? '') ?? 0;

    String strUrl = 'api_key=$apiKey&method=getNews&tbsec=$apiSecret'
        '&format=json&id=&sport_id=$sportId&limit=$limit&offset=$offset&lang=$languageCode';

    final String hash = md5.convert(utf8.encode(strUrl)).toString();
    final String url = 'https://articles.ns-platforms.com/api.php?'
        'api_key=$apiKey&method=getNews&tbsec=$hash'
        '&format=json&id=&sport_id=$sportId&limit=$limit&offset=$offset&lang=$languageCode';

    debugPrint('Articles URL: $url');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<dynamic> items = json['news']?['newsItem'] ?? [];
        return items
            .map((e) => ArticleItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('HTTP error (articles): ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception (articles): $e');
    }

    return [];
  }

  Future<String?> fetchFullArticleHtml(String id, String languageCode) async {
    final strUrl =
        'api_key=$apiKey&method=getNews&tbsec=$apiSecret&format=json&id=$id&sport_id=&limit=&offset=&lang=$languageCode';

    final hash = md5.convert(utf8.encode(strUrl)).toString();

    final url =
        'https://articles.ns-platforms.com/api.php?api_key=$apiKey&method=getNews&tbsec=$hash'
        '&format=json&id=$id&sport_id=&limit=&offset=&lang=$languageCode';

    debugPrint('Full article URL: $url');

    try {
      final response = await http.post(Uri.parse(url), headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final newsItem = json['news']?['newsItem']?[0];
        if (newsItem != null) {
          return newsItem['description']?.toString();
        }
      } else {
        debugPrint('HTTP error (article detail): ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception (article detail): $e');
    }

    return null;
  }
}
