import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Utils.dart';

class Autocomplete extends StatefulWidget {
  @override
  AutocompleteState createState() => AutocompleteState();
}

class AutocompleteState extends State<Autocomplete> {
  TextEditingController searchController = TextEditingController();

  List items = [];

  @override
  void initState() {
    super.initState();
    filterSearchResults();
  }

  void filterSearchResults() async {
    items = [];
    final response = await http.get(
        (await Utils.getPreference('mainurl')) +
            'autocomplete?q=' +
            searchController.text +
            '&model=groupusers&attribute=description&query=&where=',
        headers: {'x-access-token': await Utils.getPreference('token')});
    if (response.statusCode == 200) {
      final j = jsonDecode(response.body);
      for (int i = 0; i < j['data'].length; i++) {
        items.add(j['data'][i]);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('search'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults();
                },
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Pesquisa",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index]['text']),
                    onTap: () {
                      Navigator.pop(context, items[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
