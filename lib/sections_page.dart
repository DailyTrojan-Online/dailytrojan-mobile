import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/ui_styles.dart';
import 'package:flutter/material.dart';

class SectionsPage extends StatefulWidget {
  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = UiStyles.heading(theme);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedTitleScrollView(
        collapsingSliverAppBar: CollapsingSliverAppBar(
          title: Text(
            "Sections",
            style: headerStyle,
          ),
          actions: [NavigationBarAccountButton()],
        ),
        children: [SectionsList()],
      ),
    );
  }
}
