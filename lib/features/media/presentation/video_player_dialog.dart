import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// 🚀 Schimbăm de la meedu_player la chewie și video_player
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart'; // Folosim importul simplu

class VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  final String title;

  // Subtitrările au fost eliminate temporar.
  // final List<chewie.SubtitleSource> subtitleSources;

  const VideoPlayerDialog({
    super.key,
    required this.videoUrl,
    required this.title,
    // Subtitrările au fost eliminate temporar.
    // this.subtitleSources = const [],
  });

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  // 1. Controller-ul de bază al playerului
  late VideoPlayerController _videoPlayerController;
  // 2. Controller-ul Chewie care adaugă UI/Controale
  ChewieController? _chewieController;

  // Definirea cheii aplicației ca o constantă
  static const Map<String, String> _defaultHeaders = {
    'x-app-key': 'mobile-sports-com',
  };

  // 🚀 MOCK / DEFAULT SUBTITLE SOURCES PENTRU DEZVOLTARE 🚀
  // Eliminată temporar.

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    // 1. Inițializarea VideoPlayerController cu URL (HLS/DASH suportat automat) și headers
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
      httpHeaders: _defaultHeaders,
    );

    await _videoPlayerController.initialize();

    // 2. Definirea subtitrărilor pentru Chewie - Eliminată temporar.

    // 3. Inițializarea ChewieController
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,

      // Configurare subtitrări - Eliminată temporar.
      // subtitleConfiguration: subtitleConfiguration,

      // Personalizări UI:
      showOptions: true, // Afișăm opțiunile
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      // Aspect ratio preluat din video
      aspectRatio: _videoPlayerController.value.aspectRatio,

      // Personalizarea culorilor barei de progres pentru a se potrivi temei (Roșu Primar)
      materialProgressColors: ChewieProgressColors(
        playedColor: Theme.of(context).colorScheme.primary, // Roșu
        handleColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white,
      ),
    );

    setState(() {}); // Forțăm reconstrucția pentru a afișa playerul
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose(); // Dispunerea controllerului Chewie
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
                // Afișăm ChewiePlayer dacă _chewieController este inițializat și video-ul e gata
                _chewieController != null &&
                    _videoPlayerController.value.isInitialized
                    ? Chewie(
                  controller: _chewieController!,
                )
                // Sau un indicator de încărcare (Loading)
                    : const Center(
                  child: CircularProgressIndicator(),
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
                // Positioned(
                //   left: 16,
                //   right: 16,
                //   bottom: 8,
                //   child: Text(
                //     widget.title,
                //     maxLines: 2,
                //     overflow: TextOverflow.ellipsis,
                //     style: const TextStyle(
                //       color: Colors.white,
                //       fontWeight: FontWeight.bold,
                //       shadows: [
                //         Shadow(
                //           blurRadius: 3.0,
                //           color: Colors.black,
                //           offset: Offset(1.0, 1.0),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}