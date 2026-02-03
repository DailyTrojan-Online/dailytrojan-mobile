import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/section_route.dart';
import 'package:dailytrojan/utility.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

WebViewEnvironment? webViewEnvironment;

class SettingsRoute extends StatelessWidget {
  var debugStrings = DebugService.getAllDebugStrings();

  void openThemeDialog() async {}
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);
    final dialogHeaderStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.bold,
        height: .8);
    final subStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onSurface, fontFamily: "Inter");
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: AnimatedTitleScrollView(
          collapsingSliverAppBar: CollapsingSliverAppBar(
            backgroundColor: theme.colorScheme.surfaceContainerLowest,
            title: Text(
              "Settings",
              style: headerStyle,
            ),
          ),
          children: [
            SettingsButton(
                onTap: () {
                  showDialog<ThemeMode>(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          title: Text('Theme', style: dialogHeaderStyle),
                          children: <Widget>[
                            RadioGroup(
                          groupValue: appState.themeMode,
                                onChanged: (ThemeMode? value) {
                                  Navigator.pop(context );
                                  appState.setThemeMode(value ?? ThemeMode.system);
                                },
                                child: Column(children: [
                                  RadioListTile<ThemeMode>(title: Text("System Default"), value: ThemeMode.system),
                                  RadioListTile<ThemeMode>(title: Text("Dark"), value: ThemeMode.dark),
                                  RadioListTile<ThemeMode>(title: Text("Light"), value: ThemeMode.light),
                                ])),
                          ],
                        );
                      });
                },
                showArrow: false,
                icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
                text: "Theme"),
            Padding(
              padding: horizontalContentPadding,
              child: Divider(height: 1),
            ),
            SettingsButton(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideOverPageRoute(child: NotificationsSettingsRoute()),
                  );
                },
                icon: Icons.notifications,
                text: "Notifications"),
            Padding(
              padding: horizontalContentPadding,
              child: Divider(height: 1),
            ),
            SettingsButton(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideOverPageRoute(child: AppInfoRoute()),
                  );
                },
                icon: Icons.info_outline,
                text: "App Info"),
          ]),
    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton(
      {super.key, required this.onTap, required this.text, required this.icon, this.showArrow = true});

  final VoidCallback onTap;
  final String text;
  final IconData icon;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);
    final subStyle = theme.textTheme.titleMedium!
        .copyWith(color: theme.colorScheme.onSurface, fontFamily: "Inter");
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0)
            .add(horizontalContentPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  icon,
                  color: theme.colorScheme.onSurface,
                ),
                Text(
                  text,
                  style: subStyle,
                ),
              ],
            ),
            if(this.showArrow)
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
            )
          ],
        ),
      ),
    );
  }
}

class NotificationsSettingsRoute extends StatelessWidget {
  List<Post> sectionPosts = [];

  int sectionID = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);

    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: Placeholder(),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        surfaceTintColor: theme.colorScheme.surfaceContainerLowest,
        title: Text(
          "Notifications",
          style: headlineStyle,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.outlineVariant,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

class AppInfoRoute extends StatelessWidget {

  List<Post> sectionPosts = [];

  int sectionID = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);

    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: Placeholder(),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        surfaceTintColor: theme.colorScheme.surfaceContainerLowest,
        title: Text(
          "App Information",
          style: headlineStyle,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.outlineVariant,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
