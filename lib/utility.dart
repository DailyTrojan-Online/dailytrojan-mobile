import 'package:flutter/material.dart';
import 'package:dailytrojan/main.dart';

// A base class for routes that need to be aware of scroll position and route changes, or need to reset such states when navigated to.
abstract class StatefulScrollControllerRoute<T extends StatefulWidget> extends State<T> with RouteAware {
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
    print('[BASE IMPLEMENTATION] MyRouteAwareWidget didPush: This route is now visible. [BASE IMPLEMENTATION]');
    resetScrollProgress();
    hideShareButton();
    hideShareButtonWithBookmarkButton();
  }

  @override
  void didPopNext() {
    print('[BASE IMPLEMENTATION] MyRouteAwareWidget didPopNext: This route is now visible again.');
    resetScrollProgress();
    hideShareButton();
    hideShareButtonWithBookmarkButton();
  }

}