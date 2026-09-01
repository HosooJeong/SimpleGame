import 'dart:math';

import 'package:flutter/material.dart';

import '../app/theme.dart';

/// 홈 카드의 컬러 블록 위에 올라가는 미니 게임 장면.
/// 배경이 게임 고유색이므로 장면 요소는 흰색(+투명도)으로 그린다.

class ReactionPreview extends StatelessWidget {
  const ReactionPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child:
              Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class NumberGridPreview extends StatelessWidget {
  const NumberGridPreview({super.key, required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _miniGrid(
      cellBuilder: (i) => Container(
        width: 19,
        height: 19,
        decoration: BoxDecoration(
          color: i < 3 ? Colors.white : Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(5),
        ),
        child: i < 3
            ? Center(
                child: Text(
                  '${i + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class TapSpeedPreview extends StatelessWidget {
  const TapSpeedPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 2.5),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7), width: 2.5),
            ),
          ),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class TimingBarPreview extends StatelessWidget {
  const TimingBarPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 7,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Align(
            alignment: const Alignment(0.5, 0),
            child: Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MemoryPreview extends StatelessWidget {
  const MemoryPreview({super.key});

  Widget _pad({bool lit = false}) => Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: lit ? Colors.white : Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 58,
      child: Stack(
        children: [
          Align(alignment: Alignment.topCenter, child: _pad(lit: true)),
          Align(alignment: Alignment.centerLeft, child: _pad()),
          Align(alignment: Alignment.centerRight, child: _pad()),
          Align(alignment: Alignment.bottomCenter, child: _pad()),
        ],
      ),
    );
  }
}

class TimerTenPreview extends StatelessWidget {
  const TimerTenPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.visibility_off_rounded, size: 22, color: Colors.white),
        SizedBox(width: 6),
        Text(
          '?.??',
          style: TextStyle(
            fontFamily: 'BlackHanSans',
            fontSize: 26,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class OddTilePreview extends StatelessWidget {
  const OddTilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return _miniGrid(
      cellBuilder: (i) => Container(
        width: 19,
        height: 19,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: i == 5 ? 0.45 : 0.95),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class StroopPreview extends StatelessWidget {
  const StroopPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Text(
            '빨강',
            style: TextStyle(
              fontFamily: 'Jua',
              fontSize: 17,
              color: GameColors.blue, // 뜻과 색이 다른 함정
            ),
          ),
        ),
        const SizedBox(height: 7),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _oxDot('O'),
            const SizedBox(width: 8),
            _oxDot('X'),
          ],
        ),
      ],
    );
  }

  Widget _oxDot(String label) => Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      );
}

class ChimpPreview extends StatelessWidget {
  const ChimpPreview({super.key, required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    // 1은 보이고 나머지는 가려진 침팬지 테스트 장면.
    Widget cell(String? label, {bool hidden = false}) => Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: label == null
                ? Colors.white.withValues(alpha: 0.25)
                : hidden
                    ? Colors.white.withValues(alpha: 0.55)
                    : Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: label != null && !hidden
              ? Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                )
              : null,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          cell('1'),
          const SizedBox(width: 4),
          cell(null),
          const SizedBox(width: 4),
          cell('2', hidden: true),
        ]),
        const SizedBox(height: 4),
        Row(mainAxisSize: MainAxisSize.min, children: [
          cell('3', hidden: true),
          const SizedBox(width: 4),
          cell(null),
          const SizedBox(width: 4),
          cell('4', hidden: true),
        ]),
      ],
    );
  }
}

class HalfCutPreview extends StatelessWidget {
  const HalfCutPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(84, 48),
      painter: _HalfCutPreviewPainter(),
    );
  }
}

class _HalfCutPreviewPainter extends CustomPainter {
  const _HalfCutPreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 울퉁불퉁한 실루엣 + 가운데 절단선.
    final path = Path()..moveTo(0, size.height);
    const heights = [0.45, 0.7, 0.55, 0.85, 0.6, 0.75, 0.4, 0.65, 0.5];
    for (var i = 0; i < heights.length; i++) {
      path.lineTo(
        size.width * i / (heights.length - 1),
        size.height * (1 - heights[i]),
      );
    }
    path
      ..lineTo(size.width, size.height)
      ..close();

    // 왼쪽 절반은 진하게, 오른쪽 절반은 연하게.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width / 2, size.height));
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.restore();
    canvas.save();
    canvas.clipRect(
        Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height));
    canvas.drawPath(
        path, Paint()..color = Colors.white.withValues(alpha: 0.5));
    canvas.restore();

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_HalfCutPreviewPainter oldDelegate) => false;
}

class CircleDrawPreview extends StatelessWidget {
  const CircleDrawPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(58, 58),
      painter: _CircleDrawPreviewPainter(),
    );
  }
}

class _CircleDrawPreviewPainter extends CustomPainter {
  const _CircleDrawPreviewPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // 손으로 그린 듯 살짝 일그러진, 덜 닫힌 원.
    final center = Offset(size.width / 2, size.height / 2);
    final baseR = size.width * 0.42;
    final path = Path();
    const start = -pi / 2 + 0.35;
    const sweep = 2 * pi - 0.7;
    for (var i = 0; i <= 40; i++) {
      final t = i / 40;
      final angle = start + sweep * t;
      final r = baseR * (1 + 0.07 * sin(angle * 3 + 1));
      final p = center + Offset(cos(angle) * r, sin(angle) * r);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );
    // 펜 끝 위치 점.
    final endAngle = start + sweep;
    canvas.drawCircle(
      center +
          Offset(cos(endAngle), sin(endAngle)) *
              (baseR * (1 + 0.07 * sin(endAngle * 3 + 1))),
      4,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_CircleDrawPreviewPainter oldDelegate) => false;
}

class ShuffleTrackPreview extends StatelessWidget {
  const ShuffleTrackPreview({super.key, required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    Widget tile({bool starred = false}) => Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: starred
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(7),
          ),
          child: starred
              ? Icon(Icons.star_rounded, size: 16, color: accent)
              : null,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            tile(),
            const SizedBox(width: 6),
            tile(starred: true),
            const SizedBox(width: 6),
            tile(),
          ],
        ),
        const SizedBox(height: 4),
        const Icon(Icons.swap_horiz_rounded, size: 18, color: Colors.white),
      ],
    );
  }
}

class FlashCountPreview extends StatelessWidget {
  const FlashCountPreview({super.key});

  Widget _dot(double left, double top) => Positioned(
        left: left,
        top: top,
        child: Container(
          width: 11,
          height: 11,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 54,
      child: Stack(
        children: [
          _dot(4, 8),
          _dot(28, 2),
          _dot(50, 12),
          _dot(12, 30),
          _dot(36, 26),
          const Positioned(
            right: 0,
            bottom: 0,
            child: Text(
              '?',
              style: TextStyle(
                fontFamily: 'BlackHanSans',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FakeSignalPreview extends StatelessWidget {
  const FakeSignalPreview({super.key});

  @override
  Widget build(BuildContext context) {
    Widget signal(Color color, {Widget? child}) => Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: child,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        signal(AppColors.success),
        const SizedBox(width: 10),
        signal(
          AppColors.danger,
          child:
              const Icon(Icons.close_rounded, size: 18, color: Colors.white),
        ),
      ],
    );
  }
}

/// 3×3 미니 그리드 공통 레이아웃.
Widget _miniGrid({required Widget Function(int index) cellBuilder}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var row = 0; row < 3; row++)
        Padding(
          padding: EdgeInsets.only(top: row == 0 ? 0 : 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var col = 0; col < 3; col++)
                Padding(
                  padding: EdgeInsets.only(left: col == 0 ? 0 : 3),
                  child: cellBuilder(row * 3 + col),
                ),
            ],
          ),
        ),
    ],
  );
}
