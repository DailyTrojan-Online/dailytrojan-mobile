import 'package:dailytrojan/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

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
                onWebViewCreated: (controller) {
                  controller.addJavaScriptHandler(
                      handlerName: 'requestShare',
                      callback: (dynamic data) {
                        // print arguments and other info coming from the JavaScript side!
                        print(data[0]);

                        SharePlus.instance.share(ShareParams(text: data[0]));

                      });
                },
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
