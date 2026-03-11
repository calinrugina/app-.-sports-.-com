import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../app_config.dart';
import '../theme/colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;
  final String? moreLabel;
  final String titleRed;

  const SectionHeader({
    super.key,
    required this.title,
    this.onMore,
    required this.moreLabel ,
    this.titleRed = '',
  });

  @override
  Widget build(BuildContext context) {
    // Header: title (first word red) + See more
    final parts = title.split(RegExp(r'\s+'));
    final firstWord = parts.isNotEmpty ? parts.first : '';
    final rest = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConfig.smallSpace, horizontal: AppConfig.smallSpace),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (titleRed.isNotEmpty) ...[

                Text(
                  titleRed,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: AppColors.redSports),
                ),
                SizedBox( width: 8,),
              ],


              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),


            ],
          ),
          if (onMore != null && moreLabel != null )
            GestureDetector(
                onTap: onMore,
                child: Row(
                  mainAxisSize:
                      MainAxisSize.min, // Să ocupe doar spațiul necesar
                  children: [
                    AutoSizeText(moreLabel!,
                        minFontSize: 10,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppColors.redSports,
                            fontSize: 14)), // Textul dorit
                     const SizedBox(width: 2), // Spațiu mic între text și icon
                     const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.redSports,), // Iconul săgeată mic
                  ],
                )),
        ],
      ),
    );
  }
}
