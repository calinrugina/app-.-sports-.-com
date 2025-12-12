// lib/features/media/presentation/videos_listing.dart
import 'package:flutter/material.dart';
import 'package:sports_config_app/core/widgets/back_header.dart';
import 'package:sports_config_app/core/widgets/sports_app_bar.dart';
import 'package:sports_config_app/features/media/presentation/video_listing_one_column.dart';
import 'package:sports_config_app/l10n/app_localizations.dart';


class VideosListing extends StatelessWidget {
  final String title;
  final String mpids;
  final String languageCode;
  final String? q;

  const VideosListing({
    super.key,
    required this.title,
    required this.mpids,
    required this.languageCode,
    this.q,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SportsAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BackHeader(title: AppLocalizations.of(context)!.listing_videos_title(title)),
          Expanded(
            child: VideosListOneColumn(
              mpids: mpids,
              title: title,
              languageCode: languageCode,
              q: q
            ),
          ),
        ],
      ),
    );
  }
}