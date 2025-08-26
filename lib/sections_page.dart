import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/main_section_route.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:dailytrojan/section_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SectionsPage extends StatefulWidget {
  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.displaySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedTitleScrollView(
        title: Text(
          "Sections",
          style: headerStyle,
        ),
        actions: [
          NavigationBarAccountButton()
        ],
        backButton: false,
        children: [SectionsList()],
      ),
    );
  }
}
