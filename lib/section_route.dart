///*
/// A Section route shows all articles from a specific section in chronological order. Given by category ID.
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

class SectionRoute extends StatefulWidget {
  const SectionRoute({super.key});

  @override
  State<SectionRoute> createState() => _SectionRouteState();
}

class _SectionRouteState extends State<SectionRoute> {
  List<Post> sectionPosts = [];
  int sectionID = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    sectionID = appState.activeSection?.id ?? 0;
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refreshPosts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: FutureBuilder(
                future: initPosts(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    default:
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return Column(
                          children: [
                            for (int i = 0; i < sectionPosts.length; i++)
                              Column(
                                children: [
                                  (i == 0) ? PostElementImageLargeFullTop(post: sectionPosts[i]) : PostElementImage(post: sectionPosts[i]),
                                  Padding(padding: horizontalContentPadding, child: Divider(height: 1,))
                                ],
                              ),
                          ],
                        );
                      }
                  }
                },
              ),
            )
          ),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        surfaceTintColor: theme.colorScheme.surfaceContainerHigh,
        title: Text(appState.activeSection?.title ?? "No Section", style: headlineStyle,),
        centerTitle: false,
      ),
    );
  }


  Future<void> initPosts() async {
    sectionPosts =
        await fetchPostsWithMainCategoryAndCount(sectionID, 10);
  }

  Future<void> refreshPosts() async {
    await initPosts();
    setState(() {});
  }
}
