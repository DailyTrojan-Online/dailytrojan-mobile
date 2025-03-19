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

class BookmarksPage extends StatefulWidget {
  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Post> bookmarkedPosts = [];


  Future<void> initBookmarks() async {
    List<dynamic> bookmarks = BookmarkService.getAllBookmarks();
    bookmarkedPosts = await fetchPostsByIds(bookmarks);
  }

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
                    'Bookmarks',
                    style: headlineStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                    padding: horizontalContentPadding
                        .subtract(EdgeInsets.symmetric(horizontal: 8)),
                    child: FutureBuilder(
                      future: initBookmarks(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            return Center(
                                child: const CircularProgressIndicator());
                          case ConnectionState.done:
                            {
                              return Column(children: [
                                for (var post in bookmarkedPosts)
                                  Column(
                                    children: [
                                      PostElementImage(post: post),
                                      Padding(
                                        padding: horizontalContentPadding,
                                        child: Divider(
                                          height: 1,
                                        ),
                                      )
                                    ],
                                  ),
                              ]);
                            }
                        }
                      },
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
