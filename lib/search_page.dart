import 'dart:async';
import 'dart:convert';
import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

Future<Post> fetchPostById(int id) async {
  //fetching post by id from the user's search
  const liveUpdatesTag = 34430;
  const classifiedTag = 27249;
  final tagExcludes = [liveUpdatesTag, classifiedTag];

  const podcastCategory = 14432;
  const multimediaCategory = 9785;
  final categoryExcludes = [podcastCategory, multimediaCategory];

  final url = Uri.parse(
    'https://dailytrojan.com/wp-json/wp/v2/posts?include=$id&tags_exclude=${tagExcludes.join(',')}&categories_exclude=${categoryExcludes.join(',')}',
  );

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final List<dynamic> posts = json.decode(response.body);
    if (posts.isNotEmpty) {
      return Post.fromJson(posts[0] as Map<String, dynamic>);
    } else {
      throw Exception('Post not found');
    }
  } else {
    throw Exception('Failed to load post');
  }
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Post> _searchResults = [];
  bool _isLoading = false;
  List<Post> trendingPosts = [];

  Future<void> fetchSearchResults(String query) async {
    //fetching articles from user's search
    setState(() {
      _isLoading = true;
      _searchResults = []; // clear previous results
    });

    try {
      final queryString = Uri.encodeComponent(query);
      final url = Uri.parse(
          'https://dailytrojan.com/wp-json/wp/v2/search?search=$queryString');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        // Fetch full Post objects for each result
        final List<Post> posts = [];
        for (var item in data) {
          if (item['id'] != null) {
            try {
              final post = await fetchPostById(item['id']);
              posts.add(post);
            } catch (e) {
              print("Failed to fetch post for ID ${item['id']}: $e");
            }
          }
        }

        setState(() {
          _searchResults = posts;
        });
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to load search results: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _search() {
    fetchSearchResults(_searchController.text);
  }

  Future<void> initPosts() async {
    trendingPosts = await fetchTrendingPosts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "Inter",
        fontWeight: FontWeight.bold);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedTitleScrollView(
        shouldShowBorderWhenFullyExpanded: false,
          title: Text(
            "Search",
            style: headerStyle,
          ),
          backButton: false,
          children: [
            Padding(
              padding: horizontalContentPadding,
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                    color: theme.colorScheme.onSurface, fontFamily: "Inter"),
                onSubmitted: (value) {
                  _search();
                  FocusScope.of(context).unfocus();
                },
                onEditingComplete: () {
                  _search();
                  FocusScope.of(context).unfocus();
                },
                decoration: InputDecoration(
                  fillColor: theme.colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                    
                  ),
                  contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                  filled: true,
                  hintText: 'Search anything Daily Trojan!',
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                      });
                    },
                  ),
                ),
              ),
            ),
            Column(children: [
              if (_isLoading) Padding(
                                padding: const EdgeInsets.all(30.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ), // progress/loading bar
              !_isLoading ?
                _searchResults.isEmpty
                    ? FutureBuilder(
                        future: initPosts(),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return Padding(
                                padding: const EdgeInsets.all(30.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              );
                            default:
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: horizontalContentPadding
                                          .add(EdgeInsets.only(top: 20)),
                                      child: Text(
                                        'Trending Articles',
                                        style: headlineStyle,
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    ...trendingPosts.map((post) => Column(
                                          children: [
                                            PostElementImageShort(post: post),
                                            Padding(
                                              padding: horizontalContentPadding,
                                              child: Divider(height: 1),
                                            ),
                                          ],
                                        )),
                                  ],
                                );
                              }
                          }
                        },
                      )
                    : Column(
                        children: [
                          for (var post in _searchResults)
                            Column(
                              children: [
                                PostElementImageShort(post: post),
                                Padding(
                                  padding: horizontalContentPadding,
                                  child: Divider(height: 1),
                                ),
                              ],
                            ),
                        ],
                      ) : EmptyWidget(),
            ]),
          ]),
    );
  }
}
