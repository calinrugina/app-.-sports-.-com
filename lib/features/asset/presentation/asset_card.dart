import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/app_config.dart';
import '../../../core/app_functions.dart';
import '../../../core/network/app_image_cache.dart';
import '../../../core/theme/colors.dart';
import '../models/asset.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback? onTap;

  /// compact = true  => pentru grid (2 coloane)
  /// compact = false => pentru listă (1 coloană)
  final bool compact;
  final double pictureRatio;

  const AssetCard(
      {super.key,
      required this.asset,
      this.onTap,
      this.compact = false,
      this.pictureRatio = 16 / 11});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final aspectRatio = SportsFunction().scale(context);

    // 2 linii fixe pt descriere → înălțime egală
    final descBoxHeight = textTheme.titleLarge!.fontSize! +
        textTheme.bodyMedium!.fontSize! +
        textTheme.labelSmall!.fontSize!; // + (2+2) * aspectRatio;

    // Clamp la textScaleFactor să nu explodeze layout-ul
    final mq = MediaQuery.of(context);
    final clampedTextScale = mq.textScaleFactor.clamp(1.0, 1.2);
    final mediaWithClamp = mq.copyWith(textScaleFactor: clampedTextScale);

    final formattedDate =
        SportsFunction().formatDateRelative(context, asset.publishedAt!);

    return InkWell(
      onTap: onTap,
      child: MediaQuery(
          data: mediaWithClamp,
          child: Card(
            clipBehavior: Clip.antiAlias,
            surfaceTintColor: Colors.transparent, // Material 3 fix
            shadowColor: Colors.transparent,
            color: Colors.transparent,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: pictureRatio,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConfig.radiusApp),
                      topRight: Radius.circular(AppConfig.radiusApp),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        asset.thumb != null && asset.thumb!.isNotEmpty
                            ? AppNetworkImage(
                                url: asset.thumb,
                                fit: BoxFit.cover,
                                // headers: mediaHeaders, // ai deja headerul ăsta
                                // errorBuilder: (_, __, ___) =>
                                //     Container(color: AppColors.gray60),
                              )
                            : Container(
                                color: AppColors.gray60,
                                child: Center(
                                  child: Icon(
                                      asset.type == 'article'
                                          ? Icons.article
                                          : Icons.video_call,
                                      color: Colors.white,
                                      size: 36),
                                ),
                              ),
                        if (asset.type == 'video')
                          Align(
                            alignment: Alignment.center,
                            child: SvgIconLoader(
                              iconUrl: '',
                              localAssetPath: 'assets/images/play_icon.svg',
                              size: 48,
                              headers: {},
                              color: Colors.white,
                              backgroundColor: Colors.black.withOpacity(0.2),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2 * aspectRatio),
                    Text(
                      asset.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge,
                    ),
                    SizedBox(height: 2 * aspectRatio),
                    SizedBox(
                      height: descBoxHeight,
                      child: Text(
                        asset.description ?? '',
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

class AssetCardDark extends StatelessWidget {
  final Asset asset;
  final VoidCallback? onTap;

  /// compact = true  => pentru grid (2 coloane)
  /// compact = false => pentru listă (1 coloană)
  final bool compact;
  final double pictureRatio;

  const AssetCardDark(
      {super.key,
      required this.asset,
      this.onTap,
      this.compact = false,
      this.pictureRatio = 16 / 11});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final aspectRatio = SportsFunction().scale(context);

    // 2 linii fixe pt descriere → înălțime egală
    final descBoxHeight = textTheme.titleLarge!.fontSize! +
        textTheme.bodyMedium!.fontSize! +
        textTheme.labelSmall!.fontSize!; // + (2+2) * aspectRatio;

    // Clamp la textScaleFactor să nu explodeze layout-ul
    final mq = MediaQuery.of(context);
    final clampedTextScale = mq.textScaleFactor.clamp(1.0, 1.2);
    final mediaWithClamp = mq.copyWith(textScaleFactor: clampedTextScale);

    final formattedDate =
        SportsFunction().formatDateRelative(context, asset.publishedAt!);

    return InkWell(
      onTap: onTap,
      child: MediaQuery(
          data: mediaWithClamp,
          child: Card(
            clipBehavior: Clip.antiAlias,
            surfaceTintColor: Colors.transparent, // Material 3 fix
            shadowColor: Colors.transparent,
            color: Colors.transparent,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: pictureRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppConfig.radiusApp),
                          topRight: Radius.circular(AppConfig.radiusApp),
                        ),
                        child: asset.thumb != null && asset.thumb!.isNotEmpty
                            ? AppNetworkImage(
                          url: asset.thumb,
                          fit: BoxFit.cover,
                          // headers: mediaHeaders, // ai deja headerul ăsta
                          // errorBuilder: (_, __, ___) =>
                          //     Container(color: AppColors.gray60),
                        )
                            :  Container(
                          color: AppColors.gray60,
                          child: Center(
                            child: Icon(
                                asset.type == 'article'
                                    ? Icons.article
                                    : Icons.video_call,
                                color: Colors.white,
                                size: 36),
                          ),
                        ),
                      ),
                      if (asset.type == 'video')
                        Align(
                          alignment: Alignment.center,
                          child: SvgIconLoader(
                            iconUrl: '',
                            localAssetPath: 'assets/images/play_icon.svg',
                            size: 48,
                            headers: {},
                            color: Colors.white,
                            backgroundColor: Colors.black.withOpacity(0.2),
                          ),
                        )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2 * aspectRatio),
                    Text(
                      asset.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 2 * aspectRatio),
                    SizedBox(
                      height: descBoxHeight,
                      child: Text(
                        asset.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium
                            ?.copyWith(color: Colors.white70),
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

/// Full-width article card: large image with rounded top corners, dark gradient overlay at bottom
/// with optional label (e.g. "Top news"), title and red "READ FULL ARTICLE" button.
class AssetCardFull extends StatelessWidget {
  const AssetCardFull({
    super.key,
    required this.asset,
    this.onTap,
    this.topLabel,
    this.topLabelIcon,
    this.buttonLabel = 'READ FULL ARTICLE',
  });

  final Asset asset;
  final VoidCallback? onTap;

  /// Optional label above title (e.g. "Top news"). If null, the label row is hidden.
  final String? topLabel;

  /// Optional leading icon for topLabel (e.g. "🔥" or use Icon).
  final String? topLabelIcon;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumb = asset.thumb;

    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            AspectRatio(
              aspectRatio: 16 / 11,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppConfig.radiusApp),
                  topRight: Radius.circular(AppConfig.radiusApp),
                ),
                child: thumb != null && thumb.isNotEmpty
                    ? AppNetworkImage(
                        url: asset.thumb,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        // errorBuilder: (_, __, ___) => Container(
                        //   color: Colors.grey.shade300,
                        //   child: const Center(child: Icon(Icons.article, color: Colors.white, size: 48)),
                        // ),
                      )
                    : Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                            child: Icon(Icons.article,
                                color: Colors.white, size: 48)),
                      ),
              ),
            ),
            // Gradient overlay + content
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.85),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (topLabel != null && topLabel!.isNotEmpty) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (topLabelIcon != null && topLabelIcon!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Text(topLabelIcon!,
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          Text(
                            topLabel!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      asset.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.redSports,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: onTap,
                      child:  Text(buttonLabel.toUpperCase(), style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(color: Colors.white),),
                    ),


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

class AssetCard2Columns extends StatelessWidget {
  final Asset asset;
  final VoidCallback? onTap;

  /// compact = true  => pentru grid (2 coloane)
  /// compact = false => pentru listă (1 coloană)
  final bool compact;
  final double pictureRatio;

  const AssetCard2Columns(
      {super.key,
      required this.asset,
      this.onTap,
      this.compact = false,
      this.pictureRatio = 16 / 11});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 290,
      child: Card(
        elevation: 2,
        shadowColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.black87,
        // color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.radiusApp),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.smallSpace, vertical: 0),
            child: InkWell(
              onTap: onTap,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppConfig.radiusApp),
                    ),
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        asset.thumb != null && asset.thumb!.isNotEmpty
                            ? AppNetworkImage(
                          url: asset.thumb,
                          width: 150,
                          fit: BoxFit.cover,
                          // headers: mediaHeaders, // ai deja headerul ăsta
                          // errorBuilder: (_, __, ___) =>
                          //     Container(color: AppColors.gray60),
                        )
                            : Container(
                          color: AppColors.gray60,
                          child: Center(
                            child: Icon(
                                asset.type == 'article'
                                    ? Icons.article
                                    : Icons.video_call,
                                color: Colors.white,
                                size: 36),
                          ),
                        ),
                        if (asset.type == 'video')
                          Align(
                            alignment: Alignment.topLeft,
                            child: SvgIconLoader(
                              iconUrl: '',
                              localAssetPath: 'assets/images/play_icon.svg',
                              size: 48,
                              headers: {},
                              color: Colors.white,
                              backgroundColor: Colors.black.withOpacity(0.2),
                            ),
                          )
                      ],
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      asset.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
