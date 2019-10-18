import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:flutter_app/Login.dart';
import 'package:flutter_app/View.dart';

void main() async {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App',
      initialRoute: await Utils.checkToken() ? 'view' : 'login',
      routes: {
        'login': (context) => Login(),
        'view': (context) => View(),
      },
    ),
  );
}
