import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static String mainurl = 'http://172.10.30.33:8080';

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

  static Future selectDate(BuildContext context, fn) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    fn(picked == null ? null : DateFormat('dd/MM/yyyy').format(picked));
  }

  static Future<Map> requestGet(String url) async {
    final response = await http.get('$mainurl/$url',
        headers: {'x-access-token': await Utils.getPreference('token')});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false};
    }
  }

  static Future<Map> requestPost(String url, Map body) async {
    final response = await http.post('$mainurl/$url',
        headers: {'x-access-token': await Utils.getPreference('token')},
        body: body);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'success': false};
    }
  }

  static Future<bool> checkToken() async {
    final response = await http.get('$mainurl/home',
        headers: {'x-access-token': await Utils.getPreference('token')});
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
    var j = await Utils.requestGet('config/menu');
    if (j['success']) {
      return j['menu'];
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
}
