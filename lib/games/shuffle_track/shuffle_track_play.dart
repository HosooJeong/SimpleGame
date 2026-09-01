import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/l10n_context.dart';

import '../../app/theme.dart';
import '../shell/game_session.dart';

enum _Phase { showStar, shuffling, answer, reveal }

class ShuffleTrackPlay extends StatefulWidget {
  const ShuffleTrackPlay({super.key, required this.session});

  final GameSession session;

  @override
  State<ShuffleTrackPlay> createState() => _ShuffleTrackPlayState();
}

class _ShuffleTrackPlayState extends State<ShuffleTrackPlay>
    with SingleTickerProviderStateMixin {
  static const accent = GameColors.magenta;
  static const maxLevel = 30;

  final _random = Random();
  late final AnimationController _controller;
  Timer? _timer;

  int _level = 1;
  _Phase _phase = _Phase.showStar;
  bool _failed = false;

  /// tileSlot[타일 id] = 현재 슬롯 위치
  late List<int> _tileSlot;
  int _starTile = 0;
  int _swapsLeft = 0;
  int _swapTileA = 0, _swapTileB = 0;
  int? _tappedTile; // 실패 시 잘못 고른 타일

  int get _tileCount => min(3 + (_level - 1) ~/ 3, 5);
  int get _swapCount => 3 + _level;
  int get _swapMs => max(220, 480 - _level * 26);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _onSwapDone();
      });
    _startLevel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startLevel() {
    if (!mounted) return;
    setState(() {
      _tileSlot = List.generate(_tileCount, (i) => i);
      _starTile = _random.nextInt(_tileCount);
      _swapsLeft = _swapCount;
      _phase = _Phase.showStar;
      _tappedTile = null;
    });
    _timer = Timer(const Duration(milliseconds: 900), _startShuffle);
  }

  void _startShuffle() {
    if (!mounted) return;
    setState(() => _phase = _Phase.shuffling);
    _nextSwap();
  }

  void _nextSwap() {
    // 직전과 같은 쌍은 피해서 왕복 눈속임이 너무 쉬워지지 않게 한다.
    int a, b;
    do {
      a = _random.nextInt(_tileCount);
      b = _random.nextInt(_tileCount);
    } while (a == b ||
        (a == _swapTileA && b == _swapTileB) ||
        (a == _swapTileB && b == _swapTileA));
    _swapTileA = a;
    _swapTileB = b;
    _controller.duration = Duration(milliseconds: _swapMs);
    _controller.forward(from: 0);
  }

  void _onSwapDone() {
    if (!mounted) return;
    setState(() {
      final t = _tileSlot[_swapTileA];
      _tileSlot[_swapTileA] = _tileSlot[_swapTileB];
      _tileSlot[_swapTileB] = t;
      _swapsLeft--;
    });
    if (_swapsLeft > 0) {
      _nextSwap();
    } else {
      setState(() => _phase = _Phase.answer);
    }
  }

  void _onTileTap(int tile) {
    if (_phase != _Phase.answer) return;
    if (tile == _starTile) {
      widget.session.fx.success();
      setState(() => _phase = _Phase.reveal);
      if (_level >= maxLevel) {
        _timer = Timer(const Duration(milliseconds: 600),
            () => widget.session.finish(maxLevel));
        return;
      }
      _timer = Timer(const Duration(milliseconds: 600), () {
        _level++;
        _startLevel();
      });
    } else {
      widget.session.fx.fail();
      setState(() {
        _phase = _Phase.reveal;
        _failed = true;
        _tappedTile = tile;
      });
      _timer = Timer(const Duration(milliseconds: 1400),
          () => widget.session.finish(_level - 1));
    }
  }

  String get _hint => switch (_phase) {
        _Phase.showStar => context.l.shuffleTrackMemorize,
        _Phase.shuffling => context.l.shuffleTrackFollow,
        _Phase.answer => context.l.shuffleTrackWhere,
        _Phase.reveal => _failed
            ? context.l.shuffleTrackWrong
            : context.l.shuffleTrackCorrect,
      };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Text(context.l.countLevel('$_level'), style: textTheme.displaySmall),
          SizedBox(
            height: 24,
            child: Text(
              _hint,
              style: textTheme.bodyMedium!.copyWith(
                color: _failed ? AppColors.danger : AppColors.textDim,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final tileSize = min(width / _tileCount - 10, 76.0);
                  return SizedBox(
                    height: tileSize * 3,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) => Stack(
                        children: [
                          for (var tile = 0; tile < _tileCount; tile++)
                            _buildTile(tile, width, tileSize),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(int tile, double width, double tileSize) {
    Offset slotCenter(int slot) => Offset(
          width * (slot + 0.5) / _tileCount,
          tileSize * 1.5,
        );

    Offset center;

    if (_phase == _Phase.shuffling &&
        (tile == _swapTileA || tile == _swapTileB)) {
      // 교차 시 구분되도록 한쪽은 위, 한쪽은 아래 아크로 이동.
      final t = Curves.easeInOut.transform(_controller.value);
      final from = slotCenter(_tileSlot[tile]);
      final to = slotCenter(
          _tileSlot[tile == _swapTileA ? _swapTileB : _swapTileA]);
      final arc = (tile == _swapTileA ? -1 : 1) * tileSize * 0.85;
      center = Offset.lerp(from, to, t)! + Offset(0, sin(pi * t) * arc);
    } else {
      center = slotCenter(_tileSlot[tile]);
    }

    final showStar = tile == _starTile &&
        (_phase == _Phase.showStar || _phase == _Phase.reveal);
    final isWrongTapped = _phase == _Phase.reveal && tile == _tappedTile;
    final bg = isWrongTapped
        ? AppColors.danger
        : showStar && _phase == _Phase.reveal
            ? AppColors.success
            : accent;

    return Positioned(
      left: center.dx - tileSize / 2,
      top: center.dy - tileSize / 2,
      child: GestureDetector(
        onTapDown: (_) => _onTileTap(tile),
        child: Container(
          width: tileSize,
          height: tileSize,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: darken(bg), offset: const Offset(0, 4)),
            ],
          ),
          child: showStar
              ? Icon(Icons.star_rounded,
                  size: tileSize * 0.55, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
