import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/app_config.dart';
import '../../../core/app_functions.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/network/app_image_cache.dart';
import '../../../core/network/media_headers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/sports_app_bar.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/block_layouts.dart';
import '../../config/providers/config_provider.dart';
import '../../sports/providers/selected_sport_provider.dart';
import '../data/media_platform_client.dart';
import '../models/asset.dart';
import 'asset_card.dart';

/// Converts a string to a URL slug (lowercase, spaces to hyphens, alphanumeric + hyphens).
String _slugify(String s) {
  if (s.isEmpty) return s;
  return s
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[\s_]+'), '-')
      .replaceAll(RegExp(r'[^a-z0-9\-]'), '')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

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
class AssetDetailsPage extends ConsumerStatefulWidget {
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
  ConsumerState<AssetDetailsPage> createState() => _AssetDetailsPageState();
}

class _AssetDetailsPageState extends ConsumerState<AssetDetailsPage> {
  Asset? _asset;
  Object? _assetError;
  List<Asset> _moreAssets = [];
  bool _moreLoading = true;
  Object? _moreError;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;
  static const double _backToTopThreshold = 400;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoError = false;

  bool get _assetLoading => _asset == null && _assetError == null;
  Asset get _effectiveAsset => _asset ?? widget.asset;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    try {
      final a = await widget.client.fetchAsset(
        widget.asset.id,
        lang: widget.lang,
        country: widget.country,
      );
      if (!mounted) return;
      setState(() {
        _asset = a;
        _assetError = a == null ? true : null;
      });
      if (_asset != null) {
        _recordView();
        _loadMore();
        if (_effectiveAsset.isVideo) _initVideoPlayer();
      } else {
        _loadMore();
        if (widget.asset.isVideo) _initVideoPlayer();
        _recordView();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _assetError = e;
      });
      _loadMore();
      if (widget.asset.isVideo) _initVideoPlayer();
      _recordView();
    }
  }

  void _recordView() {
    widget.client.recordAssetView(_effectiveAsset.id).ignore();
  }

  Future<void> _initVideoPlayer() async {
    final mediaUrl = _effectiveAsset.media;
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


    final category = _effectiveAsset.categories.isNotEmpty
        ? _effectiveAsset.categories.first
        : null;
    final tag = _effectiveAsset.tags.isNotEmpty
        ? _effectiveAsset.tags.last
        : null;


    if (category == null && tag == null) {
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
          _effectiveAsset.isVideo ? ContentType.video : ContentType.article;
      final filters = AssetFilters(
        categories: category != null && category.isNotEmpty ? [category] : [],
        tags: category == null && tag != null && tag.isNotEmpty ? [tag] : [],
        excludeIds: [_effectiveAsset.id],
      );
print(filters.toJson());
      final res = await widget.client.fetchAssets(
          FetchAssetsParams(
            source: ContentSource.latest,
            contentType: contentType,
            filters: filters,
            perPage: 8,
            page: 1,
            lang: widget.lang,
            country: widget.country,
          )
      );

      if (mounted) {
        print('Related: ${filters.toJson()} Assets: ${res.assets.length}');

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

    if (_assetLoading) {
      return Scaffold(
        appBar: const SportsAppBar(),
        body: SportsFunction().customLoading(),
      );
    }

    return Scaffold(
      appBar: const SportsAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderRow(context),
            Padding(padding: const EdgeInsets.symmetric(
                horizontal: AppConfig.appPadding, vertical: 0), child: Column(
              children: [
                if (_effectiveAsset.isVideo) ...[
                  _buildVideoSection(),
                  const SizedBox(height: AppConfig.appPadding),
                  _buildTitleDescriptionAndShareBar(theme),
                ],
                if (_effectiveAsset.isArticle) _buildArticleSection(theme),
              ],
            ),),


            if (_effectiveAsset.categories.isNotEmpty || _effectiveAsset.tags.isNotEmpty) ...[
              const SizedBox(height: AppConfig.appPadding),
              _buildMoreSection(theme),
            ],
            const SizedBox(height: AppConfig.appPadding),
          ],
        ),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              heroTag: 'back_to_top',
              child: const Icon(Icons.arrow_upward, color: Colors.white,),
            )
          : null,
    );
  }

  /// Canonical share URL: {host}/{language}/{sport_slug}/news|video/{content_id}/{content_title_slug}
  String _buildCanonicalShareUrl() {
    final config = ref.read(configProvider).valueOrNull;
    final host = (config?['host'] ?? config?['site_url'] ?? AppConfig.baseUrl)
        .toString()
        .replaceAll(RegExp(r'/$'), '');
    final lang = widget.lang ?? ref.read(languageProvider).toString();
    final language = lang.isEmpty ? 'en' : lang;
    final sportSlug = _effectiveAsset.categories.isNotEmpty
        ? _slugify(_effectiveAsset.categories[0])
        : 'sport';
    final contentType = _effectiveAsset.isArticle ? 'news' : 'video';
    final contentId = _effectiveAsset.id;
    final titleSlug = _slugify(_effectiveAsset.title);
    final path = titleSlug.isEmpty
        ? '$host/$language/$sportSlug/$contentType/$contentId'
        : '$host/$language/$sportSlug/$contentType/$contentId/$titleSlug';
    return path;
  }

  Widget _buildHeaderRow(BuildContext context) {
    final configAsync = ref.watch(configProvider);
    final languageCode = ref.watch(languageProvider).isNotEmpty
        ? ref.watch(languageProvider)
        : 'en';

    return Row(
      children: [
        Expanded(
          child: BackHeader(
            title: _effectiveAsset.categories.isNotEmpty
                ? _effectiveAsset.categories[0]
                : (_effectiveAsset.tags.isNotEmpty ? _effectiveAsset.tags[0] :''),
          ),
        ),
        configAsync.when(
          data: (config) {
            final sports = (config?['sports'] as List?) ?? [];
            if (sports.isEmpty) return const SizedBox.shrink();
            return Row(
              children: [
                _SportIconsDropdown(
                  sports: sports,
                  languageCode: languageCode,
                ),
                const SizedBox(width: AppConfig.appPadding,)
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildTitleDescriptionAndShareBar(ThemeData theme) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _effectiveAsset.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleLarge,
        ),
        if (_effectiveAsset.description != null &&
            _effectiveAsset.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            _effectiveAsset.description!,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium,
          ),
        ],
        if (_effectiveAsset.publishedAt != null &&
            _effectiveAsset.publishedAt!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            SportsFunction()
                .formatDateRelative(context, _effectiveAsset.publishedAt!),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelSmall,
          ),
        ],
        const SizedBox(height: AppConfig.appPadding),
        _buildShareBar(theme),
      ],
    );
  }

  Future<void> _shareToPlatform(String platform) async {
    final shareUrl = _buildCanonicalShareUrl();
    if (widget.onShare != null) {
      widget.onShare!(platform, shareUrl);
      return;
    }
    final encodedUrl = Uri.encodeComponent(shareUrl);
    final encodedTitle = Uri.encodeComponent(_effectiveAsset.title);

    switch (platform) {
      case 'link':
        await Clipboard.setData(ClipboardData(text: shareUrl));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link copied to clipboard'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'email':
        final mailto = Uri(
          scheme: 'mailto',
          query: 'subject=${encodedTitle}&body=$encodedUrl',
        );
        if (await canLaunchUrl(mailto)) {
          await launchUrl(mailto);
        }
        break;
      case 'facebook':
        final uri = Uri.parse(
          'https://www.facebook.com/sharer/sharer.php?u=$encodedUrl',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 'twitter':
        final uri = Uri.parse(
          'https://twitter.com/intent/tweet?url=$encodedUrl&text=$encodedTitle',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 'pinterest':
        final uri = Uri.parse(
          'https://pinterest.com/pin/create/button/?url=$encodedUrl&description=$encodedTitle',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 'reddit':
        final uri = Uri.parse(
          'https://reddit.com/submit?url=$encodedUrl&title=$encodedTitle',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
      case 'linkedin':
        final uri = Uri.parse(
          'https://www.linkedin.com/sharing/share-offsite/?url=$encodedUrl',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
    }
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
      color: AppColors.redSports,
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: platforms
            .map(
              (p) => IconButton(
                onPressed: () => _shareToPlatform(p.$1),
                icon: Icon(p.$2, color: Colors.white, size: 24),
                tooltip: p.$1,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildVideoSection() {
    final mediaUrl = _effectiveAsset.media;

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
    final thumb = _effectiveAsset.thumb;
    final mediaUrl = _effectiveAsset.media;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: InkWell(
        onTap: () {
          if (widget.onPlayVideo != null) {
            widget.onPlayVideo!(_effectiveAsset);
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
    final thumb = _effectiveAsset.thumb;
    final articleUrl = _effectiveAsset.articleUrl ?? _effectiveAsset.media;

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppConfig.appPadding),
            _buildTitleDescriptionAndShareBar(theme),
            const SizedBox(height: AppConfig.appPadding),
            if (widget.articleBody != null)
              widget.articleBody!
            else if (articleUrl != null && articleUrl.isNotEmpty)
              ArticleHtmlBody(
                articleUrl: articleUrl,
                isDark: theme.brightness == Brightness.dark,
              ),
            const SizedBox(height: AppConfig.appPadding),
          ],
        ),
      ],
    );
  }

  Widget _buildMoreSection(ThemeData theme) {
    if (_moreLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppConfig.appPadding),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_moreError != null || _moreAssets.isEmpty) {
      return const SizedBox.shrink();
    }
    final effectiveBuilder =
        widget.moreItemBuilder ?? (context, asset) => AssetCard(asset: asset);
    // (context, asset) => _MoreItemCard(
    //       asset: asset,
    //       onTap: () => widget.onAssetTap?.call(asset),
    //     );
    return BlockLayoutBuilder(
      layoutType: 6,
      title: 'More',
      assets: _moreAssets,
      assetBuilder: effectiveBuilder,
      hasMore: false,
    );
  }
}

/// Dropdown with sport icons only; on tap navigates to that sport's page.
class _SportIconsDropdown extends ConsumerWidget {
  const _SportIconsDropdown({
    required this.sports,
    required this.languageCode,
  });

  final List<dynamic> sports;
  final String languageCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final color = Theme.of(context).colorScheme.onSurface;
    return PopupMenuButton<int>(
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/images/sports.svg',
            height: 35,
            width: 35,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
          const SizedBox(width: AppConfig.appPadding),

        ],
      ),
      onSelected: (int index) {
        ref.read(goToSportsWithIndexProvider.notifier).state = index;
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      itemBuilder: (BuildContext context) {
        return [
          for (int i = 0; i < sports.length; i++) ...[
            PopupMenuItem<int>(
              value: i,
              padding: const EdgeInsets.symmetric(horizontal: AppConfig.smallSpace, vertical: AppConfig.smallSpace),
              child: _SportIconItem(sport: sports[i] as Map<String, dynamic>),
            ),
          ],
        ];
      },
    );
  }
}

class _SportIconItem extends StatelessWidget {
  const _SportIconItem({required this.sport});

  final Map<String, dynamic> sport;

  @override
  Widget build(BuildContext context) {
    final iconUrl = sport['icon']?.toString();
    if (iconUrl != null && iconUrl.isNotEmpty) {
      return Row(
        children: [
          SizedBox(
            height: 30,
            width: 30,
            child: SvgIconLoader(
              iconUrl: iconUrl,
              headers: mediaHeaders,
              size: 28,
              color: Colors.white,
              backgroundColor: Colors.black
                  .withOpacity(0.9),
            ),
          ),
          const SizedBox(width: AppConfig.smallSpace,),
          Text(sport['name'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 13)
          )
        ],
      );
    }
    return const SizedBox(
      height: 32,
      width: 32,
      child: Icon(Icons.sports, size: 32),
    );
  }
}

/// Loads HTML from [articleUrl] and displays it in a [WebView] with Twitter/Instagram
/// embed scripts injected so blockquotes become full embeds. Used by [AssetDetailsPage]
/// for articles when [AssetDetailsPage.articleBody] is null.
class ArticleHtmlBody extends StatefulWidget {
  const ArticleHtmlBody({
    super.key,
    required this.articleUrl,
    required this.isDark,
  });

  final String articleUrl;
  final bool isDark;

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
        ..setBackgroundColor(Colors.transparent)
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

  @override
  void didUpdateWidget(covariant ArticleHtmlBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDark != widget.isDark &&
        _useWebView &&
        _html != null &&
        _webController != null) {
      _webViewLoaded = false;
      _loadHtmlInWebView();
    }
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
    final textColor = widget.isDark ? '#ffffff' : '#000000';
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://fonts.googleapis.com/css2?family=Open+Sans:wght@400&display=swap" rel="stylesheet">
  <style>
    html, body, .article-body {
      font-family: 'Open Sans', sans-serif;
      font-weight: 400;
      font-style: normal;
      background: transparent !important;
      color: $textColor;
    }
    .article-body * {
      color: inherit;
    }
    .article-body a {
      color: inherit;
      text-decoration: underline;
    }
  </style>
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
        padding: EdgeInsets.symmetric(vertical: AppConfig.appPadding),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConfig.appPadding),
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
      final color = Theme.of(context).colorScheme.onSurface;
      return Html(
        data: _html!,
        style: {
          'body': Style(
            color: color,
            backgroundColor: Colors.transparent,
          ),
          'p': Style(
            color: color,
            backgroundColor: Colors.transparent,
          ),
          'div': Style(
            color: color,
            backgroundColor: Colors.transparent,
          ),
          'span': Style(
            color: color,
            backgroundColor: Colors.transparent,
          ),
          'a': Style(
            color: color,
            backgroundColor: Colors.transparent,
          ),
        },
      );
    }
    final height =
        _webContentHeight != null ? _webContentHeight! + 20 : _defaultWebHeight;
    return SizedBox(
      height: height,
      child: WebViewWidget(controller: _webController!),
    );
  }
}
