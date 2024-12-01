import 'dart:async';
import 'dart:convert';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

  Future<Post> fetchPostById(int id) async { //fetching post by id from the user's search
    final live_updates_tag = 34430;
    final classified_tag = 27249;
    final tag_excludes = [live_updates_tag, classified_tag];

    final podcast_category = 14432;
    final multimedia_category = 9785;
    final category_excludes = [podcast_category, multimedia_category];

    final url = Uri.parse(
      'https://dailytrojan.com/wp-json/wp/v2/posts?include=$id&tags_exclude=${tag_excludes.join(',')}&categories_exclude=${category_excludes.join(',')}',
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

  Future<void> fetchSearchResults(String query) async { //fetching articles from user's search
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: _search,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(), // progress/loading bar
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      'Search anything Daily Trojan!',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final post = _searchResults[index];
                      return PostElementSearch(post: post); // each article has post element
                    },
                  ),
          ),
        ],
      ),
    );
  }
}



