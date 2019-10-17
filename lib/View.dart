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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   child: Icon(Icons.add),
      //   backgroundColor: Colors.green,
      // ),
      drawer: Drawer(
        child: ListView(
          children: menu,
        ),
      ),
    );
  }
}
