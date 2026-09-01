import 'package:flutter/material.dart';

import 'theme.dart';

/// 모바일 게임 클리셰 버튼 — 밑면 엣지가 있고 누르면 쑥 들어가는 3D 버튼.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.success,
    this.height = 56,
    this.icon,
    this.fontSize = 19,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final double height;
  final IconData? icon;
  final double fontSize;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  static const _edge = 5.0;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: _edge),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          height: widget.height,
          transform: Matrix4.translationValues(0, _pressed ? _edge : 0, 0),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: darken(widget.color),
                offset: Offset(0, _pressed ? 0 : _edge),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'Jua',
                    fontSize: widget.fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 정사각 아이콘 버튼 버전 (헤더의 통계·설정 버튼용).
class ChunkyIconButton extends StatefulWidget {
  const ChunkyIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color = AppColors.surface,
    this.iconColor = AppColors.textPrimary,
    this.size = 46,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color iconColor;
  final double size;

  @override
  State<ChunkyIconButton> createState() => _ChunkyIconButtonState();
}

class _ChunkyIconButtonState extends State<ChunkyIconButton> {
  static const _edge = 4.0;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onPressed();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: _edge),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          width: widget.size,
          height: widget.size,
          transform: Matrix4.translationValues(0, _pressed ? _edge : 0, 0),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.color == AppColors.surface
                    ? AppColors.surfaceEdge
                    : darken(widget.color),
                offset: Offset(0, _pressed ? 0 : _edge),
              ),
            ],
          ),
          child: Icon(widget.icon, color: widget.iconColor, size: 22),
        ),
      ),
    );
  }
}
