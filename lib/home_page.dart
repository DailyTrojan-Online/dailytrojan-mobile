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

  List<(Columnist, Post)> sportsColumnists = [];
  List<(Columnist, Post)> artsEntertainmentColumnists = [];
  List<(Columnist, Post)> opinionColumnists = [];

  bool newsDoneLoading = false;
  bool artsEntertainmentDoneLoading = false;
  bool aeColumnsDoneLoading = false;
  bool sportsDoneLoading = false;
  bool sportsColumnsDoneLoading = false;
  bool opinionDoneLoading = false;
  bool opinionColumnsDoneLoading = false;
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
            collapsingSliverAppBar: CollapsingSliverAppBar(
              title: SvgPicture.asset(
                "assets/logo/logo.svg",
                height: 30,
                color: theme.colorScheme.onSurface,
              ),
              actions: [NavigationBarAccountButton()],
              bottomPaddingCollapsed: 12,
              bottomPaddingExpanded: 10),
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
                        ColumnistHorizontalLayout(
                            columnistPosts: sportsColumnists,
                            doneLoading: sportsColumnsDoneLoading),
                        SectionHeader(title: "Arts & Entertainment"),
                        SectionPostArrangement(
                            posts: artsEntertainmentPosts,
                            doneLoading: artsEntertainmentDoneLoading),
                        ColumnistHorizontalLayout(
                          columnistPosts: artsEntertainmentColumnists,
                          doneLoading: aeColumnsDoneLoading,
                        ),
                        SectionHeader(title: "Opinion"),
                        SectionPostArrangement(
                            posts: opinionPosts,
                            doneLoading: opinionDoneLoading),
                        ColumnistHorizontalLayout(
                            columnistPosts: opinionColumnists,
                            doneLoading: opinionColumnsDoneLoading),
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

  Future<void> initPosts({bool retried = false}) async {
    try {
      newsPosts = await fetchPostsWithMainCategoryAndCount(
          NewsID, perCategoryPostCount,
          includeColumns: false);
      if (!mounted) return;
      setState(() {
        newsDoneLoading = true;
      });
      sportsPosts = await fetchPostsWithMainCategoryAndCount(
          SportsID, perCategoryPostCount,
          includeColumns: false);
      if (!mounted) return;
      setState(() {
        sportsDoneLoading = true;
      });
      sportsColumnists = await getColumnists("sports");
      if (!mounted) return;
      setState(() {
        sportsColumnsDoneLoading = true;
      });
      artsEntertainmentPosts = await fetchPostsWithMainCategoryAndCount(
          ArtsEntertainmentID, perCategoryPostCount,
          includeColumns: false);
      if (!mounted) return;
      setState(() {
        artsEntertainmentDoneLoading = true;
      });
      artsEntertainmentColumnists = await getColumnists("arts_entertainment");
      if (!mounted) return;
      setState(() {
        aeColumnsDoneLoading = true;
      });
      opinionPosts = await fetchPostsWithMainCategoryAndCount(
          OpinionID, perCategoryPostCount,
          includeColumns: false);
      if (!mounted) return;
      setState(() {
        opinionDoneLoading = true;
      });
      opinionColumnists = await getColumnists("opinion");
      if (!mounted) return;
      setState(() {
        opinionColumnsDoneLoading = true;
      });
    } catch (e) {
      if (!retried) {
        await initPosts(retried: true);
      }
    }
  }

  Future<void> refreshPosts() async {
    newsDoneLoading = false;
    artsEntertainmentDoneLoading = false;
    sportsDoneLoading = false;
    opinionDoneLoading = false;
    sportsColumnsDoneLoading = false;
    aeColumnsDoneLoading = false;
    opinionColumnsDoneLoading = false;

    await initPosts();
    setState(() {});
  }
}

class ColumnistHorizontalLayout extends StatelessWidget {
  const ColumnistHorizontalLayout({
    super.key,
    required this.columnistPosts,
    required this.doneLoading,
  });

  final List<(Columnist, Post)> columnistPosts;
  final bool doneLoading;

  @override
  Widget build(BuildContext context) {
    if(!doneLoading){
      for (int i = 0; i < columnistPosts.length; i++) {
        columnistPosts.add((Columnist.skeleton(), Post.skeleton()));
      }
    }
    columnistPosts.sort((a,b) {
      DateTime aDate = DateTime.parse(a.$2.date);
      DateTime bDate = DateTime.parse(b.$2.date);
      return bDate.compareTo(aDate);
    });
    return Skeletonizer(
      enabled: !doneLoading,
      child: Column(
        children: [
          Padding(padding: horizontalContentPadding, child: Divider(height: 1)),
          ResponsiveHorizontalScrollView(
            rowCount: 1,
            columnSubtractor: 50,
            horizontalDivider: false,
            verticalDivider: true,
            children: [
              for (int i = 0; i < columnistPosts.length; i++)
                PostElementUltimate(
                  post: columnistPosts[i].$2,
                  columnByline: columnistPosts[i].$1.byline,
                  columnName: columnistPosts[i].$1.title,
                  columnPhoto: columnistPosts[i].$1.image,
                ),
            ],
          ),
        ],
      ),
    );
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
