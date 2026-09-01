import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

enum _MemPhase { showing, input, transition, failed }

class MemoryPlay extends StatefulWidget {
  const MemoryPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<MemoryPlay> createState() => _MemoryPlayState();
}

class _MemoryPlayState extends State<MemoryPlay> {
  static const accent = GameColors.green;
  // 0=위, 1=오른쪽, 2=아래, 3=왼쪽
  static const _icons = [
    Icons.keyboard_arrow_up,
    Icons.keyboard_arrow_right,
    Icons.keyboard_arrow_down,
    Icons.keyboard_arrow_left,
  ];

  final _random = Random();
  final _sequence = <int>[];
  _MemPhase _phase = _MemPhase.transition;
  int _inputPos = 0;
  int? _lit;
  int? _wrongDir; // 실패 시 잘못 누른 버튼
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 500), _nextRound);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _nextRound() {
    if (!mounted) return;
    _sequence.add(_random.nextInt(4));
    _inputPos = 0;
    setState(() => _phase = _MemPhase.showing);
    _playSequence();
  }

  Future<void> _playSequence() async {
    // 단계가 오를수록 점멸이 빨라진다.
    final onMs = max(200, 480 - _sequence.length * 25);
    for (final dir in _sequence) {
      if (!mounted) return;
      setState(() => _lit = dir);
      widget.session.fx.tick();
      await Future.delayed(Duration(milliseconds: onMs));
      if (!mounted) return;
      setState(() => _lit = null);
      await Future.delayed(const Duration(milliseconds: 140));
    }
    if (!mounted) return;
    setState(() => _phase = _MemPhase.input);
  }

  void _onDirTap(int dir) {
    if (_phase != _MemPhase.input) return;

    if (dir == _sequence[_inputPos]) {
      setState(() => _lit = dir);
      _timer = Timer(const Duration(milliseconds: 180), () {
        if (mounted) setState(() => _lit = null);
      });
      widget.session.fx.tapLight();
      _inputPos++;
      if (_inputPos >= _sequence.length) {
        widget.session.fx.success();
        setState(() => _phase = _MemPhase.transition);
        _timer = Timer(const Duration(milliseconds: 700), _nextRound);
      }
    } else {
      // 실패: 잘못 누른 버튼은 빨강, 정답 버튼은 초록으로 잠시 보여준다.
      widget.session.fx.fail();
      setState(() {
        _phase = _MemPhase.failed;
        _wrongDir = dir;
        _lit = _sequence[_inputPos];
      });
      _timer = Timer(const Duration(milliseconds: 1400),
          () => widget.session.finish(_sequence.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hint = switch (_phase) {
      _MemPhase.showing => '잘 보세요...',
      _MemPhase.input => '따라 누르세요!',
      _MemPhase.transition => '',
      _MemPhase.failed => '틀렸어요! 정답은 초록색',
    };

    return Column(
      children: [
        const SizedBox(height: 24),
        Text('${_sequence.length}단계', style: textTheme.displaySmall),
        SizedBox(
          height: 28,
          child: Text(hint, style: textTheme.bodyMedium),
        ),
        Expanded(
          child: Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: _buildButton(0),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildButton(1),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildButton(2),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildButton(3),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildButton(int dir) {
    final lit = _lit == dir;
    final wrong = _phase == _MemPhase.failed && _wrongDir == dir;
    final color = wrong
        ? AppColors.danger
        : lit
            ? accent
            : AppColors.surface;
    return GestureDetector(
      onTapDown: (_) => _onDirTap(dir),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: color == AppColors.surface ? AppColors.border : color),
          boxShadow: color == AppColors.surface ? kCardShadow : null,
        ),
        child: Icon(
          _icons[dir],
          size: 44,
          color: color == AppColors.surface
              ? AppColors.textPrimary
              : Colors.white,
        ),
      ),
    );
  }
}
