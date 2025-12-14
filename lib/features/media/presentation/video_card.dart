import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:sports_config_app/core/app_config.dart';
import '../../../core/app_functions.dart';
import '../../../core/network/app_image_cache.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/theme/colors.dart';
import '../data/video_item.dart';

class VideoCard extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onTap;

  final double pictureRatio;
  const VideoCard({
    super.key,
    required this.video,
    required this.onTap,
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

    final formattedDate = SportsFunction().formatDateRelative(context,video.cDate);

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
                // THUMB 16:9
                AspectRatio(
                  aspectRatio:pictureRatio,
                  child: ClipRRect(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (video.thumbUrl != null)
                          AppNetworkImage(
                            url: video.thumbUrl!,
                            fit: BoxFit.cover,
                            // headers: mediaHeaders,
                            // errorBuilder: (context, error, stackTrace) {
                            //   return Container(color: AppColors.gray60);
                            // },
                          )
                        else
                          Container(color: AppColors.gray60),

                        // icon play peste imagine
                        Align(
                          alignment: Alignment.center,
                          child: SvgIconLoader(
                            iconUrl: '',
                            localAssetPath: 'assets/images/play_icon.svg',
                            size: 48,
                            headers: mediaHeaders,
                            color: Colors.white,
                            backgroundColor: Colors.black.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConfig.smallSpace),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2 * aspectRatio),
                      Text(
                        video.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleLarge,
                      ),
                      SizedBox(height: 2 * aspectRatio),

                      SizedBox(
                        height: descBoxHeight,
                        child: Text(
                          video.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium, // descStyle,
                        ),
                      ),

                      // SizedBox(height: 2 * aspectRatio),
                      Text(
                        formattedDate.toUpperCase(),
                        style: textTheme.labelSmall,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
