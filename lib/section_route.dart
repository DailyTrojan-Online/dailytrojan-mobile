///*
/// A Section route shows all articles from a specific section in chronological order. Given by category ID.
library;
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:dailytrojan/utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SectionRoute extends StatefulWidget {
  const SectionRoute({super.key});

  @override
  State<SectionRoute> createState() => _SectionRouteState();
}

class _SectionRouteState extends StatefulScrollControllerRoute<SectionRoute> {
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

    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: refreshPosts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:  EdgeInsets.only(bottom: 20.0 + bottomPadding).add(bottomAppBarPadding),
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
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        surfaceTintColor: theme.colorScheme.surfaceContainerLowest,
        title: Text(appState.activeSection?.title ?? "No Section", style: headlineStyle,),
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


  Future<void> initPosts() async {
    sectionPosts =
        await fetchPostsWithMainCategoryAndCount(sectionID, 10);
  }

  Future<void> refreshPosts() async {
    await initPosts();
    setState(() {});
  }
}
