import 'package:dailytrojan/account_route.dart';
import 'package:dailytrojan/components.dart';
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
import 'package:smooth_sheets/smooth_sheets.dart';

class SpecialEditionSheet extends StatefulWidget {
  const SpecialEditionSheet({super.key});

  @override
  State<SpecialEditionSheet> createState() => _SpecialEditionSheetState();
}

class _SpecialEditionSheetState extends State<SpecialEditionSheet> {
  bool _hasExpanded = false;

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
    // You can use PopScope to handle the swipe-to-dismiss gestures, as well as
    // the system back gestures and tapping on the barrier, all in one place.
    final List<Post> dummyData = List.filled(10, Post.skeleton());
    final ScrollController _scrollController = new ScrollController();
    final theme = Theme.of(context);
    final headerStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "ManufacturingConsent",
        height: .8);
    final EdgeInsets safePadding = MediaQuery.of(context).padding;
    return SlideTransition(
      position: sheetOffset,
      child: NotificationListener<SheetNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (!_hasExpanded && metrics.offset >= metrics.maxOffset - 100.0) {
            setState(() {
              _hasExpanded = true;
            });
          }
          return false;
        },
        child: Sheet(
          snapGrid: SheetSnapGrid(
            snaps: _hasExpanded
                ? const [SheetOffset(1)]
                : const [SheetOffset.absolute(300.0), SheetOffset(1)],
          ),
          initialOffset: const SheetOffset.absolute(300.0),
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
              padding: safePadding,
              child: AnimatedTitleScrollView(
                  collapsingSliverAppBar: CollapsingSliverAppBar(
                    title: Text(
                      "Daily Trojan Magazine",
                      style: headerStyle,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: horizontalContentPadding
                          .add(EdgeInsets.only(top: 16))
                          .add(bottomAppBarPadding),
                      child: ResponsiveGrid(children: [
                        for (int i = 0; i < Games.length; i++)
                          GameTile(game: Games[i]),
                      ]),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
