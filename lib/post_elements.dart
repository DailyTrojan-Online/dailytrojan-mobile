import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:html/parser.dart';
import 'package:share_plus/share_plus.dart';
import 'package:skeletonizer/skeletonizer.dart';

String stripHtmlTags(String htmlText) {
  if (htmlText.isEmpty) return '';
  final scriptStyleRegex = RegExp(r'<(script|style)[^>]*>.*?</\1>',
      multiLine: true, caseSensitive: false, dotAll: true);
  String cleaned = htmlText.replaceAll(scriptStyleRegex, '');
  final tagRegex = RegExp(r'<[^>]+>');
  cleaned = cleaned.replaceAll(tagRegex, '');
  cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();

  return htmlUnescape.convert(cleaned).trim();
}

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
        for (var post in posts)
          PostElementUltimate(
            post: post,
            dek: true,
            rightImage: true,
            publishDate: true,
            bookmarkShare: true,
          ),
      ],
    );
  }
}

class PostElementUltimate extends StatefulWidget {
  final Post post;
  final VoidCallback? onBookmarkChanged;
  final String columnPhoto;
  final String columnName;
  final String columnByline;
  final bool dek;
  final bool byline;
  final bool rightImage;
  final bool leftImage;
  final bool topImage;
  final bool publishDate;
  final bool bookmarkShare;
  final bool bottomImage;
  final double hedSize;
  final EdgeInsets horizontalPadding;
  final bool showBreakingTag;
  final bool expandVertically;

  const PostElementUltimate(
      {super.key,
      required this.post,
      this.dek = false,
      this.byline = false,
      this.onBookmarkChanged,
      this.rightImage = false,
      this.topImage = false,
      this.leftImage = false,
      this.columnByline = "",
      this.columnName = "",
      this.columnPhoto = "",
      this.publishDate = false,
      this.bookmarkShare = false,
      this.showBreakingTag = true,
      this.bottomImage = false,
      this.expandVertically = false,
      this.horizontalPadding = horizontalContentPadding,
      this.hedSize = 18});

  @override
  State<PostElementUltimate> createState() => _PostElementUltimateState();
}

class _PostElementUltimateState extends State<PostElementUltimate> {
  final double rightImageSize = 100.0;
  final double leftImageSize = 70.0;
  Post get post => widget.post;
  String get postId => post.id;

  void toggleBookmark() {
    if (BookmarkService.isBookmarked(postId)) {
      BookmarkService.removeBookmark(postId);
    } else {
      BookmarkService.addBookmark(postId, postId);
    }
    setState(() {}); // Refresh UI

    context.read<MyAppState>().notifyBookmarkChanged();

    widget.onBookmarkChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headlineStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontSize: widget.hedSize,
        fontWeight: FontWeight.bold);
    final authorStyle = theme.textTheme.labelSmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant, fontFamily: "Inter");
    final excerptStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14.0,
        fontFamily: "SourceSerif4");

    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.primary, fontSize: 14.0, fontFamily: "Inter");
    final columnNameStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface, fontSize: 13.0, fontFamily: "Inter", fontWeight: FontWeight.bold);
    final columnBylineStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurfaceVariant, fontSize: 14.0, fontFamily: "Inter");

    var articleDOM = parse(widget.post.content);
    var author = "By ${widget.post.author.toUpperCase()}";
    // articleDOM.querySelectorAll('h6').forEach((e) {
    //   if (e.innerHtml.startsWith("By")) {
    //     author = stripHtmlTags(htmlUnescape.convert(e.innerHtml));
    //     return;
    //   }
    // });
    String? excerpt = widget.post.excerpt;

    return InkWell(
      onTap: () {
        OpenArticleRoute(context, widget.post);
      },
      child: Column(
        children: [
          if (widget.topImage) EmptySafeImage(url: widget.post.coverImage),
          if (widget.topImage) SizedBox(height: 8),
          Expanded(
            flex: widget.expandVertically ? 1 : 0,
            child: Padding(
              padding: EdgeInsets.only(
                      top: 16.0,
                      bottom:
                          (widget.bookmarkShare || widget.publishDate ? 8 : 16))
                  .add(widget.horizontalPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.leftImage)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: EmptySafeImage(
                          url: widget.post.coverImage,
                          width: leftImageSize,
                          height: leftImageSize),
                    ),
                  if (widget.leftImage) SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (widget.columnByline.isNotEmpty ||
                            widget.columnName.isNotEmpty ||
                            widget.columnPhoto.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(children: [
                              if (widget.columnPhoto.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.matrix(<double>[
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0.2126,
                                    0.7152,
                                    0.0722,
                                    0,
                                    0,
                                    0,
                                    0,
                                    0,
                                    1,
                                    0,
                                  ]),
                                  child: ClipOval(
                                    child: EmptySafeImage(
                                        url: widget.columnPhoto,
                                        width: 40,
                                        height: 40),
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                if (widget.columnName.isNotEmpty)
                                  Text(widget.columnName.toUpperCase(),
                                      style: columnNameStyle),
                                if (widget.columnByline.isNotEmpty)
                                  Text(widget.columnByline, style: authorStyle),
                              ])
                            ]),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  (widget.post.breaking &&
                                          widget.showBreakingTag)
                                      ? Text("BREAKING",
                                          style: subStyle.copyWith(
                                              fontWeight: FontWeight.bold))
                                      : EmptyWidget(),
                                  Text(
                                    htmlUnescape.convert(widget.post.title),
                                    style: headlineStyle,
                                  ),
                                  if (excerpt != null && widget.dek)
                                    SizedBox(height: 6),
                                  if (excerpt != null && widget.dek)
                                    Text(stripHtmlTags(excerpt),
                                        style: excerptStyle),
                                  if (widget.byline) SizedBox(height: 6),
                                  if (widget.byline)
                                    Text(author, style: authorStyle),
                                  if (widget.bottomImage) SizedBox(height: 8),
                                  if (widget.bottomImage)
                                    EmptySafeImage(url: widget.post.coverImage),
                                ],
                              ),
                            ),
                            if (widget.rightImage) SizedBox(width: 16),
                            if (widget.rightImage)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: EmptySafeImage(
                                    url: widget.post.coverImage,
                                    width: rightImageSize,
                                    height: rightImageSize),
                              ),
                          ],
                        ),
                        if (widget.bookmarkShare || widget.publishDate)
                          Container(
                            height: 40,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (widget.publishDate)
                                  Text(
                                      DateFormat('MMM d, yyyy').format(
                                          DateTime.parse(widget.post.date)),
                                      style: authorStyle),
                                if (widget.bookmarkShare)
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          child: Row(
                                            children: [
                                              IconButton(
                                                  onPressed: toggleBookmark,
                                                  icon: Icon(BookmarkService
                                                          .isBookmarked(postId)
                                                      ? Icons.bookmark
                                                      : Icons
                                                          .bookmark_border_outlined)),
                                              IconButton(
                                                  onPressed: () {
                                                    Share.share(post.link);
                                                  },
                                                  icon: Icon(Icons.share)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptySafeImage extends StatelessWidget {
  const EmptySafeImage({
    super.key,
    required this.url,
    this.width,
    this.height,
  });

  final String url;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    var aspectRatio = 4 / 3;
    if (width != null && height != null) {
      aspectRatio = width! / height!;
    }
    return url.isEmpty
        ? Skeleton.shade(
            child: AspectRatio(
              aspectRatio: aspectRatio, // Ensures a 16:9 ratio
              child: Container(
                color: Colors.blue,
              ),
            ),
          )
        : Image(
            image: CachedNetworkImageProvider(url),
            width: width,
            height: height,
            fit: BoxFit.cover,
          );
  }
}

class HomePagePostLayoutElement extends StatelessWidget {
  final List<Post> posts;

  const HomePagePostLayoutElement({
    super.key,
    required this.posts,
  });

  final double imageSize = 100.0;

  @override
  Widget build(BuildContext context) {
    return TwoColumnBreakpoint(
        breakpoint: 600,
        singleColumnChild: Column(
          children: [
            for (int i = 0; i < posts.length; i++)
              Column(
                children: [
                  (i % 3 == 0)
                      ? PostElementUltimate(
                          post: posts[i],
                          byline: true,
                          bottomImage: true,
                          hedSize: 24,
                          dek: true,
                        )
                      : PostElementUltimate(post: posts[i], byline: true),
                  (i != posts.length - 1)
                      ? Padding(
                          padding: horizontalContentPadding,
                          child: Divider(height: 1),
                        )
                      : EmptyWidget()
                ],
              ),
          ],
        ),
        leftColumnChild: Column(
          children: [
            for (int i = 0; i < posts.length; i++)
              Column(children: [
                PostElementUltimate(post: posts[i], byline: true, dek: true),
                (i != posts.length - 1)
                    ? Padding(
                        padding: horizontalContentPadding,
                        child: Divider(height: 1),
                      )
                    : EmptyWidget()
              ]),
          ],
        ),
        rightColumnChild: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0)
              .add(EdgeInsets.only(right: horizontalContentPadding.right)),
          child: InkWell(
            onTap: () {
              OpenArticleRoute(context, posts[0]);
            },
            child: EmptySafeImage(url: posts[0].coverImage),
          ),
        ));
  }
}
