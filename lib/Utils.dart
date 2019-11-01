import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static const String mainurl = 'http://191.239.240.29';

  static String jwt;

  static void setJwt(jwt) {
    Utils.jwt = jwt;
    Utils.setPreference('token', jwt);
  }

  static void removeJwt() {
    Utils.jwt = null;
    Utils.removePreference('token');
  }

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

  static DateTime parseDate(String value) {
    if (value.contains(':')) {
      final splitted = value.split(' ');
      final date = splitted[0].split('/');
      final time = splitted[1].split(':');
      return DateTime.utc(int.parse(date[2]), int.parse(date[1]),
          int.parse(date[0]), int.parse(time[0]), int.parse(time[1]));
    } else {
      final splitted = value.split('/');
      return DateTime.utc(int.parse(splitted[2]), int.parse(splitted[1]),
          int.parse(splitted[0]));
    }
  }

  static Future selectDate(BuildContext context, String value) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: value == null || value.isEmpty
            ? DateTime.now()
            : Utils.parseDate(value),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    return picked == null ? null : DateFormat('dd/MM/yyyy').format(picked);
  }

  static Future selectTime(BuildContext context, String value) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: value == null || value.isEmpty
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(Utils.parseDate(value)),
    );
    return picked == null
        ? null
        : '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }

  static Future<Map> requestGet(String url) async {
    final response =
        await http.get('$mainurl/$url', headers: {'x-access-token': Utils.jwt});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false};
    }
  }

  static Future<Map> requestPost(String url, Map body) async {
    final response = await http.post('$mainurl/$url',
        headers: {'x-access-token': Utils.jwt}, body: body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false};
    }
  }

  static Future<bool> checkToken() async {
    if (Utils.jwt == null) return false;
    final response =
        await http.get('$mainurl/home', headers: {'x-access-token': Utils.jwt});
    return response.statusCode == 200;
  }

  static Widget recursiveMenu(context, item, viewSelect) {
    if (item['children'] != null && item['children'].length > 0) {
      List<Widget> childrens = [];
      for (int i = 0; i < item['children'].length; i++) {
        childrens.add(recursiveMenu(context, item['children'][i], viewSelect));
      }
      return ExpansionTile(
        title: Text(item['description']),
        children: childrens,
      );
    } else {
      return ListTile(
        title: Text(item['description']),
        onTap: () async {
          Navigator.of(context).pop();
          viewSelect(item);
        },
      );
    }
  }

  static Future loadMenu() async {
    final j = await Utils.requestGet('config/menu');
    if (j['success']) {
      return j['menu'];
    } else {
      return [];
    }
  }

  static Future loadProfile() async {
    final j = await Utils.requestGet('config/profile');
    if (j['success']) {
      return j['profile'];
    } else {
      return [];
    }
  }

  static String adjustData(value) {
    if (value is bool) {
      return value ? 'Sim' : 'Não';
    } else if (value == null) {
      return '';
    } else {
      return value.toString();
    }
  }

  static void hideSnackBar(BuildContext context) {
    Scaffold.of(context).removeCurrentSnackBar();
  }

  static void showSnackBar(BuildContext context, String text, Color color) {
    Utils.hideSnackBar(context);
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
      ),
    );
  }

  static void hideSnackBarByKey(GlobalKey<ScaffoldState> key) {
    key.currentState.removeCurrentSnackBar();
  }

  static void showSnackBarByKey(
      GlobalKey<ScaffoldState> key, String text, Color color) {
    Utils.hideSnackBarByKey(key);
    key.currentState.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
      ),
    );
  }
}
