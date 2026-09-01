/// 앱 공통 한국어 UI 텍스트.
/// 게임별 텍스트(제목·설명·공유 문구)는 각 게임의 GameDefinition에 있다.
abstract final class Strings {
  // TODO(release): 출시 전 앱 이름 확정 후 교체 (AndroidManifest의 label도 함께).
  static const appName = '스낵게임';
  static const appTagline = '초간단 두뇌 미니게임 모음';

  static const homeTagline = '네 한계를 증명해봐';

  static const start = '도전 시작';
  static const retry = '한 번 더';
  static const share = '자랑하기';
  static const home = '홈으로';
  static const newRecord = '신기록!';
  static const bestPrefix = 'BEST';
  static const noRecord = '아직 아무도 도전하지 않았다';

  static const stats = '기록';
  static const settings = '설정';
  static const sound = '효과음';
  static const haptics = '진동';
  static const resetRecords = '기록 전체 초기화';
  static const resetConfirmTitle = '기록을 모두 지울까요?';
  static const resetConfirmBody = '모든 게임의 최고 기록과 통계가 삭제됩니다. 되돌릴 수 없어요.';
  static const cancel = '취소';
  static const delete = '삭제';
  static const resetDone = '기록이 초기화됐어요';
  static const copiedFallback = '이 환경에선 공유 대신 내용을 복사했어요';
  static const shareApp = '친구에게 앱 공유하기';
  static const shareAppBody = '심심할 때 딱 좋은 두뇌 미니게임 모음.\n반응속도부터 기억력까지 테스트해봐.';
  static const noStatsYet = '아직 기록이 없어요';
  static const playsSuffix = '회 플레이';
}
