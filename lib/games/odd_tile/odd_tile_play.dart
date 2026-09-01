import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/l10n_context.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

class OddTilePlay extends StatefulWidget {
  const OddTilePlay({super.key, required this.session});

  final GameSession session;

  @override
  State<OddTilePlay> createState() => _OddTilePlayState();
}

class _OddTilePlayState extends State<OddTilePlay> {
  static const totalMs = 30000;
  static const wrongPenaltyMs = 2000;
  static const accent = GameColors.pink;

  final _random = Random();
  Timer? _ticker;
  Timer? _answerTimer;
  int _timeLeftMs = totalMs;
  int _level = 1;
  bool _finished = false;
  bool _showAnswer = false;

  late int _gridSize;
  late int _oddIndex;
  late Color _baseColor;
  late Color _oddColor;

  @override
  void initState() {
    super.initState();
    _generateBoard();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => _timeLeftMs -= 100);
      if (_timeLeftMs <= 0) _finish();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _answerTimer?.cancel();
    super.dispose();
  }

  void _finish() {
    if (_finished) return;
    _finished = true;
    _ticker?.cancel();
    // 시간 종료 안내 + 정답 타일을 잠시 보여준 뒤 결과 화면으로.
    widget.session.fx.fail();
    setState(() => _showAnswer = true);
    _answerTimer = Timer(const Duration(milliseconds: 1300),
        () => widget.session.finish(_level - 1));
  }

  void _generateBoard() {
    _gridSize = min(6, _level + 1);
    _oddIndex = _random.nextInt(_gridSize * _gridSize);

    final hue = _random.nextDouble() * 360;
    const saturation = 0.6;
    const lightness = 0.5;
    // 단계가 오를수록 색차 감소.
    final delta = max(0.035, 0.20 * pow(0.85, _level - 1).toDouble());
    final sign = _random.nextBool() ? 1 : -1;
    final oddLightness = (lightness + sign * delta).clamp(0.08, 0.92);

    _baseColor =
        HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
    _oddColor =
        HSLColor.fromAHSL(1, hue, saturation, oddLightness).toColor();
  }

  void _onCellTap(int index) {
    if (_finished) return;
    if (index == _oddIndex) {
      widget.session.fx.tapLight();
      setState(() {
        _level++;
        _generateBoard();
      });
    } else {
      widget.session.fx.fail();
      setState(() => _timeLeftMs = max(0, _timeLeftMs - wrongPenaltyMs));
      if (_timeLeftMs <= 0) _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final timeRatio = (_timeLeftMs / totalMs).clamp(0.0, 1.0);
    final urgent = _timeLeftMs < 5000;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(context.l.countLevel('$_level'), style: textTheme.displaySmall),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: timeRatio,
              minHeight: 8,
              backgroundColor: Colors.white,
              color: urgent ? AppColors.danger : accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _showAnswer
                ? context.l.oddTileTimeUp
                : context.l.countSeconds((_timeLeftMs / 1000).toStringAsFixed(1)),
            style: _showAnswer
                ? textTheme.bodyMedium!.copyWith(color: AppColors.danger)
                : textTheme.bodySmall,
          ),
          const Spacer(),
          AspectRatio(
            aspectRatio: 1,
            child: GridView.count(
              crossAxisCount: _gridSize,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (var i = 0; i < _gridSize * _gridSize; i++)
                  GestureDetector(
                    onTapDown: (_) => _onCellTap(i),
                    child: Container(
                      decoration: BoxDecoration(
                        // 정답 공개 중엔 정답 타일만 또렷하게, 나머지는 흐리게.
                        color: (i == _oddIndex ? _oddColor : _baseColor)
                            .withValues(
                                alpha: _showAnswer && i != _oddIndex
                                    ? 0.3
                                    : 1.0),
                        borderRadius: BorderRadius.circular(10),
                        border: _showAnswer && i == _oddIndex
                            ? Border.all(color: Colors.white, width: 4)
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
