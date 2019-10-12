import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:flutter_app/Login.dart';
import 'package:flutter_app/View.dart';
import 'package:flutter_app/ViewRegister.dart';

void main() async {
  Utils.setPreference('mainurl', 'http://192.168.0.103:8080/');
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Named Routes Demo',
      initialRoute: await Utils.checkToken() ? 'view' : 'login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'login':
            return MaterialPageRoute(builder: (_) => Login());
          case 'view':
            return MaterialPageRoute(
              builder: (_) => View(),
            );
          case 'viewregister':
            Map args = settings.arguments;
            return MaterialPageRoute(
              builder: (_) => ViewRegister(
                id: args['id'],
                viewurl: args['viewurl'],
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ),
            );
        }
      },
    ),
  );
}
