import 'package:dailytrojan/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

WebViewEnvironment? webViewEnvironment;

class GameRoute extends StatelessWidget {
  final String gameUrl;
  final String gameShareableUrl;
  GameRoute({required this.gameUrl, required this.gameShareableUrl});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: InAppWebView(
                initialSettings: InAppWebViewSettings(
                  isInspectable: kDebugMode,
                ),
                initialUrlRequest: URLRequest(url: WebUri(gameUrl ?? "")),
                onWebViewCreated: (controller) {},
                onLoadStart: (controller, url) {},
                onLoadStop: (controller, url) async {
                  await controller.evaluateJavascript(
                      source:
                          "hideHeader(); hideBackButton(); ${isDarkMode ? "enableDarkMode();" : ""}");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
