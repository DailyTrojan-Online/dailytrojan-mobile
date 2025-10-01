import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  List<Post> posts = [];
  List<Post> newsPosts = [];
  List<Post> artsEntertainmentPosts = [];
  List<Post> sportsPosts = [];
  List<Post> opinionPosts = [];
  int perCategoryPostCount = 6;
  late Future<void> _initPostData;
  @override
  void initState() {
    super.initState();
    _initPostData = initPosts();
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
                  child: FutureBuilder(
                    future: _initPostData,
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
                            return MainPagePostArrangement(
                                newsPosts: newsPosts,
                                artsEntertainmentPosts: artsEntertainmentPosts,
                                sportsPosts: sportsPosts,
                                opinionPosts: opinionPosts);
                          }
                      }
                    },
                  ),
                ),
              ]),
        ));
  }

  Future<void> initPosts() async {
    newsPosts =
        await fetchPostsWithMainCategoryAndCount(NewsID, perCategoryPostCount);
    artsEntertainmentPosts = await fetchPostsWithMainCategoryAndCount(
        ArtsEntertainmentID, perCategoryPostCount);
    opinionPosts = await fetchPostsWithMainCategoryAndCount(
        OpinionID, perCategoryPostCount);
    sportsPosts = await fetchPostsWithMainCategoryAndCount(
        SportsID, perCategoryPostCount);
  }

  Future<void> refreshPosts() async {
    await initPosts();
    setState(() {});
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

class MainPagePostArrangement extends StatelessWidget {
  const MainPagePostArrangement(
      {super.key,
      required this.newsPosts,
      required this.artsEntertainmentPosts,
      required this.sportsPosts,
      required this.opinionPosts});

  final List<Post> newsPosts;
  final List<Post> artsEntertainmentPosts;
  final List<Post> sportsPosts;
  final List<Post> opinionPosts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionPostArrangement(posts: newsPosts),
        SectionHeader(title: "Trending Articles"),
        TrendingArticleList(),
        SectionHeader(title: "Arts & Entertainment"),
        SectionPostArrangement(posts: artsEntertainmentPosts),
        SectionHeader(title: "Sports"),
        SectionPostArrangement(posts: sportsPosts),
        SectionHeader(title: "Opinion"),
        SectionPostArrangement(posts: opinionPosts),
        SectionHeader(title: "Games"),
        Padding(
            padding: horizontalContentPadding,
            child: ResponsiveGrid(breakpoint: 600, children: [
              for (int i = 0; i < Games.length; i++) GameBrick(game: Games[i]),
            ]))
      ],
    );
  }
}

class SectionPostArrangement extends StatelessWidget {
  const SectionPostArrangement({super.key, required this.posts});

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    final List<Post> orderedPosts = orderPostByFeatureAndColumn(posts);
    return Column(
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
                PostElement(post: posts[2]),
                Padding(
                  padding: horizontalContentPadding,
                  child: Divider(height: 1),
                ),
                PostElement(post: posts[3]),
              ],
            ),
            leftColumnChild: PostElementSmall(post: posts[2]),
            rightColumnChild: PostElementSmall(post: posts[3])),
        Padding(
          padding: horizontalContentPadding,
          child: Divider(height: 1),
        ),
        HomePagePostLayoutElement(posts: orderedPosts.skip(4).take(2).toList()),
      ],
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
