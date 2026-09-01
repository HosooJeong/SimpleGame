import 'package:flutter/material.dart';

/// 최근 기록 추이를 그리는 초경량 스파크라인 (외부 차트 라이브러리 불필요).
class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.values, required this.color});

  final List<num> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(values: values, color: color),
      size: const Size.fromHeight(48),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<num> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final min = values.reduce((a, b) => a < b ? a : b).toDouble();
    final max = values.reduce((a, b) => a > b ? a : b).toDouble();
    final range = max - min;

    // 세로 여백을 둬서 선이 잘리지 않게.
    const pad = 4.0;
    final h = size.height - pad * 2;

    Offset pointAt(int i) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final norm = range == 0 ? 0.5 : (values[i] - min) / range;
      return Offset(x, pad + h * (1 - norm));
    }

    if (values.length > 1) {
      final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
      for (var i = 1; i < values.length; i++) {
        path.lineTo(pointAt(i).dx, pointAt(i).dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // 최신 기록 점 강조.
    canvas.drawCircle(
        pointAt(values.length - 1), 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
