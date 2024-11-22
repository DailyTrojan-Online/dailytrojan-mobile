import 'dart:async';
import 'dart:convert';

import 'package:dailytrojan/article_route.dart';
import 'package:dailytrojan/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart';

class PostList extends StatelessWidget {
  const PostList({
    super.key,
    required this.posts,
  });

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var post in posts) PostElementImage(post: post),
      ],
    );
  }
}

class PostElementImage extends StatelessWidget {
  final Post post;

  const PostElementImage({
    super.key,
    required this.post,
  });

  final double imageSize = 100.0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.headlineSmall!.copyWith(
        color: theme.colorScheme.primary,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.tertiary, fontSize: 14.0, fontFamily: "Inter");
    final authorStyle = theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.tertiary, fontFamily: "Inter");
    final excerptStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.secondary, fontSize: 14.0, fontFamily: "SourceSerif4");

    var articleDOM = parse(post.content);
    var author = '';
    articleDOM.querySelectorAll('h6').forEach((e) {
      // a really awful way to do things because the wordpress api doesnt return the correct author 100% of the time.
      ;
      if (e.innerHtml.startsWith("By")) {
        author = (htmlUnescape.convert(e.innerHtml));
        return;
      }
    });

    return InkWell(
      onTap: () {
        appState.setArticle(post);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ArticleRoute()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0).add(horizontalContentPadding),
        child: Row(
          children: [
            Image(
              image: NetworkImage(post.coverImage),
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  htmlUnescape.convert(post.title),
                  style: headlineStyle,
                ),
                SizedBox(width: 10),
                Text(author, style: authorStyle),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class PostElement extends StatelessWidget {
  final Post post;

  const PostElement({
    super.key,
    required this.post,
  });

  final double imageSize = 100.0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.primary,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.tertiary, fontSize: 14.0, fontFamily: "Inter");
    final authorStyle = theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.tertiary, fontFamily: "Inter");
    final excerptStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.secondary, fontSize: 14.0, fontFamily: "SourceSerif4");

    var articleDOM = parse(post.content);
    var author = '';
    articleDOM.querySelectorAll('h6').forEach((e) {
      // a really awful way to do things because the wordpress api doesnt return the correct author 100% of the time.
      ;
      if (e.innerHtml.startsWith("By")) {
        author = (htmlUnescape.convert(e.innerHtml));
        return;
      }
    });

    return InkWell(
      onTap: () {
        appState.setArticle(post);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ArticleRoute()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0).add(horizontalContentPadding),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                post.breaking ? Text("BREAKING", style: subStyle.copyWith(fontWeight: FontWeight.bold)) : EmptyWidget(),
                Text(
                  htmlUnescape.convert(post.title),
                  style: headlineStyle,
                ),
                SizedBox(height: 6),
                Text(author, style: authorStyle)
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class PostElementImageLarge extends StatelessWidget {
  final Post post;

  const PostElementImageLarge({
    super.key,
    required this.post,
  });

  final double imageSize = 100.0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.headlineSmall!.copyWith(
        color: theme.colorScheme.primary,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.tertiary, fontSize: 14.0, fontFamily: "Inter");
    final authorStyle = theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.tertiary, fontFamily: "Inter");
    final excerptStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.secondary, fontSize: 16.0, fontFamily: "SourceSerif4");

    var articleDOM = parse(post.content);
    var author = '';
    articleDOM.querySelectorAll('h6').forEach((e) {
      // a really awful way to do things because the wordpress api doesnt return the correct author 100% of the time.
      ;
      if (e.innerHtml.startsWith("By")) {
        author = (htmlUnescape.convert(e.innerHtml));
        return;
      }
    });

    return InkWell(
      onTap: () {
        appState.setArticle(post);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ArticleRoute()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0).add(horizontalContentPadding),
        child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                post.breaking ? Text("BREAKING", style: subStyle.copyWith(fontWeight: FontWeight.bold)) : EmptyWidget(),
                Text(
                  htmlUnescape.convert(post.title),
                  style: headlineStyle,
                ),
                SizedBox(height: 6),
                Text(parse(htmlUnescape.convert(post.excerpt)).querySelector("p")?.innerHtml ?? "", style: excerptStyle),
                SizedBox(height: 6),
                Text(author, style: authorStyle),
                SizedBox(height: 8),                    
                Image(
                  image: NetworkImage(post.coverImage),
                  fit: BoxFit.cover,
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}
