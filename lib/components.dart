import 'dart:ui';

import 'package:dailytrojan/account_route.dart';
import 'package:dailytrojan/game_route.dart';
import 'package:dailytrojan/main.dart';
import 'package:dailytrojan/main_section_route.dart';
import 'package:dailytrojan/post_elements.dart';
import 'package:dailytrojan/section_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class TitleBorderClipper extends CustomClipper<Path> {
  final bool shouldClipPadding;
  TitleBorderClipper({this.shouldClipPadding = false});
  @override
  Path getClip(Size size) {
    final path = Path();
    double horizontalPadding =
        shouldClipPadding ? horizontalContentPadding.right : 0;
    // Define the path for the triangle
    path.moveTo(0, 0); // Top left
    path.lineTo(size.width, 0);
    path.lineTo(size.width - horizontalPadding, size.height); // Bottom right
    path.lineTo(horizontalPadding, size.height); // Bottom left
    path.close(); // Close the path to form a triangle
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    if (oldClipper is TitleBorderClipper) {
      return oldClipper.shouldClipPadding != shouldClipPadding;
    }
    return false; // Set to true if the clipping path needs to change dynamically
  }
}

class AnimatedTitleScrollView extends StatefulWidget {
  final List<Widget> children;
  final Widget title;
  final bool backButton;
  final double? bottomPaddingExpanded;
  final double? bottomPaddingCollapsed;
  final PreferredSizeWidget? bottom;
  final List<Widget>? actions;
  final bool shouldShowBorderWhenFullyExpanded;
  final bool shouldShowBorder;
  final Widget? beneathAppBar;

  const AnimatedTitleScrollView(
      {super.key,
      required this.children,
      required this.title,
      this.shouldShowBorderWhenFullyExpanded = true,
      this.shouldShowBorder = true,
      this.backButton = true,
      this.bottomPaddingExpanded,
      this.bottomPaddingCollapsed,
      this.bottom,
      this.beneathAppBar,
      this.actions});

  @override
  State<AnimatedTitleScrollView> createState() =>
      _AnimatedTitleScrollViewState();
}

class _AnimatedTitleScrollViewState extends State<AnimatedTitleScrollView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double topPadding = MediaQuery.paddingOf(context).top;
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;
    final double expandedHeight = widget.backButton ? 130.0 : 100.0;
    double t = 0;
    return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            primary: true,
            backgroundColor:
                theme.colorScheme.surfaceContainerLowest.withAlpha(0),
            surfaceTintColor: Colors.transparent,
            collapsedHeight: kToolbarHeight,
            expandedHeight: expandedHeight,
            floating: false,
            automaticallyImplyLeading: widget.backButton,
            pinned: true,
            stretch: true,
            bottom: widget.bottom,
            actions: widget.actions,
            flexibleSpace: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double appBarHeight = constraints.biggest.height;
                t = ((appBarHeight - topPadding - kToolbarHeight) /
                    (expandedHeight - kToolbarHeight));
                final double titlePadding = lerpDouble(
                        widget.backButton ? 72 : 20,
                        20,
                        clampDouble(t, 0.0, 1.0)) ??
                    16;
                final double bottomPadding = lerpDouble(
                        widget.bottomPaddingCollapsed ?? 19,
                        widget.bottomPaddingExpanded ?? 16,
                        clampDouble(t, 0.0, 1.0)) ??
                    16;
                Color baseColor = theme.colorScheme.surfaceContainerLowest;
                Color backgroundColor = Color.lerp(
                        baseColor,
                        baseColor.withAlpha(0),
                        clampDouble(t * 2.0, 0.0, 1.0)) ??
                    Colors.red;
                var shouldClipPadding = t > 0;
                return ClipPath(
                  clipper:
                      TitleBorderClipper(shouldClipPadding: shouldClipPadding),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: (widget.shouldShowBorder &&
                                  (widget.shouldShowBorderWhenFullyExpanded
                                      ? true
                                      : t == 0.0))
                              ? theme.colorScheme.outlineVariant
                              : Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: FlexibleSpaceBar(
                        centerTitle: false,
                        expandedTitleScale: 1.65,
                        titlePadding: EdgeInsets.only(
                            left: titlePadding,
                            bottom: bottomPadding,
                            right: 30),
                        title: widget.title),
                  ),
                );
              },
            ),
          ),
          if (widget.beneathAppBar != null) widget.beneathAppBar!,
          SliverPadding(
              padding: EdgeInsets.only(bottom: 20.0 + bottomPadding),
              sliver: SliverList(
                  delegate: SliverChildListDelegate([...widget.children]))),
        ]);
  }
}

class SearchBarSliverAppBar extends StatelessWidget {
  final Widget searchTextField;

  const SearchBarSliverAppBar({
    super.key,
    required this.searchTextField,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      primary: false,
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      collapsedHeight: 64,
      expandedHeight: 64,
      floating: false,
      automaticallyImplyLeading: false,
      pinned: true,
      stretch: false,
      flexibleSpace: Center(child: searchTextField),
    );
  }
}

class SearchBarSliverDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // TODO: implement build
    return Container(color: Colors.red, child: Expanded(child: Text("hi")));
  }

  @override
  double get maxExtent => 264;

  @override
  double get minExtent => 84;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class NavigationBarAccountButton extends StatelessWidget {
  const NavigationBarAccountButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              SlideOverPageRoute(child: AccountRoute()),
            );
          },
          icon: Icon(Icons.account_circle)),
    );
  }
}

class TwoColumnBreakpoint extends StatelessWidget {
  final Widget singleColumnChild;
  final Widget leftColumnChild;
  final Widget rightColumnChild;
  final Widget separator;
  final int breakpoint;

  const TwoColumnBreakpoint(
      {super.key,
      required this.singleColumnChild,
      required this.leftColumnChild,
      required this.rightColumnChild,
      this.separator = const EmptyWidget(),
      this.breakpoint = 600});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double maxWidth = constraints.maxWidth;
      bool split = maxWidth > breakpoint;
      return split
          ? IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: leftColumnChild),
                  separator,
                  Expanded(child: rightColumnChild)
                ],
              ),
            )
          : singleColumnChild;
    });
  }
}

class SectionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    final mainSectionStyle = theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "Inter",
        fontWeight: FontWeight.bold);
    final subSectionStyle = theme.textTheme.titleMedium!.copyWith(
        color: theme.colorScheme.onSurfaceVariant, fontFamily: "Inter");
    return Column(children: [
      for (int i = 0; i < Sections.length; i++)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0)
                      .add(horizontalContentPadding),
                  child: Text(
                    Sections[i].mainSection.title,
                    style: mainSectionStyle,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              onTap: () {
                if (Sections[i].subsections.isNotEmpty) {
                  appState.setMainSection(Sections[i]);
                  Navigator.push(
                    context,
                    SlideOverPageRoute(child: MainSectionRoute()),
                  );
                } else {
                  appState.setSection(Sections[i].mainSection);
                  Navigator.push(
                    context,
                    SlideOverPageRoute(child: const SectionRoute()),
                  );
                }
              },
            ),
            if (!(Sections[i].subsections.isEmpty && i >= Sections.length - 1))
              Padding(
                padding: horizontalContentPadding,
                child: Divider(thickness: 2, height: 2),
              ),
            for (int j = 0; j < Sections[i].subsections.length; j++)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    child: SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0)
                            .add(horizontalContentPadding),
                        child: Text(
                          Sections[i].subsections[j].title,
                          style: subSectionStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    onTap: () {
                      appState.setSection(Sections[i].subsections[j]);
                      Navigator.push(
                        context,
                        SlideOverPageRoute(child: SectionRoute()),
                      );
                    },
                  ),
                  if (j < Sections[i].subsections.length - 1)
                    Padding(
                      padding: horizontalContentPadding,
                      child: Divider(height: 1),
                    ),
                ],
              ),
            if (Sections[i].subsections.isNotEmpty && i < Sections.length - 1)
              Padding(
                padding: horizontalContentPadding,
                child: Divider(thickness: 2, height: 2),
              ),
          ],
        ),
    ]);
  }
}

class TrendingArticleList extends StatelessWidget {
  List<Post>? trendingPosts;

  Future<void> initPosts() async {
    trendingPosts = await fetchTrendingPosts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initPosts(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: CircularProgressIndicator(),
            ));
          } else if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          } else {
            return Column(children: [
              for (int i = 0; i < 5; i++)
                if (trendingPosts?[i] != null)
                  Column(
                    children: [
                      PostElementUltimate(post: trendingPosts![i], publishDate: true, bookmarkShare: true, dek: true, leftImage: true),
                      if (i < 4)
                        Padding(
                          padding: horizontalContentPadding,
                          child: Divider(height: 1),
                        ),
                    ],
                  )
            ]);
          }
        });
  }
}

class GameTile extends StatelessWidget {
  final Game game;
  const GameTile({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);
    final buttonStyle = theme.textTheme.titleMedium!.copyWith(
        fontFamily: "Inter",
        color: theme.colorScheme.onPrimaryFixed,
        fontWeight: FontWeight.bold);

    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 14.0,
        fontFamily: "SourceSerif4");
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            SlideOverPageRoute(
              child: GameRoute(
                  gameUrl: game.gameUrl,
                  gameShareableUrl: game.gameShareableUrl),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Padding(
              padding: (EdgeInsets.only(bottom: 16)),
              child: Container(
                decoration: BoxDecoration(
                    color: game.color,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8))),
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      game.imageUrl,
                      height: 70,
                      width: 70,
                    ),
                  ),
                ),
              ),
            ),
            Text(
              game.title,
              style: titleStyle,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                game.description,
                style: subStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SizedBox(
                width: 150,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "PLAY",
                      style: buttonStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class GameBrick extends StatelessWidget {
  final Game game;
  const GameBrick({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge!.copyWith(
        color: theme.colorScheme.onSurface,
        fontFamily: "SourceSerif4",
        fontWeight: FontWeight.bold);

    final subStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.onSurface,
        fontSize: 14.0,
        fontFamily: "SourceSerif4");
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            SlideOverPageRoute(
              child: GameRoute(
                  gameUrl: game.gameUrl,
                  gameShareableUrl: game.gameShareableUrl),
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 110,
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: game.color,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8))),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      game.imageUrl,
                      height: 70,
                      width: 70,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        game.title,
                        style: titleStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 12.0, top: 6.0, right: 12.0),
                      child: Text(
                        game.description,
                        style: subStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int breakpoint;
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.breakpoint = 500,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double maxWidth = constraints.maxWidth;

      // Set tile width based on screen width
      double tileWidth = maxWidth > breakpoint
          ? (maxWidth / 2) - 8 // Two columns, with spacing
          : maxWidth; // One column on small screens
      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (int i = 0; i < children.length; i++)
            SizedBox(
              width: tileWidth,
              child: children[i],
            ),
        ],
      );
    });
  }
}

class SlideOverPageRoute extends PageRouteBuilder {
  final Widget child;

  SlideOverPageRoute({required this.child, RouteSettings? settings})
      : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 450),
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Animation for the incoming route (sliding in from right)
            final newRouteTween = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.linearToEaseOut,
                reverseCurve: Curves.easeInToLinear,
              ),
            );

            // Animation for the outgoing route (sliding out to left)
            final oldRouteTween = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.35, 0.0),
            ).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.linearToEaseOut,
                reverseCurve: Curves.easeInToLinear,
              ),
            );

            final dimAnimation = Tween<double>(
              begin: 0.0,
              end: 0.15, // how much to dim (0.0–1.0, like opacity of black)
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
                reverseCurve: Curves.easeIn,
              ),
            );

            return SlideTransition(
              position: newRouteTween, // Apply slide-in to the new route
              child: SlideTransition(
                position: oldRouteTween, // Apply slide-out to the old route
                child: child,
              ),
            );
          },
        );
}
