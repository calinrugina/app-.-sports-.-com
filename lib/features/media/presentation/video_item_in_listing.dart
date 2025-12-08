import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/app_functions.dart';
import '../data/video_item.dart';

class VideoListItem extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onTap;
  final Map<String, String>? headers;
  final double sizeWidth;

  const VideoListItem({
    super.key,
    required this.video,
    required this.onTap,
    this.headers,
    this.sizeWidth = 0,
  });

  // Funcție utilitară pentru a formata durata (Ex: 03:45)
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) {
      return "${d.inHours}:${minutes}:${seconds}";
    }
    return "$minutes:$seconds";
  }

  // Funcție utilitară pentru a formata data (Ex: 3 ore în urmă)
  String _formatDateRelative(String dateString) {
    DateTime videoDate;
    try {
      // 🚀 CONVERSIE DIN STRING LA DATETIME 🚀
      videoDate = DateTime.parse(dateString).toLocal();
    } catch (e) {
      // Gestionarea erorilor de parsare (dacă stringul nu este un format ISO 8601 valid)
      print('Eroare la parsarea datei "$dateString": $e');
      return 'Dată necunoscută';
    }

    final difference = DateTime.now().difference(videoDate);

    // Logica de calcul a diferenței relative
    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} ani în urmă';
    }
    if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} luni în urmă';
    }
    if (difference.inDays > 0) {
      return '${difference.inDays} zile în urmă';
    }
    if (difference.inHours > 0) {
      return '${difference.inHours} ore în urmă';
    }
    if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute în urmă';
    }
    return 'Acum';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: sizeWidth > 0
          ? SizedBox(width: sizeWidth, child: _videoPreview(context))
          : _videoPreview(context),
    );
  }

  Widget _videoPreview(BuildContext context) {
    // Definirea stilului pentru detaliile secundare (gri)
    final secondaryTextStyle = TextStyle(
      fontSize: 12,
      color: Colors.grey.shade600,
    );

    // Obținerea duratei și datei formatate
    final formattedDate = _formatDateRelative(video.cDate); // Acum trimite string-ul


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Imaginea Thumbnail (de pe rețea sau placeholder)
                if (video.thumbUrl != null)
                  Image.network(
                    video.thumbUrl!,
                    fit: BoxFit.cover,
                    headers: headers ?? const {},
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey.shade300);
                    },
                  )
                else
                  Container(color: Colors.grey.shade300),

                // 3. Iconița de Play (Overlay, centrată)
                Align(
                  alignment: Alignment.center,
                  child: SvgIconLoader(
                    iconUrl: '',
                    localAssetPath: 'assets/images/play_icon.svg',
                    size: 48,
                    headers: const {},
                    color: Colors.white,
                    // Fundal semi-transparent pentru a imita iconița de play
                    backgroundColor: Colors.black.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 2), // Mărit spațiul față de thumbnail

        // 4. Titlul Video-ului (Gros și pe maxim 2 rânduri)
        Text(
          video.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 2),

        // 5. Detaliile Secundare (Source Name + Dată)
        SizedBox(
          height: 40,
          child: Text(
            video.description??'',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          formattedDate.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall,
        )
      ],
    );
  }
}