import 'package:flutter/material.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';

import '../../../core/network/media_headers.dart';



class VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerDialog({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  // 1. Inițializarea Controllerului
  final MeeduPlayerController _meeduPlayerController = MeeduPlayerController(
    // Proprietățile de configurare (ex: orientarea) se setează acum direct
    // pe controller sau sunt gestionate implicit.
  );

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // 2. Definirea sursei video
    final dataSource = DataSource(
      type: DataSourceType.network,
      source: widget.videoUrl,

      // 🚀 Adăugarea header-ului HTTP solicitat AICI
      httpHeaders: mediaHeaders,

      // 'subtitleTracks' este numele corect al parametrului
      // subtitleTracks: [],
    );

    // 3. Setarea sursei video
    await _meeduPlayerController.setDataSource(
      dataSource,
      autoplay: true,
      // Puteți seta opțiuni suplimentare aici
      // closedCaptionEnabled: true,
    );
  }

  @override
  void dispose() {
    _meeduPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(12),
      backgroundColor: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                // Meedu Video Player (acest widget folosește controllerul pentru a afișa UI)
                MeeduVideoPlayer(
                  controller: _meeduPlayerController,
                ),

                // Butonul de închidere (Custom Overlay)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),

                // Titlul (Custom Overlay)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 8,
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}