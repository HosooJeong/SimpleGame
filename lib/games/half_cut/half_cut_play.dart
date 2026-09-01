import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

class HalfCutPlay extends StatefulWidget {
  const HalfCutPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<HalfCutPlay> createState() => _HalfCutPlayState();
}

class _HalfCutPlayState extends State<HalfCutPlay> {
  static const rounds = 5;
  static const samples = 160;
  static const accent = GameColors.lime;

  final _random = Random();
  Timer? _timer;

  int _round = 1;
  int _total = 0;
  int? _roundPoints; // null이면 아직 안 자름
  double? _cutX; // 0..1
  late List<double> _heights; // 실루엣 높이 0..1
  late List<double> _prefixArea; // 누적 넓이

  @override
  void initState() {
    super.initState();
    _generateShape();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _generateShape() {
    // 사인파 2~3개를 겹친 매끄러운 불규칙 실루엣.
    final f1 = 0.6 + _random.nextDouble() * 0.8;
    final f2 = 1.6 + _random.nextDouble() * 1.8;
    final f3 = 3.0 + _random.nextDouble() * 2.0;
    final p1 = _random.nextDouble() * 2 * pi;
    final p2 = _random.nextDouble() * 2 * pi;
    final p3 = _random.nextDouble() * 2 * pi;
    final a2 = 0.15 + _random.nextDouble() * 0.15;
    final a3 = 0.05 + _random.nextDouble() * 0.08;

    _heights = List.generate(samples, (i) {
      final t = i / (samples - 1);
      final h = 0.5 +
          0.24 * sin(2 * pi * f1 * t + p1) +
          a2 * sin(2 * pi * f2 * t + p2) +
          a3 * sin(2 * pi * f3 * t + p3);
      return h.clamp(0.12, 1.0);
    });

    _prefixArea = List.filled(samples, 0);
    var acc = 0.0;
    for (var i = 0; i < samples; i++) {
      acc += _heights[i];
      _prefixArea[i] = acc;
    }
  }

  /// 드래그 중 절단선 위치 갱신 (아직 채점 안 함).
  void _updateCut(double x) {
    if (_roundPoints != null) return;
    setState(() => _cutX = x.clamp(0.0, 1.0));
  }

  /// 드래그를 놓으면 절단선 고정 + 채점.
  void _lockCut() {
    if (_roundPoints != null || _cutX == null) return;
    final index =
        (_cutX! * (samples - 1)).round().clamp(0, samples - 1);
    final ratio = _prefixArea[index] / _prefixArea[samples - 1];
    final error = (ratio - 0.5).abs(); // 0(완벽) ~ 0.5(끝)
    final closeness = (1 - error / 0.5).clamp(0.0, 1.0);
    final points = (closeness * closeness * 100).round();
    _total += points;
    points >= 90 ? widget.session.fx.success() : widget.session.fx.tap();
    setState(() => _roundPoints = points);
    _timer = Timer(const Duration(milliseconds: 1100), _nextRound);
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
      _cutX = null;
      _generateShape();
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
          Text('라운드 $_round / $rounds  ·  $_total점',
              style: textTheme.bodyMedium),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: cardDecoration(radius: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GestureDetector(
                  onPanDown: (details) =>
                      _updateCut(details.localPosition.dx / width),
                  onPanUpdate: (details) =>
                      _updateCut(details.localPosition.dx / width),
                  onPanEnd: (_) => _lockCut(),
                  onPanCancel: _lockCut,
                  child: CustomPaint(
                    size: Size(width, 240),
                    painter: _ShapePainter(
                      heights: _heights,
                      cutX: _cutX,
                      color: accent,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 64,
            child: _roundPoints != null
                ? Text('$_roundPoints점!',
                    style: textTheme.displaySmall!
                        .copyWith(color: darken(accent, 0.12)))
                : Text(
                    _cutX == null
                        ? '도형을 눌러 절단선을 잡으세요'
                        : '드래그로 옮기고, 놓으면 확정!',
                    style: textTheme.bodyMedium!
                        .copyWith(color: AppColors.textDim)),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({required this.heights, required this.cutX, required this.color});

  final List<double> heights;
  final double? cutX;
  final Color color;

  Path _silhouette(Size size) {
    final path = Path()..moveTo(0, size.height);
    for (var i = 0; i < heights.length; i++) {
      path.lineTo(
        size.width * i / (heights.length - 1),
        size.height * (1 - heights[i]),
      );
    }
    path
      ..lineTo(size.width, size.height)
      ..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _silhouette(size);

    if (cutX == null) {
      canvas.drawPath(path, Paint()..color = color);
      return;
    }

    // 잘린 뒤: 왼쪽은 진하게, 오른쪽은 연하게 + 절단선.
    final cutPx = size.width * cutX!;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, cutPx, size.height));
    canvas.drawPath(path, Paint()..color = darken(color, 0.25));
    canvas.restore();
    canvas.save();
    canvas.clipRect(
        Rect.fromLTWH(cutPx, 0, size.width - cutPx, size.height));
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.55));
    canvas.restore();

    canvas.drawLine(
      Offset(cutPx, 0),
      Offset(cutPx, size.height),
      Paint()
        ..color = AppColors.textPrimary
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) =>
      oldDelegate.heights != heights ||
      oldDelegate.cutX != cutX ||
      oldDelegate.color != color;
}
