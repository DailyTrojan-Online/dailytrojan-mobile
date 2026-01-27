import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/game_route.dart';
import 'package:dailytrojan/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedTitleScrollView(
          collapsingSliverAppBar: CollapsingSliverAppBar(
            title: Text(
              "Games",
              style: headerStyle,
            ),
            actions: [NavigationBarAccountButton()],
          ),
          children: [
            Padding(
              padding: horizontalContentPadding
                  .add(EdgeInsets.only(top: 16))
                  .add(bottomAppBarPadding),
              child: ResponsiveGrid(children: [
                for (int i = 0; i < Games.length; i++) GameTile(game: Games[i]),
              ]),
            ),
          ]),
    );
  }
}
