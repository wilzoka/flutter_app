import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class View extends StatefulWidget {
  @override
  ViewState createState() => ViewState();
}

class ViewState extends State<View> {
  String viewurl = '';
  String title = 'Home';

  Map<String, dynamic> _currentConf = {};
  Map<String, dynamic> _currentDatasource = {};
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
    print((await Utils.getPreference('mainurl')) +
        'v/' +
        view['url'] +
        '/config');
    final responseConfig = await http.get(
        (await Utils.getPreference('mainurl')) + 'v/' + view['url'] + '/config',
        headers: {'x-access-token': await Utils.getPreference('token')});
    if (responseConfig.statusCode == 200) {
      _currentConf = jsonDecode(responseConfig.body);
      final responseDatasource = await http.post(
          (await Utils.getPreference('mainurl')) + 'datasource',
          headers: {'x-access-token': await Utils.getPreference('token')},
          body: {'view': view['url'], 'start': '0', 'length': '10'});
      if (responseDatasource.statusCode == 200) {
        _currentDatasource = jsonDecode(responseDatasource.body);
        setState(() {
          buildDatasource();
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

  void buildDatasource() {
    cards = [];
    for (int i = 0; i < _currentDatasource['data'].length; i++) {
      List<Widget> rows = List<Widget>();
      for (int c = 0; c < _currentConf['columns'].length; c++) {
        rows.add(Row(children: <Widget>[
          Expanded(
            child: RichText(
              text: TextSpan(
                  style: new TextStyle(
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                        text: _currentConf['columns'][c]['title'].toString() +
                            ': ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                        text: adjustData(_currentDatasource['data'][i]
                            [_currentConf['columns'][c]['data']])),
                  ]),
            ),
          )
        ]));
      }
      cards.add(Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed('viewregister', arguments: {
              'id': _currentDatasource['data'][i]['id'],
              'view': viewurl
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: rows,
            ),
          ),
        ),
      ));
    }
  }

  void _loadMenu() async {
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List menu = jsonDecode(prefs.get('menu'));
    for (int i = 0; i < menu.length; i++) {
      _menuItens.add(_getChild(menu[i]));
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
        onPressed: () {
          // Add your onPressed code here!
        },
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
