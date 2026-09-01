import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/feedback_service.dart';

/// 공용 3-2-1 카운트다운 오버레이.
class CountdownView extends StatefulWidget {
  const CountdownView({
    super.key,
    required this.fx,
    required this.accent,
    required this.onDone,
  });

  final FeedbackService fx;
  final Color accent;
  final VoidCallback onDone;

  @override
  State<CountdownView> createState() => _CountdownViewState();
}

class _CountdownViewState extends State<CountdownView> {
  int _count = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.fx.tick();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (t) {
      if (!mounted) return;
      if (_count > 1) {
        setState(() => _count--);
        widget.fx.tick();
      } else {
        t.cancel();
        setState(() => _count = 0);
        widget.fx.go();
        _timer = Timer(const Duration(milliseconds: 450), widget.onDone);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Text(
          _count > 0 ? '$_count' : '시작!',
          key: ValueKey(_count),
          style: Theme.of(context)
              .textTheme
              .displayLarge!
              .copyWith(fontSize: 96, color: widget.accent),
        ),
      ),
    );
  }
}
