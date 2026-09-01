import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/chunky_button.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../models/game_record.dart';
import 'countdown_view.dart';
import 'game_definition.dart';
import 'game_session.dart';
import 'result_view.dart';

enum _Phase { intro, countdown, playing, result }

/// 모든 게임이 공유하는 흐름:
/// intro → countdown → playing → result(기록 저장) → 공유/재도전.
class GameShellScreen extends StatefulWidget {
  const GameShellScreen({super.key, required this.definition});

  final GameDefinition definition;

  @override
  State<GameShellScreen> createState() => _GameShellScreenState();
}

class _GameShellScreenState extends State<GameShellScreen> {
  _Phase _phase = _Phase.intro;
  GameRecord _record = const GameRecord();
  num? _score;
  bool _isNewBest = false;
  String? _abortMessage;
  GameSession? _session;
  int _playKey = 0;
  bool _loaded = false;

  GameDefinition get _def => widget.definition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _record = AppScope.of(context).records.load(_def.id);
      _loaded = true;
    }
  }

  void _startCountdown() {
    setState(() {
      _score = null;
      _abortMessage = null;
      _isNewBest = false;
      _phase = _Phase.countdown;
    });
  }

  void _startPlaying() {
    final scope = AppScope.of(context);
    _session = GameSession(
      fx: scope.fx,
      onFinish: _handleFinish,
      onAbort: _handleAbort,
    );
    setState(() {
      _playKey++;
      _phase = _Phase.playing;
    });
  }

  /// 플레이 중단 — 기록 없이 인트로로 복귀 (플레이 위젯은 dispose되며 타이머 정리).
  void _quitToIntro() {
    setState(() {
      _session = null;
      _score = null;
      _abortMessage = null;
      _phase = _Phase.intro;
    });
  }

  Future<void> _handleFinish(num score) async {
    final scope = AppScope.of(context);
    final outcome = await scope.records.addResult(_def.id, score, _def.order);
    if (!mounted) return;
    if (outcome.isNewBest) scope.fx.success();
    setState(() {
      _score = score;
      _isNewBest = outcome.isNewBest;
      _record = outcome.record;
      _phase = _Phase.result;
    });
  }

  void _handleAbort(String? message) {
    if (!mounted) return;
    setState(() {
      _score = null;
      _abortMessage = message;
      _phase = _Phase.result;
    });
  }

  Future<void> _share() async {
    if (_score == null) return;
    final shared =
        await AppScope.of(context).share.shareScore(_def.shareBody(_score!));
    if (!shared && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(Strings.copiedFallback)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (_phase) {
          _Phase.intro => _IntroView(
              definition: _def,
              best: _record.best,
              onStart: _startCountdown,
              onClose: () => Navigator.pop(context),
            ),
          _Phase.countdown => CountdownView(
              fx: AppScope.of(context).fx,
              accent: _def.accent,
              onDone: _startPlaying,
            ),
          _Phase.playing => Stack(
              children: [
                KeyedSubtree(
                  key: ValueKey(_playKey),
                  child: _def.buildPlay(_session!),
                ),
                // 중단 버튼 — 뒤로가기(<), 앱 공통 흰 원형 스타일.
                Positioned(
                  top: 8,
                  left: 12,
                  child: _BackCircleButton(onTap: _quitToIntro),
                ),
              ],
            ),
          _Phase.result => ResultView(
              definition: _def,
              score: _score,
              isNewBest: _isNewBest,
              best: _record.best,
              abortMessage: _abortMessage,
              onShare: _share,
              onRetry: _startCountdown,
              onHome: () => Navigator.pop(context),
            ),
        },
      ),
    );
  }
}

/// 뒤로가기(<) 원형 버튼 — 흰 원 + 소프트 섀도, 인트로·플레이 화면 공용.
class _BackCircleButton extends StatelessWidget {
  const _BackCircleButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: kCardShadow,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _IntroView extends StatelessWidget {
  const _IntroView({
    required this.definition,
    required this.best,
    required this.onStart,
    required this.onClose,
  });

  final GameDefinition definition;
  final num? best;
  final VoidCallback onStart;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _BackCircleButton(onTap: onClose),
          ),
          const Spacer(),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: definition.accent,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: darken(definition.accent, 0.3),
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(definition.icon, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            definition.title,
            style: textTheme.displaySmall!.copyWith(fontSize: 32),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: cardDecoration(radius: 16),
            child: Text(
              definition.howTo,
              style: textTheme.bodyMedium!.copyWith(height: 1.7),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: best == null
                ? Text(Strings.noRecord,
                    style: const TextStyle(
                        fontFamily: 'Jua',
                        fontSize: 14,
                        color: AppColors.textDim))
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: cardDecoration(radius: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.emoji_events_rounded,
                            size: 16, color: definition.accent),
                        const SizedBox(width: 6),
                        Text(
                          '${Strings.bestPrefix} ${definition.formatScore(best!)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: definition.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const Spacer(),
          ChunkyButton(
            label: Strings.start,
            color: AppColors.success,
            height: 58,
            onPressed: onStart,
          ),
        ],
      ),
    );
  }
}
