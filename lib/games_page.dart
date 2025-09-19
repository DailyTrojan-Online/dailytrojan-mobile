import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/game_route.dart';
import 'package:dailytrojan/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';

class GamesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.displaySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final titleStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final buttonStyle = theme.textTheme.titleMedium!.copyWith(
        fontFamily: "Inter",
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.bold);

    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14.0,
        fontFamily: "SourceSerif4");
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedTitleScrollView(
          title: Text(
            "Games",
            style: headerStyle,
          ),
        actions: [
          NavigationBarAccountButton()
        ],
          backButton: false,
          children: [
            Padding(
              padding: horizontalContentPadding.add(EdgeInsets.only(top: 16)),
              child: ResponsiveGrid(children: [
                for (int i = 0; i < Games.length; i++)
                  GameTile(game: Games[i]),
              ]),
            ),
          ]),
    );
  }
}
