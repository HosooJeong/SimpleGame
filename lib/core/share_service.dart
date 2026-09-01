import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../app/strings.dart';

class ShareService {
  const ShareService();

  // TODO(release): 출시 전 확정된 applicationId로 교체할 것 (현재 임시값).
  // applicationId는 첫 Play 업로드 후 변경 불가 — android/app/build.gradle.kts와 함께 확정.
  static const _appId = 'kr.hosoo.simple_game';
  static const playUrl = 'https://play.google.com/store/apps/details?id=$_appId';

  /// [body]는 게임별 자랑 문구(GameDefinition.shareBody) — 설치 링크를 붙여 공유.
  /// 반환값이 false면 공유 시트를 못 열어 클립보드 복사로 대체된 것.
  Future<bool> shareScore(String body) => _share(body);

  Future<bool> shareApp() => _share(Strings.shareAppBody);

  Future<bool> _share(String body) async {
    final text = '$body\n\n${Strings.appName} – ${Strings.appTagline}\n$playUrl';
    try {
      await SharePlus.instance.share(ShareParams(text: text));
      return true;
    } catch (_) {
      // 웹의 일부 브라우저(HTTP, Firefox 데스크톱 등)는 공유 API가 없다.
      await Clipboard.setData(ClipboardData(text: text));
      return false;
    }
  }
}
