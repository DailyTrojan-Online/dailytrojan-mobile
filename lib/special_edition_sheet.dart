import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dailytrojan/account_route.dart';
import 'package:dailytrojan/components.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:dailytrojan/ui_styles.dart';
import 'package:dailytrojan/games_page.dart';
import 'package:dailytrojan/icons/daily_trojan_icons.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/section_route.dart';
import 'package:dailytrojan/utility.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smooth_gradient/smooth_gradient.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:intl/intl.dart';

class SpecialEditionSheet extends StatefulWidget {
  final SpecialEdition edition;
  final bool fullSize;
  const SpecialEditionSheet(
      {super.key, required this.edition, this.fullSize = false});

  @override
  State<SpecialEditionSheet> createState() => _SpecialEditionSheetState();
}

class _SpecialEditionSheetState
    extends StatefulScrollControllerRoute<SpecialEditionSheet> {
  bool _hasExpanded = false;
  bool showSheetContent = false;

  @override
  void initState(){
    super.initState();
    
    _hasExpanded = widget.fullSize;
    showSheetContent = widget.fullSize;
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final secondaryAnimation =
        route?.secondaryAnimation ?? kAlwaysDismissedAnimation;

    final sheetOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.35, 0.0),
    ).animate(
      CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.linearToEaseOut,
        reverseCurve: Curves.easeInToLinear,
      ),
    );
    final List<Post> dummyData = List.filled(10, Post.skeleton());
    final ScrollController _scrollController = new ScrollController();
    final theme = Theme.of(context);
    final headerStyle = widget.edition.style == "magazine"
        ? UiStyles.headingMagazine(theme)
        : UiStyles.heading(theme);
    final excerptStyle = UiStyles.subHeading(theme);
    final metadataStyle = UiStyles.metadata(theme);

    final String dummyText =
        '\n' * (4); //assume 4 lines of text for the excerpt

    final textPainter = TextPainter(
        text: TextSpan(text: dummyText, style: excerptStyle),
        textDirection: ui.TextDirection.ltr)
      ..layout();

    final EdgeInsets safePadding = MediaQuery.of(context).padding;

    final double headerExpandedHeight = 100.0;
    const double buttonHeight = 60;

    final double coverImageHeight = 300.0;
    final double peekHeight = headerExpandedHeight +
        coverImageHeight +
        safePadding.top +
        bottomAppBarPadding.bottom +
        safePadding.bottom +
        textPainter.size.height +
        buttonHeight;
    final SheetController controller = SheetController();
    return SlideTransition(
      position: sheetOffset,
      child: NotificationListener<SheetNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (!_hasExpanded && metrics.offset >= metrics.maxOffset * .5) {
            setState(() {
              _hasExpanded = true;
              showSheetContent = true;
            });
          }
          print(_hasExpanded);
          return false;
        },
        child: Sheet(
          controller: controller,
          snapGrid: SheetSnapGrid(
            snaps: _hasExpanded || widget.fullSize
                ? const [SheetOffset(1)]
                : [SheetOffset.absolute(peekHeight), SheetOffset(1)],
          ),
          initialOffset: widget.fullSize ? SheetOffset(1) : SheetOffset.absolute(peekHeight),
          scrollConfiguration: const SheetScrollConfiguration(
            delegateUnhandledOverscrollToChild: false,
          ),
          physics: const BouncingSheetPhysics(
            resistance: 6,
            bounceExtent: 120,
          ),
          decoration: MaterialSheetDecoration(
            size: SheetSize.fit,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            color: theme.colorScheme.surfaceContainerLowest,
          ),
          child: SheetContentScaffold(
            backgroundColor: theme.colorScheme.surfaceContainerLowest,
            body: Padding(
              padding: EdgeInsets.only(
                  bottom: safePadding.bottom,
                  left: safePadding.left,
                  right: safePadding.right),
              child: AnimatedTitleScrollView(
                  preHeader: SizedBox(
                    height: coverImageHeight,
                  ),
                  headerBackgroundImage: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return SmoothGradient(
                        from: Colors.white,
                        to: Colors.transparent,
                        curve: Curves.linear,
                        begin: AlignmentGeometry.center,
                        end: AlignmentGeometry.bottomCenter,
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: Container(
                      height: coverImageHeight +
                          headerExpandedHeight +
                          safePadding.top,
                      width: double.infinity,
                      child: Image(
                        image: CachedNetworkImageProvider(
                            widget.edition.imageUrl,
                            headers: const {
                              'User-Agent':
                                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/145 Safari/537.36',
                              'Referer': 'https://dailytrojan.com/',
                            }),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image);
                        },
                      ),
                    ),
                  ),
                  collapsingSliverAppBar: CollapsingSliverAppBar(
                    expandedHeight: headerExpandedHeight,
                    shouldClipPadding: false,
                    shouldShowBorderWhenFullyExpanded: false,
                    topPadding: safePadding.top,
                    shouldFadeBackground: true,
                    title: Text(
                      widget.edition.title,
                      style: headerStyle,
                    ),
                  ),
                  children: [
                    Padding(
                        padding: horizontalContentPadding,
                        child: Text(
                            DateFormat('MMM d, yyyy').format(
                                DateTime.parse(widget.edition.publishDate)),
                            style: metadataStyle)),
                    Padding(
                        padding: horizontalContentPadding
                            .add(EdgeInsetsGeometry.only(top: 8.0)),
                        child:
                            Text(widget.edition.subtitle, style: excerptStyle)),
                    Stack(children: [
                      IgnorePointer(
                        ignoring: showSheetContent,
                        child: AnimatedOpacity(
                          opacity: showSheetContent ? 0.0 : 1.0,
                          duration: const Duration(milliseconds: 300),
                          child: Padding(
                            padding: horizontalContentPadding
                                .add(EdgeInsetsGeometry.only(top: 12.0)),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStatePropertyAll(
                                        theme.colorScheme.inverseSurface),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    controller.animateTo(SheetOffset(1.0));
                                    setState(() {
                                      showSheetContent = true;
                                      print(showSheetContent);
                                    });
                                  },
                                  child: Text('VIEW ALL ARTICLES')),
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        ignoring: !showSheetContent,
                        child: AnimatedOpacity(
                          opacity: showSheetContent ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Padding(
                              padding: bottomAppBarPadding
                                  .add(EdgeInsets.only(top: 16)),
                              child: Column(children: [
                                for (Post article
                                    in widget.edition.articles) ...[
                                  PostElementUltimate(
                                    post: article,
                                    leftImage: true,
                                    dek: true,
                                    byline: true,
                                  ),
                                  Padding(
                                    padding: horizontalContentPadding,
                                    child: Divider(
                                      height: 1,
                                    ),
                                  )
                                ]
                              ])),
                        ),
                      ),
                    ]),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
