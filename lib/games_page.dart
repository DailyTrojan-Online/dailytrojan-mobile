import 'dart:async';
import 'dart:convert';
import 'package:dailytrojan/game_route.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
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
        
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: verticalContentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0)
                      .add(horizontalContentPadding),
                  child: Text(
                    'Games',
                    style: headlineStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                    padding: horizontalContentPadding
                        .subtract(EdgeInsets.symmetric(horizontal: 8)),
                    child: ResponsiveGridRow(
                      children: [
                        ResponsiveGridCol(
                          xs: 12,
                          sm: 6,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Material(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.colorScheme.surfaceContainer,
                              child: InkWell(
                                onTap: () {
                                  appState.setGameUrl("http://localhost:8080/bandle/index.html");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GameRoute(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: SvgPicture.asset(
                                        "games/bandle/imgs/bandle.svg",
                                        height: 70,
                                        width: 70,
                                      ),
                                    ),
                                    Text(
                                      "Bandle",
                                      style: titleStyle,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 12.0),
                                      child: Text(
                                        "Guess the song played by the Trojan Marching Band",
                                        style: subStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: FractionallySizedBox(
                                        widthFactor: 0.8,
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
                            ),
                          ),
                        ),
                      
                        ResponsiveGridCol(
                          xs: 12,
                          sm: 6,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: Material(
                              borderRadius: BorderRadius.circular(8),
                              color: theme.colorScheme.surfaceContainer,
                              child: InkWell(
                                onTap: () {
                                  appState.setGameUrl("http://localhost:8080/spelling-beads/index.html");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GameRoute(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: SvgPicture.asset(
                                        "games/spelling-beads/imgs/spelling_beads.svg",
                                        height: 70,
                                        width: 70,
                                      ),
                                    ),
                                    Text(
                                      "Spelling Beads",
                                      style: titleStyle,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0, vertical: 12.0),
                                      child: Text(
                                        "Find as many words as you can, as fast as you can",
                                        style: subStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: FractionallySizedBox(
                                        widthFactor: 0.8,
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
                            ),
                          ),
                        ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
