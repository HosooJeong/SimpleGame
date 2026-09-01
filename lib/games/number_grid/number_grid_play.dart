import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/l10n_context.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

class NumberGridPlay extends StatefulWidget {
  const NumberGridPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<NumberGridPlay> createState() => _NumberGridPlayState();
}

class _NumberGridPlayState extends State<NumberGridPlay> {
  static const size = 5;

  late final List<int> _numbers;
  final _stopwatch = Stopwatch();
  Timer? _ticker;
  Timer? _flashTimer;
  int _next = 1;
  int? _wrongIndex;

  @override
  void initState() {
    super.initState();
    _numbers = List.generate(size * size, (i) => i + 1)..shuffle();
    _stopwatch.start();
    _ticker = Timer.periodic(
        const Duration(milliseconds: 100), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _onCellTap(int index) {
    final n = _numbers[index];
    if (n < _next) return; // 이미 누른 칸
    if (n == _next) {
      widget.session.fx.tapLight();
      setState(() => _next++);
      if (_next > size * size) {
        _stopwatch.stop();
        _ticker?.cancel();
        widget.session.finish(_stopwatch.elapsedMilliseconds);
      }
    } else {
      widget.session.fx.fail();
      setState(() => _wrongIndex = index);
      _flashTimer = Timer(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => _wrongIndex = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            context.l.countSeconds(
                (_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(1)),
            style: textTheme.displaySmall,
          ),
          Text(context.l.numberGridNext(_next), style: textTheme.bodySmall),
          const Spacer(),
          AspectRatio(
            aspectRatio: 1,
            child: GridView.count(
              crossAxisCount: size,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < _numbers.length; i++) _buildCell(i),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildCell(int index) {
    final n = _numbers[index];
    final done = n < _next;
    final wrong = index == _wrongIndex;

    return GestureDetector(
      onTapDown: done ? null : (_) => _onCellTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: wrong
              ? AppColors.danger
              : done
                  ? Colors.transparent
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: done
              ? null
              : Border.all(
                  color: wrong ? AppColors.danger : AppColors.border),
          boxShadow: done || wrong
              ? null
              : const [
                  BoxShadow(
                    color: AppColors.surfaceEdge,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        child: Center(
          child: done
              ? null
              : Text(
                  '$n',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: wrong ? Colors.white : AppColors.textPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}
