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

class _AccountRouteState extends StatefulScrollControllerRoute<AccountRoute>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  List<Post> bookmarkedPosts = [];

  int _refreshKey = 0;

  bool noBookmarks = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

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

    const tabHeight = 36.0;
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    final bottomPaddingPadding = EdgeInsets.only(bottom: bottomPadding).add(bottomAppBarPadding);

    return Scaffold(
        body: NestedScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverOverlapAbsorber(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          sliver: CollapsingSliverAppBar(
            shouldClipPadding: false,
            backgroundColor: theme.colorScheme.surface,
            shouldShowBorder: false,
            title: Text(
              "Saved",
              style: headerStyle,
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(tabHeight),
              child: Column(
                children: [
                  Divider(
                    height: 1,
                  ),
                  TabBar(
                    controller: _tabController,
                    tabs: const <Widget>[
                      Tab(text: "Bookmarks", height: tabHeight),
                      Tab(text: "History", height: tabHeight),
                    ],
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.settings),
                  ))
            ],
          ),
        )
      ],
      body: TabBarView(controller: _tabController, children: [
        Builder(
          builder: (context) => FutureBuilder(
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
                    return CustomScrollView(
                        key: PageStorageKey<String>("bookmarks"),
                        slivers: [
                          SliverOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                          ),
                          SliverPadding(
                            padding: bottomPaddingPadding,
                            sliver: SliverList.builder(
                                itemBuilder: (context, index) {
                                  var post = bookmarkedPosts[index];
                                  return Column(
                                    children: [
                                      PostElementUltimate(
                                          post: post,
                                          dek: true,
                                          rightImage: true,
                                          publishDate: true,
                                          bookmarkShare: true,
                                          onBookmarkChanged:
                                              handleBookmarkChanged),
                                      Padding(
                                        padding: horizontalContentPadding,
                                        child: Divider(
                                          height: 1,
                                        ),
                                      )
                                    ],
                                  );
                                },
                                itemCount: bookmarkedPosts.length),
                          )
                        ]);
                  }
              }
            },
          ),
        ),
        Builder(
          builder: (context) => CustomScrollView(
              key: PageStorageKey<String>("history"),
              slivers: [
                SliverOverlapInjector(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                ),
                SliverPadding(
                  padding: bottomPaddingPadding,
                  sliver: SliverList.builder(
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            PostElementUltimate(
                                post: Post.skeleton(),
                                dek: true,
                                rightImage: false,
                                publishDate: true,
                                bookmarkShare: true,
                                onBookmarkChanged: handleBookmarkChanged),
                            Padding(
                              padding: horizontalContentPadding,
                              child: Divider(
                                height: 1,
                              ),
                            )
                          ],
                        );
                      }),
                )
              ]),
        ),
      ]),
    ));
  }
}

class SlimTabBar extends TabBar {
  final double height;
  SlimTabBar(this.height,
      {required super.tabs, required super.controller, super.key})
      : super(
          indicatorSize: TabBarIndicatorSize.label,
          labelPadding: EdgeInsets.zero,
        );
  @override
  Size get preferredSize {
    return Size.fromHeight(height);
  }
}
