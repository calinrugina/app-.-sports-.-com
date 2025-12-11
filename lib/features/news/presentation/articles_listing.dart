import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/sports_app_bar.dart';
import 'article_listing_one_column.dart';

class ArticlesListing extends StatelessWidget {
  final Map<String, dynamic> sport;
  final String languageCode;
  const ArticlesListing({super.key,
    required this.sport,
    required this.languageCode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SportsAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BackHeader(title: 'Listing Articles ${sport['name']}'),
          Expanded(
            child: ArticlesListOneColumn(
              sport: sport,
              languageCode: languageCode,
            ),
          ),
        ],
      ),
    );
  }
}
