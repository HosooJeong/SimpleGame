import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// 화면 코드에서 `context.l.share` 처럼 짧게 쓰기 위한 접근자.
extension L10nContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this);
}
