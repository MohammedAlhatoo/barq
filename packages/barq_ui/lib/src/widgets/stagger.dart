import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../foundation/barq_tokens.dart';

/// One item of a list: it fades in and rises a little, after the items before
/// it. Works in lazy lists, where the items are not built together.
///
/// Only the first appearance plays. [group] names the list on its screen, so
/// scrolling back or a refresh never plays it again. Items that arrive later,
/// by scrolling or from the next page, start their own short sequence.
class BarqStaggerItem extends StatefulWidget {
  const BarqStaggerItem({
    super.key,
    required this.group,
    required this.index,
    required this.child,
  });

  /// Different for each list on a screen. Change it when the list shows new
  /// content, such as a new search, to play it again.
  final String group;
  final int index;
  final Widget child;

  @override
  State<BarqStaggerItem> createState() => _BarqStaggerItemState();
}

/// What a list has shown so far. It lives in the route's PageStorage, because
/// lazy lists destroy their items while scrolling.
class _StaggerMemory {
  int lastIndex = -1;

  /// The first item built in this frame.
  int? firstInFrame;
}

class _BarqStaggerItemState extends State<BarqStaggerItem> {
  /// Keeps long lists from waiting: item 50 starts with the others.
  static const _maxSteps = 8;
  static const _rise = 0.08;

  List<Effect<dynamic>>? _effects;
  bool _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    if (MediaQuery.disableAnimationsOf(context)) return;
    final step = _nextStep();
    if (step == null) return;
    final delay = BarqDurations.staggerInterval * min(step, _maxSteps);
    _effects = [
      FadeEffect(
        delay: delay,
        duration: BarqDurations.staggerItem,
        curve: Curves.easeOutCubic,
        begin: 0,
        end: 1,
      ),
      SlideEffect(
        delay: delay,
        duration: BarqDurations.staggerItem,
        curve: Curves.easeOutCubic,
        begin: const Offset(0, _rise),
        end: Offset.zero,
      ),
    ];
  }

  /// This item's place in its sequence, or null if it was already shown.
  int? _nextStep() {
    final memory = _memory();
    if (widget.index <= memory.lastIndex) return null;
    memory.lastIndex = widget.index;
    if (memory.firstInFrame == null) {
      memory.firstInFrame = widget.index;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => memory.firstInFrame = null,
      );
    }
    return widget.index - memory.firstInFrame!;
  }

  _StaggerMemory _memory() {
    final storage = PageStorage.maybeOf(context);
    final id = 'stagger-${widget.group}';
    final saved = storage?.readState(context, identifier: id);
    if (saved is _StaggerMemory) return saved;
    final memory = _StaggerMemory();
    storage?.writeState(context, memory, identifier: id);
    return memory;
  }

  @override
  Widget build(BuildContext context) {
    final effects = _effects;
    return effects == null
        ? widget.child
        : Animate(effects: effects, child: widget.child);
  }
}
