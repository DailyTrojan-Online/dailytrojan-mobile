import 'dart:async';
import 'dart:convert';

import 'package:dailytrojan/article_route.dart';
import 'package:dailytrojan/bookmarks_page.dart';
import 'package:dailytrojan/firebase_options.dart';
import 'package:dailytrojan/home_page.dart';
import 'package:dailytrojan/search_page.dart';
import 'package:dailytrojan/sections_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:dailytrojan/games_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:responsive_grid/responsive_grid.dart';
import './icons/daily_trojan_icons.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

final InAppLocalhostServer localhostServer =
    InAppLocalhostServer(documentRoot: './games');

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('bookmarks');
  ResponsiveGridBreakpoints.value = ResponsiveGridBreakpoints(
    xs: 420,
    sm: 905,
    md: 1240,
    lg: 1440,
  );

  if (!kIsWeb) {
    await localhostServer.start();
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // You may set the permission requests to "provisional" which allows the user to choose what type
// of notifications they would like to receive once the user receives a notification.
  final notificationSettings =
      await FirebaseMessaging.instance.requestPermission(provisional: true);

// For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
  final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  if (apnsToken != null) {
    // APNS token is available, make FCM plugin API requests...
  }
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    // TODO: If necessary send token to application server.
    print("FCM Token: $fcmToken");

    // Note: This callback is fired at each app startup and whenever a new
    // token is generated.
  }).onError((err) {
    // Error getting token.
  });

  runApp(MyApp());
}

class BookmarkService {
  static final _box = Hive.box('bookmarks');

  // Add bookmark (key is WP post ID)
  static void addBookmark(String key, dynamic data) {
    _box.put(key, data);
  }

  static bool isBookmarked(String key) {
    return _box.containsKey(key);
  }

  static void removeBookmark(String key) {
    _box.delete(key);
  }

  static void toggleBookmark(String key, dynamic data) {
    if (isBookmarked(key)) {
      removeBookmark(key);
    } else {
      addBookmark(key, data);
    }
  }

  static List<dynamic> getAllBookmarks() {
    return _box.values.toList();
  }
}

Future<List<Post>> fetchPosts() async {
  print("Fetching posts");
  // Get current date and set time to midnight
  final now = DateTime.now();
  final todayMidnight = DateTime(now.year, now.month, now.day);

  // Format midnight to ISO 8601 string
  final String afterDate = todayMidnight.toIso8601String();
  //exclude live updates tag because content is difficult to parse
  const liveUpdatesTag = 34430;
  const classifiedTag = 27249;
  final tagExcludes = [liveUpdatesTag, classifiedTag];

  const podcastCategory = 14432;
  const multimediaCategory = 9785;

  final categoryExcludes = [podcastCategory, multimediaCategory];

  // Construct API URL with the 'after' query parameter
  final url = Uri.parse(
      'https://dailytrojan.com/wp-json/wp/v2/posts?per_page=15&tags_exclude=${tagExcludes.join(',')}&categories_exclude=${categoryExcludes.join(',')}');

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

Future<Post> fetchPostById(String postId) {
  print("Fetching post with id $postId");
  final url = Uri.parse(
      'https://dailytrojan.com/wp-json/wp/v2/posts/$postId?context=embed');
  print(url);
  return http.get(url).then((response) {
    if (response.statusCode == 200) {
      var post = jsonDecode(response.body);
      return Post.fromJson(post as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load post');
    }
  });
}

Future<List<Post>> fetchPostsByIds(List<dynamic> postIds) {
  print("Fetching posts with ids $postIds");
  final url = Uri.parse(
      'https://dailytrojan.com/wp-json/wp/v2/posts?include=${postIds.join(',')}');
  print(url);
  return http.get(url).then((response) {
    if (response.statusCode == 200) {
      List<Post> posts = [];
      print(response.body);
      for (var post in jsonDecode(response.body)) {
        posts.add(Post.fromJson(post as Map<String, dynamic>));
      }
      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  });
}

Future<List<Post>> fetchPostsWithMainCategoryAndCount(
    int mainCategoryId, int count,
    {int pageOffset = 1}) async {
  print("Fetching posts");

  //exclude live updates tag because content is difficult to parse
  const liveUpdatesTag = 34430;
  const classifiedTag = 27249;
  final tagExcludes = [liveUpdatesTag, classifiedTag];

  const podcastCategory = 14432;
  const multimediaCategory = 9785;

  final categoryExcludes = [podcastCategory, multimediaCategory];

  // Construct API URL with the 'after' query parameter
  final url = Uri.parse(
      'https://dailytrojan.com/wp-json/wp/v2/posts?per_page=$count&page=$pageOffset&tags_exclude=${tagExcludes.join(',')}&categories_exclude=${categoryExcludes.join(',')}&categories=$mainCategoryId');

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

Future<List<Post>> fetchTrendingPosts() {
  //first we want to really quickly fetch the page of trending articles
  //https://dailytrojan.com/wp-json/wp/v2/pages/233168
  //then we want to parse its contents as html and find all the urls for the articles
  //then we want to use those slugs in a new query to the posts api and then use those pieces of data
  final trendingUrl =
      Uri.parse('https://dailytrojan.com/wp-json/wp/v2/pages/233168');
  return http.get(trendingUrl).then((response) {
    if (response.statusCode == 200) {
      //replace anything that is between html comment tags (<!-- and -->) including the tags from response body
      String body =
          response.body.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
      var page = jsonDecode(body);
      var articleDOM = parse(page['content']['rendered']);
      var links = articleDOM.querySelectorAll("a");
      List<String> slugs = [];
      for (var link in links) {
        if (link.attributes['href'] != null &&
            link.attributes['href']!.contains("dailytrojan.com")) {
          List<String> parts = link.attributes['href']!.split("/");
          slugs.add(parts[parts.length - 2]);
        }
      }
      //now we have a list of slugs, we can use them to fetch the posts
      return fetchPostsBySlugs(slugs);
    } else {
      throw Exception('Failed to load posts');
    }
  });
}

void OpenArticleRoute(BuildContext context, Post article) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => ArticleRoute(article: article)),
  );
}

Future<bool> OpenArticleRouteByURL(BuildContext context, String url) async {
  try {
    // Extract slug from URL

    List<String> parts = url.split("/");
    var slug = (parts[parts.length - 2]);
    
    if (slug == null) {
      print("Invalid URL: $url");
      return false;
    }
  
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArticleRoute(articleUrl: url)),
    );
    return true;
  } catch (e) {
    print("Error opening article by slug: $e");
    return false;
  }
}

Future<List<Post>> fetchPostsBySlugs(List<String> slugs) {
  print("Fetching posts with slugs $slugs");
  final url = Uri.parse(
      'https://dailytrojan.com/wp-json/wp/v2/posts?slug=${slugs.join(',')}');
  print(url);
  return http.get(url).then((response) {
    if (response.statusCode == 200) {
      List<Post> posts = [];
      for (var post in jsonDecode(response.body)) {
        posts.add(Post.fromJson(post as Map<String, dynamic>));
      }
      return posts;
    } else {
      throw Exception('Failed to load posts');
    }
  });
}

Future<Post> fetchPostBySlug(String slug) {
  print("Fetching post with slug $slug");
  final url = Uri.parse(
    'https://dailytrojan.com/wp-json/wp/v2/posts?slug=$slug');
  print(url);
  return http.get(url).then((response) {
    if (response.statusCode == 200) {
      List<Post> posts = [];
      for (var post in jsonDecode(response.body)) {
        posts.add(Post.fromJson(post as Map<String, dynamic>));
      }
      if (posts.isNotEmpty) {
        return posts.first;
      } else {
        throw Exception('Post not found');
      }
    } else {
      throw Exception('Failed to load posts');
    }
  });
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
  final String id;

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
    required this.id,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'].toString(),
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
    final textTheme = Theme.of(context).textTheme.apply(fontFamily: "Inter");
    final colorScheme = ColorScheme.fromSeed(
        seedColor: Color(0xFF990000),
        primary: Color.fromARGB(255, 187, 23, 34),
        dynamicSchemeVariant: DynamicSchemeVariant.monochrome);
    final darkColorScheme = ColorScheme.fromSeed(
        seedColor: Color.fromARGB(255, 0, 0, 0),
        brightness: Brightness.dark,
        primary: Color.fromARGB(255, 243, 60, 75),
        dynamicSchemeVariant: DynamicSchemeVariant.monochrome);
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
    );
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: textTheme,
    );

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Daily Trojan',
        theme: theme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: Navigation(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Post? article;
  SectionHeirarchy? activeMainSection;
  Section? activeSection;
  String? gameUrl;
  String? gameShareableUrl;

  setArticle(Post article) {
    this.article = article;
    notifyListeners();
  }

  setMainSection(SectionHeirarchy mainSection) {
    activeMainSection = mainSection;
    notifyListeners();
  }

  setSection(Section section) {
    activeSection = section;
    notifyListeners();
  }

  setGameUrl(String url) {
    gameUrl = url;
    notifyListeners();
  }

  setGameShareableUrl(String url) {
    gameShareableUrl = url;
    notifyListeners();
  }
}

class Navigation extends StatefulWidget {
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int selectedIndex = 0;
  int oldIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
      case 1:
        page = SectionsPage();
      case 2:
        page = SearchPage();
      case 3:
        page = GamesPage();
      case 4:
        page = BookmarksPage();
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }

    double direction = selectedIndex > oldIndex ? 1 : -1;
    direction *= 0.05;
    var theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final isIncoming = (child.key as ValueKey).value == selectedIndex;

          final offsetAnimation = animation.drive(
            Tween<Offset>(
              begin: Offset(isIncoming ? direction : -direction, 0.0),
              end: Offset(isIncoming ? 0.0 : 0.0, 0.0),
            ).chain(CurveTween(
                curve:
                    isIncoming ? Curves.easeInOut : Curves.easeInOut.flipped)),
          );

          final fadeAnimation = animation.drive(
            Tween<double>(begin: 0.0, end: 1.0)
                .chain(CurveTween(curve: Curves.easeInOut)),
          );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(selectedIndex),
          child: page,
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle:
                WidgetStateProperty.resolveWith<TextStyle?>((states) {
              final baseStyle = Theme.of(context).textTheme.labelMedium;
              final color = states.contains(WidgetState.selected)
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.5);
              return baseStyle?.copyWith(color: color);
            }),
            iconTheme:
                WidgetStateProperty.resolveWith<IconThemeData?>((states) {
              final color = states.contains(WidgetState.selected)
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.5);
              return IconThemeData(
                color: color,
              );
            }),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1.0,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              if (index == selectedIndex) return;
              setState(() {
                oldIndex = selectedIndex;
                selectedIndex = index;
              });
            },
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            labelPadding: EdgeInsets.only(top: 2, bottom: 5),
            backgroundColor: theme.colorScheme.surfaceContainerLow,
            indicatorColor: Colors.transparent,
            destinations: const [
              NavigationDestination(
                  icon: Icon(DailyTrojanIcons.logo), label: 'Home'),
              NavigationDestination(
                  icon: Icon(DailyTrojanIcons.section), label: 'Sections'),
              NavigationDestination(
                  icon: Icon(DailyTrojanIcons.search), label: 'Search'),
              NavigationDestination(
                  icon: Icon(DailyTrojanIcons.game), label: 'Games'),
              NavigationDestination(
                  icon: Icon(DailyTrojanIcons.bookmark), label: 'Saved'),
            ],
          ),
        ),
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
