import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';

class ShareService {
  const ShareService();

  /// 받는 사람이 설치 없이 바로 플레이할 수 있도록 웹 빌드를 가리킨다.
  /// Play 출시 후에도 이 URL은 유지하고, 설치 유도는 웹 페이지에서 한다.
  static const shareUrl = 'https://hosoojeong.github.io/SimpleGame/';

  /// 자랑한 게임으로 바로 들어가는 링크. 홈이 아니라 그 게임 화면이 열린다.
  static String gameUrl(String gameId) => '$shareUrl?game=$gameId';

  /// [body]는 게임별 자랑 문구(GameDefinition.shareBody) — 플레이 링크를 붙여 공유.
  /// 반환값이 false면 공유 시트를 못 열어 클립보드 복사로 대체된 것.
  Future<bool> shareScore(AppLocalizations l, String body,
          {required String gameId}) =>
      _share(l, body, url: gameUrl(gameId));

  Future<bool> shareApp(AppLocalizations l) =>
      _share(l, l.shareAppBody, url: shareUrl);

  Future<bool> _share(AppLocalizations l, String body,
      {required String url}) async {
    final text = '$body\n\n${l.appName} – ${l.appTagline}\n$url';
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
