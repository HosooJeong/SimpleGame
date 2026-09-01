import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    soundOn = _prefs.getBool(_kSound) ?? true;
    hapticsOn = _prefs.getBool(_kHaptics) ?? true;
    localeCode = _prefs.getString(_kLocale);
  }

  static const _kSound = 'set.sound';
  static const _kHaptics = 'set.haptics';
  static const _kLocale = 'set.locale';

  final SharedPreferences _prefs;

  late bool soundOn;
  late bool hapticsOn;

  /// 'ko' | 'en' | null(기기 언어를 따름).
  late String? localeCode;

  void setSound(bool value) {
    soundOn = value;
    _prefs.setBool(_kSound, value);
    notifyListeners();
  }

  void setHaptics(bool value) {
    hapticsOn = value;
    _prefs.setBool(_kHaptics, value);
    notifyListeners();
  }

  void setLocaleCode(String? code) {
    localeCode = code;
    if (code == null) {
      _prefs.remove(_kLocale);
    } else {
      _prefs.setString(_kLocale, code);
    }
    notifyListeners();
  }
}
