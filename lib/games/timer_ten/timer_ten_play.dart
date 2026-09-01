import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

class TimerTenPlay extends StatefulWidget {
  const TimerTenPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<TimerTenPlay> createState() => _TimerTenPlayState();
}

class _TimerTenPlayState extends State<TimerTenPlay> {
  static const targetMs = 10000;
  static const visibleMs = 3000;

  final _stopwatch = Stopwatch();
  Timer? _ticker;
  Timer? _finishTimer;
  int? _stoppedMs;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _ticker = Timer.periodic(const Duration(milliseconds: 33), (t) {
      if (_stopwatch.elapsedMilliseconds >= visibleMs) {
        t.cancel();
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _finishTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown() {
    if (_stoppedMs != null) return;
    final ms = _stopwatch.elapsedMilliseconds;
    _stopwatch.stop();
    _ticker?.cancel();
    widget.session.fx.tap();
    setState(() => _stoppedMs = ms);
    final diff = (ms - targetMs).abs();
    _finishTimer = Timer(const Duration(milliseconds: 1400),
        () => widget.session.finish(diff));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final elapsed = _stopwatch.elapsedMilliseconds;

    final Widget content;
    if (_stoppedMs != null) {
      final sec = (_stoppedMs! / 1000).toStringAsFixed(2);
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$sec초',
              style: textTheme.displayLarge!
                  .copyWith(color: AppColors.accent)),
          const SizedBox(height: 12),
          Text('목표: 10.00초', style: textTheme.bodySmall),
        ],
      );
    } else if (elapsed < visibleMs) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text((elapsed / 1000).toStringAsFixed(2),
              style: textTheme.displayLarge),
          const SizedBox(height: 12),
          Text('곧 가려집니다...', style: textTheme.bodySmall),
        ],
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.visibility_off_rounded,
              size: 64, color: AppColors.textDim),
          const SizedBox(height: 16),
          Text('감각으로 10.00초에 터치!',
              style: textTheme.bodyMedium!
                  .copyWith(color: AppColors.textDim)),
        ],
      );
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onPointerDown(),
      child: SizedBox.expand(child: content),
    );
  }
}
