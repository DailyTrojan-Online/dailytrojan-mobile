import 'dart:convert';

import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:dailytrojan/scroll_physics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

int perCategoryPostCount = 6;

class _HomePageState extends State<HomePage> {
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  List<Post> posts = [];
  List<Post> newsPosts = [];
  List<Post> artsEntertainmentPosts = [];
  List<Post> sportsPosts = [];
  List<Post> opinionPosts = [];

  bool newsDoneLoading = false;
  bool artsEntertainmentDoneLoading = false;
  bool sportsDoneLoading = false;
  bool opinionDoneLoading = false;
  @override
  void initState() {
    super.initState();
    initPosts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14.0,
        fontFamily: "Inter");
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: refreshPosts,
          child: AnimatedTitleScrollView(
              backButton: false,
              title: SvgPicture.asset(
                "assets/logo/logo.svg",
                height: 30,
                color: theme.colorScheme.onSurface,
              ),
              actions: [NavigationBarAccountButton()],
              bottomPaddingCollapsed: 12,
              bottomPaddingExpanded: 10,
              children: [
                Padding(
                  padding: horizontalContentPadding
                      .add(EdgeInsets.only(top: 10, bottom: 6)),
                  child: Text(
                    DateFormat('MMMM d, y').format(DateTime.now()),
                    style: subStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
                Padding(
                    padding: bottomAppBarPadding,
                    child: Column(
                      children: [
                        SectionPostArrangement(
                            posts: newsPosts, doneLoading: newsDoneLoading),
                        SectionHeader(title: "Trending Articles"),
                        TrendingArticleList(),
                        SectionHeader(title: "Sports"),
                        SectionPostArrangement(
                            posts: sportsPosts, doneLoading: sportsDoneLoading),
                        ColumnistHorizontalLayout(section: "sports"),
                        SectionHeader(title: "Arts & Entertainment"),
                        SectionPostArrangement(
                            posts: artsEntertainmentPosts,
                            doneLoading: artsEntertainmentDoneLoading),
                        ColumnistHorizontalLayout(section: "arts_entertainment"),
                        SectionHeader(title: "Opinion"),
                        SectionPostArrangement(
                            posts: opinionPosts,
                            doneLoading: opinionDoneLoading),
                        ColumnistHorizontalLayout(section: "opinion"),
                        SectionHeader(title: "Games"),
                        Padding(
                            padding: horizontalContentPadding,
                            child: ResponsiveGrid(breakpoint: 600, children: [
                              for (int i = 0; i < Games.length; i++)
                                GameBrick(game: Games[i]),
                            ]))
                      ],
                    )),
              ]),
        ));
  }

  Future<void> initPosts() async {
    newsPosts =
        await fetchPostsWithMainCategoryAndCount(NewsID, perCategoryPostCount, includeColumns: false);
    if (!mounted) return;
    setState(() {
      newsDoneLoading = true;
    });
    artsEntertainmentPosts = await fetchPostsWithMainCategoryAndCount(
        ArtsEntertainmentID, perCategoryPostCount, includeColumns: false);
    if (!mounted) return;
    setState(() {
      artsEntertainmentDoneLoading = true;
    });
    opinionPosts = await fetchPostsWithMainCategoryAndCount(
        OpinionID, perCategoryPostCount, includeColumns: false);
    if (!mounted) return;
    setState(() {
      opinionDoneLoading = true;
    });
    sportsPosts = await fetchPostsWithMainCategoryAndCount(
        SportsID, perCategoryPostCount, includeColumns: false);
    if (!mounted) return;
    setState(() {
      sportsDoneLoading = true;
    });
  }

  Future<void> refreshPosts() async {
    newsDoneLoading = false;
    artsEntertainmentDoneLoading = false;
    sportsDoneLoading = false;
    opinionDoneLoading = false;
    await initPosts();
    setState(() {});
  }
}

class ColumnistHorizontalLayout extends StatefulWidget {
  const ColumnistHorizontalLayout({
    super.key,
    required this.section,
  });

  final String section;

  @override
  State<ColumnistHorizontalLayout> createState() =>
      _ColumnistHorizontalLayoutState();
}

class _ColumnistHorizontalLayoutState extends State<ColumnistHorizontalLayout> {
  List<(Columnist, Post)> columnistPosts = [];
  @override
  void initState() {
    super.initState();
    getColumnists();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(padding: horizontalContentPadding, child: Divider(height: 1)),
        ResponsiveHorizontalScrollView(
          rowCount: 1,
          columnSubtractor: 50,
          horizontalDivider: false,
          verticalDivider: true,
          children: [
            for(int i = 0; i < columnistPosts.length; i++)PostElementUltimate(post: columnistPosts[i].$2, columnByline: columnistPosts[i].$1.byline, columnName: columnistPosts[i].$1.title, columnPhoto: columnistPosts[i].$1.image,),
            ],
        ),
      ],
    );
  }

  Future<void> getColumnists() async {
    print('a');
    final url =
        Uri.parse('${API_BASE_URL}app/columns?section=${widget.section}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print(response.body);
      List<Columnist> columnists = [];
      for (var column in jsonDecode(response.body)) {
        columnists.add(Columnist.fromJson(column));
      }
      //get latest post for each columnist and future.wait them all at once and it returns a type of List<Post>
      List<Future<List<Post>>> postFutures = [];
      for (var columnist in columnists) {
        postFutures.add(fetchPostsWithMainCategoryAndCount(columnist.tag_id, 1));
      }
      List<List<Post>> latestPosts = await Future.wait(postFutures);
      print(latestPosts);
      columnistPosts = [];
      for (int i = 0; i < columnists.length; i++) {
        if (latestPosts[i].isNotEmpty) {
          columnistPosts.add((columnists[i], latestPosts[i][0]));
        }
      }
      print(columnistPosts.length);
      setState(() {});

    } else {
      throw Exception('Failed to load columns');
    }
  }
}

List<Post> orderPostByFeatureAndColumn(List<Post> posts) {
  // return posts;
  List<Post> orderedPosts = [];
  List<Post> mainFeaturePosts = [];
  List<Post> otherPosts = [];
  List<Post> columnPosts = [];
  bool mainFeatureAdded = false;
  for (int i = 0; i < posts.length; i++) {
    if (posts[i].isMainFeature && !mainFeatureAdded) {
      mainFeatureAdded = true;
      mainFeaturePosts.add(posts[i]);
    } else if (posts[i].isColumn) {
      columnPosts.add(posts[i]);
    } else {
      otherPosts.add(posts[i]);
    }
  }
  orderedPosts.addAll(mainFeaturePosts);
  orderedPosts.addAll(otherPosts);
  orderedPosts.addAll(columnPosts);
  return orderedPosts;
}

class SectionPostArrangement extends StatelessWidget {
  const SectionPostArrangement(
      {super.key, required this.posts, required this.doneLoading});

  final List<Post> posts;
  final bool doneLoading;

  @override
  Widget build(BuildContext context) {
    if (!doneLoading) {
      for (int i = 0; i < perCategoryPostCount; i++) {
        posts.add(Post.skeleton());
      }
    }
    final List<Post> orderedPosts = orderPostByFeatureAndColumn(posts);
    return Skeletonizer(
      enabled: !doneLoading,
      child: Column(
        children: [
          HomePagePostLayoutElement(posts: orderedPosts.take(2).toList()),
          Padding(
            padding: horizontalContentPadding,
            child: Divider(height: 1),
          ),
          TwoColumnBreakpoint(
            separator: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: VerticalDivider(width: 1),
            ),
            singleColumnChild: Column(
              children: [
                PostElementUltimate(post: orderedPosts[2], byline: true),
                Padding(
                  padding: horizontalContentPadding,
                  child: Divider(height: 1),
                ),
                PostElementUltimate(post: orderedPosts[3], byline: true),
              ],
            ),
            leftColumnChild:
                PostElementUltimate(post: orderedPosts[2], byline: true),
            rightColumnChild:
                PostElementUltimate(post: orderedPosts[3], byline: true),
          ),
          Padding(
            padding: horizontalContentPadding,
            child: Divider(height: 1),
          ),
          HomePagePostLayoutElement(
              posts: orderedPosts.skip(4).take(2).toList()),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.primary,
        fontFamily: "Inter",
        fontWeight: FontWeight.bold);
    return Padding(
      padding: horizontalContentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            thickness: 2,
            height: 2,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              title.toUpperCase(),
              style: headlineStyle,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}
