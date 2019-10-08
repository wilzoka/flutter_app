import 'package:flutter/material.dart';
import 'package:flutter_app/Home.dart';
import 'package:flutter_app/Login.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Named Routes Demo',
    initialRoute: 'login',
    onGenerateRoute: (settings) {
      switch (settings.name) {
        case 'login':
          return MaterialPageRoute(builder: (_) => LoginScreen());
        case 'home':
          return MaterialPageRoute(builder: (_) => Home());
        default:
          return MaterialPageRoute(
              builder: (_) => Scaffold(
                    body: Center(
                        child: Text('No route defined for ${settings.name}')),
                  ));
      }
    },
  ));
}
