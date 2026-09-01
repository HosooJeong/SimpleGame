import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

class TimingBarPlay extends StatefulWidget {
  const TimingBarPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<TimingBarPlay> createState() => _TimingBarPlayState();
}

class _TimingBarPlayState extends State<TimingBarPlay>
    with SingleTickerProviderStateMixin {
  static const rounds = 5;
  static const accent = GameColors.purple;

  late final AnimationController _ctrl;
  Timer? _timer;
  int _round = 1;
  int _total = 0;
  int? _roundPoints; // null이면 이동 중

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onPointerDown() {
    if (_roundPoints != null) return;
    _ctrl.stop();
    final distance = ((_ctrl.value - 0.5).abs() * 2).clamp(0.0, 1.0);
    final points = ((1 - distance) * (1 - distance) * 100).round();
    _total += points;
    points >= 90 ? widget.session.fx.success() : widget.session.fx.tap();
    setState(() => _roundPoints = points);
    _timer = Timer(const Duration(milliseconds: 900), _nextRound);
  }

  void _nextRound() {
    if (!mounted) return;
    if (_round >= rounds) {
      widget.session.finish(_total);
      return;
    }
    setState(() {
      _round++;
      _roundPoints = null;
    });
    _ctrl.duration = Duration(
        milliseconds: (1100 * pow(0.85, _round - 1)).round());
    _ctrl.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onPointerDown(),
      child: SizedBox.expand(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('라운드 $_round / $rounds  ·  $_total점',
                  style: textTheme.bodyMedium),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 56,
                        child: AnimatedBuilder(
                          animation: _ctrl,
                          builder: (context, _) => Stack(
                            alignment: Alignment.center,
                            children: [
                              // 트랙
                              Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: kCardShadow,
                                ),
                              ),
                              // 중앙 목표선
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // 움직이는 원
                              Align(
                                alignment:
                                    Alignment(_ctrl.value * 2 - 1, 0),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: const BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 80,
                        child: _roundPoints != null
                            ? Text('$_roundPoints점!',
                                style: textTheme.displaySmall!
                                    .copyWith(color: accent))
                            : Text('정중앙에서 터치!',
                                style: textTheme.bodyMedium!
                                    .copyWith(color: AppColors.textDim)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
