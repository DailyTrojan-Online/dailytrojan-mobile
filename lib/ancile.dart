import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:dailytrojan/main.dart';
import 'package:http/http.dart' as http;
const Duration cacheDuration = Duration(minutes: 2);

Future<List<(Columnist, Post)>> getColumnists(String section) async {
  final url = Uri.parse('${API_BASE_URL}app/columns?section=${section}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
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

SpecialEdition? cachedSpecialEdition;
DateTime? trendingSpecialEditionTime;

Future<SpecialEdition?> getSpecialEdition() async {
  if (cachedSpecialEdition != null &&
      trendingSpecialEditionTime != null &&
      DateTime.now().difference(trendingSpecialEditionTime!) < cacheDuration) {
    trendingSpecialEditionTime = DateTime.now();
    return Future.value(cachedSpecialEdition);
  }
  trendingSpecialEditionTime = DateTime.now();
  final url = Uri.parse('${API_BASE_URL}app/editions');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<SpecialEdition> editions = [];
    for (var ed in jsonDecode(response.body)) {
      editions.add(SpecialEdition.fromJson(ed));
    }
    await editions[0].fetchArticles();
    cachedSpecialEdition = editions[0];
    return editions[0];
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
DateTime? trendingCachedTime;

Future<List<Post>> fetchTrendingPosts() {
  if (cachedTrendingPosts != null &&
      trendingCachedTime != null &&
      DateTime.now().difference(trendingCachedTime!) < cacheDuration) {
    trendingCachedTime = DateTime.now();
    return Future.value(cachedTrendingPosts);
  }
  trendingCachedTime = DateTime.now();
  //first we want to really quickly fetch the page of trending articles
  //then we want to parse its contents as html and find all the urls for the articles
  //then we want to use those slugs in a new query to the posts api and then use those pieces of data
  final trendingUrl = Uri.parse(
      'https://dailytrojan.com/wp-json/wordpress-popular-posts/v1/popular-posts?post_type=post&limit=10&range=last7days');
  return http.get(trendingUrl).then((response) {
    if (response.statusCode == 200) {
      var ids = <int>[];
      for (var post in jsonDecode(response.body)) {
        ids.add(post['id'] as int);
      }
      //now we have a list of slugs, we can use them to fetch the posts
      return fetchPostsByIds(ids).then((posts) {
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
      print(response.statusCode);
      print(response.body);
      throw Exception('Failed to load posts');
    }
  });
}

Future<List<Post>> fetchPostsBySlugs(List<String> slugs) {
  print("Fetching posts with slugs $slugs");
  final url = Uri.parse('${POSTS_BASE_URL}?slug=${slugs.join(',')}');
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
