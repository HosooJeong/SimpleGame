import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/l10n_context.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

/// 실루엣 높이로부터 누적 넓이를 만든다. `prefix[i]`는 0번 샘플부터 i번 샘플까지의
/// 넓이(가로 간격은 1로 두고 잰 값 — 비율만 쓰므로 단위는 상관없다).
///
/// 화면에 그려지는 도형은 샘플 점들을 직선으로 이은 폴리곤(_ShapePainter)이므로
/// 사다리꼴로 재야 채점이 눈에 보이는 그림과 일치한다. 단순 누적합(직사각형)으로
/// 재면 정확히 반을 잘라도 만점이 나오지 않는다.
List<double> buildPrefixArea(List<double> heights) {
  final prefix = List.filled(heights.length, 0.0);
  var acc = 0.0;
  for (var i = 1; i < heights.length; i++) {
    acc += (heights[i - 1] + heights[i]) / 2;
    prefix[i] = acc;
  }
  return prefix;
}

/// 절단선 [cutX](0~1) 왼쪽 넓이가 전체에서 차지하는 비율.
///
/// 샘플 사이도 보간해서 잰다. 가장 가까운 샘플로 반올림하면 손가락 위치가
/// 160칸으로 뭉개져, 최적으로 잘라도 만점이 나오지 않는다.
double areaRatioAt(
    List<double> heights, List<double> prefixArea, double cutX) {
  final last = heights.length - 1;
  final pos = cutX.clamp(0.0, 1.0) * last;
  final i = pos.floor().clamp(0, last - 1);
  final f = (pos - i).clamp(0.0, 1.0);
  final heightAtCut = heights[i] + (heights[i + 1] - heights[i]) * f;
  final area = prefixArea[i] + f * (heights[i] + heightAtCut) / 2;
  return area / prefixArea[last];
}

/// 넓이 비율을 0~100점으로. 정확히 반(0.5)이면 100점, 끝까지 치우치면 0점.
int scoreForRatio(double ratio) {
  final error = (ratio - 0.5).abs(); // 0(완벽) ~ 0.5(끝)
  final closeness = (1 - error / 0.5).clamp(0.0, 1.0);
  return (closeness * closeness * 100).round();
}

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

    _prefixArea = buildPrefixArea(_heights);
  }

  /// 드래그 중 절단선 위치 갱신 (아직 채점 안 함).
  void _updateCut(double x) {
    if (_roundPoints != null) return;
    setState(() => _cutX = x.clamp(0.0, 1.0));
  }

  /// 드래그를 놓으면 절단선 고정 + 채점.
  void _lockCut() {
    if (_roundPoints != null || _cutX == null) return;
    final points = scoreForRatio(areaRatioAt(_heights, _prefixArea, _cutX!));
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
          Text(context.l.roundProgressScore(_round, rounds, _total),
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
                ? Text(context.l.pointsGained(_roundPoints!),
                    style: textTheme.displaySmall!
                        .copyWith(color: darken(accent, 0.12)))
                : Text(
                    _cutX == null
                        ? context.l.halfCutGrabCue
                        : context.l.halfCutDragCue,
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
