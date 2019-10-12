import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';

class View extends StatefulWidget {
  @override
  ViewState createState() => ViewState();
}

class ViewState extends State<View> {
  String title = 'Home';

  Map<String, dynamic> _currentConf = {};
  Map<String, dynamic> _currentDatasource = {};
  Map _currentView = {};
  List<Widget> cards = List<Widget>();

  List<Widget> _menuItens = [
    DrawerHeader(
      child: Text('Drawer Header'),
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
    )
  ];

  void viewSelect(view) async {
    _currentView = view;
    _currentConf = await Utils.requestGet('v/' + view['url'] + '/config');
    if (_currentConf['success']) {
      _currentDatasource = await Utils.requestPost(
        'datasource',
        {'view': view['url'], 'start': '0', 'length': '15'},
      );
      if (_currentDatasource['success']) {
        setState(() {
          _buildDatasource();
          title = view['description'];
        });
      }
    }
  }

  adjustData(value) {
    if (value is bool) {
      return value ? 'Sim' : 'Não';
    } else if (value == null) {
      return '';
    } else {
      return value.toString();
    }
  }

  void _buildDatasource() {
    cards = [];
    for (int i = 0; i < _currentDatasource['data'].length; i++) {
      List<Widget> rows = List<Widget>();
      for (int c = 0; c < _currentConf['columns'].length; c++) {
        rows.add(
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: _currentConf['columns'][c]['title'].toString() + ': ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: adjustData(_currentDatasource['data'][i]
                        [_currentConf['columns'][c]['data']])),
              ],
            ),
          ),
        );
      }
      cards.add(
        Card(
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                'viewregister',
                arguments: {
                  'title': _currentView['description'].toString(),
                  'id': _currentDatasource['data'][i]['id'].toString(),
                  'viewurl': _currentView['url']
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: new BorderRadius.circular(8.0),
                    child: Image.network(
                      'https://picsum.photos/200/300',
                      height: 150.0,
                      width: 100.0,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rows,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _getChild(item) {
    if (item['children'] != null && item['children'].length > 0) {
      List<Widget> childrens = [];
      for (int i = 0; i < item['children'].length; i++) {
        childrens.add(_getChild(item['children'][i]));
      }
      return ExpansionTile(
        title: Text(item['description']),
        children: childrens,
      );
    } else {
      return ListTile(
        title: Text(item['description']),
        onTap: () {
          viewSelect(item);
          Navigator.of(context).pop();
        },
      );
    }
  }

  void _loadMenu() async {
    final j = await Utils.requestGet('config/menu');
    if (j['success']) {
      List menu = j['menu'];
      for (int i = 0; i < menu.length; i++) {
        _menuItens.add(_getChild(menu[i]));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        margin: const EdgeInsets.all(10),
        child: ListView(
          children: cards,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: _menuItens,
        ),
      ),
    );
  }
}
