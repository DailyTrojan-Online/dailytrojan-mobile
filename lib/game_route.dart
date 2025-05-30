import 'dart:async';
import 'dart:convert';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

WebViewEnvironment? webViewEnvironment;

class GameRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.displaySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
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
                      URLRequest(url: WebUri(appState.gameUrl ?? "")),
                  onWebViewCreated: (controller) {},
                  onLoadStart: (controller, url) {},
                  onLoadStop: (controller, url) async {
                    var result = await controller.evaluateJavascript(
                        source: "hideHeader(); hideBackButton(); ${isDarkMode ? "enableDarkMode();" : ""}");
                   
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1.0,
              ),
            ),
          ),
          child: BottomAppBar(
            color: theme.colorScheme.surfaceContainerLow,
            surfaceTintColor: theme.colorScheme.surfaceContainerLow,
            child:
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(
                icon: Icon(Icons.arrow_back_ios_new),
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.all(12.0),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.bar_chart),
                    onPressed: () {},
                    padding: EdgeInsets.all(12.0),
                  ),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      Share.share(
                          appState.gameShareableUrl ?? "https://dailytrojan.com/games");
                    },
                    padding: EdgeInsets.all(12.0),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert_sharp),
                    onPressed: () {},
                    padding: EdgeInsets.all(12.0),
                  ),
                ],
              ),
            ]),
          ),
        ));
  }
}
