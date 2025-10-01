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
                  initialUrlRequest:
                      URLRequest(url: WebUri(gameUrl ?? "")),
                  onWebViewCreated: (controller) {},
                  onLoadStart: (controller, url) {},
                  onLoadStop: (controller, url) async {
                    await controller.evaluateJavascript(
                        source: "hideHeader(); hideBackButton(); ${isDarkMode ? "enableDarkMode();" : ""}");
                   
                  },
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: Container(
        //   decoration: BoxDecoration(
        //     border: Border(
        //       top: BorderSide(
        //         color: theme.colorScheme.outlineVariant,
        //         width: 1.0,
        //       ),
        //     ),
        //   ),
        //   child: BottomAppBar(
        //     height: 64,
        //     color: theme.colorScheme.surfaceContainerLow,
        //     surfaceTintColor: theme.colorScheme.surfaceContainerLow,
        //     child:
        //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        //       IconButton(
        //         icon: Icon(Icons.arrow_back_ios_new),
        //         onPressed: () {
        //           Navigator.pop(context);
        //         },
        //       ),
        //       Expanded(
        //         child: Padding(
        //           padding: const EdgeInsets.all(8.0),
        //         ),
        //       ),
        //       Row(
        //         children: [
        //           IconButton(
        //             icon: Icon(Icons.bar_chart),
        //             onPressed: () {},
        //           ),
        //           IconButton(
        //             icon: Icon(Icons.share),
        //             onPressed: () {
        //               Share.share(
        //                   appState.gameShareableUrl ?? "https://dailytrojan.com/games");
        //             },
        //           ),
        //           IconButton(
        //             icon: Icon(Icons.more_vert_sharp),
        //             onPressed: () {},
        //           ),
        //         ],
        //       ),
        //     ]),
        //   ),
        // ),
        );
  }
}
