import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

class ChimpPlay extends StatefulWidget {
  const ChimpPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<ChimpPlay> createState() => _ChimpPlayState();
}

class _ChimpPlayState extends State<ChimpPlay> {
  static const cols = 4;
  static const rows = 6;
  static const startCount = 4;
  static const maxCount = 20;
  static const accent = GameColors.teal;

  final _random = Random();
  Timer? _timer;

  int _count = startCount;
  /// 숫자 n(1부터)이 놓인 셀 인덱스: _cellOf[n - 1]
  List<int> _cellOf = [];
  int _next = 1;
  bool _revealed = true;
  bool _transition = false;
  bool _failed = false;
  int? _wrongNumber; // 실패 시 잘못 누른 숫자

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRound() {
    if (!mounted) return;
    final cells = List.generate(cols * rows, (i) => i)..shuffle(_random);
    setState(() {
      _cellOf = cells.take(_count).toList();
      _next = 1;
      _revealed = true;
      _transition = false;
    });
  }

  void _onNumberTap(int n) {
    if (_transition || _failed) return;
    if (n == _next) {
      widget.session.fx.tapLight();
      setState(() {
        if (_next == 1) _revealed = false; // 첫 터치 순간 나머지 가림
        _next++;
      });
      if (_next > _count) {
        widget.session.fx.success();
        if (_count >= maxCount) {
          widget.session.finish(_count);
          return;
        }
        setState(() {
          _count++;
          _transition = true;
        });
        _timer = Timer(const Duration(milliseconds: 700), _startRound);
      }
    } else {
      // 실패: 남은 숫자를 전부 공개해서 정답 순서를 보여준다.
      widget.session.fx.fail();
      setState(() {
        _failed = true;
        _wrongNumber = n;
        _revealed = true;
      });
      _timer = Timer(const Duration(milliseconds: 1600),
          () => widget.session.finish(_count - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 셀 인덱스 → 숫자(1..count), 없으면 null
    final numberAt = <int, int>{
      for (var n = 1; n <= _cellOf.length; n++) _cellOf[n - 1]: n,
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text('$_count개', style: textTheme.displaySmall),
          SizedBox(
            height: 24,
            child: Text(
              _failed
                  ? '틀렸어요! 다음은 $_next이었어요'
                  : _revealed
                      ? '위치를 기억하세요'
                      : '순서대로 터치!',
              style: textTheme.bodyMedium!.copyWith(
                  color:
                      _failed ? AppColors.danger : AppColors.textDim),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: cols / rows,
                child: GridView.count(
                  crossAxisCount: cols,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var cell = 0; cell < cols * rows; cell++)
                      _buildCell(numberAt[cell]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(int? n) {
    if (n == null || n < _next) {
      // 빈 칸이거나 이미 누른 숫자는 사라짐.
      return const SizedBox.shrink();
    }
    final showNumber = _revealed;
    // 실패 시: 눌렀어야 할 숫자는 초록, 잘못 누른 숫자는 빨강으로 표시.
    final isCorrectNext = _failed && n == _next;
    final isWrongTapped = _failed && n == _wrongNumber;
    final bg = isCorrectNext
        ? AppColors.success
        : isWrongTapped
            ? AppColors.danger
            : showNumber
                ? Colors.white
                : accent;
    final numberColor =
        isCorrectNext || isWrongTapped ? Colors.white : accent;

    return GestureDetector(
      onTapDown: (_) => _onNumberTap(n),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: bg == Colors.white
                  ? AppColors.surfaceEdge
                  : darken(bg),
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: showNumber
            ? Center(
                child: Text(
                  '$n',
                  style: TextStyle(
                    fontFamily: 'Jua',
                    fontSize: 22,
                    color: numberColor,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
