import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

class TapSpeedPlay extends StatefulWidget {
  const TapSpeedPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<TapSpeedPlay> createState() => _TapSpeedPlayState();
}

class _TapSpeedPlayState extends State<TapSpeedPlay> {
  static const durationMs = 10000;

  final _stopwatch = Stopwatch();
  Timer? _ticker;
  int _count = 0;
  bool _finished = false;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _onPointerDown() {
    if (_finished) return;
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (_stopwatch.elapsedMilliseconds >= durationMs) {
          _ticker?.cancel();
          _stopwatch.stop();
          setState(() => _finished = true);
          widget.session.finish(_count);
        } else {
          setState(() {}); // 남은 시간 표시 갱신
        }
      });
    }
    widget.session.fx.tapLight();
    setState(() => _count++);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final remaining =
        ((durationMs - _stopwatch.elapsedMilliseconds) / 1000).clamp(0.0, 10.0);

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onPointerDown(),
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              remaining.toStringAsFixed(1),
              style: textTheme.displaySmall!
                  .copyWith(color: AppColors.textDim),
            ),
            const SizedBox(height: 24),
            Text(
              '$_count',
              style: textTheme.displayLarge!.copyWith(
                fontSize: 96,
                color: darken(GameColors.yellow, 0.12),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _stopwatch.isRunning ? '계속 탭하세요!' : '탭하는 순간 시작!',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
