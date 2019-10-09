import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:flutter_app/Login.dart';
import 'package:flutter_app/View.dart';
import 'package:flutter_app/ViewRegister.dart';

void main() {
  final logged = Utils.getPreference('token');
  Utils.setPreference('mainurl', 'https://siprs.plastrela.com.br/');
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Named Routes Demo',
      initialRoute: logged.toString().isEmpty ? 'login' : 'view',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case 'login':
            return MaterialPageRoute(builder: (_) => Login());
          case 'view':
            return MaterialPageRoute(builder: (_) => View());
          case 'viewregister':
            Map args = settings.arguments;
            return MaterialPageRoute(
                builder: (_) => ViewRegister(
                      id: args['id'],
                      viewurl: args['view'],
                    ));
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
