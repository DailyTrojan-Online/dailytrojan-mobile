import 'dart:ui';

import 'package:dailytrojan/main.dart';
import 'package:flutter/material.dart';

class TitleBorderClipper extends CustomClipper<Path> {
      final bool shouldClipPadding;
      TitleBorderClipper({this.shouldClipPadding = false});
      @override
      Path getClip(Size size) {
        final path = Path();
        double horizontalPadding = shouldClipPadding ? horizontalContentPadding.right : 0;
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
            backgroundColor: theme.colorScheme.surfaceContainerLowest.withAlpha(0),
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
                  clipper: TitleBorderClipper(shouldClipPadding: shouldClipPadding),
                  child: Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      border: Border(
                        bottom: BorderSide(
                          color: (widget.shouldShowBorder && (widget.shouldShowBorderWhenFullyExpanded ? true : t == 0.0))
                              ? theme.colorScheme.outlineVariant
                              : Colors.transparent,
                          width: 1.0,
                        ),
                      ),),
                    child: FlexibleSpaceBar(
                        centerTitle: false,
                        expandedTitleScale: 1.65,
                        titlePadding: EdgeInsets.only(
                            left: titlePadding, bottom: bottomPadding, right: 30),
                        title: widget.title),
                  ),
                );
              },
            ),
          ),
          SliverPadding(
              padding: EdgeInsets.only(bottom: 20.0 + bottomPadding),
              sliver: SliverList(
                  delegate: SliverChildListDelegate([...widget.children]))),
        ]);
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
