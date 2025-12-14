import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sports_config_app/core/app_functions.dart';

import '../../../core/network/app_image_cache.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/theme/colors.dart';
import '../data/article_item.dart';

class ArticleCard extends StatelessWidget {
  final ArticleItem article;
  final VoidCallback? onTap;

  /// compact = true  => pentru grid (2 coloane)
  /// compact = false => pentru listă (1 coloană)
  final bool compact;
  final double pictureRatio;

  const ArticleCard({
    super.key,
    required this.article,
    this.onTap,
    this.compact = false,
    this.pictureRatio = 16 / 11
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final aspectRatio = SportsFunction().scale(context);

    // 2 linii fixe pt descriere → înălțime egală
    final descBoxHeight = textTheme.titleLarge!.fontSize! +
        textTheme.bodyMedium!.fontSize! +
        textTheme.labelSmall!.fontSize! ; // + (2+2) * aspectRatio;

    // Clamp la textScaleFactor să nu explodeze layout-ul
    final mq = MediaQuery.of(context);
    final clampedTextScale = mq.textScaleFactor.clamp(1.0, 1.2);
    final mediaWithClamp = mq.copyWith(textScaleFactor: clampedTextScale);

    final formattedDate =
        SportsFunction().formatDateRelative(context,article.publishDate);

    return InkWell(
      onTap: onTap,
      child: MediaQuery(
          data: mediaWithClamp,
          child: Card(
            clipBehavior: Clip.antiAlias,
            surfaceTintColor: Colors.transparent, // Material 3 fix
            shadowColor: Colors.transparent,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: pictureRatio,
                  child: ClipRRect(
                    child:
                        article.mediaUrl != null && article.mediaUrl!.isNotEmpty
                            ? AppNetworkImage(
                                url: article.mediaUrl!,
                                fit: BoxFit.cover,
                                // headers: mediaHeaders, // ai deja headerul ăsta
                                // errorBuilder: (_, __, ___) =>
                                //     Container(color: AppColors.gray60),
                              )
                            : Container(
                                color: AppColors.gray60,
                                child: const Center(
                                  child: Icon(Icons.article,
                                      color: Colors.white, size: 36),
                                ),
                              ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2 * aspectRatio),
                    Text(
                      article.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge,
                    ),
                    SizedBox(height: 2 * aspectRatio),
                    SizedBox(
                      height: descBoxHeight,
                      child: Text(
                        article.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      formattedDate.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall,
                    ),
                  ],
                ),



              ],
            ),
          )),
    );
  }
}
