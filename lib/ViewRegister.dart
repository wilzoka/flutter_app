import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:http/http.dart' as http;

class ViewRegister extends StatefulWidget {
  final String viewurl;
  final int id;
  const ViewRegister({Key key, this.viewurl, this.id}) : super(key: key);

  @override
  ViewRegisterState createState() => ViewRegisterState();
}

class ViewRegisterState extends State<ViewRegister> {
  Map<String, dynamic> _currentConf = {};

  void _getConf() async {
    final responseConfig = await http.get(
        await Utils.getPreference('mainurl') +
            widget.viewurl +
            '/' +
            widget.id.toString() +
            '/config',
        headers: {'x-access-token': await Utils.getPreference('token')});
    if (responseConfig.statusCode == 200) {}
  }

  @override
  void initState() {
    super.initState();
    _getConf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[Text(widget.viewurl), Text(widget.id.toString())],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.check),
        backgroundColor: Colors.green,
      ),
    );
  }
}
