import 'package:flutter/material.dart';
import 'Utils.dart';

class Autocomplete extends StatefulWidget {
  final String title;
  final String model;
  final String attribute;
  final String query;
  final String where;

  const Autocomplete(
      {Key key,
      this.title,
      this.model,
      this.attribute = '',
      this.query = '',
      this.where = ''})
      : super(key: key);

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

  @override
  void dispose() {
    searchController.dispose();
    items = [];
    super.dispose();
  }

  void filterSearchResults() async {
    items = [];
    final j = await Utils.requestGet('autocomplete?q=' +
        searchController.text +
        '&model=' +
        widget.model +
        '&attribute=' +
        widget.attribute +
        '&query=' +
        widget.query +
        '&where=' +
        widget.where);
    if (j['success']) {
      for (int i = 0; i < j['data'].length; i++) {
        items.add(j['data'][i]);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) => filterSearchResults(),
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
                    title: Text(items[index]['text'].toString()),
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
