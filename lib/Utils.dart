import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static nonEmptyValidator(String value) {
    return value.isEmpty ? 'Campo Obrigatório' : null;
  }

  static Future<String> getPreference(String key) async {
    return (await SharedPreferences.getInstance()).getString(key);
  }

  static void setPreference(String key, String value) async {
    (await SharedPreferences.getInstance()).setString(key, value);
  }

  static void removePreference(String key) async {
    (await SharedPreferences.getInstance()).remove(key);
  }
}
