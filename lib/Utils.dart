import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  static Future<Null> selectDate(BuildContext context, fn) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    fn(picked == null ? null : DateFormat('dd/MM/yyyy').format(picked));
  }
}
