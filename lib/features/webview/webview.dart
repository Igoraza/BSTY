import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../common_widgets/background_image.dart';
import '../../utils/functions.dart';
import '../../utils/global_keys.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage(this.url, {Key? key}) : super(key: key);

  static const String routeName = '/webview';

  final String url;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onWebResourceError: (WebResourceError error) {
            debugPrint('=======> WebView Error: $error');
            // handle errors

            navigatorKey.currentState!.pop();
            showSnackBar('Error loading page');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url == widget.url) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundImage(
      child: Scaffold(
        appBar: AppBar(),
        body: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }
}
