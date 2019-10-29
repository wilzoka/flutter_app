import 'dart:async';

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
  Timer timer;
  bool loading = false;

  List items = [];

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  @override
  void dispose() {
    searchController.dispose();
    items = [];
    timer?.cancel();
    super.dispose();
  }

  void fetchResults() async {
    if (mounted)
      setState(() {
        loading = true;
      });
    final j = await Utils.requestGet(
        'autocomplete?q=${searchController.text}&model=${widget.model}&attribute=${widget.attribute}&query=${widget.query}&where=${widget.where}');
    if (j['success']) {
      items = j['data'];
    }
    if (mounted)
      setState(() {
        loading = false;
      });
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
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey[400],
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
                child: TextField(
                  onChanged: (value) {
                    if (timer != null) timer.cancel();
                    timer = Timer(Duration(milliseconds: 750), () {
                      fetchResults();
                    });
                  },
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: "Pesquisa",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(top: 15)),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(items[index]['text'].toString()),
                          onTap: () {
                            Navigator.pop(context, items[index]);
                          },
                        ),
                      );
                    },
                  ),
                  loading
                      ? Center(child: CircularProgressIndicator())
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
