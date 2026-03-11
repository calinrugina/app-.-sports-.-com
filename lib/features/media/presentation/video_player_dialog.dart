import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// MP4: "default" platform player (AVPlayer / MediaPlayer)
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

// HLS (.m3u8): awesome_video_player (BetterPlayer-like)
import 'package:awesome_video_player/awesome_video_player.dart';

import '../../../core/network/media_headers.dart';

class VideoSubtitle {
  final String url; // .vtt
  final String label; // ex: "RO", "EN"
  const VideoSubtitle({required this.url, required this.label});
}

class VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  final String title;

  /// Folosite DOAR pe HLS (m3u8) în awesome_video_player (subtitles).
  /// (Pe MP4, chewie/video_player nu îți gestionează VTT out-of-the-box.)
  final List<VideoSubtitle> subtitles;

  const VideoPlayerDialog({
    super.key,
    required this.videoUrl,
    required this.title,
    this.subtitles = const [],
  });

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  // ---- MP4 (video_player + chewie)
  VideoPlayerController? _vp;
  ChewieController? _chewie;

  // ---- HLS (awesome_video_player)
  BetterPlayerController? _hls;

  String? _errorText;
  bool _ready = false;

  bool get _isHls {
    final u = widget.videoUrl.toLowerCase();
    return u.contains('.m3u8') || u.contains('m3u8');
  }

  @override
  void initState() {
    super.initState();

    // ✅ Permitem landscape doar cât timp dialogul e deschis
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _init();
  }

  Future<void> _init() async {
    setState(() {
      _errorText = null;
      _ready = false;
    });

    if (_isHls) {
      await _initHls();
    } else {
      await _initMp4();
    }
  }

  Future<void> _initMp4() async {
    // Curățăm tot ce e HLS
    _hls?.dispose();
    _hls = null;

    // Curățăm MP4 vechi
    _chewie?.dispose();
    _vp?.dispose();
    _chewie = null;
    _vp = null;

    try {
      final vp = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: mediaHeaders, // IMPORTANT: headerul tău
      );

      // log-uri utile pentru cazurile "se aude dar nu se vede"
      vp.addListener(() {
        final v = vp.value;
        if (v.hasError) {
          debugPrint(
            "[MP4] VideoPlayer ERROR: ${v.errorDescription}  url=${widget.videoUrl}",
          );
        }
        // uneori pe iOS vezi 0x0 / NaN; logăm dimensiunea
        if (v.isInitialized) {
          debugPrint(
            "[MP4] init=${v.isInitialized} size=${v.size.width}x${v.size.height} "
                "ar=${v.aspectRatio} pos=${v.position} dur=${v.duration}",
          );
        }
      });

      await vp.initialize();
      if (!mounted) return;

      final chewie = ChewieController(
        videoPlayerController: vp,
        autoPlay: true,
        looping: false,
        showOptions: true,
        allowFullScreen: true,
        allowMuting: true,
        allowedScreenSleep: false,

        // ✅ fullscreen -> landscape
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        // ✅ exit fullscreen -> portrait
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
        ],
      );

      setState(() {
        _vp = vp;
        _chewie = chewie;
        _ready = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = "[MP4] init failed: $e";
      });
      debugPrint(_errorText);
    }
  }

  Future<void> _initHls() async {
    // Curățăm MP4
    _chewie?.dispose();
    _vp?.dispose();
    _chewie = null;
    _vp = null;

    // Curățăm HLS vechi
    _hls?.dispose();
    _hls = null;

    try {
      final subtitleSources = widget.subtitles
          .map(
            (s) => BetterPlayerSubtitlesSource(
          type: BetterPlayerSubtitlesSourceType.network,
          name: s.label,
          urls: [s.url],
        ),
      )
          .toList();

      final config = BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        fit: BoxFit.contain,
        allowedScreenSleep: false,

        deviceOrientationsOnFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
        ],

        controlsConfiguration: BetterPlayerControlsConfiguration(
          playerTheme: BetterPlayerTheme.material,

          // doar ce are sens la HLS:
          enableQualities: true,
          enableAudioTracks: true,

          // subtitles doar dacă ai listă
          enableSubtitles: subtitleSources.isNotEmpty,

          enableFullscreen: true,
          enablePlaybackSpeed: true,

          // (opțional) ca să nu “clipească” controls
          showControlsOnInitialize: false,
        ),
      );

      final controller = BetterPlayerController(config);

      controller.addEventsListener((event) {
        debugPrint(
          "[HLS] event=${event.betterPlayerEventType} params=${event.parameters}",
        );

        if (!mounted) return;

        if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
          setState(() {
            _errorText = event.parameters?["exception"]?.toString() ??
                event.parameters?.toString() ??
                "Playback error";
          });
        }

        if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
          setState(() => _ready = true);
        }
      });

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoUrl,
        headers: mediaHeaders, // IMPORTANT: headerul tău
        videoFormat: BetterPlayerVideoFormat.hls,
        subtitles: subtitleSources.isEmpty ? null : subtitleSources,
      );

      setState(() {
        _hls = controller;
        _errorText = null;
        _ready = false;
      });

      await controller.setupDataSource(dataSource);
      if (!mounted) return;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = "[HLS] init failed: $e";
      });
      debugPrint(_errorText);
    }
  }

  @override
  void dispose() {
    _hls?.dispose();
    _chewie?.dispose();
    _vp?.dispose();

    // ✅ Revine aplicația la portrait-only
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  @override


  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(0),
      child: SafeArea(
        child: Stack(
          children: [
            Center(child: _buildPlayer()),

            Positioned(
              top: 20,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            Positioned(
              left: 12,
              top: 12,
              child: (_errorText == null && !_ready)
                  ? const Text(
                "Loading...",
                style: TextStyle(color: Colors.white),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
  Widget build_dialog(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(
          children: [
            // ✅ fundal negru full-screen
            const Positioned.fill(
              child: ColoredBox(color: Colors.black),
            ),

            // ✅ player centrat, dar cu background negru peste tot
            Positioned.fill(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain, // sau BoxFit.cover dacă vrei să “umple” fără benzi
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: _buildPlayer(), // playerul tău (mp4 / hls)
                  ),
                ),
              ),
            ),

            // close
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPlayer() {
    if (_errorText != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          _errorText!,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      );
    }

    // ✅ MP4 -> AVPlayer / MediaPlayer (chewie)
    if (!_isHls && _chewie != null && _vp != null) {
      final v = _vp!.value;
      final ar =
      (v.isInitialized && v.aspectRatio.isFinite && v.aspectRatio > 0)
          ? v.aspectRatio
          : 16 / 9;

      return AspectRatio(
        aspectRatio: ar,
        child: Chewie(controller: _chewie!),
      );
    }

    // ✅ HLS (.m3u8) -> awesome_video_player / BetterPlayer
    if (_isHls && _hls != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(controller: _hls!),
      );
    }

    return const SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}