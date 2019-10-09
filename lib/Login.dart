import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Utils.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginScreenForm(),
    );
  }
}

class LoginScreenForm extends StatefulWidget {
  @override
  LoginScreenFormState createState() => LoginScreenFormState();
}

// Create a corresponding State class.
// This class holds data related to the form.
class LoginScreenFormState extends State<LoginScreenForm> {
  final _formKey = GlobalKey<FormState>();
  bool _perfomingLogin = false;

  var controllers = {
    'username': TextEditingController(),
    'password': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    controllers['username'].text = 'williamb';
    controllers['password'].text = 'wb1015\$\$';
  }

  @override
  void dispose() {
    controllers['username'].dispose();
    controllers['password'].dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 40, right: 40, top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Image.network(
              'https://siprs.plastrela.com.br/file/11625',
            ),
            TextFormField(
              controller: controllers['username'],
              decoration: InputDecoration(labelText: 'Usuário'),
              validator: (value) => Utils.nonEmptyValidator(value),
            ),
            TextFormField(
              controller: controllers['password'],
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
              validator: (value) => Utils.nonEmptyValidator(value),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: RaisedButton(
                  color: Colors.lightBlue,
                  onPressed: _perfomingLogin
                      ? null
                      : () async {
                          if (!_formKey.currentState.validate()) return;
                          setState(() {
                            _perfomingLogin = true;
                          });
                          final response = await http
                              .post('http://192.168.0.103:8080/login', body: {
                            '_mobile': 'true',
                            'username': controllers['username'].text,
                            'password': controllers['password'].text
                          });
                          try {
                            if (response.statusCode == 200) {
                              final json = jsonDecode(response.body);
                              final prefs =
                                  await SharedPreferences.getInstance();
                              prefs.setString('menu', jsonEncode(json['menu']));
                              prefs.setString('token', json['token']);
                              Navigator.pushReplacementNamed(context, 'home');
                            } else {
                              Scaffold.of(context).removeCurrentSnackBar();
                              Scaffold.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Acesso não autorizado'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          } catch (e) {
                            print(e.toString());
                          } finally {
                            setState(() {
                              _perfomingLogin = false;
                            });
                          }
                        },
                  child: _perfomingLogin
                      ? SizedBox(
                          height: 25.0,
                          width: 25.0,
                          child: CircularProgressIndicator(),
                        )
                      : Text('Enviar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
