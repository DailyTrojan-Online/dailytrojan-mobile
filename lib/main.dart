import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dailytrojan/article_route.dart';
import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/firebase_options.dart';
import 'package:dailytrojan/home_page.dart';
import 'package:dailytrojan/search_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:dailytrojan/games_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uuid/uuid.dart';
import './icons/daily_trojan_icons.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

const API_BASE_URL =
    // 'https://dailytrojan.com/wp-json/wp/v2/search';
    "https://ancile.dailytrojandigitalmanaging.workers.dev/api/";
const POSTS_BASE_URL =
    // 'https://dailytrojan.com/wp-json/wp/v2/posts';
    "${API_BASE_URL}wp_posts";
const SEARCH_BASE_URL =
    // 'https://dailytrojan.com/wp-json/wp/v2/search';
    "${API_BASE_URL}wp_search";

final InAppLocalhostServer localhostServer =
    InAppLocalhostServer(documentRoot: './games');

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('article_bookmarks');
  await Hive.openBox('article_history');
  await Hive.openBox("app_debug");
  await Hive.openBox("user_preferences");
  ResponsiveGridBreakpoints.value = ResponsiveGridBreakpoints(
    xs: 420,
    sm: 905,
    md: 1240,
    lg: 1440,
  );

  if (!kIsWeb) {
    await localhostServer.start();
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // You may set the permission requests to "provisional" which allows the user to choose what type
// of notifications they would like to receive once the user receives a notification.
    final notificationSettings = await FirebaseMessaging.instance
        .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true);

// For apple platforms, ensure the APNS token is available before making any FCM plugin API calls
    final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    if (apnsToken != null) {
      // APNS token is available, make FCM plugin API requests...
    }
    print(apnsToken);
    print("firebase notifs");
    var token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      var uri = Uri.parse(
          'https://project-traveler.vercel.app/api/add-notification-token?token=$token');
      //TODO: for some reason this isnt working and is throwing a 308 code. need to figure this out tomorrow
      print(uri);
      var response = await http.post(uri);
      DebugService.addDebugString("firebase_getToken_token", token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) async {
      // TODO: If necessary send token to application server.
      print("FCM Token: $fcmToken");
      var uri = Uri.parse(
          'https://project-traveler.vercel.app/api/add-notification-token?token=$fcmToken');
      var response = await http.post(uri);
      print(response);
      DebugService.addDebugString("firebase_refresh_token", fcmToken);

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
      print(err);
      DebugService.addDebugString("firebase_refresh_err", err);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    await FirebaseMessaging.instance.subscribeToTopic("breaking");

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("Error initializing Firebase Messaging: $e");
    DebugService.addDebugString("firebase_init_error", e.toString());
  }

  runApp(MyApp());

  try {
    updateSections();
  } catch (e) {
    print("Error updating sections: $e");
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class DebugService {
  static final _box = Hive.box('app_debug');
  static void addDebugString(String key, String value) {
    _box.put(key, value);
  }

  static List<(String, String)> getAllDebugStrings() {
    var debugStrings = _box.keys
        .map((key) => (key as String, _box.get(key) as String))
        .toList();
    return debugStrings;
  }
}

class BookmarkService {
  static final _box = Hive.box('article_bookmarks');

  // Add bookmark (key is WP post ID)
  static void addBookmark(String key) {
    DateTime dateAdded = DateTime.now();
    _box.put(key, dateAdded);
  }

  static bool isBookmarked(String key) {
    return _box.containsKey(key);
  }

  static void removeBookmark(String key) {
    _box.delete(key);
  }

  static void toggleBookmark(String key) {
    if (isBookmarked(key)) {
      removeBookmark(key);
    } else {
      addBookmark(key);
    }
  }

  static List<String> getAllBookmarks() {
    var bookmarks = _box.keys
        .map((key) => (key as String, _box.get(key) as DateTime))
        .toList();
    bookmarks.sort((a, b) => b.$2.compareTo(a.$2));
    var ids = bookmarks.map((e) => e.$1).toList();
    return ids;
  }
}

class HistoryService {
  static final _box = Hive.box('article_history');

  // Add history entry (key is WP post ID)
  static void addToHistory(String key) {
    print("Adding $key to history");
    if (_box.containsKey(key)) {
      _box.delete(key);
    }
    _box.put(key, DateTime.now());
  }

  static bool isInHistory(String key) {
    return _box.containsKey(key);
  }

  static void removeFromHistory(String key) {
    _box.delete(key);
  }

  static List<String> getAllHistory() {
    var history = _box.keys
        .map((key) => (key as String, _box.get(key) as DateTime))
        .toList();
    history.sort((a, b) => b.$2.compareTo(a.$2));
    var ids = history.map((e) => e.$1).toList();
    return ids;
  }
}

class PreferencesService {
  static final _box = Hive.box('user_preferences');
  static void setThemeMode(ThemeMode mode) {
    switch (mode)
    {
      case ThemeMode.system:
        _box.put("theme_mode", "system");

      case ThemeMode.light:
        _box.put("theme_mode", "light");

      case ThemeMode.dark:
        _box.put("theme_mode", "dark");
    }
  }

  static bool hasThemeMode() {
    return _box.containsKey("theme_mode");
  }

  static ThemeMode getThemeMode() {
    if (!hasThemeMode()) {
      _box.put("theme_mode", ThemeMode.system);
    }

    switch (_box.get("theme_mode"))
    {
      case "system":
        return ThemeMode.system;

      case "light":
        return ThemeMode.light;

      case "dark":
        return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  static String getAID() {
    if (!_box.containsKey("app_instance_id")) {
      var newAID = const Uuid().v4();
      _box.put("app_instance_id", newAID);
      return newAID;
    }
    return _box.get("app_instance_id");
  }
}

Future<List<(Columnist, Post)>> getColumnists(String section) async {
  print('a');
  final url = Uri.parse('${API_BASE_URL}app/columns?section=${section}');
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
    List<(Columnist, Post)> cPosts = [];
    for (int i = 0; i < columnists.length; i++) {
      if (latestPosts[i].isNotEmpty) {
        cPosts.add((columnists[i], latestPosts[i][0]));
      }
    }
    return cPosts;
  } else {
    throw Exception('Failed to load columns');
  }
}

Future<List<Post>> fetchPostsByIds(List<dynamic> postIds) {
  print("Fetching posts with ids $postIds");
  const liveUpdatesTag = 34430;
  const classifiedTag = 27249;
  final tagExcludes = [liveUpdatesTag, classifiedTag];
  final url = Uri.parse(
      '${POSTS_BASE_URL}?include=${postIds.join(',')}&tags_exclude=${tagExcludes.join(',')}');
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

Future<List<Post>> fetchPostsWithMainCategoryAndCount(
    int mainCategoryId, int count,
    {int pageOffset = 1, bool includeColumns = true}) async {
  print("Fetching posts");

  //exclude live updates tag because content is difficult to parse
  const liveUpdatesTag = 34430;
  const classifiedTag = 27249;
  final tagExcludes = [liveUpdatesTag, classifiedTag];

  const podcastCategory = 14432;

  // final categoryExcludes = [];
  final categoryExcludes = [podcastCategory];

  // Construct API URL with the 'after' query parameter
  final url = Uri.parse(
      '${POSTS_BASE_URL}?per_page=$count&page=$pageOffset&tags_exclude=${tagExcludes.join(',')}&categories_exclude=${categoryExcludes.join(',')}&categories=$mainCategoryId&exclude_columns=${includeColumns ? 'false' : 'true'}');

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

List<Post>? cachedTrendingPosts;
DateTime? lastFetchTime;
const Duration cacheDuration = Duration(minutes: 2);

Future<List<Post>> fetchTrendingPosts() {
  if (cachedTrendingPosts != null &&
      lastFetchTime != null &&
      DateTime.now().difference(lastFetchTime!) < cacheDuration) {
    lastFetchTime = DateTime.now();
    print("Returning cached trending posts");
    return Future.value(cachedTrendingPosts);
  }
  lastFetchTime = DateTime.now();
  print("Cached trending posts: $cachedTrendingPosts");
  print("Fetching new trending posts");
  //first we want to really quickly fetch the page of trending articles
  //then we want to parse its contents as html and find all the urls for the articles
  //then we want to use those slugs in a new query to the posts api and then use those pieces of data
  final trendingUrl =
      Uri.parse('https://dailytrojan.com/wp-json/wtpsw/v1/trending?limit=10');
  return http.get(trendingUrl).then((response) {
    if (response.statusCode == 200) {
      var ids = <int>[];
      for (var post in jsonDecode(response.body)) {
        print(post);
        ids.add(post['id'] as int);
      }
      //now we have a list of slugs, we can use them to fetch the posts
      return fetchPostsByIds(ids).then((posts) {
        print(posts.length);
        posts.sort((a, b) => ids
            .indexOf(int.parse(a.id))
            .compareTo(ids.indexOf(int.parse(b.id))));
        List<Post> returnedPosts = [];
        for (int i = 0; i < math.min(5, posts.length); i++) {
          returnedPosts.add(posts[i]);
        }
        cachedTrendingPosts = returnedPosts;
        return returnedPosts;
      });
    } else {
      throw Exception('Failed to load posts');
    }
  });
}

void OpenArticleRoute(BuildContext context, Post article) {
  Navigator.push(
    context,
    SlideOverPageRoute(child: ArticleRoute(article: article)),
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
      SlideOverPageRoute(
        child: ArticleRoute(articleUrl: url),
      ),
    );
    return true;
  } catch (e) {
    print("Error opening article by slug: $e");
    return false;
  }
}

Future<List<Post>> fetchPostsBySlugs(List<String> slugs) {
  print("Fetching posts with slugs $slugs");
  final url = Uri.parse('${POSTS_BASE_URL}?slug=${slugs.join(',')}');
  // print(url);
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
  final url = Uri.parse('${POSTS_BASE_URL}?slug=$slug');
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

class Section {
  final String title;
  final int id;
  Section({required this.title, required this.id});
}

class SectionHeirarchy {
  final Section mainSection;
  final List<Section> subsections;
  SectionHeirarchy({required this.mainSection, required this.subsections});
}

List<SectionHeirarchy> Sections = [
  SectionHeirarchy(
      mainSection: Section(title: "News", id: NewsID),
      subsections: [
        Section(title: "City", id: 27273),
        Section(title: "USG", id: 33500),
        Section(title: "Student Health", id: 33503),
        Section(title: "Science", id: 33501),
        Section(title: "Labor", id: 33502),
        Section(title: "Finance", id: 33504),
        Section(title: "Housing", id: 16940),
        Section(title: "Sustainability", id: 34536),
      ]),
  SectionHeirarchy(
      mainSection:
          Section(title: "Arts & Entertainment", id: ArtsEntertainmentID),
      subsections: [
        Section(title: "Culture", id: 30770),
        Section(title: "Film", id: 8),
        Section(title: "Food", id: 27516),
        Section(title: "Games", id: 134),
        Section(title: "Literature", id: 27508),
        Section(title: "Music", id: 48),
        Section(title: "Reviews", id: 101),
      ]),
  SectionHeirarchy(
      mainSection: Section(title: "Sports", id: SportsID),
      subsections: [
        Section(title: "Baseball", id: 92),
        Section(title: "Basketball", id: 85),
        Section(title: "Football", id: 7),
        Section(title: "Soccer", id: 262),
        Section(title: "Tennis", id: 84),
        Section(title: "Volleyball", id: 271),
        Section(title: "Water Polo", id: 164),
      ]),
  SectionHeirarchy(
      mainSection: Section(title: "Opinion", id: OpinionID),
      subsections: [
        Section(title: "From The Editors", id: 891),
        Section(title: "Letters to the Editor", id: 16943),
      ]),
  SectionHeirarchy(
      mainSection: Section(title: "Magazine", id: 33530),
      subsections: [
        Section(title: "Culture", id: 34336),
        Section(title: "Campus", id: 35366),
        Section(title: "Letter from the Editors", id: 33947),
        Section(title: "Perspectives", id: 33604),
        Section(title: "Multimedia", id: 35363),
        Section(title: "The Back Page", id: 35364),
      ]),
];
Future<void> updateSections() async {
  final url = Uri.parse('${API_BASE_URL}app/sections');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<SectionHeirarchy> updatedSections = [];
    for (var mainSectionJson in jsonDecode(response.body)) {
      Section mainSection = Section(
          title: mainSectionJson["mainSection"]['title'],
          id: mainSectionJson["mainSection"]['id']);
      List<Section> subsections = [];
      for (var subsectionJson in mainSectionJson['subSections']) {
        subsections.add(
            Section(title: subsectionJson['title'], id: subsectionJson['id']));
      }
      updatedSections.add(
          SectionHeirarchy(mainSection: mainSection, subsections: subsections));
    }
    Sections = updatedSections;
  } else {
    throw Exception('Failed to load sections');
  }
}

class Game {
  final String title;
  final String description;
  final String imageUrl;
  final String gameUrl;
  final String gameShareableUrl;
  final Color color;

  Game({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.gameUrl,
    required this.gameShareableUrl,
    required this.color,
  });
}

List<Game> Games = [
  Game(
    title: "Troydle",
    description: "Guess the song played by the Trojan Marching Band.",
    imageUrl: "games/troydle/imgs/troydle.svg",
    gameUrl: "http://localhost:8080/troydle/index.html",
    gameShareableUrl: "https://dailytrojan-online.github.io/troydle/",
    color: Color(0xFF990000),
  ),
  Game(
    title: "Spelling Beads",
    description: "Find as many words as you can, as fast as you can.",
    imageUrl: "games/spelling-beads/imgs/spelling_beads.svg",
    gameUrl: "http://localhost:8080/spelling-beads/index.html",
    gameShareableUrl: "https://dailytrojan-online.github.io/spelling-beads/",
    color: Color(0xFFFFCC00),
  ),
  Game(
    title: "Sharks!",
    description:
        "How many words can you make before the sharks eat your letters?",
    imageUrl: "games/sharks/sharks.svg",
    gameUrl: "http://localhost:8080/sharks/index.html",
    gameShareableUrl: "https://dailytrojan-online.github.io/sharks/",
    color: Color(0xFF0071ff),
  )
];

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

class Columnist {
  final String title;
  final String byline;
  final String image;
  final String description;
  final int tag_id;
  Columnist({
    required this.title,
    required this.byline,
    required this.image,
    required this.description,
    required this.tag_id,
  });

  factory Columnist.fromJson(Map<String, dynamic> json) {
    return Columnist(
      title: json['title'],
      byline: json['byline'],
      image: json['image'],
      description: json['description'],
      tag_id: json['tag_id'],
    );
  }
  factory Columnist.skeleton() {
    return Columnist(
      title: BoneMock.title,
      byline: BoneMock.fullName,
      image: "",
      description: BoneMock.paragraph,
      tag_id: -1,
    );
  }
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

  factory Post.skeleton() {
    return Post(
      id: "-1",
      title: BoneMock.title,
      content: "",
      date: "2026-01-01T01:00:00",
      link: "",
      author: BoneMock.fullName,
      coverImage: "",
      excerpt: BoneMock.paragraph,
      mainCategory: PostMainCategory.News,
      breaking: false,
      isColumn: false,
      isMainFeature: false,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"].toString(),
      title: json["title"],
      content: json["content"],
      date: json["date"],
      link: json["url"],
      author: json["author"],
      coverImage: json["image"],
      excerpt: json["excerpt"],
      mainCategory: PostMainCategory.News,
      breaking: json['taxonomy'].contains(30231) == true, // TODO: fix this
      isColumn: isColumnFromCategories(json['taxonomy'].cast<int>()),
      isMainFeature: isMainFeatureFromCategories(json['taxonomy'].cast<int>()),
      // breaking: json['taxonomy'].contains(30231) == true,
      // isColumn: isColumnFromCategories(json['taxonomy'].cast<List<int>>()),
      // isMainFeature: isMainFeatureFromCategories(json['taxonomy'].cast<List<int>>()),
    );
    // return Post(
    //   id: json['id'].toString(),
    //   title: json['title']['rendered'],
    //   content: json['content']['rendered'],
    //   date: json['date'],
    //   link: json['link'] ?? json['guid']['rendered'],
    //   mainCategory: getMainCategory(json['categories'].cast<int>()),
    //   author: json['yoast_head_json']['author'],
    //   coverImage: json['yoast_head_json']['og_image'][0]['url'],
    //   excerpt: json['excerpt']['rendered'],
    //   breaking: json['tags'].contains(30231) == true,
    //   isColumn: isColumnFromCategories(json['categories'].cast<int>()),
    //   isMainFeature:
    //       isMainFeatureFromCategories(json['categories'].cast<int>()),
    // );
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
    final darkTextTheme = Theme.of(context).textTheme.apply(fontFamily: "Inter");
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
    );
    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
    );
    theme.textTheme.apply(fontFamily: "Inter");
    darkTheme.textTheme.apply(fontFamily: "Inter");

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: Consumer<MyAppState>(builder: (context, appState, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Daily Trojan',
          theme: theme,
          darkTheme: darkTheme,
          themeMode: appState.themeMode,
          home: Navigation(),
        );
      }),
    );
  }
}

class MyAppState extends ChangeNotifier {
  Post? article;
  SectionHeirarchy? activeMainSection;
  Section? activeSection;
  String? gameUrl;
  String? gameShareableUrl;
  ValueNotifier<double> scrollProgress = ValueNotifier(0.0);

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  MyAppState() {
    _themeMode = PreferencesService.getThemeMode();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    PreferencesService.setThemeMode(mode);
    notifyListeners();
  }

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

  notifyBookmarkChanged() {
    notifyListeners();
  }
}

class Navigation extends StatefulWidget {
  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    print("Setting up interacted message");
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      // _handleMessage(initialMessage);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleMessage(initialMessage);
      });
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  // void _handleMessage(RemoteMessage message) {
  //   print(message);
  //   print("message nreceiverd");
  //   if (message.data['url'] != null) {
  //     print(message.data['url']);
  //     OpenArticleRouteByURL(context, message.data['url']);
  //   }
  // }

  void _handleMessage(RemoteMessage message) {
    final url = message.data['url'];
    if (url is String && url.isNotEmpty) {
      _openArticleInTabNavigator(url); //open article inside _MainNavigator
    }
  }

  void _openArticleInTabNavigator(String url) {
    if (selectedIndex != 0) {
      // open on top of home tab
      setState(() {
        oldIndex = selectedIndex;
        selectedIndex = 0;
        articleRouteObserver = articleRouteObservers[selectedIndex];
      });
    }

    void pushNow() {
      final nav = navigatorKeys[selectedIndex].currentState;
      if (nav == null) return;

      nav.push(
        SlideOverPageRoute(
          child: ArticleRoute(articleUrl: url),
        ),
      );
    }

    // if NavigatorState isn't ready yet wait until after first frame
    if (navigatorKeys[selectedIndex].currentState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => pushNow());
    } else {
      pushNow();
    }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  int selectedIndex = 0;
  int oldIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
      case 1:
        page = SearchPage();
      case 2:
        page = GamesPage();
      default:
        throw UnimplementedError("no widget for $selectedIndex");
    }

    double direction = selectedIndex > oldIndex ? 1 : -1;
    direction *= 0.05;
    var theme = Theme.of(context);

    void selectDestination(int index) {
      if (index == selectedIndex) return;
      setState(() {
        oldIndex = selectedIndex;
        selectedIndex = index;
        articleRouteObserver = articleRouteObservers[selectedIndex];
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) =>
          {navigatorKeys[selectedIndex].currentState?.pop()},
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final isIncoming =
                      (child.key as ValueKey).value == selectedIndex;

                  final offsetAnimation = animation.drive(
                    Tween<Offset>(
                      begin: Offset(isIncoming ? direction : -direction, 0.0),
                      end: Offset(isIncoming ? 0.0 : 0.0, 0.0),
                    ).chain(CurveTween(
                        curve: isIncoming
                            ? Curves.easeInOut
                            : Curves.easeInOut.flipped)),
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
                child: _MainNavigator(
                  key: ValueKey<int>(selectedIndex),
                  navKey: navigatorKeys[selectedIndex],
                  selectedIndex: selectedIndex,
                  navigatorObserver: navigatorObservers[selectedIndex],
                  articleRouteObserver: articleRouteObservers[selectedIndex],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FloatingNavigationBar(
                  navKey: navigatorKeys[selectedIndex],
                  navigatorObserver: navigatorObservers[selectedIndex],
                  selectedIndex: selectedIndex,
                  onIndexChanged: selectDestination),
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingNavigationBar extends StatefulWidget {
  const FloatingNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.navigatorObserver,
    required this.navKey,
  });

  final int selectedIndex;
  final Function(int) onIndexChanged;
  final MainNavigatorObserver navigatorObserver;
  final GlobalKey<NavigatorState> navKey;

  @override
  State<FloatingNavigationBar> createState() => _FloatingNavigationBarState();
}

class _FloatingNavigationBarState extends State<FloatingNavigationBar> {
  @override
  void dispose() {
    disposeScrollProgressListener();

    super.dispose();
  }

  void toggleBookmark() {
    print(bookmarkId.value);
    if (BookmarkService.isBookmarked(bookmarkId.value)) {
      BookmarkService.removeBookmark(bookmarkId.value);
    } else {
      BookmarkService.addBookmark(bookmarkId.value);
    }
    setState(() {}); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    //observe navigatorObserver

    var steps = 5;
    //generate list of colors that evenly distributes alpha of the color scheme's surfaceContainerLowest color
    final linearColors = List.generate(
        steps,
        (i) => theme.colorScheme.surfaceContainerLowest
            .withOpacity(i / (steps - 1)));
    final curvedColors = linearColors
        .map((color) => color.withOpacity(Curves.easeOut
            .transform(color.opacity))) // Apply curve transform to opacity
        .toList();

    var bottomPadding = MediaQuery.of(context).padding.bottom + 0;
    var bottomMinHeight = 70;

    initScrollProgressListener();

    return SizedBox(
      height: bottomMinHeight + bottomPadding,
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: curvedColors,
                    ),
                    // color: Colors.red
                  ),
                ),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: widget.navigatorObserver.isOnHomePage,
              builder: (context, isOnHomePage, child) {
                return AnimatedPositioned(
                  left: (MediaQuery.of(context).size.width / 2) -
                      (135) +
                      ((isOnHomePage == true) ? 60 : 0),
                  bottom: (bottomMinHeight / 2) - (50 / 2) + bottomPadding,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOutQuad,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: (isOnHomePage == true) ? 0.0 : 1.0,
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(80),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withAlpha(100),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: BottomBarIconButton(
                              onPressed: () {
                                if (widget.navKey.currentState != null &&
                                    widget.navKey.currentState!.canPop()) {
                                  widget.navKey.currentState!.pop();
                                }
                              },
                              icon: Icon(Icons.arrow_back_rounded)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: shouldShowBookmarkButton,
              builder: (context, value, child) {
                return AnimatedPositioned(
                  left: (MediaQuery.of(context).size.width / 2) +
                      (85) +
                      ((value == true) ? 0 : -60),
                  bottom: (bottomMinHeight / 2) - (50 / 2) + bottomPadding,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOutQuad,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: (value == true) ? 1.0 : 0.0,
                    child: Container(
                      width: 90,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(80),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withAlpha(100),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: BottomBarIconButton(
                                    onPressed: () {
                                      SharePlus.instance.share(ShareParams(
                                          title: shareTitle.value,
                                          uri: Uri.parse(shareLink.value)));
                                    },
                                    icon: Icon(Icons.share_rounded)),
                              ),
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: ValueListenableBuilder(
                                    valueListenable: bookmarkId,
                                    builder: (context, value, child) {
                                      return BottomBarIconButton(
                                          onPressed: toggleBookmark,
                                          selected:
                                              BookmarkService.isBookmarked(
                                                  value),
                                          icon: Icon(BookmarkService
                                                  .isBookmarked(value)
                                              ? Icons.bookmark_rounded
                                              : Icons.bookmark_border_rounded));
                                    }),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ValueListenableBuilder(
              valueListenable: shouldShowShareButton,
              builder: (context, value, child) {
                return AnimatedPositioned(
                  left: (MediaQuery.of(context).size.width / 2) +
                      (85) +
                      ((value == true) ? 0 : -60),
                  bottom: (bottomMinHeight / 2) - (50 / 2) + bottomPadding,
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOutQuad,
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 200),
                    opacity: (value == true) ? 1.0 : 0.0,
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          height: 4.0,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(80),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withAlpha(100),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: BottomBarIconButton(
                              onPressed: () {
                                SharePlus.instance.share(ShareParams(
                                    title: shareTitle.value,
                                    uri: Uri.parse(shareLink.value)));
                              },
                              icon: Icon(Icons.share_rounded)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: SizedBox(
                    width:
                        164, //was giving me a 2px overflow issue so inc width by 4
                    height: 50,
                    child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(120),
                          border: Border.all(
                            color:
                                theme.colorScheme.outlineVariant.withAlpha(100),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              BottomBarIconButton(
                                onPressed: () => {
                                  if (widget.selectedIndex == 0)
                                    {
                                      if (widget.navKey.currentState != null &&
                                          widget.navKey.currentState!.canPop())
                                        {
                                          widget.navKey.currentState!.popUntil(
                                              (route) => route.isFirst)
                                        }
                                    }
                                  else
                                    widget.onIndexChanged(0)
                                },
                                selected: widget.selectedIndex == 0,
                                icon: Icon(DailyTrojanIcons.logo),
                              ),
                              BottomBarIconButton(
                                onPressed: () => {
                                  if (widget.selectedIndex == 1)
                                    {
                                      if (widget.navKey.currentState != null &&
                                          widget.navKey.currentState!.canPop())
                                        {
                                          widget.navKey.currentState!.popUntil(
                                              (route) => route.isFirst)
                                        }
                                    }
                                  else
                                    widget.onIndexChanged(1)
                                },
                                selected: widget.selectedIndex == 1,
                                icon: Icon(DailyTrojanIcons.search),
                              ),
                              BottomBarIconButton(
                                onPressed: () => {
                                  if (widget.selectedIndex == 2)
                                    {
                                      if (widget.navKey.currentState != null &&
                                          widget.navKey.currentState!.canPop())
                                        {
                                          widget.navKey.currentState!.popUntil(
                                              (route) => route.isFirst)
                                        }
                                    }
                                  else
                                    widget.onIndexChanged(2)
                                },
                                selected: widget.selectedIndex == 2,
                                icon: Icon(DailyTrojanIcons.game),
                              ),
                            ],
                          ),
                        )),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: IgnorePointer(
                    child: Container(
                      height: 50,
                      width: 160,
                      child: ValueListenableBuilder(
                          valueListenable: scrollProgress,
                          builder: (context, value, child) {
                            return ValueListenableBuilder(
                                valueListenable: scrollProgressOpacity,
                                builder: (context, value, child) {
                                  return CustomPaint(
                                    painter: OutlineRadialPainter(
                                      scrollProgress: scrollProgress.value,
                                      scrollProgressOpacity:
                                          scrollProgressOpacity.value,
                                      color: theme.colorScheme.primary,
                                      strokeWidth: 2.0,
                                    ),
                                  );
                                });
                          }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OutlineRadialPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double scrollProgress;
  final double scrollProgressOpacity;

  OutlineRadialPainter(
      {required this.color,
      required this.strokeWidth,
      required this.scrollProgress,
      required this.scrollProgressOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    // A Paint object for the outline with rounded caps
    final outlinePaint = Paint()
      ..color = color.withOpacity(scrollProgressOpacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Add round caps to the stroke
    var r = size.height / 2;

    // Create the path
    final path = Path();
    // Start at the center of the left edge
    path.moveTo(size.width / 2, size.height);
    // Draw a line to the center of the right edge
    path.lineTo(r, size.height);
    path.arcToPoint(
      Offset(r, 0),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.lineTo(size.width - r, 0);
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: Radius.circular(r),
      clockwise: true,
    );
    path.lineTo(size.width / 2, size.height);
    path.close();
    final linePath = Path(); //simpler
    linePath.moveTo(r, size.height);
    linePath.lineTo(size.width - r, size.height);

    // Fill the path from 0 to t (where t is between 0 and 1)
    double t = 0;
    t = scrollProgress;

    final metrics = linePath.computeMetrics();
    for (final metric in metrics) {
      final extractLength = metric.length * t.clamp(0.0, 1.0);
      final partialPath = metric.extractPath(0, extractLength);
      canvas.drawPath(partialPath, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(OutlineRadialPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.scrollProgress != scrollProgress ||
        oldDelegate.scrollProgressOpacity != scrollProgressOpacity;
  }
}

final navigatorObservers = [
  MainNavigatorObserver(),
  MainNavigatorObserver(),
  MainNavigatorObserver(),
];
final navigatorKeys = [
  GlobalKey<NavigatorState>(),
  GlobalKey<NavigatorState>(),
  GlobalKey<NavigatorState>()
];
final articleRouteObservers = [
  RouteObserver<ModalRoute<void>>(),
  RouteObserver<ModalRoute<void>>(),
  RouteObserver<ModalRoute<void>>()
];

RouteObserver<ModalRoute<void>>? articleRouteObserver =
    articleRouteObservers[0];

class MainNavigatorObserver extends NavigatorObserver {
  final ValueNotifier<bool?> isOnHomePage = ValueNotifier<bool?>(null);

  void didChangeTop(Route route, Route? previousRoute) {
    print('Top route changed: ${route.settings.name}');
    isOnHomePage.value = route.settings.name == "/";
    if (route.settings.name == "/") {
      resetScrollProgress();
      hideShareButton();
      hideShareButtonWithBookmarkButton();
    }
  }
}

class BottomBarIconButton extends StatelessWidget {
  BottomBarIconButton({
    super.key,
    this.selected,
    required this.onPressed,
    required this.icon,
  });

  final bool? selected;
  final Function() onPressed;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return IconButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      icon: icon,
      style: ButtonStyle(
        animationDuration: const Duration(milliseconds: 100),
        overlayColor: WidgetStateProperty.all(Colors.transparent), // no splash
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.pressed)) {
            return theme.colorScheme.outline.withAlpha(80); // pressed color
          } else if (selected == true) {
            return theme.colorScheme.primary; // selected color
          }
          return theme.colorScheme.outline; // default color
        }),
      ),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }
}

class _MainNavigator extends StatelessWidget {
  final int selectedIndex;

  const _MainNavigator(
      {super.key,
      required this.selectedIndex,
      required this.navKey,
      required this.navigatorObserver,
      required this.articleRouteObserver});
  final NavigatorObserver navigatorObserver;
  final RouteObserver<ModalRoute<void>> articleRouteObserver;
  final GlobalKey<NavigatorState> navKey;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navKey,
      observers: [navigatorObserver, articleRouteObserver],
      onGenerateRoute: (settings) {
        late Widget page;
        switch (selectedIndex) {
          case 0:
            page = HomePage();
            break;
          case 1:
            page = SearchPage();
            break;
          case 2:
            page = GamesPage();
            break;
          default:
            page = const SizedBox.shrink();
        }

        return SlideOverPageRoute(child: page, settings: settings);
      },
    );
  }
}

const headlineVerticalPadding = EdgeInsets.only(top: 80.0, bottom: 20.0);
const overallContentPadding =
    EdgeInsets.only(left: 20.0, right: 20.0, top: 60.0, bottom: 50.0);
const verticalContentPadding = EdgeInsets.only(top: 60.0, bottom: 50.0);
const horizontalContentPadding = EdgeInsets.only(left: 20.0, right: 20.0);
const bottomAppBarPadding = EdgeInsets.only(bottom: 70.0);

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

ValueNotifier<double> scrollProgress = ValueNotifier(0.0);
ValueNotifier<double> scrollProgressOpacity = ValueNotifier(0.0);
ValueNotifier<bool> shouldShowShareButton = ValueNotifier(false);
ValueNotifier<bool> shouldShowBookmarkButton = ValueNotifier(false);
ValueNotifier<String> bookmarkId = ValueNotifier("");
ValueNotifier<String> shareLink = ValueNotifier("");
ValueNotifier<String> shareTitle = ValueNotifier("");

Future<void> showShareButton(String link, String title) async {
  print("Showing share button with link $link");

  WidgetsBinding.instance.addPostFrameCallback((_) {
    shareLink.value = link;
    shareTitle.value = title;
    shouldShowShareButton.value = true;
  });
}

Future<void> hideShareButton() async {
  print("Hiding share button");
  WidgetsBinding.instance.addPostFrameCallback((_) {
    shouldShowShareButton.value = false;
  });
}

Future<void> showShareButtonWithBookmarkButton(
    String link, String title, String postId) async {
  print("Showing bookmark button with postId $postId");

  WidgetsBinding.instance.addPostFrameCallback((_) {
    bookmarkId.value = postId;
    shouldShowBookmarkButton.value = true;
    shareLink.value = link;
    shareTitle.value = title;
  });
}

Future<void> hideShareButtonWithBookmarkButton() async {
  print("Hiding bookmark button");
  WidgetsBinding.instance.addPostFrameCallback((_) {
    shouldShowBookmarkButton.value = false;
  });
}

Future<void> lerpScrollProgress(double t) async {
  final start = scrollProgress.value;
  final duration = const Duration(milliseconds: 450);
  final startTime = DateTime.now();
  final endTime = startTime.add(duration);

  while (DateTime.now().isBefore(endTime)) {
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final progress = (elapsed / duration.inMilliseconds).clamp(0.0, 1.0);
    scrollProgress.value =
        start + (t - start) * Curves.linearToEaseOut.transform(progress);

    await Future.delayed(const Duration(milliseconds: 16));
  }
  scrollProgress.value = t;
}

Future<void> setScrollProgress(double t) async {
  scrollProgress.value = t;
}

Future<void> resetScrollProgress() async {
  lerpScrollProgress(0.0);
}

Future<void> lerpScrollProgressOpacity(double t) async {
  final start = scrollProgressOpacity.value;
  final duration = const Duration(milliseconds: 100);
  final startTime = DateTime.now();
  final endTime = startTime.add(duration);

  while (DateTime.now().isBefore(endTime)) {
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final progress = (elapsed / duration.inMilliseconds).clamp(0.0, 1.0);
    scrollProgressOpacity.value =
        start + (t - start) * Curves.easeInOut.transform(progress);
    await Future.delayed(const Duration(milliseconds: 16));
  }
  scrollProgressOpacity.value = t;
}

bool opacityState = false;

void initScrollProgressListener() {
  scrollProgress.addListener(progressListener);
}

void disposeScrollProgressListener() {
  print("Disposing scroll progress listener");
  scrollProgress.removeListener(progressListener);
}

void progressListener() {
  var threshold = 0.015;

  if (scrollProgress.value < threshold && opacityState == false) {
    opacityState = true;
    lerpScrollProgressOpacity(0.0);
  }
  if (scrollProgress.value >= threshold && opacityState == true) {
    opacityState = false;
    lerpScrollProgressOpacity(1.0);
  }
}

void HapticButtonTap() async {
  final canVibrate = await Haptics.canVibrate();
  if (canVibrate) {
    await Haptics.vibrate(HapticsType.rigid);
  }
}
