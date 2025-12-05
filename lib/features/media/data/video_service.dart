import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'video_item.dart';

class VideoService {
  final String apiKey;
  final String apiSecret;

  const VideoService({
    this.apiKey = '890133dcde505434a06fbbce55e23c2d',
    this.apiSecret = '43d3020546d63aea239d97c63a10adff',
  });

  /// Fetch videos for a given sport (uses its `mpid`).
  Future<List<VideoItem>> fetchVideos(
    Map<String, dynamic> sport,
    int offset,
    String languageCode, {
    int limit = 5,
  }) async {
    final String mpid = sport['mpid'].toString();
    return fetchVideosForSets(mpid, offset, languageCode, limit: limit);
  }

  /// Fetch videos for an arbitrary `from_sets` value (comma separated ids).
  Future<List<VideoItem>> fetchVideosForSets(
    String fromSets,
    int offset,
    String languageCode, {
    int limit = 5,
  }) async {
    const String method = 'list_contents';
    final int timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final Map<String, dynamic> checksumParams = {
      "from_sets": fromSets,
      "format_ids": 32,
      "offset": offset,
      "limit": limit,
      "get_thumbs": 1,
      "width": 512,
      "get_sets": 1,
    };

    final Map<String, dynamic> nonChecksumParams = {"minify": 1};

    String checksumClear = '';
    for (var value in checksumParams.values) {
      checksumClear += '$value:';
    }
    checksumClear += '$method:$apiSecret:$timestamp';

    final String checksum = md5.convert(utf8.encode(checksumClear)).toString();

    final Map<String, dynamic> requestJson = {
      'params': {...checksumParams, ...nonChecksumParams},
      'request': {
        "output_format": "json",
        "timestamp": timestamp,
        "method": method,
        "checksum": checksum,
      }
    };

    final String jsonEncoded = jsonEncode(requestJson);
    final String urlEncoded = Uri.encodeFull(jsonEncoded);
    final String postStr = 'data=$urlEncoded';

    final uri = Uri.parse(
      'https://media.ns-platforms.com/_apis/3rd.php?_slng=$languageCode&_ak=$apiKey',
    );

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: postStr,
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        final list =
            responseJson['response_data']?['list'] as List<dynamic>? ?? [];
        return list
            .map((item) => VideoItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        debugPrint('HTTP Error (videos): ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception (videos): $e');
    }

    return [];
  }
}
