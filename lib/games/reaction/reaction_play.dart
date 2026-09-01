import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/l10n_context.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

enum _RoundPhase { waiting, ready, roundResult, falseStart }

/// 정밀 타이밍 원칙:
/// - 초록 전환 후 addPostFrameCallback에서 Stopwatch 시작 (실제 표시 시점 기준)
/// - Listener.onPointerDown으로 즉시 포착 (GestureDetector.onTap의 지연 회피)
/// - 대기 화면은 완전 정적 (Timer 하나 외에 아무 작업 없음)
class ReactionPlay extends StatefulWidget {
  const ReactionPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<ReactionPlay> createState() => _ReactionPlayState();
}

class _ReactionPlayState extends State<ReactionPlay> {
  static const rounds = 5;

  final _random = Random();
  final _stopwatch = Stopwatch();
  final _results = <int>[];
  _RoundPhase _phase = _RoundPhase.waiting;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRound() {
    if (!mounted) return;
    _stopwatch
      ..stop()
      ..reset();
    setState(() => _phase = _RoundPhase.waiting);
    _timer = Timer(
      Duration(milliseconds: 2000 + _random.nextInt(2500)),
      () {
        if (!mounted) return;
        setState(() => _phase = _RoundPhase.ready);
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _stopwatch.start());
      },
    );
  }

  void _onPointerDown() {
    switch (_phase) {
      case _RoundPhase.waiting:
        _timer?.cancel();
        widget.session.fx.fail();
        setState(() => _phase = _RoundPhase.falseStart);
        _timer = Timer(const Duration(milliseconds: 1200), _startRound);
      case _RoundPhase.ready:
        final micros = _stopwatch.elapsedMicroseconds;
        _stopwatch.stop();
        _results.add((micros / 1000).round());
        widget.session.fx.tap();
        setState(() => _phase = _RoundPhase.roundResult);
        if (_results.length >= rounds) {
          final avg = (_results.reduce((a, b) => a + b) / rounds).round();
          _timer = Timer(const Duration(milliseconds: 900),
              () => widget.session.finish(avg));
        } else {
          _timer = Timer(const Duration(milliseconds: 900), _startRound);
        }
      case _RoundPhase.roundResult:
      case _RoundPhase.falseStart:
        break; // 무시
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 빨강/초록 전체 화면 위에서는 흰 텍스트를 쓴다.
    final (Color bg, Widget content) = switch (_phase) {
      _RoundPhase.waiting => (
          AppColors.danger,
          Text(context.l.reactionWaitCue,
              style: textTheme.displaySmall!.copyWith(color: Colors.white),
              textAlign: TextAlign.center),
        ),
      _RoundPhase.ready => (
          AppColors.success,
          Text(context.l.reactionGoCue,
              style: textTheme.displaySmall!.copyWith(color: Colors.white)),
        ),
      _RoundPhase.roundResult => (
          AppColors.bg,
          Text('${_results.last}ms',
              style: textTheme.displayLarge!
                  .copyWith(color: AppColors.success)),
        ),
      _RoundPhase.falseStart => (
          AppColors.bg,
          Text(context.l.reactionTooEarly,
              style: textTheme.displaySmall!
                  .copyWith(color: AppColors.danger),
              textAlign: TextAlign.center),
        ),
    };
    final onColoredBg =
        _phase == _RoundPhase.waiting || _phase == _RoundPhase.ready;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onPointerDown(),
      child: ColoredBox(
        color: bg,
        child: SizedBox.expand(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  context.l.roundProgress((_results.length + 1).clamp(1, rounds), rounds),
                  style: textTheme.bodyMedium!.copyWith(
                    color:
                        onColoredBg ? Colors.white70 : AppColors.textDim,
                  ),
                ),
              ),
              Expanded(child: Center(child: content)),
            ],
          ),
        ),
      ),
    );
  }
}
