import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:flutter_app/Login.dart';
import 'package:flutter_app/View.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  runApp(
    MaterialApp(
        title: 'App',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.grey[100],
        ),
        initialRoute: await Utils.checkToken() ? 'view' : 'login',
        routes: {
          'login': (context) => Login(),
          'view': (context) => View(),
        },
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('pt'),
        ]),
  );
}
