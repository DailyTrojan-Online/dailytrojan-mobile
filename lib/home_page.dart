import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
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
  int perCategoryPostCount = 5;
  late Future<void> _initPostData;
  @override
  void initState() {
    super.initState();
    _initPostData = initPosts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.displaySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    return Scaffold(
        body: SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: refreshPosts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: verticalContentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0)
                      .add(horizontalContentPadding),
                  child: Text(
                    DateFormat.yMMMMd().format(DateTime.now()),
                    style: headlineStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
                FutureBuilder(
                  future: _initPostData,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return Center(child: const CircularProgressIndicator());
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
              ],
            ),
          ),
        ),
      ),
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
        SectionHeader(title: "Arts & Entertainment"),
        SectionPostArrangement(posts: artsEntertainmentPosts),
        SectionHeader(title: "Sports"),
        SectionPostArrangement(posts: sportsPosts),
        SectionHeader(title: "Opinion"),
        SectionPostArrangement(posts: opinionPosts)
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
        for (int i = 0; i < orderedPosts.length; i++)
          Column(
            children: [
              (i % 3 == 0)
                  ? PostElementImageLarge(post: orderedPosts[i])
                  : PostElement(post: orderedPosts[i]),
              (i != orderedPosts.length - 1)
                  ? Padding(
                      padding: horizontalContentPadding,
                      child: Divider(height: 1),
                    )
                  : EmptyWidget()
            ],
          ),
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
        fontFamily: "SourceSerif4",
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
