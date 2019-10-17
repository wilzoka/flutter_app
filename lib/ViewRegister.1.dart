import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:flutter_app/ViewTable.dart';
import 'package:http/http.dart' as http;
import 'Autocomplete.dart';

class ViewRegister extends StatefulWidget {
  final String id;
  final String viewurl;
  ViewRegister({Key key, this.viewurl, this.id}) : super(key: key);

  @override
  ViewRegisterState createState() => ViewRegisterState();
}

class ViewRegisterState extends State<ViewRegister> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String title = '';
  Map<String, dynamic> _currentConf = {};
  List<Widget> fields = [];
  List<Widget> tabs = [];
  Map<String, List<Widget>> tabfields = {};
  List<Widget> tabscontainer = [];
  Map<String, dynamic> fieldcontroller = {};
  Map<String, dynamic> lastSaveRequest = {};
  bool saving = false;

  String validator(fieldname) {
    if (lastSaveRequest.containsKey('invalidfields') &&
        lastSaveRequest['invalidfields'].indexOf(fieldname) >= 0) {
      return ''; //lastSaveRequest['msg'];
    } else {
      return null;
    }
  }

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
        title = _currentConf['view']['name'];
        _buildView();
      });
    }
  }

  void _buildView() {
    for (int i = 0; i < _currentConf['zone'].length; i++) {
      final zone = _currentConf['zone'][i];
      tabs.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(_currentConf['zones'][zone]['description'] ?? zone),
        ),
      );
      tabfields[zone] = [];
      for (int z = 0; z < _currentConf['zones'][zone]['fields'].length; z++) {
        var field =
            _currentConf['fields'][_currentConf['zones'][zone]['fields'][z]];
        field['label'] += field['notnull'] ? '*' : '';
        switch (field['type']) {
          case 'autocomplete':
            if (!fieldcontroller.containsKey(field['name'])) {
              // ID
              fieldcontroller[field['name']] = TextEditingController(
                text: field['value'] == null
                    ? ''
                    : field['value']['id'].toString(),
              );
              // TEXT
              fieldcontroller[field['name'] + '_text'] = TextEditingController(
                text: field['value'] == null
                    ? ''
                    : field['value']['text'].toString(),
              );
            }
            tabfields[zone].add(
              Stack(alignment: Alignment(1.0, 1.0), children: <Widget>[
                TextFormField(
                  readOnly: true,
                  controller: fieldcontroller[field['name'] + '_text'],
                  validator: (value) => validator(field['name']),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.only(top: 13, bottom: 10, right: 45),
                    labelText: field['label'],
                  ),
                  onTap: () async {
                    final ac = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Autocomplete(
                                  title: field['label'],
                                  model: field['add']['model'],
                                  attribute: field['add']['attribute'] ?? '',
                                  query: field['add']['query'] ?? '',
                                  where: field['add']['where'] ?? '',
                                )));
                    if (ac != null) {
                      fieldcontroller[field['name']].text = ac['id'].toString();
                      fieldcontroller[field['name'] + '_text'].text =
                          ac['text'].toString();
                    }
                  },
                ),
                IconButton(
                  onPressed: () {
                    fieldcontroller[field['name']].clear();
                    fieldcontroller[field['name'] + '_text'].clear();
                  },
                  icon: Icon(Icons.clear),
                ),
              ]),
            );
            break;
          case 'boolean':
            if (!fieldcontroller.containsKey(field['name']))
              fieldcontroller[field['name']] = TextEditingController(
                  text: field['value'] == null
                      ? 'Não'
                      : field['value'] ? 'Sim' : 'Nâo');
            tabfields[zone].add(TextFormField(
              enableInteractiveSelection: false,
              readOnly: true,
              controller: fieldcontroller[field['name']],
              validator: (value) => validator(field['name']),
              decoration: InputDecoration(
                  labelText: field['label'], suffixIcon: Icon(Icons.cached)),
              onTap: () {
                setState(() {
                  if (fieldcontroller[field['name']].text == 'Sim') {
                    fieldcontroller[field['name']].text = 'Não';
                  } else {
                    fieldcontroller[field['name']].text = 'Sim';
                  }
                });
              },
            ));
            break;
          case 'date':
            if (!fieldcontroller.containsKey(field['name'])) {
              fieldcontroller[field['name']] = TextEditingController(
                  text:
                      field['value'] == null ? '' : field['value'].toString());
            }
            tabfields[zone].add(
              Stack(alignment: Alignment(1.0, 1.0), children: <Widget>[
                TextFormField(
                  readOnly: true,
                  controller: fieldcontroller[field['name']],
                  validator: (value) => validator(field['name']),
                  decoration: InputDecoration(
                    labelText: field['label'],
                  ),
                  onTap: () {
                    Utils.selectDate(context, (picked) {
                      fieldcontroller[field['name']].text = picked;
                    });
                  },
                ),
                IconButton(
                  onPressed: () {
                    fieldcontroller[field['name']].clear();
                  },
                  icon: Icon(Icons.clear),
                )
              ]),
            );
            break;
          case 'decimal':
            if (!fieldcontroller.containsKey(field['name']))
              fieldcontroller[field['name']] = TextEditingController(
                  text:
                      field['value'] == null ? '' : field['value'].toString());
            tabfields[zone].add(
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                controller: fieldcontroller[field['name']],
                validator: (value) => validator(field['name']),
                decoration: InputDecoration(labelText: field['label']),
              ),
            );
            break;
          case 'text':
            if (!fieldcontroller.containsKey(field['name']))
              fieldcontroller[field['name']] = TextEditingController(
                  text:
                      field['value'] == null ? '' : field['value'].toString());
            tabfields[zone].add(
              TextFormField(
                controller: fieldcontroller[field['name']],
                validator: (value) => validator(field['name']),
                decoration: InputDecoration(labelText: field['label']),
              ),
            );
            break;
        }
      }
      // Just a padding for Floating Button
      tabfields[zone].add(Padding(
        padding: EdgeInsets.symmetric(vertical: 33),
        child: Container(),
      ));
      if (zone == 'reservas') {
        tabscontainer.add(
          ViewTable(
            key: ValueKey('volume_-_reserva'),
            url: 'volume_-_reserva',
          ),
        );
      } else {
        tabscontainer.add(
          Container(
            margin: const EdgeInsets.all(10),
            child: ListView(
              children: tabfields[zone],
            ),
          ),
        );
      }
    }
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
    _currentConf = {};
    fields = [];
    tabs = [];
    tabfields = {};
    tabscontainer = [];
    fieldcontroller = {};
    lastSaveRequest = {};
    saving = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (tabs.length == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (tabs.length == 1) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(title),
          actions: <Widget>[
            ListTile(
              title: Text('Salvar'),
              onTap: () {},
            )
          ],
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          child: Form(
            key: _formKey,
            child: ListView(
              children: tabfields[_currentConf['zone'][0]],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.check),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(title),
            actions: <Widget>[
              FlatButton(
                textColor: Colors.white,
                onPressed: () {},
                child: Text("Salvar"),
                shape:
                    CircleBorder(side: BorderSide(color: Colors.transparent)),
              )
            ],
            bottom: TabBar(
              isScrollable: tabs.length > 3,
              tabs: tabs,
            ),
          ),
          body: Form(
            key: _formKey,
            child: TabBarView(children: tabscontainer),
          ),
          floatingActionButton: saving
              ? FloatingActionButton(
                  child: CircularProgressIndicator(),
                  backgroundColor: Colors.white,
                  onPressed: () {},
                )
              : FloatingActionButton(
                  child: Icon(Icons.check),
                  backgroundColor: Colors.green,
                  onPressed: () async {
                    Map register = {};
                    _currentConf['fields'].forEach((key, value) {
                      if (fieldcontroller.containsKey(key)) {
                        switch (value['type']) {
                          case 'boolean':
                            if (fieldcontroller[key].text == 'Sim') {
                              register[key] = 'true';
                            } else {
                              register[key] = 'false';
                            }
                            break;
                          default:
                            // fieldcontroller[key].build
                            register[key] = fieldcontroller[key].text;
                            break;
                        }
                      }
                    });

                    lastSaveRequest['invalidfields'] = [];
                    _formKey.currentState.validate();
                    setState(() {
                      saving = true;
                    });
                    lastSaveRequest = await Utils.requestPost(
                        'v/' + widget.viewurl + '/' + widget.id, register);
                    if (lastSaveRequest['success']) {
                      Navigator.pop(context, lastSaveRequest);
                    } else {
                      _scaffoldKey.currentState.removeCurrentSnackBar();
                      _scaffoldKey.currentState.showSnackBar(
                        SnackBar(
                          content: Text(lastSaveRequest['msg']),
                          backgroundColor: Colors.red,
                        ),
                      );
                      _formKey.currentState.validate();
                    }
                    setState(() {
                      saving = false;
                    });
                  },
                ),
        ),
      );
    }
  }
}
