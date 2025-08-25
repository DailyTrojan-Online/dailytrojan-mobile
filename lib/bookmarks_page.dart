import 'dart:async';
import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookmarksPage extends StatefulWidget {
  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Post> bookmarkedPosts = [];
  bool noBookmarks = false;


  Future<void> initBookmarks() async {
    List<dynamic> bookmarks = BookmarkService.getAllBookmarks();
    if (bookmarks.isEmpty) {
      noBookmarks = true;
      return;
    }
    bookmarkedPosts = await fetchPostsByIds(bookmarks);
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);
    final subStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onSurfaceVariant, fontFamily: "Inter");


    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedTitleScrollView(
        title: Text(
          "Saved",
          style: headerStyle,
        ),
        backButton: false,
        children: [
          FutureBuilder(
          future: initBookmarks(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Center(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: const CircularProgressIndicator(),
                    ));
              case ConnectionState.done:
                {
                  if(noBookmarks) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Text("No bookmarks yet!", style: subStyle),
                      ),
                    );
                  }
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
        ),]
      ),
    );
  }
}
