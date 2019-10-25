import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'ViewTable.dart';

class View extends StatefulWidget {
  @override
  ViewState createState() => ViewState();
}

class ViewState extends State<View> {
  String title = '';
  Map currentview = {};
  Map profile = {
    'id': null,
    'fullname': '',
    'email': '',
  };

  List<Widget> menu = [];

  void viewSelect(view) {
    setState(() {
      title = view['description'];
      currentview = view;
    });
  }

  void initAsync() async {
    final m = await Utils.loadMenu();
    for (int i = 0; i < m.length; i++) {
      menu.add(Utils.recursiveMenu(context, m[i], viewSelect));
    }
    profile = await Utils.loadProfile();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: currentview.length > 0
          ? ViewTable(
              key: ValueKey(currentview['url']),
              url: currentview['url'],
            )
          : Container(),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(profile['fullname']),
              accountEmail: Text(profile['email']),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.blue,
                backgroundImage: NetworkImage(
                    'https://www.w3schools.com/w3images/avatar2.png'),
              ),
              otherAccountsPictures: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  child: IconButton(
                    color: Colors.blue,
                    icon: Icon(Icons.edit),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(0),
                children: menu,
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () {
                Utils.removePreference('token');
                Navigator.pushReplacementNamed(context, 'login');
              },
            )
          ],
        ),
      ),
    );
  }
}
