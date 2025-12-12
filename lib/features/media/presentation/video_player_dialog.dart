import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:sports_config_app/core/network/media_headers.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoSubtitle {
  final String url;
  final String label;
  const VideoSubtitle({required this.url, required this.label});
}

class VideoPlayerDialog extends StatefulWidget {
  final String videoUrl;
  final String title;
  final List<VideoSubtitle> subtitles; // folosite pe HLS (BetterPlayer)

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
  bool get _isHls => widget.videoUrl.toLowerCase().contains('.m3u8');
  bool get _isMp4 => widget.videoUrl.toLowerCase().contains('.mp4');

  BetterPlayerController? _betterM3U8Controller;
  BetterPlayerController? _betterMP4Controller;

  VideoPlayerController? _vpController;
  ChewieController? _chewieController;

  String? _errorText;
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _init();
  }

  Future<void> _init() async {
    try {
      if (_isMp4 && !_isHls) {
        await _initMp4WithAvPlayer();
      } else {
        await _initHlsWithBetterPlayer();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorText = e.toString());
    }
  }

  Future<void> _initMp4WithAvPlayer() async {
    if (false) {
      // is Better
      final subtitles = widget.subtitles
          .map((s) => BetterPlayerSubtitlesSource(
                type: BetterPlayerSubtitlesSourceType.network,
                name: s.label,
                urls: [s.url],
              ))
          .toList();

      final config = BetterPlayerConfiguration(
        autoPlay: false,
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
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enableSubtitles: true,
          enableQualities: true,
          enableAudioTracks: true,
          enablePlaybackSpeed: true,
        ),
      );
      final controller = BetterPlayerController(config);
      controller.addEventsListener((event) {

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
          // pornește doar după init
          controller.play();
        }
      });
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        widget.videoUrl,
        headers: mediaHeaders,
        videoFormat: _isHls ? BetterPlayerVideoFormat.hls : null,
        subtitles: subtitles.isEmpty ? null : subtitles,
      );

      setState(() {
        _betterMP4Controller = controller;

        _betterM3U8Controller?.dispose();
        _betterM3U8Controller = null;

        _vpController?.dispose();
        _vpController = null;

        _errorText = null;
        _ready = true;
      });

      try {
        // 🔥 IMPORTANT: setupDataSource explicit
        await controller.setupDataSource(dataSource);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _errorText = e.toString();
        });
      }
    } else {
      // is VP-MEdiaPlayer
      final vp = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: mediaHeaders,
      );

      await vp.initialize();
      if (!mounted) return;

      final chewie = ChewieController(
        videoPlayerController: vp,
        autoPlay: true,
        looping: false,
        showOptions: true,
        allowFullScreen: true,
        deviceOrientationsOnEnterFullScreen: const [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        deviceOrientationsAfterFullScreen: const [
          DeviceOrientation.portraitUp,
        ],
      );

      setState(() {
        _vpController = vp;
        _chewieController = chewie;

        _betterM3U8Controller?.dispose();
        _betterM3U8Controller = null;

        _betterMP4Controller?.dispose();
        _betterMP4Controller = null;

        _errorText = null;
        _ready = true;
      });
    }
  }

  Future<void> _initHlsWithBetterPlayer() async {
    final subtitles = widget.subtitles
        .map((s) => BetterPlayerSubtitlesSource(
              type: BetterPlayerSubtitlesSourceType.network,
              name: s.label,
              urls: [s.url],
            ))
        .toList();

    final config = BetterPlayerConfiguration(
      autoPlay: false,
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
      controlsConfiguration: const BetterPlayerControlsConfiguration(
        enableFullscreen: true,
        enableSubtitles: true,
        enableQualities: true,
        enableAudioTracks: true,
        enablePlaybackSpeed: true,
      ),
    );

    final controller = BetterPlayerController(config);

    controller.addEventsListener((event) {

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
        controller.play();
      }
    });

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.videoUrl,
      headers: mediaHeaders,
      videoFormat: BetterPlayerVideoFormat.hls,
      subtitles: subtitles.isEmpty ? null : subtitles,
    );

    setState(() {
      _betterM3U8Controller = controller;

      _chewieController?.dispose();
      _vpController?.dispose();
      _chewieController = null;
      _vpController = null;

      _betterMP4Controller?.dispose();
      _betterMP4Controller = null;

      _errorText = null;
      _ready = false;
    });

    await controller.setupDataSource(dataSource);
  }

  @override
  void dispose() {
    _betterM3U8Controller?.dispose();
    _chewieController?.dispose();
    _vpController?.dispose();
    _betterMP4Controller?.dispose();

    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: SafeArea(
        child: Stack(
          children: [
            Center(child: _buildPlayer()),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: (_errorText == null && !_ready)
                  ? const Text("Loading...",
                      style: TextStyle(color: Colors.white70))
                  : const SizedBox.shrink(),
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

    // MP4 => Chewie (AVPlayer pe iOS)
    // HLS => BetterPlayer
    if (_betterMP4Controller != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(controller: _betterMP4Controller!),
      );
    }

    if (_chewieController != null && _vpController != null) {
      final ar = _vpController!.value.isInitialized
          ? _vpController!.value.aspectRatio
          : (16 / 9);
      return AspectRatio(
        aspectRatio: ar.isFinite && ar > 0 ? ar : (16 / 9),
        child: Chewie(controller: _chewieController!),
      );
    }

    // HLS => BetterPlayer
    if (_betterM3U8Controller != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: BetterPlayer(controller: _betterM3U8Controller!),
      );
    }

    return const SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
