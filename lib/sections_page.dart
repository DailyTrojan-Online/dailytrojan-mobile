import 'package:dailytrojan/components.dart';
import 'package:flutter/material.dart';

class SectionsPage extends StatefulWidget {
  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
