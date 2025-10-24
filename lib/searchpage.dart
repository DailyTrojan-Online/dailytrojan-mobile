import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  Future<List<Map<String, dynamic>>>? _searchResults;

  // Simulate a network call to fetch search results
  Future<List<Map<String, dynamic>>> fetchSearchResults(String query) async {
    // Replace with your API URL
    final url = Uri.parse('https://yourapi.com/search?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON response
      List data = json.decode(response.body);
      return data.map((item) => {
        'title': item['title'],
        'excerpt': item['excerpt'],
      }).toList();
    } else {
      throw Exception('Failed to load search results');
    }
  }

  void _search() {
    setState(() {
      // Start the search and fetch the results
      _searchResults = fetchSearchResults(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: _search,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Search anything Daily Trojan!'));
          } else {
            final results = snapshot.data!;
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                return ListTile(
                  title: Text(result['title']),
                  subtitle: Text(result['excerpt']),
                  onTap: () {
                    // Handle tap on result (e.g., open the article)
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
