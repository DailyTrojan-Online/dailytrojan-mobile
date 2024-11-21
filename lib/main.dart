import 'dart:async';
import 'dart:convert';

import 'package:dailytrojan/article_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';

void main() {
  runApp(MyApp());
}

Future<List<Post>> fetchPosts() async {
  print("Fetching posts");
  // Get current date and set time to midnight
  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day - 1);

  // Format midnight to ISO 8601 string
  final String afterDate = todayMidnight.toIso8601String();
  //exclude live updates tag because content is difficult to parse
  final live_updates_tag = 34430;
  final classified_tag = 27249;
  final tag_excludes = [live_updates_tag, classified_tag];

  final podcast_category = 14432;
  final multimedia_category = 9785;

  final category_excludes = [podcast_category, multimedia_category];

  // Construct API URL with the 'after' query parameter
  final url = Uri.parse(
      'https://dailytrojan.com/wp-json/wp/v2/posts?per_page=100&after=$afterDate&tags_exclude=${tag_excludes.join(',')}&categories_exclude=${category_excludes.join(',')}');

  // Make HTTP GET request
  final response = await http.get(url);

  print(response.statusCode);
  List<Post> posts = [];
  if (response.statusCode == 200) {
    for (var post in jsonDecode(response.body)) {
      print('adding');
      posts.add(Post.fromJson(post as Map<String, dynamic>));
    }
    return posts;
  } else {
    throw Exception('Failed to load posts');
  }
}

HtmlUnescape htmlUnescape = HtmlUnescape();

class Post {
  final String title;
  final String content;
  final String date;
  final String link;
  final String author;
  final String coverImage;
  final String excerpt;
  final bool breaking;

  const Post({
    required this.title,
    required this.content,
    required this.date,
    required this.link,
    required this.author,
    required this.coverImage,
    required this.excerpt,
    required this.breaking,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title']['rendered'],
      content: json['content']['rendered'],
      date: json['date'],
      link: json['link'],
      author: json['yoast_head_json']['author'],
      coverImage: json['yoast_head_json']['og_image'][0]['url'],
      excerpt: json['excerpt']['rendered'],
      breaking: json['tags'].contains(30231) == true,
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: (ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF990000)),
            textTheme: textTheme)),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Post? article;

  setArticle(Post article) {
    this.article = article;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MainPage();
        break;
      case 1:
        page = Placeholder();
        break;
      case 2:
        page = Placeholder();
        break;
      case 3:
        page = Placeholder();
        break;
      case 4:
        page = Placeholder();
        break;
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: page,
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Sections',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.games),
            label: 'Games',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
  }
}

const headlineVerticalPadding = EdgeInsets.only(top: 80.0, bottom: 20.0);
const overallContentPadding =
    EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0, bottom: 50.0);

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
                        padding: overallContentPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Text(
                                DateFormat.yMMMMd().format(DateTime.now()),
                                style: headlineStyle,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            HomePagePostArrangement(posts: posts),
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

class HomePagePostArrangement extends StatelessWidget {
  const HomePagePostArrangement({super.key, required this.posts});

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < posts.length; i++) Column(
          children: [
            (i % 4 == 0) ? PostElementImageLarge(post: posts[i]) : PostElement(post: posts[i]),
            Divider()
          ],
        ),
      ],
    );
  }
}

class PostList extends StatelessWidget {
  const PostList({
    super.key,
    required this.posts,
  });

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var post in posts) PostElementImage(post: post),
      ],
    );
  }
}

class PostElementImage extends StatelessWidget {
  final Post post;

  const PostElementImage({
    super.key,
    required this.post,
  });

  final double imageSize = 100.0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.headlineSmall!.copyWith(
        color: theme.colorScheme.primary,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.tertiary, fontSize: 14.0, fontFamily: "Inter");
    final authorStyle = theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.tertiary, fontFamily: "Inter");
    final excerptStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.secondary, fontSize: 14.0, fontFamily: "SourceSerif4");

    var articleDOM = parse(post.content);
    var author = '';
    articleDOM.querySelectorAll('h6').forEach((e) {
      // a really awful way to do things because the wordpress api doesnt return the correct author 100% of the time.
      ;
      if (e.innerHtml.startsWith("By")) {
        author = (htmlUnescape.convert(e.innerHtml));
        return;
      }
    });

    return InkWell(
      onTap: () {
        appState.setArticle(post);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ArticleRoute()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Image(
              image: NetworkImage(post.coverImage),
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  htmlUnescape.convert(post.title),
                  style: headlineStyle,
                ),
                SizedBox(width: 10),
                Text(author, style: authorStyle),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class PostElement extends StatelessWidget {
  final Post post;

  const PostElement({
    super.key,
    required this.post,
  });

  final double imageSize = 100.0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.primary,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.tertiary, fontSize: 14.0, fontFamily: "Inter");
    final authorStyle = theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.tertiary, fontFamily: "Inter");
    final excerptStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.secondary, fontSize: 14.0, fontFamily: "SourceSerif4");

    var articleDOM = parse(post.content);
    var author = '';
    articleDOM.querySelectorAll('h6').forEach((e) {
      // a really awful way to do things because the wordpress api doesnt return the correct author 100% of the time.
      ;
      if (e.innerHtml.startsWith("By")) {
        author = (htmlUnescape.convert(e.innerHtml));
        return;
      }
    });

    return InkWell(
      onTap: () {
        appState.setArticle(post);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ArticleRoute()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                post.breaking ? Text("BREAKING", style: subStyle.copyWith(fontWeight: FontWeight.bold)) : EmptyWidget(),
                Text(
                  htmlUnescape.convert(post.title),
                  style: headlineStyle,
                ),
                SizedBox(height: 6),
                Text(author, style: authorStyle)
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class PostElementImageLarge extends StatelessWidget {
  final Post post;

  const PostElementImageLarge({
    super.key,
    required this.post,
  });

  final double imageSize = 100.0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.headlineSmall!.copyWith(
        color: theme.colorScheme.primary,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.tertiary, fontSize: 14.0, fontFamily: "Inter");
    final authorStyle = theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.tertiary, fontFamily: "Inter");
    final excerptStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.secondary, fontSize: 16.0, fontFamily: "SourceSerif4");

    var articleDOM = parse(post.content);
    var author = '';
    articleDOM.querySelectorAll('h6').forEach((e) {
      // a really awful way to do things because the wordpress api doesnt return the correct author 100% of the time.
      ;
      if (e.innerHtml.startsWith("By")) {
        author = (htmlUnescape.convert(e.innerHtml));
        return;
      }
    });

    return InkWell(
      onTap: () {
        appState.setArticle(post);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ArticleRoute()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                post.breaking ? Text("BREAKING", style: subStyle.copyWith(fontWeight: FontWeight.bold)) : EmptyWidget(),
                Text(
                  htmlUnescape.convert(post.title),
                  style: headlineStyle,
                ),
                SizedBox(height: 6),
                Text(parse(htmlUnescape.convert(post.excerpt)).querySelector("p")?.innerHtml ?? "", style: excerptStyle),
                SizedBox(height: 6),
                Text(author, style: authorStyle),
                SizedBox(height: 8),                    
                Image(
                  image: NetworkImage(post.coverImage),
                  fit: BoxFit.cover,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
