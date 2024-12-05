import 'package:dailytrojan/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

class ArticleRoute extends StatefulWidget {
  const ArticleRoute({super.key});

  @override
  State<ArticleRoute> createState() => _ArticleRouteState();
}

class _ArticleRouteState extends State<ArticleRoute> {
  double articleProgress = 00;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      double currentProgressValue =
          scrollController.offset / scrollController.position.maxScrollExtent;

      if (currentProgressValue < 0.0) {
        currentProgressValue = 0.0;
      }

      if (currentProgressValue > 1.0) {
        currentProgressValue = 1.0;
      }

      articleProgress = currentProgressValue;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 16.0,
        fontFamily: "SourceSerif4");
    var appState = context.watch<MyAppState>();

    var articleDOM = parse(appState.article?.content ?? "No content");
    articleDOM.querySelector("[id='article-donation-plug']")?.remove();
    articleDOM.querySelector("[id='ema_signup_form']")?.remove();
    articleDOM.querySelectorAll("br").forEach((e) => e.remove());
    articleDOM.querySelector("[id='column-hdshot']")?.remove();
    articleDOM.querySelectorAll('h6').forEach((e) {
      var p = dom.Element.tag("p");
      p.innerHtml = e.innerHtml;
      p.classes.add("h6");
      e.replaceWith(p);
    });
    var meta = articleDOM.querySelectorAll(".av-post-metadata-container");
    if (meta.isNotEmpty) {
      var siblings = meta.last.parentNode?.nodes;
      var index = siblings?.indexOf(meta.last);
      if (index != null && siblings != null) {
        for (var i = siblings.length - 1; i > index; i--) {
          siblings[i].remove();
        }
      }
      // Traverse up the parent elements and remove any tags that come after the meta element
      var parent = meta.last.parentNode;
      while (parent != null) {
        var parentSiblings = parent.parent?.nodes;
        if (parentSiblings != null) {
          var parentIndex = parentSiblings.indexOf(parent);
          for (var i = parentSiblings.length - 1; i > parentIndex; i--) {
            parentSiblings[i].remove();
          }
        }
        parent = parent.parent;
      }
      meta.last.remove();
    }
    //remove subscription form stuff. extremely finicky, and if the text ever changes,  this will fail, but we can only hope.
    var hrEls = articleDOM.querySelectorAll("hr");
    for (var hr in hrEls) {
      var next = hr.nextElementSibling;
      if (next != null && next.innerHtml.contains("Daily")) {
        var nextNext = next.nextElementSibling;
        if (nextNext != null && nextNext.innerHtml.contains("Subscribe")) {
          hr.remove();
          next.remove();
          nextNext.nextElementSibling?.remove();
          nextNext.remove();
        }
      }
    }

    //TODO: weekly frame and live events both handle html differently. ill need to investigate what other pages do things differently too

    var articleContent = articleDOM.outerHtml.toString();

    // print(articleContent);
    return Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: overallContentPadding,
                    child: SafeArea(
                      bottom: false,
                      child: HtmlWidget(
                        articleContent,
                        textStyle: bodyStyle,
                        customStylesBuilder: (element) {
                          if (element.localName == "h1") {
                            return {
                              'color': toHex(theme.colorScheme.onSurface),
                            };
                          }
                          if (element.localName == "h2") {
                            return {
                              'color': toHex(theme.colorScheme.onSurfaceVariant),
                            };
                          }
                          if (element.className.contains("h6")) {
                            return {'color': toHex(theme.colorScheme.outline), 'font-family': 'Inter', 'font-size': '14px'};
                          }
                          if (element.className
                              .contains("avia-image-container")) {
                            return {
                              "margin-top": "16px",
                            };
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          surfaceTintColor: theme.colorScheme.surfaceContainerHigh,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context);
              },
              padding: EdgeInsets.all(12.0),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 6.0,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: theme.colorScheme.outlineVariant,
                  ),
                  child: FractionallySizedBox(
                    heightFactor: 1.0,
                    widthFactor: articleProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.bookmark_border),
                  onPressed: () {},
                  padding: EdgeInsets.all(12.0),
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    Share.share(
                        appState.article?.link ?? "https://dailytrojan.com");
                  },
                  padding: EdgeInsets.all(12.0),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert_sharp),
                  onPressed: () {},
                  padding: EdgeInsets.all(12.0),
                ),
              ],
            ),
          ]),
        ));
  }
}

String toHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
}
