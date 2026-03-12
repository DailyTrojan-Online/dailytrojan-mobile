import 'dart:async';

import 'package:dailytrojan/components.dart';
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
    print(
        '[ARTICLE IMPLEMENTATION] MyRouteAwareWidget didPush: This route is now visible. [BASE IMPLEMENTATION]');

    resetScrollProgress();
    // showShareButton(widget.article?.link ?? "https://dailytrojan.com", widget.article?.title ?? "Daily Trojan");
    showShareButtonWithBookmarkButton(
        widget.article?.link ?? "https://dailytrojan.com",
        widget.article?.title ?? "Daily Trojan",
        postId);
  }

  @override
  void didPopNext() {
    print(
        '[ARTICLE IMPLEMENTATION] MyRouteAwareWidget didPopNext: This route is now visible again.');
    lerpScrollProgress(articleProgress);
    // showShareButton(widget.article?.link ?? "https://dailytrojan.com", widget.article?.title ?? "Daily Trojan");
    showShareButtonWithBookmarkButton(
        widget.article?.link ?? "https://dailytrojan.com",
        widget.article?.title ?? "Daily Trojan",
        postId);
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
      setScrollProgress(articleProgress);
    });

    if (widget.article == null && widget.articleUrl != null) {
      List<String> parts = widget.articleUrl!.split("/");
      var slug = (parts[parts.length - 2]);
      fetchPostBySlug(slug).then((post) {
        setState(() {
          widget.article = post;
          showShareButtonWithBookmarkButton(
              widget.article?.link ?? "https://dailytrojan.com",
              widget.article?.title ?? "Daily Trojan",
              postId);
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
        decoration: TextDecoration.none,
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

    //handle metasliders
    var metasliders = articleDOM.querySelectorAll(".metaslider");
    var sliderDataList = <List<(String url, String caption)>>[];
    for (var metaslider in metasliders) {
      var images = metaslider.querySelectorAll(".ms-image");
      List<(String url, String caption)> sliderData = [];
      var filteredImages =
          (images.where((img) => !img.className.contains("clone")));
      for (var image in filteredImages) {
        var imgEl = image.querySelector("img");
        if (imgEl != null) {
          var caption = (image.text);
          var url = imgEl.attributes["src"] ?? "";
          print(url.replaceAll(RegExp(r'-\d+[Xx]\d+\.'), "."));
          sliderData
              .add((url.replaceAll(RegExp(r'-\d+[Xx]\d+\.'), "."), caption));
        }
      }
      sliderDataList.add(sliderData);
    }

    var aeScoreEl = articleDOM.getElementById("ae-review-score");
    var aeScoreText = aeScoreEl?.querySelector("p")?.innerHtml;
    var aeScoreCount = aeScoreText != null ? double.parse(aeScoreText) : 0.0;
    // //TODO: weekly frame and live events both handle html differently. ill need to investigate what other pages do things differently too
    // addNewlinesToBlocks(articleDOM);
    var articleContent = articleDOM.outerHtml.toString();
    // articleContent = content;

    var metaSliderIndex = 0;

    final screenWidth = MediaQuery.of(context).size.width;

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
          if (element.className.contains("metaslider")) {
            var sliderData = sliderDataList[metaSliderIndex];
            metaSliderIndex++;
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  var sliderWidth = constraints.maxWidth;
                  return SingleChildScrollView(
                    physics: PageScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    
                    children: List<Widget>.generate(sliderData.length, (int index) {
                      return Container(
                        width: sliderWidth,
                        child: Stack(
                          children: [Image.network(
                            sliderData[index].$1,
                            fit: BoxFit.cover,
                          
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                              color: Colors.black54,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  sliderData[index].$2,
                                  style: theme.textTheme.labelSmall!.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                          
                          ]
                        ),
                      );
                    }),
                  ),
                );
                },
              ),
            );
          }
          return null;
        },
        customStylesBuilder: (element) {
          Map<String, String> baseStyles = {};
          if (element.localName == "h1") {
            baseStyles.addAll({
              'color': toHex(theme.colorScheme.onSurface),
            });
          }
          if (element.localName == "h2") {
            baseStyles.addAll({
              'color': toHex(theme.colorScheme.onSurfaceVariant),
            });
          }
          if (element.className.contains("h6")) {
            if (element.parent?.className.contains("liv-updat-post") ?? false) {
              baseStyles.addAll({"margin-top": "0px"});
            }
            baseStyles.addAll({
              'color': toHex(theme.colorScheme.outline),
              'font-family': 'Inter',
              'font-size': '14px'
            });
          }
          if (element.className.contains("ms-image")) {
            baseStyles.addAll({"list-style-type": "none"});
          }
          if (element.className.contains("liv-updat-post")) {
            baseStyles.addAll({
              "border": "1px solid ${toHex(theme.colorScheme.outlineVariant)}",
              "padding": "18px 16px",
              "margin-top": "16px",
              "border-radius": "8px",
              "background-color": toHex(theme.colorScheme.surfaceContainerLow),
            });
          }
          if (element.className.contains("avia-image-container")) {
            baseStyles.addAll({
              "margin-top": "16px",
            });
          }
          baseStyles.addAll({
            "text-decoration": "none",
            "margin-bottom": "0px",
          });
          return baseStyles;
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
