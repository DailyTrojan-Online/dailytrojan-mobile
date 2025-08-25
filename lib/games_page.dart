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
          backButton: false,
          children: [
            Padding(
              padding: horizontalContentPadding.add(EdgeInsets.only(top: 16)),
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                double maxWidth = constraints.maxWidth;
              
                // Set tile width based on screen width
                double tileWidth = maxWidth > 500
                    ? (maxWidth / 2) - 8 // Two columns, with spacing
                    : maxWidth; // One column on small screens
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(
                      width: tileWidth,
                      child: GameTile(
                          onTap: () {
                            appState.setGameUrl(
                                "http://localhost:8080/troydle/index.html");
                            appState.setGameShareableUrl(
                                "https://dailytrojan-online.github.io/troydle/");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameRoute(),
                              ),
                            );
                          },
                          color: Color(0xFF990000),
                          gameTitle: "Troydle",
                          gameDescription:
                              "Guess the song played by the Trojan Marching Band.",
                          gameImage: "games/troydle/imgs/troydle.svg"),
                    ),
                    SizedBox(
                      width: tileWidth,
                      child: GameTile(
                          color: Color(0xFFFFCC00),
                          onTap: () {
                            appState.setGameUrl(
                                "http://localhost:8080/spelling-beads/index.html");
                            appState.setGameShareableUrl(
                                "https://dailytrojan-online.github.io/spelling-beads/");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameRoute(),
                              ),
                            );
                          },
                          gameTitle: "Spelling Beads",
                          gameDescription:
                              "Find as many words as you can, as fast as you can.",
                          gameImage:
                              "games/spelling-beads/imgs/spelling_beads.svg"),
                    )
                  ],
                );
              }),
            ),
          ]),
    );
  }
}

class GameTile extends StatelessWidget {
  final String gameTitle;
  final String gameDescription;
  final String gameImage;
  final GestureTapCallback onTap;
  final Color color;
  const GameTile({
    super.key,
    required this.gameTitle,
    required this.gameDescription,
    required this.gameImage,
    required this.onTap,
    this.color = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.displaySmall!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final titleStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final buttonStyle = theme.textTheme.titleMedium!.copyWith(
        fontFamily: "Inter",
        color: theme.colorScheme.onPrimaryFixed,
        fontWeight: FontWeight.bold);

    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 14.0,
        fontFamily: "SourceSerif4");
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: this.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Padding(
              padding: (EdgeInsets.only(bottom: 16)),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8))
                ),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      this.gameImage,
                      height: 70,
                      width: 70,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              this.gameTitle,
              style: titleStyle,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                this.gameDescription,
                style: subStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: 150,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "PLAY",
                      style: buttonStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
