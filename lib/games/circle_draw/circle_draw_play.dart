import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

class CircleDrawPlay extends StatefulWidget {
  const CircleDrawPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<CircleDrawPlay> createState() => _CircleDrawPlayState();
}

class _CircleDrawPlayState extends State<CircleDrawPlay> {
  static const accent = GameColors.cyan;
  static const minPoints = 16;
  static const minRadius = 50.0;
  static const minSweepRad = 5.24; // 약 300° — 이보다 덜 이으면 무효

  Timer? _timer;
  final List<Offset> _points = [];
  bool _drawing = false;
  bool _scored = false;
  double? _score;
  Offset? _fitCenter; // 채점 후 보여줄 이상적인 원
  double? _fitRadius;
  String? _hint; // 무효 사유 안내

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onPanStart(Offset pos) {
    if (_scored) return;
    setState(() {
      _points
        ..clear()
        ..add(pos);
      _drawing = true;
      _hint = null;
    });
  }

  void _onPanUpdate(Offset pos) {
    if (_scored || !_drawing) return;
    // 지나치게 촘촘한 점은 건너뛰어 점 수를 관리한다.
    if (_points.isNotEmpty && (pos - _points.last).distance < 2) return;
    setState(() => _points.add(pos));
  }

  void _onPanEnd() {
    if (_scored || !_drawing) return;
    _drawing = false;
    _judge();
  }

  void _judge() {
    if (_points.length < minPoints) {
      _invalid('더 크게, 끝까지 이어서 그리세요');
      return;
    }

    // 중심(무게중심) 기준 반지름 통계.
    var cx = 0.0, cy = 0.0;
    for (final p in _points) {
      cx += p.dx;
      cy += p.dy;
    }
    final center = Offset(cx / _points.length, cy / _points.length);

    var radiusSum = 0.0;
    for (final p in _points) {
      radiusSum += (p - center).distance;
    }
    final meanRadius = radiusSum / _points.length;
    if (meanRadius < minRadius) {
      _invalid('너무 작아요! 크게 그리세요');
      return;
    }

    // 중심 기준 각도를 누적해 얼마나 한 바퀴를 돌았는지 확인.
    var sweep = 0.0;
    var prevAngle = (_points.first - center).direction;
    for (final p in _points.skip(1)) {
      final angle = (p - center).direction;
      var delta = angle - prevAngle;
      if (delta > pi) delta -= 2 * pi;
      if (delta < -pi) delta += 2 * pi;
      sweep += delta;
      prevAngle = angle;
    }
    if (sweep.abs() < minSweepRad) {
      _invalid('원이 닫히지 않았어요! 한 바퀴를 이으세요');
      return;
    }

    // 원형도: 반지름 변동계수(표준편차/평균)가 작을수록 완벽.
    var varianceSum = 0.0;
    for (final p in _points) {
      final d = (p - center).distance - meanRadius;
      varianceSum += d * d;
    }
    final cv = sqrt(varianceSum / _points.length) / meanRadius;
    final score = ((100 * (1 - cv * 3)).clamp(0.0, 100.0) * 10).round() / 10;

    score >= 90 ? widget.session.fx.success() : widget.session.fx.tap();
    setState(() {
      _scored = true;
      _score = score;
      _fitCenter = center;
      _fitRadius = meanRadius;
    });
    _timer = Timer(const Duration(milliseconds: 1600),
        () => widget.session.finish(score));
  }

  void _invalid(String reason) {
    widget.session.fx.fail();
    setState(() {
      _points.clear();
      _hint = reason;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          SizedBox(
            height: 44,
            child: _score != null
                ? Text('${_score!.toStringAsFixed(1)}%',
                    style: textTheme.displaySmall!
                        .copyWith(color: darken(accent, 0.12)))
                : Text('한 획으로 완벽한 원을!',
                    style: textTheme.titleLarge),
          ),
          SizedBox(
            height: 20,
            child: _hint != null
                ? Text(_hint!,
                    style: textTheme.bodyMedium!
                        .copyWith(color: AppColors.danger))
                : null,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: cardDecoration(radius: 24),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                onPanStart: (d) => _onPanStart(d.localPosition),
                onPanUpdate: (d) => _onPanUpdate(d.localPosition),
                onPanEnd: (_) => _onPanEnd(),
                onPanCancel: _onPanEnd,
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _StrokePainter(
                    points: List.of(_points),
                    color: accent,
                    fitCenter: _fitCenter,
                    fitRadius: _fitRadius,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({
    required this.points,
    required this.color,
    required this.fitCenter,
    required this.fitRadius,
  });

  final List<Offset> points;
  final Color color;
  final Offset? fitCenter;
  final double? fitRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // 채점 후: 이상적인 원을 아래에 깔아 비교하게 한다.
    if (fitCenter != null && fitRadius != null) {
      canvas.drawCircle(
        fitCenter!,
        fitRadius!,
        Paint()
          ..color = AppColors.textDim.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_StrokePainter oldDelegate) =>
      oldDelegate.points.length != points.length ||
      oldDelegate.fitCenter != fitCenter;
}
