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
  int _refreshKey = 0;

  Future<List<Post>> loadBookmarks() async {
    List<dynamic> bookmarks = BookmarkService.getAllBookmarks();
    if (bookmarks.isEmpty) {
      return [];
    }
    return await fetchPostsByIds(bookmarks);
  }

  void handleBookmarkChanged() {
    setState(() {
      _refreshKey++;

    });
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
        actions: [NavigationBarAccountButton()],
        backButton: false,
        children: [
          FutureBuilder<List<Post>>(
            key: ValueKey(_refreshKey),
            future: loadBookmarks(),
            builder: (context, snapshot) {
                            print('📦 FutureBuilder building, hasData: ${snapshot.hasData}');

              if (!snapshot.hasData) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final posts = snapshot.data!;
              if (posts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text("No bookmarks yet!", style: subStyle),
                  ),
                );
              }

              return Column(
                children: [
                  for (var post in posts)
                    Column(
                      children: [
                        PostElementUltimate(post: post, dek: true, rightImage: true, publishDate: true, bookmarkShare: true,
                          onBookmarkChanged: handleBookmarkChanged,),
                        Padding(
                          padding: horizontalContentPadding,
                          child: Divider(
                            height: 1,
                          ),
                        )
                      ],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}