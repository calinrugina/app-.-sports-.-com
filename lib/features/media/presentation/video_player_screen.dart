import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../core/network/media_headers.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _initializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
        httpHeaders: mediaHeaders,
      );
      await controller.initialize();

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        allowedScreenSleep: false,
      );

      if (!mounted) {
        controller.dispose();
        chewie.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _chewieController = chewie;
        _initializing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load video';
        _initializing = false;
      });
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _initializing
            ? const CircularProgressIndicator()
            : (_error != null
                ? Text(_error!)
                : (_chewieController != null
                    ? AspectRatio(
                        aspectRatio:
                            _videoController?.value.aspectRatio ?? 16 / 9,
                        child: Chewie(controller: _chewieController!),
                      )
                    : const Text('No video'))),
      ),
    );
  }
}
