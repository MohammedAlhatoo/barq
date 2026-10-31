import 'package:flutter/material.dart';

/// Calls [onLoadMore] when the user nears the end of the scrolling [child].
class LoadMoreListener extends StatelessWidget {
  const LoadMoreListener({
    super.key,
    required this.onLoadMore,
    required this.child,
  });

  static const _threshold = 300.0;

  final VoidCallback onLoadMore;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.extentAfter < _threshold) onLoadMore();
          return false;
        },
        child: child,
      );
}
