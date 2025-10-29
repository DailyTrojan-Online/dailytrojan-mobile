///*
/// A Main Section shows all of its subsections, and shows a few recent articles from each subsection.
/// Users will then have the option to either view all articles from this main section in chronological order, or view all articles from a specific subsection in chronological order.
library;

import 'dart:ui';
import "dart:math";

import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:dailytrojan/section_route.dart';
import 'package:dailytrojan/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class MainSectionRoute extends StatefulWidget {
  const MainSectionRoute({super.key});

  @override
  State<MainSectionRoute> createState() => _MainSectionRouteState();
}

class _MainSectionRouteState
    extends StatefulScrollControllerRoute<MainSectionRoute> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold,
        height: .8);
    final subStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onSurface, fontFamily: "Inter");
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: AnimatedTitleScrollView(
          shouldShowBorderWhenFullyExpanded: false,
          backButton: false,
          title: Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Text(
              appState.activeMainSection?.mainSection.title ?? "No Section",
              style: headerStyle,
            ),
          ),
          children: [
            Padding(
              padding: bottomAppBarPadding,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      appState.setSection(
                          appState.activeMainSection?.mainSection ??
                              appState.activeSection!);
                      Navigator.push(
                        context,
                        SlideOverPageRoute(child: SectionRoute()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0)
                          .add(horizontalContentPadding),
                      child: Row(
                        children: [
                          Text(
                            'View All ${appState.activeMainSection?.mainSection.title} Articles',
                            style: subStyle,
                          ),
                          SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: horizontalContentPadding,
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  for (var section
                      in appState.activeMainSection?.subsections ?? [])
                    SubSection(section: section),
                ],
              ),
            ),
          ]),
    );
  }
}

class SubSection extends StatefulWidget {
  final Section section;

  const SubSection({
    super.key,
    required this.section,
  });

  @override
  State<SubSection> createState() => _SubSectionState();
}

class _SubSectionState extends State<SubSection> {
  List<Post> posts = [];
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    final headlineStyle = theme.textTheme.headlineMedium!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final subStyle = theme.textTheme.titleSmall!
        .copyWith(color: theme.colorScheme.onSurface, fontFamily: "Inter");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: horizontalContentPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(widget.section.title, style: headlineStyle),
              ),
              Divider(
                height: 1,
              )
            ],
          ),
        ),
        FutureBuilder(
          future: initPosts(widget.section.id),
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
                  final screenWidth = MediaQuery.of(context).size.width;
                  final columnWidth = screenWidth - 40; // 90% of screen width
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: horizontalContentPadding,
                      child: IntrinsicWidth(
                        child: Column(
                          children: [
                            for (int i = 0; i < 2; i++)
                              Column(children: [
                                IntrinsicHeight(
                                  child: Row(
                                    spacing: 10,
                                    children: [
                                      for (int j = i; j < min(6, posts.length.isOdd ? posts.length - 1 : posts.length); j += 2)
                                        SizedBox(
                                          width: columnWidth,
                                          child: PostElementUltimate(
                                                post: posts[j],
                                                dek: false,
                                                leftImage: true,
                                                showBreakingTag: false,
                                                publishDate: true,
                                                bookmarkShare: true,
                                                expandVertically: true,
                                                horizontalPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 0.0),
                                              ),
                                        ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 1,
                                ),
                              ]),
                          ],
                        ),
                      ),
                    ),
                  );
                }
            }
          },
        ),
        InkWell(
          onTap: () {
            appState.setSection(widget.section);
            Navigator.push(
              context,
              SlideOverPageRoute(child: SectionRoute()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0)
                .add(horizontalContentPadding),
            child: Row(
              children: [
                Text(
                  'View All ${widget.section.title} Articles',
                  style: subStyle,
                ),
                SizedBox(width: 10),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: horizontalContentPadding,
          child: Divider(
            height: 1,
          ),
        )
      ],
    );
  }

  Future<void> initPosts(int id) async {
    posts = await fetchPostsWithMainCategoryAndCount(id, 6);
  }

  Future<void> refreshPosts(int id) async {
    await initPosts(id);
    setState(() {});
  }
}
