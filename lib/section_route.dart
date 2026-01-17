///*
/// A Section route shows all articles from a specific section in chronological order. Given by category ID.
library;

import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:dailytrojan/utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class SectionRoute extends StatefulWidget {
  const SectionRoute({super.key});

  @override
  State<SectionRoute> createState() => _SectionRouteState();
}

class _SectionRouteState extends StatefulScrollControllerRoute<SectionRoute> {
  List<Post> sectionPosts = [];
  int sectionID = 0;
  late final pagingController = PagingController<int, Post>(
    getNextPageKey: (state) =>
        state.lastPageIsEmpty ? null : state.nextIntPageKey,
    fetchPage: (pageKey) => fetchPage(pageKey),
  );

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
                    (index == 0)
                        ? PostElementUltimate(
                            post: item,
                            dek: true,
                            topImage: true,
                            publishDate: true,
                            bookmarkShare: true,
                            hedSize: 24,
                          )
                        : PostElementUltimate(
                            post: item,
                            dek: true,
                            rightImage: true,
                            publishDate: true,
                            bookmarkShare: true,
                          ),
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
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: theme.colorScheme.surfaceContainerLowest,
        surfaceTintColor: theme.colorScheme.surfaceContainerLowest,
        title: Text(
          appState.activeSection?.title ?? "No Section",
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

  Future<void> initPosts() async {
    sectionPosts = await fetchPostsWithMainCategoryAndCount(sectionID, 10);
  }

  Future<void> refreshPosts() async {
    await initPosts();
    setState(() {});
  }

  Future<List<Post>> fetchPage(int pageKey) async {
    final newItems = await fetchPostsWithMainCategoryAndCount(sectionID, 15,
        pageOffset: pageKey);
    return newItems;
  }
}
