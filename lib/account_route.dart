import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:dailytrojan/utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AccountRoute extends StatefulWidget {
  @override
  State<AccountRoute> createState() => _AccountRouteState();
}

class _AccountRouteState extends StatefulScrollControllerRoute<AccountRoute> {
  List<Post> bookmarkedPosts = [];

  int _refreshKey = 0;

  bool noBookmarks = false;

  Future<void> initBookmarks() async {
    List<dynamic> bookmarks = BookmarkService.getAllBookmarks();
    if (bookmarks.isEmpty) {
      noBookmarks = true;
      return;
    }
    bookmarkedPosts = await fetchPostsByIds(bookmarks);
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
    final subStyle = theme.textTheme.titleSmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant, fontFamily: "Inter");

    return Scaffold(
      body: AnimatedTitleScrollView(
        title: Text(
          "Saved",
          style: headerStyle,
        ),
        backButton: false,
        actions: [
          Padding(
              padding: EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.settings),
              ))
        ],
        children: [
          FutureBuilder(
            key: ValueKey(_refreshKey),
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
                    if (noBookmarks) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Text("No bookmarks yet!", style: subStyle),
                        ),
                      );
                    }
                    return Padding(
                      padding: bottomAppBarPadding,
                      child: Column(children: [
                        for (var post in bookmarkedPosts)
                          Column(
                            children: [
                              PostElementUltimate(
                                post: post,
                                dek: true,
                                rightImage: true,
                                publishDate: true,
                                bookmarkShare: true,
                                onBookmarkChanged: handleBookmarkChanged
                              ),
                              Padding(
                                padding: horizontalContentPadding,
                                child: Divider(
                                  height: 1,
                                ),
                              )
                            ],
                          ),
                      ]),
                    );
                  }
              }
            },
          ),
        ],
      ),
    );
  }
}
