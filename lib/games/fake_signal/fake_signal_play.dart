import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

enum _Phase { gap, signal, dead }

/// 초록 신호의 남은 시간 링 — 12시 방향부터 시계 방향으로 닳는다.
class _TimeRingPainter extends CustomPainter {
  _TimeRingPainter(this.remaining);

  final double remaining; // 1..0

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2 - 11),
      -pi / 2,
      2 * pi * remaining,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TimeRingPainter oldDelegate) =>
      oldDelegate.remaining != remaining;
}

class FakeSignalPlay extends StatefulWidget {
  const FakeSignalPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<FakeSignalPlay> createState() => _FakeSignalPlayState();
}

class _FakeSignalPlayState extends State<FakeSignalPlay> {
  static const maxStreak = 200;

  final _random = Random();
  Timer? _timer;

  _Phase _phase = _Phase.gap;
  bool _isFake = false;
  int _streak = 0;
  int _greenRun = 0; // 연속 초록 수 — 리듬 탭 방지용
  String? _failReason;
  bool _failedInGap = false; // 신호 없는데 터치해서 실패

  /// 초록(진짜) 터치 제한 — 루트 감쇠(매 회를 2회분으로 가속): 초반(850ms)은
  /// 여유 있게 시작해 급격히 팽팽해지고, 약 24회에 한계(400ms) 도달.
  int get _greenWindowMs => max(400, (850 - 65 * sqrt(2.0 * _streak)).round());

  /// 빨강(가짜) 표시 시간 — 초록 커브를 따라가되 조금 짧게.
  int get _redShowMs => max(400, _greenWindowMs - 100);

  @override
  void initState() {
    super.initState();
    _scheduleSignal();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _scheduleSignal() {
    _timer = Timer(
      Duration(milliseconds: 350 + _random.nextInt(400)),
      _showSignal,
    );
  }

  void _showSignal() {
    if (!mounted) return;
    // 초록이 3연속이면 강제로 가짜 — 박자 외워 누르기 방지.
    final fake = _greenRun >= 3 || _random.nextDouble() < 0.35;
    setState(() {
      _phase = _Phase.signal;
      _isFake = fake;
    });
    _timer = Timer(
        Duration(milliseconds: fake ? _redShowMs : _greenWindowMs), () {
      if (!mounted) return;
      if (_isFake) {
        // 가짜를 참아냈다 — 통과.
        widget.session.fx.tick();
        _greenRun = 0;
        _pass();
      } else {
        _fail('신호를 놓쳤어요!');
      }
    });
  }

  void _pass() {
    // 초록을 터치로 통과한 경우 아직 살아 있는 판정 타이머를 반드시 끊는다.
    // 안 끊으면 다음 신호가 뜬 뒤에 유령 타이머가 터져 엉뚱한 판정을 낸다.
    _timer?.cancel();
    _streak++;
    if (_streak >= maxStreak) {
      widget.session.finish(maxStreak);
      return;
    }
    setState(() => _phase = _Phase.gap);
    _scheduleSignal();
  }

  void _onTap() {
    switch (_phase) {
      case _Phase.gap:
        _failedInGap = true;
        _fail('신호가 없을 때 터치했어요!');
      case _Phase.signal:
        if (_isFake) {
          _fail('가짜 신호에 낚였어요!');
        } else {
          widget.session.fx.tapLight();
          _greenRun++;
          _pass();
        }
      case _Phase.dead:
        break;
    }
  }

  void _fail(String reason) {
    _timer?.cancel();
    widget.session.fx.fail();
    setState(() {
      _phase = _Phase.dead;
      _failReason = reason;
    });
    _timer = Timer(const Duration(milliseconds: 1400),
        () => widget.session.finish(_streak));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dead = _phase == _Phase.dead;
    final showCircle = _phase == _Phase.signal || (dead && !_failedInGap);

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _onTap(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Text('$_streak개', style: textTheme.displaySmall),
            SizedBox(
              height: 24,
              child: Text(
                dead
                    ? _failReason!
                    : _phase == _Phase.gap
                        ? '기다리세요...'
                        : _isFake
                            ? '참아!'
                            : '터치!',
                style: textTheme.bodyMedium!.copyWith(
                  color: dead ? AppColors.danger : AppColors.textDim,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: showCircle
                    ? Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color:
                              _isFake ? AppColors.danger : AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: darken(
                                  _isFake
                                      ? AppColors.danger
                                      : AppColors.success,
                                  0.3),
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: dead
                            ? const Icon(Icons.close_rounded,
                                size: 72, color: Colors.white)
                            : _isFake
                                ? null
                                // 남은 시간 게이지 — 링이 다 닳기 전에 터치.
                                : TweenAnimationBuilder<double>(
                                    key: ValueKey(_streak),
                                    tween: Tween(begin: 1, end: 0),
                                    duration: Duration(
                                        milliseconds: _greenWindowMs),
                                    builder: (context, v, _) => CustomPaint(
                                      size: const Size(170, 170),
                                      painter: _TimeRingPainter(v),
                                    ),
                                  ),
                      )
                    : Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _failedInGap
                                ? AppColors.danger
                                : AppColors.textDim.withValues(alpha: 0.4),
                            width: 3,
                          ),
                        ),
                        child: _failedInGap
                            ? const Icon(Icons.close_rounded,
                                size: 72, color: AppColors.danger)
                            : null,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
