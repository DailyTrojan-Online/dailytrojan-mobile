import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  List<Post> posts = [];
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
        color: theme.colorScheme.primary,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    return Scaffold(
        body: FutureBuilder(
      future: _initPostData,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return Center(child: const CircularProgressIndicator());
          case ConnectionState.done:
            {
              return SafeArea(
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
                            MainPagePostArrangement(posts: posts),
                          ],
                        ),
                      ),
                    )),
              );
            }
        }
      },
    ));
  }

  Future<void> initPosts() async {
    posts = await fetchPosts();
  }

  Future<void> refreshPosts() async {
    await initPosts();
    setState(() {});
  }
}

class MainPagePostArrangement extends StatelessWidget {
  const MainPagePostArrangement({super.key, required this.posts});

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < posts.length; i++)
          Column(
            children: [
              (i % 3 == 0)
                  ? PostElementImageLarge(post: posts[i])
                  : PostElement(post: posts[i]),
              Padding(
                padding: horizontalContentPadding,
                child: Divider(),
              )
            ],
          ),
      ],
    );
  }
}
