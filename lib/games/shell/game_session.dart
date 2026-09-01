import '../../core/feedback_service.dart';

/// 셸이 플레이 위젯에 넘겨주는 세션 컨트롤러.
class GameSession {
  GameSession({
    required this.fx,
    required void Function(num score) onFinish,
    required void Function(String? message) onAbort,
  })  : _onFinish = onFinish,
        _onAbort = onAbort;

  final FeedbackService fx;
  final void Function(num score) _onFinish;
  final void Function(String? message) _onAbort;
  bool _done = false;

  /// 게임 종료 — 결과 화면으로 전환되고 기록이 저장된다.
  void finish(num score) {
    if (_done) return;
    _done = true;
    _onFinish(score);
  }

  /// 기록 저장 없이 결과 화면으로 (예: 중도 포기).
  void abort({String? message}) {
    if (_done) return;
    _done = true;
    _onAbort(message);
  }
}
