import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  String viewurl = '';
  String title = 'Home';

  List<Widget> _menuItens = [
    DrawerHeader(
      child: Text('Drawer Header'),
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
    )
  ];

  viewSelect(view) async {
    final response = await http.post(
        'http://172.10.30.33:8080/v/' + view['url'] + '/config?issubview=false',
        body: {
          '_mobile': 'true',
        });
    print(response.body);
    print(response.statusCode);
    print(view['url']);
  }

  _loadMenu() async {
    _getChild(item) {
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
    List menu = jsonDecode(prefs.get('__menu'));
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
      body: Center(),
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
