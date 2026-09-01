import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._prefs) {
    soundOn = _prefs.getBool(_kSound) ?? true;
    hapticsOn = _prefs.getBool(_kHaptics) ?? true;
  }

  static const _kSound = 'set.sound';
  static const _kHaptics = 'set.haptics';

  final SharedPreferences _prefs;

  late bool soundOn;
  late bool hapticsOn;

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
}
