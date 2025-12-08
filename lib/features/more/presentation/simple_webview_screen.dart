import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/widgets/back_header.dart';
import '../../../core/widgets/sports_app_bar.dart';

class SimpleWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const SimpleWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<SimpleWebViewScreen> createState() => _SimpleWebViewScreenState();
}

class _SimpleWebViewScreenState extends State<SimpleWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _loading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SportsAppBar(),
      body: Column(
        children: [
           BackHeader(title: widget.title),
          Expanded(child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ))
        ],
      ),
    );
  }
}
