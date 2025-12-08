import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sports_config_app/core/network/media_headers.dart';

class SportBannersCarousel extends StatefulWidget {
  final Map<String, dynamic> sport;

  const SportBannersCarousel({
    super.key,
    required this.sport,
  });

  @override
  State<SportBannersCarousel> createState() => _SportBannersCarouselState();
}

class _SportBannersCarouselState extends State<SportBannersCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  List<_BannerItem> get _items => _parseBannerItems(widget.sport);

  int get _slideSeconds {
    final banners = widget.sport['banners'] as Map<String, dynamic>?;
    final top = banners?['top'] as List? ?? [];
    if (top.isNotEmpty) {
      final raw = top.first['slide_timer'];
      final v = int.tryParse(raw?.toString() ?? '');
      if (v != null && v > 0) return v;
    }
    return 5;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _restartTimer();
  }

  @override
  void didUpdateWidget(covariant SportBannersCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sport != widget.sport) {
      _currentIndex = 0;
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    final items = _items;
    if (items.length <= 1) return;

    _timer = Timer.periodic(
      Duration(seconds: _slideSeconds),
          (timer) {
        if (!_pageController.hasClients) return;
        int next = _currentIndex + 1;
        if (next >= items.length) next = 0;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 350,
      child: Padding( padding: EdgeInsets.only(left: 15, right: 15), child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => _onTapBanner(item),
                  child: ClipRRect(
                    // borderRadius: BorderRadius.circular(12),
                    child: SizedBox.expand(
                      child: _buildBannerImage(item.imageUrl),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(items.length, (i) {
              final isActive = i == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 10 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),),
    );
  }

  Widget _buildBannerImage(String url) {
    if (url.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        url,
        fit: BoxFit.cover,
        headers: mediaHeaders,
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      headers: mediaHeaders,
    );
  }

  Future<void> _onTapBanner(_BannerItem item) async {
    final link = item.link;
    if (link == null || link.isEmpty) return;

    final uri = Uri.tryParse(link);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ---- helpers ----

  List<_BannerItem> _parseBannerItems(Map<String, dynamic> sport) {
    final banners = sport['banners'] as Map<String, dynamic>?;
    if (banners == null) return [];

    final top = banners['top'] as List? ?? [];
    final List<_BannerItem> result = [];

    for (final t in top) {
      final m = t as Map<String, dynamic>?;
      if (m == null) continue;
      final items = m['items'] as List? ?? [];
      for (final rawItem in items) {
        final i = rawItem as Map<String, dynamic>?;
        if (i == null) continue;
        if (i['type']?.toString() != 'image') continue;

        final img = (i['mobile_image'] ?? i['desktop_image'])?.toString();
        if (img == null || img.isEmpty) continue;

        final rawLink = i['link']?.toString();
        final cleanLink = _extractHref(rawLink);

        result.add(_BannerItem(
          imageUrl: img,
          link: cleanLink,
        ));
      }
    }

    return result;
  }

  String? _extractHref(String? raw) {
    if (raw == null) return null;
    // ex: "href=https://beta.sports.com/en/slk"
    const prefix = 'href=';
    final idx = raw.indexOf(prefix);
    if (idx == -1) return raw;
    return raw.substring(idx + prefix.length);
  }
}

class _BannerItem {
  final String imageUrl;
  final String? link;

  _BannerItem({
    required this.imageUrl,
    required this.link,
  });
}