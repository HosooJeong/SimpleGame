import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import 'settings_controller.dart';

enum Sfx { tap, success, fail, tick, go }

/// 사운드 + 햅틱 단일 창구. 설정 토글은 내부에서 확인하므로
/// 게임 코드는 `session.fx.success()` 처럼 한 줄만 호출한다.
class FeedbackService {
  FeedbackService(this._settings);

  final SettingsController _settings;
  final Map<Sfx, AudioPlayer> _players = {};
  bool _soundReady = false;

  Future<void> init() async {
    try {
      for (final sfx in Sfx.values) {
        final player = AudioPlayer();
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setSource(AssetSource('sfx/${sfx.name}.wav'));
        _players[sfx] = player;
      }
      _soundReady = true;
    } catch (_) {
      // 에셋이 없거나 오디오 초기화에 실패하면 무음으로 동작.
      _soundReady = false;
    }
  }

  void _play(Sfx sfx) {
    if (!_soundReady || !_settings.soundOn) return;
    final player = _players[sfx];
    if (player == null) return;
    unawaited(
      player.stop().then((_) => player.resume()).catchError((_) {}),
    );
  }

  void _haptic(Future<void> Function() impact) {
    if (_settings.hapticsOn) unawaited(impact());
  }

  /// 일반 터치 확인 (햅틱 + 짧은 효과음).
  void tap() {
    _haptic(HapticFeedback.selectionClick);
    _play(Sfx.tap);
  }

  /// 연타·연속 입력용 — 햅틱만, 사운드 없음.
  void tapLight() => _haptic(HapticFeedback.selectionClick);

  void success() {
    _haptic(HapticFeedback.mediumImpact);
    _play(Sfx.success);
  }

  void fail() {
    _haptic(HapticFeedback.heavyImpact);
    _play(Sfx.fail);
  }

  /// 카운트다운 숫자용.
  void tick() {
    _haptic(HapticFeedback.selectionClick);
    _play(Sfx.tick);
  }

  /// 카운트다운 종료(시작!) 용.
  void go() {
    _haptic(HapticFeedback.lightImpact);
    _play(Sfx.go);
  }
}
