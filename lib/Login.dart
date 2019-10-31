import 'package:flutter/material.dart';
import 'Utils.dart';

class Login extends StatefulWidget {
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _perfomingLogin = false;

  Map controllers = {
    'username': TextEditingController(),
    'password': TextEditingController(),
  };

  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 15, vertical: 12);

  Future<void> login() async {
    if (!_formKey.currentState.validate()) return;
    setState(() {
      _perfomingLogin = true;
    });
    final j = await Utils.requestPost('login', {
      '_mobile': 'true',
      'username': controllers['username'].text,
      'password': controllers['password'].text
    });
    if (j['success']) {
      Utils.jwt = j['token'];
      Utils.setPreference('jwt', j['token']);
      Navigator.pushReplacementNamed(
        context,
        'view',
        arguments: {'menu': j['menu']},
      );
    } else {
      _scaffoldKey.currentState.removeCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text('Acesso não autorizado'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _perfomingLogin = false;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controllers.forEach((key, value) => {controllers[key].dispose()});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 50.0),
                  SizedBox(
                    height: 150.0,
                    child: Image.network(
                      Utils.mainurl + '/config/loginimage',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 25.0),
                  TextFormField(
                    controller: controllers['username'],
                    style: style,
                    validator: (value) => Utils.nonEmptyValidator(value),
                    decoration: InputDecoration(
                      contentPadding: padding,
                      hintText: "Usuário",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.0),
                  TextFormField(
                    controller: controllers['password'],
                    obscureText: true,
                    validator: (value) => Utils.nonEmptyValidator(value),
                    style: style,
                    decoration: InputDecoration(
                      contentPadding: padding,
                      hintText: "Senha",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.0),
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.blue,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: padding,
                      onPressed: _perfomingLogin ? null : login,
                      child: _perfomingLogin
                          ? SizedBox(
                              height: 25.0,
                              width: 25.0,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              ),
                            )
                          : Text(
                              "Login",
                              textAlign: TextAlign.center,
                              style: style.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
