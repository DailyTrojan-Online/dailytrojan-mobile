import 'dart:async';
import 'dart:convert';

import 'package:dailytrojan/article_route.dart';
import 'package:html/parser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

void main() {
  runApp(MyApp());
}

Future<List<Post>> fetchPosts() async {
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

  List<Post> posts = [];
  if (response.statusCode == 200) {
    for (var post in jsonDecode(response.body)) {
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

  const Post(
      {required this.title,
      required this.content,
      required this.date,
      required this.link,
      required this.author,
      required this.coverImage,
      required this.excerpt});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title']['rendered'],
      content: json['content']['rendered'],
      date: json['date'],
      link: json['link'],
      author: json['yoast_head_json']['author'],
      coverImage: json['yoast_head_json']['og_image'][0]['url'],
      excerpt: json['excerpt']['rendered'],
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Post>> posts;

  @override
  void initState() {
    super.initState();
    posts = fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF990000)),
          textTheme: GoogleFonts.latoTextTheme(textTheme).copyWith(
            bodyMedium: GoogleFonts.sourceSerif4(textStyle: textTheme.bodyMedium),
          ),
        ),
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
                    icon: Icon(Icons.gamepad),
                    label: 'Games',
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
const overallContentPadding = EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0, bottom: 50.0);

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = GoogleFonts.sourceSerif4(
        textStyle: theme.textTheme.displaySmall!.copyWith(
            color: theme.colorScheme.primary, fontWeight: FontWeight.bold));
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: overallContentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    DateFormat.yMMMMd().format(DateTime.now()),
                    style: headlineStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
                FutureBuilder<List<Post>>(
                  future: fetchPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return PostList(posts: snapshot.data!);
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return Center(child: const CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
        for (var post in posts) PostElement(post: post),
      ],
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
    final headlineStyle = GoogleFonts.sourceSerif4(
        textStyle: theme.textTheme.headlineSmall!.copyWith(
            color: theme.colorScheme.primary, fontWeight: FontWeight.bold));
    final subStyle = GoogleFonts.inter(
        textStyle: theme.textTheme.bodySmall!
            .copyWith(color: theme.colorScheme.tertiary, fontSize: 14.0));

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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(htmlUnescape.convert(post.title), style: headlineStyle,
  maxLines: 2, 

  overflow: TextOverflow.ellipsis,),
                SizedBox(height: 10),
                Text("BY ${post.author.toUpperCase()}", style: subStyle),
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