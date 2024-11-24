import 'dart:async';
import 'dart:convert';

import 'package:dailytrojan/home_page.dart';
import 'package:dailytrojan/sections_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

void main() {
  runApp(MyApp());
}

Future<List<Post>> fetchPosts() async {
  print("Fetching posts");
  // Get current date and set time to midnight
  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day);

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
      'https://dailytrojan.com/wp-json/wp/v2/posts?per_page=15&tags_exclude=${tag_excludes.join(',')}&categories_exclude=${category_excludes.join(',')}');

  // Make HTTP GET request
  final response = await http.get(url);

  print(response.statusCode);
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

Future<List<Post>> fetchPostsWithMainCategoryAndCount(
    int mainCategoryId, int count, {int pageOffset = 1}) async {
  print("Fetching posts");

  //exclude live updates tag because content is difficult to parse
  final live_updates_tag = 34430;
  final classified_tag = 27249;
  final tag_excludes = [live_updates_tag, classified_tag];

  final podcast_category = 14432;
  final multimedia_category = 9785;

  final category_excludes = [podcast_category, multimedia_category];

  // Construct API URL with the 'after' query parameter
  final url = Uri.parse(
      'https://dailytrojan.com/wp-json/wp/v2/posts?per_page=$count&page=$pageOffset&tags_exclude=${tag_excludes.join(',')}&categories_exclude=${category_excludes.join(',')}&categories=$mainCategoryId');

  // Make HTTP GET request
  final response = await http.get(url);

  print(response.statusCode);
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

enum PostMainCategory { News, ArtsEntertainment, Sports, Opinion, Magazine }

const int NewsID = 3;
const int ArtsEntertainmentID = 5;
const int OpinionID = 4;
const int SportsID = 6;
const int MagazineID = 33530;
const int NewsFeatureID = 28938;
const int OpinionFeatureID = 35056;
const int SportsFeatureID = 34018;
const int ArtsEntertainmentColumnID = 888;
const int OpinionColumnID = 890;
const int SportsColumnID = 889;

final Map<int, PostMainCategory> mainCategoryMap = {
  NewsID: PostMainCategory.News,
  ArtsEntertainmentID: PostMainCategory.ArtsEntertainment,
  OpinionID: PostMainCategory.Opinion,
  SportsID: PostMainCategory.Sports,
  MagazineID: PostMainCategory.Magazine,
};

final Map<PostMainCategory, String> mainCategoryNames = {
  PostMainCategory.News: "News",
  PostMainCategory.ArtsEntertainment: "Arts & Entertainment",
  PostMainCategory.Opinion: "Opinion",
  PostMainCategory.Sports: "Sports",
  PostMainCategory.Magazine: "Magazine",
};

PostMainCategory getMainCategory(List<int> ids) {
  for (int id in ids) {
    if (mainCategoryMap.containsKey(id)) {
      return mainCategoryMap[id]!;
    }
  }
  return PostMainCategory.News;
}

bool isColumnFromCategories(List<int> ids) {
  return ids.contains(ArtsEntertainmentColumnID) ||
      ids.contains(OpinionColumnID) ||
      ids.contains(SportsColumnID);
}

bool isMainFeatureFromCategories(List<int> ids) {
  return ids.contains(NewsFeatureID) ||
      ids.contains(OpinionFeatureID) ||
      ids.contains(SportsFeatureID);
}

class Post {
  final String title;
  final String content;
  final String date;
  final String link;
  final String author;
  final String coverImage;
  final String excerpt;
  final PostMainCategory mainCategory;
  final bool breaking;
  final bool isColumn;
  final bool isMainFeature;

  const Post({
    required this.title,
    required this.content,
    required this.date,
    required this.link,
    required this.author,
    required this.coverImage,
    required this.excerpt,
    required this.mainCategory,
    required this.breaking,
    required this.isColumn,
    required this.isMainFeature,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      title: json['title']['rendered'],
      content: json['content']['rendered'],
      date: json['date'],
      link: json['link'],
      mainCategory: getMainCategory(json['categories'].cast<int>()),
      author: json['yoast_head_json']['author'],
      coverImage: json['yoast_head_json']['og_image'][0]['url'],
      excerpt: json['excerpt']['rendered'],
      breaking: json['tags'].contains(30231) == true,
      isColumn: isColumnFromCategories(json['categories'].cast<int>()),
      isMainFeature:
          isMainFeatureFromCategories(json['categories'].cast<int>()),
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
            colorScheme: ColorScheme.fromSeed(
                seedColor: Color(0xFF990000),
                brightness: Brightness.dark,
                dynamicSchemeVariant: DynamicSchemeVariant.rainbow),
            textTheme: textTheme)),
        home: Navigation(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Post? article;
  SectionHeirarchy? activeMainSection;
  Section? activeSection;

  setArticle(Post article) {
    this.article = article;
    notifyListeners();
  }

  setMainSection(SectionHeirarchy mainSection) {
    this.activeMainSection = mainSection;
    notifyListeners();
  }

  setSection(Section section) {
    this.activeSection = section;
    notifyListeners();
  }
}

class Navigation extends StatefulWidget {
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
        break;
      case 1:
        page = SectionsPage();
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
            icon: Icon(Icons.newspaper),
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
const verticalContentPadding = EdgeInsets.only(top: 60.0, bottom: 50.0);
const horizontalContentPadding = EdgeInsets.only(left: 20.0, right: 20.0);

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
