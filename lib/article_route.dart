import 'dart:async';

import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

void addNewlinesToBlocks(dom.Document document) {
  final blockTags = {
    'p',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    'blockquote',
  };

  void processNode(dom.Node node) {
    if (node is dom.Element) {
      for (final child in node.nodes.toList()) {
        processNode(child);
      }

      if (blockTags.contains(node.localName)) {
        node.append(dom.Text('\u00A0')); 
        // node.append(dom.Element.tag('br'));
        // node.append(dom.Element.tag('br'));
        // node.append(dom.Element.tag('br'));
      }
    }
  }

  for (final child in document.body?.nodes.toList() ?? []) {
    processNode(child);
  }
}

class ArticleRoute extends StatefulWidget {
  ArticleRoute({super.key, this.article, this.articleUrl});
  Post? article;
  final String? articleUrl;

  @override
  State<ArticleRoute> createState() => _ArticleRouteState();
}

class _ArticleRouteState extends StatefulScrollControllerRoute<ArticleRoute> {
  double articleProgress = 0.0;
  ScrollController scrollController = ScrollController();
  final scrollProgressNotifier = ValueNotifier<double>(0.0);

  String get postId => widget.article?.id ?? "-1";

  void toggleBookmark() {
    print(postId);
    if (BookmarkService.isBookmarked(postId)) {
      BookmarkService.removeBookmark(postId);
    } else {
      BookmarkService.addBookmark(postId);
    }
    setState(() {}); // Refresh UI
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    articleRouteObserver?.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    articleRouteObserver?.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    print('[ARTICLE IMPLEMENTATION] MyRouteAwareWidget didPush: This route is now visible. [BASE IMPLEMENTATION]');
    
    resetScrollProgress();
    // showShareButton(widget.article?.link ?? "https://dailytrojan.com", widget.article?.title ?? "Daily Trojan");
    showShareButtonWithBookmarkButton(widget.article?.link ?? "https://dailytrojan.com", widget.article?.title ?? "Daily Trojan", postId);
  }

  @override
  void didPopNext() {
    print('[ARTICLE IMPLEMENTATION] MyRouteAwareWidget didPopNext: This route is now visible again.');
    lerpScrollProgress(articleProgress);
    // showShareButton(widget.article?.link ?? "https://dailytrojan.com", widget.article?.title ?? "Daily Trojan");
    showShareButtonWithBookmarkButton(widget.article?.link ?? "https://dailytrojan.com", widget.article?.title ?? "Daily Trojan", postId);
  }


  @override
  void initState() {
    super.initState();
    HistoryService.addToHistory(postId);
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
      scrollProgressNotifier.value = articleProgress;
      setScrollProgress(  articleProgress);
    });

    if (widget.article == null && widget.articleUrl != null) {
      List<String> parts = widget.articleUrl!.split("/");
      var slug = (parts[parts.length - 2]);
      fetchPostBySlug(slug).then((post) {
        setState(() {
          widget.article = post;
          showShareButtonWithBookmarkButton(widget.article?.link ?? "https://dailytrojan.com", widget.article?.title ?? "Daily Trojan", postId);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Center(
                  child: widget.article == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 80.0),
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        )
                      : Padding(
                          padding: bottomAppBarPadding,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: 750,
                            ),
                            child: Padding(
                              padding: overallContentPadding,
                              child: PostHtmlWidget(post: widget.article!),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: ValueListenableBuilder<double>(
      //     valueListenable: scrollProgressNotifier,
      //     builder: (context, progress, _) {
      //       return Container(
      //         decoration: BoxDecoration(
      //           border: Border(
      //             top: BorderSide(
      //               color: theme.colorScheme.outlineVariant,
      //               width: 1.0,
      //             ),
      //           ),
      //         ),
      //         child: BottomAppBar(
      //           height: 64,
      //           color: theme.colorScheme.surfaceContainerLow,
      //           surfaceTintColor: theme.colorScheme.surfaceContainerLow,
      //           child: Row(
      //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //               children: [
      //                 IconButton(
      //                   icon: Icon(Icons.arrow_back_ios_new),
      //                   onPressed: () {
      //                     Navigator.pop(context);
      //                   },
      //                 ),
      //                 Expanded(
      //                   child: Padding(
      //                     padding: const EdgeInsets.all(8.0),
      //                     child: Container(
      //                       height: 6.0,
      //                       alignment: Alignment.centerLeft,
      //                       decoration: BoxDecoration(
      //                         borderRadius: BorderRadius.circular(10.0),
      //                         color: theme.colorScheme.outlineVariant,
      //                       ),
      //                       child: FractionallySizedBox(
      //                         heightFactor: 1.0,
      //                         widthFactor: progress,
      //                         child: Container(
      //                           decoration: BoxDecoration(
      //                             borderRadius: BorderRadius.circular(10.0),
      //                             color: theme.colorScheme.primary,
      //                           ),
      //                         ),
      //                       ),
      //                     ),
      //                   ),
      //                 ),
      //                 Row(
      //                   children: [
      //                     IconButton(
      //                       onPressed: toggleBookmark,
      //                       icon: Icon(BookmarkService.isBookmarked(postId)
      //                           ? Icons.bookmark
      //                           : Icons.bookmark_border_outlined),
      //                     ),
      //                     IconButton(
      //                       icon: Icon(Icons.share),
      //                       onPressed: () {
      //                         Share.share(appState.article?.link ??
      //                             "https://dailytrojan.com");
      //                       },
      //                     ),
      //                     IconButton(
      //                       icon: Icon(Icons.more_vert_sharp),
      //                       onPressed: () {},
      //                     ),
      //                   ],
      //                 ),
      //               ]),
      //         ),
      //       );
      //     }),
    );
  }
}

class PostHtmlWidget extends StatelessWidget {
  final Post post;

  PostHtmlWidget({Key? key, required this.post}) : super(key: key);

  String get postId => post.id;

  FutureOr<bool> handleOpenLink(BuildContext context, String url) {
    if (url.contains("dailytrojan.com") && !url.contains("wp-")) {
      // Handle internal links
      return OpenArticleRouteByURL(context, url);
    }
    return false; // true means that I have handled it, false means that it is handling it
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 16.0,
        fontFamily: "SourceSerif4");

    var content = post.content.replaceAll("\n", "");

    var articleDOM = parse(content);
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
    // var meta = articleDOM.querySelectorAll(".av-post-metadata-container");
    // meta = meta.where((element) => element.querySelectorAll(".av-post-metadata-published-date").isEmpty).toList();
    // if (meta.isNotEmpty) {
    //   var siblings = meta.last.parentNode?.nodes;
    //   var index = siblings?.indexOf(meta.last);
    //   if (index != null && siblings != null) {
    //     for (var i = siblings.length - 1; i > index; i--) {
    //       // siblings[i].remove();
    //     }
    //   }
    //   // Traverse up the parent elements and remove any tags that come after the meta element
    //   var parent = meta.last.parentNode;
    //   while (parent != null) {
    //     var parentSiblings = parent.parent?.nodes;
    //     if (parentSiblings != null) {
    //       var parentIndex = parentSiblings.indexOf(parent);
    //       for (var i = parentSiblings.length - 1; i > parentIndex; i--) {
    //         parentSiblings[i].remove();
    //       }
    //     }
    //     parent = parent.parent;
    //   }
    //   meta.last.remove();
    // }
    // var hide = articleDOM.querySelectorAll(".av-mini-hide.av-small-hide.av-medium-hide.av-desktop-hide, .av-mini-hide, .av-small-hide");
    // for (var h in hide) {
    //   h.remove();
    // }
    // //remove subscription form stuff. extremely finicky, and if the text ever changes,  this will fail, but we can only hope.
    // var hrEls = articleDOM.querySelectorAll("hr");
    // for (var hr in hrEls) {
    //   var next = hr.nextElementSibling;
    //   if (next != null && next.innerHtml.contains("Daily")) {
    //     var nextNext = next.nextElementSibling;
    //     if (nextNext != null && nextNext.innerHtml.contains("Subscribe")) {
    //       hr.remove();
    //       next.remove();
    //       nextNext.nextElementSibling?.remove();
    //       nextNext.remove();
    //     }
    //   }
    // }

    // void removeEmptyElements(dom.Element element) {
    //   for (var child in element.children.toList()) {
    //     removeEmptyElements(child);
    //   }
    //   final hasNonTextContent = element.children.any((child) =>
    //     child.localName == 'img' ||
    //     child.localName == 'iframe' ||
    //     child.localName == 'video' ||
    //     child.localName == 'audio' ||
    //     child.localName == 'svg' ||
    //     child.localName == 'picture'
    //   ) || (
    //     element.localName == 'img' ||
    //     element.localName == 'iframe' ||
    //     element.localName == 'video' ||
    //     element.localName == 'audio' ||
    //     element.localName == 'svg' ||
    //     element.localName == 'picture'
    //   );
    //   if (element.children.isEmpty && element.text.trim().isEmpty && !hasNonTextContent) {
    //     element.remove();
    //   }
    // }

    // removeEmptyElements(articleDOM.documentElement!);

    var aeScoreEl = articleDOM.getElementById("ae-review-score");
    var aeScoreText = aeScoreEl?.querySelector("p")?.innerHtml;
    var aeScoreCount = aeScoreText != null ? double.parse(aeScoreText) : 0.0;
    // //TODO: weekly frame and live events both handle html differently. ill need to investigate what other pages do things differently too
    // addNewlinesToBlocks(articleDOM);
    var articleContent = articleDOM.outerHtml.toString();
    // articleContent = content;
    

    return SelectionArea(
      child: HtmlWidget(
        articleContent,
        onTapUrl: (url) => handleOpenLink(context, url),
        textStyle: bodyStyle,
        customWidgetBuilder: (element) {
          if (element.id == "ae-review-score") {
            // render a custom block widget that takes the full width
            return AEReviewStars(aeScoreCount: aeScoreCount);
          }
          return null;
        },
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
            return {
              'color': toHex(theme.colorScheme.outline),
              'font-family': 'Inter',
              'font-size': '14px'
            };
          }
          if (element.className.contains("avia-image-container")) {
            return {
              "margin-top": "16px",
            };
          }
          return {
            "margin-bottom": "0px",
          };
        },
      ),
    );
  }
}

//TODO: currently copying text is scuffed because newlines. this is a way to get newlines to display properly but it requires a lot of manually recreating logic from flutter widget from html that i just cannot care to do 
class _NewlineFactory extends WidgetFactory {
  final smilieOp = BuildOp(
    onParsed: (tree) {
      return tree..addText("\n\n");
    },
  );

  @override
  void parse(BuildTree tree) {
    final e = tree.element;
    if (e.localName == 'p') {
      tree.register(smilieOp);
      return;
    }

    return super.parse(tree);
  }
}

class AEReviewStars extends StatelessWidget {
  const AEReviewStars({
    super.key,
    required this.aeScoreCount,
  });

  final double aeScoreCount;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return new Row(
      children: List.generate(5, (index) {
        if (index < aeScoreCount.floor()) {
          return Icon(Icons.star, size: 30.0, color: theme.colorScheme.primary);
        } else if (index == aeScoreCount.floor() && aeScoreCount % 1 >= 0.5) {
          return Stack(
            children: [
              Icon(Icons.star_border,
                  size: 30.0, color: theme.colorScheme.outline),
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.5,
                  child: Icon(Icons.star,
                      size: 30.0, color: theme.colorScheme.primary),
                ),
              ),
            ],
          );
        } else {
          return Icon(Icons.star_border,
              size: 30.0, color: theme.colorScheme.outline);
        }
      }),
    );
  }
}

String toHex(Color color) {
  return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
}
