import 'package:shared_preferences/shared_preferences.dart';

class SharePrefManager {
  static const mode1 = "bluetooth";
  static const mode2 = "touch";
  static const mode3 = "ss";

  static const led1on = "led1 on";
  static const led1off = "led1 off";

  static const led2on = "led2 on";
  static const led2off = "led2 off";

  static const led3on = "led3 on";
  static const led3off = "led3 off";

  static const led4on = "led4 on";
  static const led4off = "led4 off";

  static const fanOn = "fan on";
  static const fanOff = "fan off";

  static const wdoOn = "wdo on";
  static const wdoOff = "wdo off";

  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
