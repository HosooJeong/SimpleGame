import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/l10n_context.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

enum _Phase { flash, blank, question, reveal }

class FlashCountPlay extends StatefulWidget {
  const FlashCountPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<FlashCountPlay> createState() => _FlashCountPlayState();
}

class _FlashCountPlayState extends State<FlashCountPlay> {
  static const accent = GameColors.emerald;
  static const maxLevel = 15;
  static const dotRadius = 11.0;

  final _random = Random();
  Timer? _timer;

  int _level = 1;
  int _dotCount = 3;
  _Phase _phase = _Phase.blank;
  List<Offset> _dots = []; // 0..1 상대 좌표
  List<int> _options = [];
  bool _failed = false;
  int? _chosen;

  int get _flashMs => max(350, 700 - _level * 25);

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLevel() {
    if (!mounted) return;
    setState(() {
      // 단계 = 중심값일 뿐, ±2 랜덤이라 단계만으로 정답을 예측할 수 없다.
      _dotCount = max(3, 2 + _level + _random.nextInt(5) - 2);
      _dots = _placeDots(_dotCount);
      _options = _makeOptions(_dotCount);
      _phase = _Phase.flash;
      _chosen = null;
    });
    _timer = Timer(Duration(milliseconds: _flashMs), () {
      if (!mounted) return;
      setState(() => _phase = _Phase.blank);
      // 잔상이 가라앉을 짧은 공백 후 보기 표시.
      _timer = Timer(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => _phase = _Phase.question);
      });
    });
  }

  /// 겹치지 않는 점 배치 (0..1 상대 좌표, 거절 샘플링).
  List<Offset> _placeDots(int count) {
    final dots = <Offset>[];
    var attempts = 0;
    while (dots.length < count && attempts < 800) {
      attempts++;
      final p = Offset(
        0.08 + _random.nextDouble() * 0.84,
        0.08 + _random.nextDouble() * 0.84,
      );
      final tooClose = dots.any((d) => (d - p).distance < 0.13);
      if (!tooClose) dots.add(p);
    }
    return dots;
  }

  List<int> _makeOptions(int answer) {
    final pool = [answer - 2, answer - 1, answer + 1, answer + 2]
        .where((n) => n >= 1)
        .toList()
      ..shuffle(_random);
    return ([answer, ...pool.take(3)])..shuffle(_random);
  }

  void _answer(int n) {
    if (_phase != _Phase.question) return;
    if (n == _dotCount) {
      widget.session.fx.tapLight();
      setState(() {
        _phase = _Phase.reveal;
        _chosen = n;
      });
      if (_level >= maxLevel) {
        widget.session.fx.success();
        _timer = Timer(const Duration(milliseconds: 600),
            () => widget.session.finish(maxLevel));
        return;
      }
      _timer = Timer(const Duration(milliseconds: 550), () {
        _level++;
        _startLevel();
      });
    } else {
      widget.session.fx.fail();
      setState(() {
        _phase = _Phase.reveal;
        _failed = true;
        _chosen = n;
      });
      _timer = Timer(const Duration(milliseconds: 1500),
          () => widget.session.finish(_level - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(context.l.countLevel('$_level'), style: textTheme.displaySmall),
          SizedBox(
            height: 24,
            child: Text(
              switch (_phase) {
                _Phase.flash => context.l.flashCountPrompt,
                _Phase.blank => '',
                _Phase.question => context.l.flashCountAsk,
                _Phase.reveal =>
                  _failed
            ? context.l.flashCountWrong(_dotCount)
            : context.l.flashCountCorrect,
              },
              style: textTheme.bodyMedium!.copyWith(
                color: _failed ? AppColors.danger : AppColors.textDim,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: cardDecoration(radius: 24),
              child: _phase == _Phase.flash || _phase == _Phase.reveal
                  ? LayoutBuilder(
                      builder: (context, constraints) => Stack(
                        children: [
                          for (final d in _dots)
                            Positioned(
                              left: d.dx * constraints.maxWidth - dotRadius,
                              top: d.dy * constraints.maxHeight - dotRadius,
                              child: Container(
                                width: dotRadius * 2,
                                height: dotRadius * 2,
                                decoration: const BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 76,
            child: _phase == _Phase.question || _phase == _Phase.reveal
                ? Row(
                    children: [
                      for (final (i, n) in _options.indexed) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(child: _optionButton(n)),
                      ],
                    ],
                  )
                : null,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _optionButton(int n) {
    // 공개 단계: 정답은 초록, 잘못 고른 보기는 빨강, 나머지는 흐리게.
    final isAnswer = _phase == _Phase.reveal && n == _dotCount;
    final isWrongChoice = _phase == _Phase.reveal && _failed && n == _chosen;
    final dimmed = _phase == _Phase.reveal && !isAnswer && !isWrongChoice;
    final color = isAnswer
        ? AppColors.success
        : isWrongChoice
            ? AppColors.danger
            : accent;

    return GestureDetector(
      onTapDown: (_) => _answer(n),
      child: Container(
        decoration: BoxDecoration(
          color: dimmed ? color.withValues(alpha: 0.3) : color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: dimmed
              ? null
              : [
                  BoxShadow(color: darken(color), offset: const Offset(0, 4)),
                ],
        ),
        child: Center(
          child: Text(
            '$n',
            style: const TextStyle(
              fontFamily: 'BlackHanSans',
              fontSize: 26,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
