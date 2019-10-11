import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
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
  String title = '';
  Map<String, dynamic> _currentConf = {};
  List<Widget> fields = [];
  List<Widget> tabs = [];
  Map<String, List<Widget>> tabfields = {};
  List<Widget> tabscontainer = [];
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
        var field = _currentConf['zones'][zone]['fields'][z];
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
                TextField(
                  readOnly: true,
                  controller: fieldcontroller[field['name'] + '_text'],
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
              decoration: InputDecoration(
                  labelText: field['label'], suffixIcon: Icon(Icons.cached)),
              validator: (value) => Utils.nonEmptyValidator(value),
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
                decoration: InputDecoration(labelText: field['label']),
                validator: (value) => Utils.nonEmptyValidator(value),
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
                decoration: InputDecoration(labelText: field['label']),
                validator: (value) => Utils.nonEmptyValidator(value),
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
    } else if (tabs.length > 1) {
      return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            bottom: TabBar(
              isScrollable: tabs.length > 2,
              tabs: tabs,
            ),
          ),
          body: TabBarView(children: tabscontainer),
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: Icon(Icons.check),
            backgroundColor: Colors.green,
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          child: ListView(
            children: tabfields[_currentConf['zone'][0]],
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
}
