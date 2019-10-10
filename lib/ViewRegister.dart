import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:http/http.dart' as http;
import 'Autocomplete.dart';

class ViewRegister extends StatefulWidget {
  final String viewurl;
  final String id;
  ViewRegister({Key key, this.viewurl, this.id}) : super(key: key);

  @override
  ViewRegisterState createState() => ViewRegisterState();
}

class ViewRegisterState extends State<ViewRegister> {
  Map<String, dynamic> _currentConf = {};
  List autocomplete = [];
  List<Widget> fields = [];
  Map<String, dynamic> fieldcontroller = {};

  void _getConf() async {
    final response = await http.get(
        (await Utils.getPreference('mainurl')) +
            'v/' +
            widget.viewurl +
            '/' +
            widget.id +
            '/config',
        headers: {'x-access-token': await Utils.getPreference('token')});
    if (response.statusCode == 200) {
      _currentConf = jsonDecode(response.body);
      setState(() {
        _buildView();
      });
    }
  }

  Widget row(value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          value,
          style: TextStyle(fontSize: 16.0),
        ),
      ],
    );
  }

  void getAutocompleteSource() async {
    try {
      autocomplete = [];
      final response =
          await http.get("https://jsonplaceholder.typicode.com/users");
      if (response.statusCode == 200) {
        final j = jsonDecode(response.body);
        for (var i = 0; i < j.length; i++) {
          autocomplete.add(
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  j[i]['name'],
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  j[i]['name'],
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print("Error getting Ac.");
    }
  }

  void _buildView() {
    Map zones = _currentConf['zones'];
    fields = [];
    zones.forEach((zone, v) {
      if (zone != 'hidden') {
        for (int i = 0; i < _currentConf['zones'][zone]['fields'].length; i++) {
          final field = _currentConf['zones'][zone]['fields'][i];

          switch (field['type']) {
            case 'text':
              if (!fieldcontroller.containsKey(field['name']))
                fieldcontroller[field['name']] = TextEditingController(
                    text: field['value'] == null
                        ? ''
                        : field['value'].toString());
              fields.add(
                TextFormField(
                  controller: fieldcontroller[field['name']],
                  decoration: InputDecoration(labelText: field['label']),
                  validator: (value) => Utils.nonEmptyValidator(value),
                ),
              );
              break;
            case 'autocomplete':
              if (!fieldcontroller.containsKey(field['name']))
                fieldcontroller[field['name']] = TextEditingController(
                    text: field['value'] == null
                        ? ''
                        : field['value'].toString());
              fields.add(
                Stack(alignment: Alignment(1.0, 1.0), children: <Widget>[
                  TextField(
                    readOnly: true,
                    controller: fieldcontroller[field['name']],
                    decoration: InputDecoration(
                      labelText: field['label'],
                    ),
                    onTap: () async {
                      final ac = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Autocomplete()));
                      fieldcontroller[field['name']].text = ac['text'];
                    },
                  ),
                  FlatButton(
                    onPressed: () {
                      fieldcontroller[field['name']].clear();
                    },
                    child: Icon(Icons.clear),
                  ),
                ]),
              );
              break;
            case 'date':
              if (!fieldcontroller.containsKey(field['name'])) {
                fieldcontroller[field['name']] = TextEditingController(
                    text: field['value'] == null
                        ? ''
                        : field['value'].toString());
              }
              fields.add(
                Stack(alignment: Alignment(1.0, 1.0), children: <Widget>[
                  TextField(
                    readOnly: true,
                    controller: fieldcontroller[field['name']],
                    decoration: InputDecoration(
                      labelText: field['label'],
                    ),
                    onTap: () {
                      Utils.selectDate(context, (picked) {
                        fieldcontroller[field['name']].text = picked;
                      });
                    },
                  ),
                  FlatButton(
                    onPressed: () {
                      fieldcontroller[field['name']].clear();
                    },
                    child: Icon(Icons.clear),
                  )
                ]),
              );
              break;
            case 'decimal':
              if (!fieldcontroller.containsKey(field['name']))
                fieldcontroller[field['name']] = TextEditingController(
                    text: field['value'] == null
                        ? ''
                        : field['value'].toString());
              fields.add(
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: fieldcontroller[field['name']],
                  decoration: InputDecoration(labelText: field['label']),
                  validator: (value) => Utils.nonEmptyValidator(value),
                ),
              );
              break;
            case 'boolean':
              if (!fieldcontroller.containsKey(field['name'])) {
                fieldcontroller[field['name']] =
                    field['value'].toString().isEmpty
                        ? false
                        : field['value'] as bool;
              }
              fields.add(
                CheckboxListTile(
                  title: Text(field['label']),
                  value: fieldcontroller[field['name']],
                  onChanged: (val) {
                    setState(() {
                      fieldcontroller[field['name']] = val;
                      _buildView();
                    });
                  },
                ),
              );
              break;
          }
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getConf();
  }

  @override
  void dispose() {
    fieldcontroller.forEach((key, value) {
      if (fieldcontroller[key] is TextEditingController) {
        fieldcontroller[key].dispose();
      }
    });
    super.dispose();
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
          children: fields,
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
