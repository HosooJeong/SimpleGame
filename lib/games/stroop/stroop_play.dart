import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/l10n_context.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

class StroopPlay extends StatefulWidget {
  const StroopPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<StroopPlay> createState() => _StroopPlayState();
}

class _StroopPlayState extends State<StroopPlay> {
  static const totalMs = 30000;
  static const accent = GameColors.indigo;

  /// 색 이름은 언어마다 다르므로 표시 시점에 꺼낸다. _inks 와 순서가 같아야 한다.
  static List<String> _wordsOf(BuildContext context) => [
        context.l.colorRed,
        context.l.colorBlue,
        context.l.colorGreen,
        context.l.colorYellow,
        context.l.colorPurple,
      ];
  static const _inks = [
    GameColors.red,
    GameColors.blue,
    GameColors.green,
    GameColors.yellow,
    GameColors.purple,
  ];

  final _random = Random();
  Timer? _ticker;
  Timer? _flashTimer;
  int _timeLeftMs = totalMs;
  int _score = 0;
  int _wordIndex = 0;
  int _inkIndex = 0;
  bool _finished = false;
  bool _flashWrong = false;

  @override
  void initState() {
    super.initState();
    _nextProblem();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => _timeLeftMs -= 100);
      if (_timeLeftMs <= 0) _finish();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _ticker?.cancel();
    widget.session.finish(_score);
  }

  void _nextProblem() {
    _wordIndex = _random.nextInt(_inks.length);
    // 절반 확률로 뜻과 색을 일치시킨다.
    _inkIndex = _random.nextBool()
        ? _wordIndex
        : (_wordIndex + 1 + _random.nextInt(_inks.length - 1)) %
            _inks.length;
  }

  void _answer(bool saidMatch) {
    if (_finished) return;
    final isMatch = _wordIndex == _inkIndex;
    if (saidMatch == isMatch) {
      widget.session.fx.tapLight();
      _score++;
    } else {
      // 오답 안내: 카드 테두리를 잠깐 빨갛게.
      widget.session.fx.fail();
      _score = max(0, _score - 1);
      _flashWrong = true;
      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(milliseconds: 250), () {
        if (mounted) setState(() => _flashWrong = false);
      });
    }
    setState(_nextProblem);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final timeRatio = (_timeLeftMs / totalMs).clamp(0.0, 1.0);
    final urgent = _timeLeftMs < 5000;
    // 크림 배경에서 노랑 잉크는 살짝 어둡게 보정.
    final ink =
        _inkIndex == 3 ? darken(_inks[3], 0.14) : _inks[_inkIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(context.l.countPoints('$_score'), style: textTheme.displaySmall),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: timeRatio,
              minHeight: 8,
              backgroundColor: Colors.white,
              color: urgent ? AppColors.danger : accent,
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 42),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: kCardShadow,
                  border: _flashWrong
                      ? Border.all(color: AppColors.danger, width: 3)
                      : null,
                ),
                child: Center(
                  child: Text(
                    _wordsOf(context)[_wordIndex],
                    style: TextStyle(
                      fontFamily: 'BlackHanSans',
                      fontSize: 58,
                      color: ink,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _OxButton(
                  label: 'O',
                  caption: context.l.stroopMatch,
                  color: AppColors.success,
                  onPressed: () => _answer(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _OxButton(
                  label: 'X',
                  caption: context.l.stroopMismatch,
                  color: AppColors.danger,
                  onPressed: () => _answer(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// 스피드 판단용 대형 O/X 버튼 — 즉시 반응을 위해 pointerDown에서 처리.
class _OxButton extends StatelessWidget {
  const _OxButton({
    required this.label,
    required this.caption,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String caption;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onPressed(),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: darken(color), offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'BlackHanSans',
                fontSize: 30,
                color: Colors.white,
                height: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              style: const TextStyle(
                fontFamily: 'Jua',
                fontSize: 13,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
