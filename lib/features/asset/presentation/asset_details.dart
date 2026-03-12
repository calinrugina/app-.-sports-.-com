import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/app_functions.dart';
import '../../../core/network/app_image_cache.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/block_layouts.dart';
import '../data/media_platform_client.dart';
import '../models/asset.dart';

/// Full-page asset details: video (thumb + play) or article (thumb + title + description + HTML),
/// plus a "More" section with 4 assets from the same category (layoutType 6).
///
/// For articles, if [articleBody] is null the package uses [ArticleHtmlBody] (flutter_html) to load
/// and display HTML from [Asset.articleUrl] or [Asset.media]. Pass a custom widget to override.
///
/// Usage:
/// ```dart
/// Navigator.of(context).push(
///   MaterialPageRoute(
///     builder: (_) => AssetDetailsPage(
///       asset: asset,
///       client: client,
///       onPlayVideo: (a) => openVideo(a.media),
///       onAssetTap: openAssetDetails,
///     ),
///   ),
/// );
/// ```
class AssetDetailsPage extends StatefulWidget {
  const AssetDetailsPage({
    super.key,
    required this.asset,
    required this.client,
    this.lang,
    this.country,

    /// For video: called when play is tapped (e.g. open player with asset.media).
    this.onPlayVideo,

    /// For article: widget that displays HTML. If null, uses [ArticleHtmlBody] to load from [Asset.articleUrl]/[Asset.media].
    this.articleBody,

    /// Optional: open URL (e.g. via url_launcher). Used for "Read full article" or fallback when onPlayVideo is null.
    this.onOpenUrl,

    /// Called when a "More" item is tapped (e.g. push same AssetDetailsPage).
    this.onAssetTap,

    /// Optional: called when a share action is tapped (platform: 'link', 'email', 'facebook', 'pinterest', 'twitter', 'reddit', 'linkedin').
    this.onShare,

    /// Custom tile for "More" section. Default: compact card with thumb + title.
    this.moreItemBuilder,
  });

  final Asset asset;
  final MediaPlatformClient client;
  final String? lang;
  final String? country;
  final void Function(Asset asset)? onPlayVideo;
  final Widget? articleBody;
  final void Function(String url)? onOpenUrl;
  final void Function(Asset asset)? onAssetTap;
  final void Function(String platform, String shareUrl)? onShare;
  final Widget Function(BuildContext context, Asset asset)? moreItemBuilder;

  @override
  State<AssetDetailsPage> createState() => _AssetDetailsPageState();
}

class _AssetDetailsPageState extends State<AssetDetailsPage> {
  List<Asset> _moreAssets = [];
  bool _moreLoading = true;
  Object? _moreError;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  static const double _backToTopThreshold = 400;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
    if (widget.asset.isVideo) _initVideoPlayer();
    _recordView();
  }

  void _recordView() {
    widget.client.recordAssetView(widget.asset.id).ignore();
  }

  Future<void> _initVideoPlayer() async {
    final mediaUrl = widget.asset.media;
    if (mediaUrl == null || mediaUrl.isEmpty) return;
    _videoController = VideoPlayerController.networkUrl(Uri.parse(mediaUrl),
        httpHeaders: mediaHeaders);
    try {
      await _videoController!.initialize();
      if (!mounted) return;
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          aspectRatio: _videoController!.value.aspectRatio,
          // Fullscreen → landscape; exit fullscreen → portrait only
          deviceOrientationsOnEnterFullScreen: const [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
          deviceOrientationsAfterFullScreen: const [
            DeviceOrientation.portraitUp,
          ],
        );
      });
    } catch (e) {
      if (mounted) setState(() => _videoError = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.hasClients &&
        _scrollController.offset > _backToTopThreshold;
    if (show != _showBackToTop && mounted) {
      setState(() => _showBackToTop = show);
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _loadMore() async {
    final category = widget.asset.categories.isNotEmpty
        ? widget.asset.categories.first
        : null;
    if (category == null) {
      setState(() {
        _moreLoading = false;
        _moreAssets = [];
      });
      return;
    }
    setState(() {
      _moreLoading = true;
      _moreError = null;
    });
    try {
      final contentType =
          widget.asset.isVideo ? ContentType.video : ContentType.article;
      final res = await widget.client.fetchAssets(FetchAssetsParams(
        source: ContentSource.latest,
        contentType: contentType,
        filters: AssetFilters(
          categories: [category],
          excludeIds: [widget.asset.id],
        ),
        perPage: 4,
        page: 1,
        lang: widget.lang,
        country: widget.country,
      ));
      if (mounted) {
        setState(() {
          _moreAssets = res.assets;
          _moreLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _moreError = e;
          _moreLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const SportsAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BackHeader(
                title: AppLocalizations.of(context)!
                    .listing_videos_title(widget.asset.categories[0])),
            if (widget.asset.isVideo) ...[
              _buildVideoSection(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildTitleDescriptionAndShareBar(theme),
              ),
            ],
            if (widget.asset.isArticle) _buildArticleSection(theme),
            if (widget.asset.categories.isNotEmpty) _buildMoreSection(theme),
          ],
        ),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              heroTag: 'back_to_top',
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  String get _shareUrl => widget.asset.articleUrl ?? widget.asset.media ?? '';

  Widget _buildTitleDescriptionAndShareBar(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.asset.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.asset.description != null &&
            widget.asset.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            widget.asset.description!,
            style: theme.textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: 12),
        _buildShareBar(theme),
      ],
    );
  }

  Widget _buildShareBar(ThemeData theme) {
    const platforms = [
      ('link', Icons.link),
      ('email', Icons.mail_outline),
      ('facebook', Icons.facebook),
      ('pinterest', Icons.camera_alt),
      ('twitter', Icons.alternate_email),
      ('reddit', Icons.forum),
      ('linkedin', Icons.business_center),
    ];
    return Container(
      color: theme.colorScheme.error,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: platforms
            .map(
              (p) => IconButton(
                onPressed: _shareUrl.isEmpty
                    ? null
                    : () => widget.onShare?.call(p.$1, _shareUrl),
                icon: Icon(p.$2, color: Colors.white, size: 24),
                tooltip: p.$1,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildVideoSection() {
    final mediaUrl = widget.asset.media;

    if (mediaUrl == null || mediaUrl.isEmpty) {
      return _buildVideoThumbFallback();
    }
    if (_videoError) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.grey.shade300,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'Video failed to load',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_chewieController == null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }
    final ratio = _chewieController!.videoPlayerController.value.aspectRatio;
    return AspectRatio(
      aspectRatio: ratio > 0 ? ratio : 16 / 9,
      child: Chewie(controller: _chewieController!),
    );
  }

  Widget _buildVideoThumbFallback() {
    final thumb = widget.asset.thumb;
    final mediaUrl = widget.asset.media;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: InkWell(
        onTap: () {
          if (widget.onPlayVideo != null) {
            widget.onPlayVideo!(widget.asset);
          } else if (mediaUrl != null &&
              mediaUrl.isNotEmpty &&
              widget.onOpenUrl != null) {
            widget.onOpenUrl!(mediaUrl);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            if (thumb != null && thumb.isNotEmpty)
              AppNetworkImage(
                url: thumb,
                fit: BoxFit.cover,
                width: double.infinity,
              )
            else
              Container(
                color: Colors.grey.shade300,
                child: const Center(child: Icon(Icons.videocam_off, size: 48)),
              ),
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
    );
  }

  Widget _buildArticleSection(ThemeData theme) {
    final thumb = widget.asset.thumb;
    final articleUrl = widget.asset.articleUrl ?? widget.asset.media;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (thumb != null && thumb.isNotEmpty)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: AppNetworkImage(
              url: thumb,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleDescriptionAndShareBar(theme),
              const SizedBox(height: 20),
              if (widget.articleBody != null)
                widget.articleBody!
              else if (articleUrl != null && articleUrl.isNotEmpty)
                ArticleHtmlBody(articleUrl: articleUrl),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoreSection(ThemeData theme) {
    if (_moreLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_moreError != null || _moreAssets.isEmpty) {
      return const SizedBox.shrink();
    }
    final effectiveBuilder = widget.moreItemBuilder ??
        (context, asset) => _MoreItemCard(
              asset: asset,
              onTap: () => widget.onAssetTap?.call(asset),
            );
    return BlockLayoutBuilder(
      layoutType: 8,
      title: 'More',
      assets: _moreAssets,
      assetBuilder: effectiveBuilder,
    );
  }
}

/// Loads HTML from [articleUrl] and displays it in a [WebView] with Twitter/Instagram
/// embed scripts injected so blockquotes become full embeds. Used by [AssetDetailsPage]
/// for articles when [AssetDetailsPage.articleBody] is null.
class ArticleHtmlBody extends StatefulWidget {
  const ArticleHtmlBody({super.key, required this.articleUrl});

  final String articleUrl;

  @override
  State<ArticleHtmlBody> createState() => _ArticleHtmlBodyState();
}

class _ArticleHtmlBodyState extends State<ArticleHtmlBody> {
  String? _html;
  bool _loading = true;
  String? _error;
  WebViewController? _webController;
  double? _webContentHeight;
  bool _webViewLoaded = false;

  static const double _defaultWebHeight = 600;

  bool get _useWebView => !kIsWeb;

  @override
  void initState() {
    super.initState();
    if (_useWebView) {
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'HeightChannel',
          onMessageReceived: (JavaScriptMessage m) {
            if (m.message.isEmpty) return;
            final h = double.tryParse(m.message);
            if (h != null && mounted) {
              setState(() => _webContentHeight = h);
            }
          },
        );
    }
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    try {
      final res =
          await http.get(Uri.parse(widget.articleUrl), headers: mediaHeaders);
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() {
          _html = res.body;
          _loading = false;
        });
        if (_useWebView) _loadHtmlInWebView();
      } else {
        setState(() {
          _error = 'Failed to load (${res.statusCode})';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _loadHtmlInWebView() {
    if (_html == null ||
        _html!.isEmpty ||
        _webViewLoaded ||
        _webController == null) return;
    _webViewLoaded = true;
    final fullHtml = _buildFullHtml(_html!);
    _webController!.loadHtmlString(
      fullHtml,
      baseUrl: widget.articleUrl,
    );
  }

  /// Full HTML document: article body in .article-body + Twitter/Instagram embed scripts.
  String _buildFullHtml(String bodyHtml) {
    // Avoid breaking the parser if article contains </script>
    final safeBody = bodyHtml.replaceAll('</script>', r'<\/script>');
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
  <div class="article-body">$safeBody</div>
  <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
  <script async src="https://www.instagram.com/embed.js"></script>
  <script>
    (function() {
      var articleBody = document.querySelector('.article-body');
      if (!articleBody) return;

      function runTwitter() {
        if (window.twttr && window.twttr.widgets) {
          window.twttr.widgets.load(articleBody);
          return true;
        }
        return false;
      }
      function runInstagram() {
        if (window.instgrm && window.instgrm.Embeds) {
          window.instgrm.Embeds.process();
          return true;
        }
        return false;
      }

      var twitterDone = false;
      var twitterCheck = setInterval(function() {
        if (twitterDone) return;
        if (window.twttr && window.twttr.ready) {
          window.twttr.ready(function() {
            runTwitter();
            twitterDone = true;
          });
          clearInterval(twitterCheck);
        }
      }, 100);
      setTimeout(function() { clearInterval(twitterCheck); }, 10000);

      var instagramCheck = setInterval(function() {
        if (runInstagram()) clearInterval(instagramCheck);
      }, 150);
      setTimeout(function() { clearInterval(instagramCheck); }, 8000);
    })();
  </script>
  <script>
    (function() {
      function postHeight() {
        if (window.HeightChannel && typeof window.HeightChannel.postMessage === 'function') {
          window.HeightChannel.postMessage(String(document.body.scrollHeight));
        }
      }
      if (document.readyState === 'complete') postHeight();
      else window.addEventListener('load', postHeight);
      window.addEventListener('resize', postHeight);
    })();
  </script>
</body>
</html>''';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Error: $_error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }
    if (_html == null || _html!.isEmpty) {
      return const SizedBox.shrink();
    }
    if (!_useWebView) {
      return Html(data: _html!);
    }
    final height = _webContentHeight ?? _defaultWebHeight;
    return SizedBox(
      height: height,
      child: WebViewWidget(controller: _webController!),
    );
  }
}

/// Compact card for "More" section (layoutType 6).
class _MoreItemCard extends StatelessWidget {
  const _MoreItemCard({required this.asset, this.onTap});

  final Asset asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumb = asset.thumb;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: thumb != null && thumb.isNotEmpty
                  ? AppNetworkImage(url: thumb, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                asset.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
