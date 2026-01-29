import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:dailytrojan/settings_route.dart';
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
  List<Post> historyPosts = [];


  late Future<void> _bookmarkFuture;
  late Future<void> _historyFuture;

  int _refreshKey = 0;

  bool noBookmarks = false;

  @override
  void initState() {
    super.initState();
    _bookmarkFuture = initBookmarks();
    _historyFuture = initHistory();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> initBookmarks() async {
    List<dynamic> bookmarks = BookmarkService.getAllBookmarks();
    //remove empty strings
    bookmarks.removeWhere((element) => element.toString().isEmpty);
    if (bookmarks.isEmpty) {
      noBookmarks = true;
      return;
    }
    bookmarkedPosts = await fetchPostsByIds(bookmarks);
    bookmarkedPosts.sort((a, b) =>
        bookmarks.indexOf(a.id.toString()) - bookmarks.indexOf(b.id.toString()));
  }

  Future<void> initHistory() async {
    List<dynamic> history = HistoryService.getAllHistory();
    print(history.length);
    history.removeWhere((element) => element.toString().isEmpty);
    print(history.length);
    if (history.isEmpty) {
      return;
    }
    print(history);
    historyPosts = await fetchPostsByIds(history);
    print(historyPosts.map((e)=>{e.id}).toList());
    historyPosts.sort((a, b) =>
        history.indexOf(a.id.toString()) - history.indexOf(b.id.toString()));
  }

  void handleBookmarkChanged(String id) {
    setState(() {
      bookmarkedPosts.removeWhere((post) => post.id.toString() == id);
      if(bookmarkedPosts.isEmpty) {
        noBookmarks = true;
      }
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
                    onPressed: () {

            Navigator.push(
              context,
              SlideOverPageRoute(child: SettingsRoute()),
            );
                    },
                    icon: Icon(Icons.settings),
                  ))
            ],
          ),
        )
      ],
      body: TabBarView(controller: _tabController, children: [
        Builder(
          builder: (context) => FutureBuilder(
            future: _bookmarkFuture,
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
                    if (bookmarkedPosts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Text("No bookmarks.", style: subStyle),
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
          builder: (context) => FutureBuilder(
            future: _historyFuture,
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
                    if (historyPosts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Text("No history.", style: subStyle),
                        ),
                      );
                    }
                    return CustomScrollView(
                        key: PageStorageKey<String>("history"),
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
                                  var post = historyPosts[index];
                                  return Column(
                                    children: [
                                      PostElementUltimate(
                                          post: post,
                                          dek: true,
                                          rightImage: true,
                                          publishDate: true,
                                          bookmarkShare: true,),
                                      Padding(
                                        padding: horizontalContentPadding,
                                        child: Divider(
                                          height: 1,
                                        ),
                                      )
                                    ],
                                  );
                                },
                                itemCount: historyPosts.length),
                          )
                        ]);
                  }
              }
            },
          ),
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
