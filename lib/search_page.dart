import 'dart:async';
import 'dart:convert';
import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  _SearchPageState createState() => _SearchPageState();
}

Future<Post> fetchPostById(int id) async {
  //fetching post by id from the user's search
  const liveUpdatesTag = 34430;
  const classifiedTag = 27249;
  final tagExcludes = [liveUpdatesTag, classifiedTag];

  final url = Uri.parse(
    '${POSTS_BASE_URL}?include=$id&tags_exclude=${tagExcludes.join(',')}',
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

  bool hasSearched = false;
  String searchQuery = "";

  void _search() {
    print("Searching");
    Navigator.push(
      context,
      SlideOverPageRoute(
          child: SearchRoute(
        searchQuery: _searchController.text,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "Inter",
        fontWeight: FontWeight.bold);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedTitleScrollView(
          collapsingSliverAppBar: CollapsingSliverAppBar(
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(61.0),
              child: Column(
                children: [
                  Divider(height: 1),
                  Padding(
                    padding: horizontalContentPadding
                        .add(EdgeInsetsGeometry.symmetric(vertical: 8))
                        .subtract(EdgeInsets.only(top: 1)),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontFamily: "Inter"),
                      onSubmitted: (value) {
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
                ],
              ),
            ),
            shouldShowBorderWhenFullyExpanded: false,
            title: Text(
              "Search",
              style: headerStyle,
            ),
            actions: [NavigationBarAccountButton()],
          ),
          children: [
            Padding(
              padding: bottomAppBarPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: horizontalContentPadding
                        .add(EdgeInsets.only(top: 16, bottom: 8)),
                    child: Text(
                      'Sections',
                      style: headlineStyle,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: horizontalContentPadding,
                    child: Divider(height: 1),
                  ),
                  SectionsList()
                ],
              ),
            ),
          ]),
    );
  }
}

class SearchRoute extends StatefulWidget {
  final String searchQuery;
  SearchRoute({required this.searchQuery});

  @override
  State<SearchRoute> createState() => _SearchRouteState();
}

class _SearchRouteState extends State<SearchRoute> {
  late final pagingController = PagingController<int, Post>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => fetchSearchResults(widget.searchQuery, pageKey),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);

    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
          bottom: false,
          child: PagingListener(
            controller: pagingController,
            builder: (context, state, fetchNextPage) => RefreshIndicator(
              onRefresh: () async {
                pagingController.refresh();
              },
              child: PagedListView<int, Post>(
                state: state,
                fetchNextPage: fetchNextPage,
                padding: EdgeInsets.only(bottom: 20.0 + bottomPadding)
                    .add(bottomAppBarPadding),
                builderDelegate: PagedChildBuilderDelegate(
                  itemBuilder: (context, item, index) => Column(
                    children: [
                      PostElementUltimate(
                          post: item,
                          publishDate: true,
                          bookmarkShare: true,
                          dek: true,
                          leftImage: true),
                      Padding(
                          padding: horizontalContentPadding,
                          child: Divider(
                            height: 1,
                          ))
                    ],
                  ),
                ),
              ),
            ),
          )),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        surfaceTintColor: theme.colorScheme.surfaceContainerLowest,
        title: Text(
          widget.searchQuery,
          style: headlineStyle,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.colorScheme.outlineVariant,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Future<List<Post>> fetchSearchResults(String query, int page) async {
    try {
      final queryString = Uri.encodeComponent(query);
      final url = Uri.parse(
          '${SEARCH_BASE_URL}?search=$queryString&per_page=15&page=$page');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Fetch full Post objects for each result
        final List<Post> posts = [];
        for (var post in jsonDecode(response.body)) {
          posts.add(Post.fromJson(post as Map<String, dynamic>));
        }
        return posts;
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
    }
    return [];
  }
}
