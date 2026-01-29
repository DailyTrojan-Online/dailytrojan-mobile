import 'package:dailytrojan/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

WebViewEnvironment? webViewEnvironment;

class SettingsRoute extends StatelessWidget {
  var debugStrings = DebugService.getAllDebugStrings();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            for (var (key, value) in debugStrings)
              ListTile(
                title: Text(key),
                subtitle: Text(value),
              ),
          ],
        ),
      ),
    );
  }
}
