import 'package:flutter/material.dart';
import 'package:flutter_app/ViewRegister.dart';
import 'Utils.dart';

class ViewTable extends StatefulWidget {
  final String url;
  ViewTable({Key key, this.url}) : super(key: key);

  @override
  ViewTableState createState() => ViewTableState();
}

class ViewTableState extends State<ViewTable> {
  ScrollController scrollController = ScrollController();
  Map<String, dynamic> conf = {};
  List data = [];
  int dsIndex = 0;
  int dsLength = 20;
  bool fullfetched = false;
  bool selectMode = false;
  List<int> selectedIds = [];

  void fetchData() async {
    final j = await Utils.requestPost(
      'datasource',
      {
        'view': widget.url,
        'start': dsIndex.toString(),
        'length': dsLength.toString()
      },
    );
    if (j['success']) {
      if (j['data'].length < dsLength) {
        fullfetched = true;
      }
      dsIndex += dsLength;
      setState(() {
        data.addAll(j['data']);
      });
    }
  }

  void getConf() async {
    dsIndex = 0;
    conf = await Utils.requestGet('v/${widget.url}/config');
    if (conf['success']) {
      fetchData();
    }
  }

  Color cardColor(int id) {
    return selectedIds.indexOf(id) >= 0 ? Colors.grey[300] : Colors.white;
  }

  void cardTap(int id) {
    if (selectMode) {
      setState(() {
        final idx = selectedIds.indexOf(id);
        if (idx >= 0) {
          selectedIds.removeAt(idx);
        } else {
          selectedIds.add(id);
        }
        if (selectedIds.length == 0) {
          selectMode = false;
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewRegister(
              key: ValueKey(widget.url),
              id: id.toString(),
              viewurl: widget.url),
        ),
      );
    }
  }

  void cardLongPress(int id) {
    setState(() {
      selectMode = true;
      if (selectedIds.indexOf(id) < 0) {
        selectedIds.add(id);
      }
    });
  }

  void eventSelect(option) {
    if (option['type'] == 'action') {
      if (option['value'] == 'unmark') {
        setState(() {
          selectedIds = [];
          selectMode = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !fullfetched) {
        fetchData();
      }
    });
    getConf();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  // iconSize: 20.2,
                  icon: Icon(Icons.add_box),
                  color: Colors.green,
                  iconSize: 30,
                  onPressed: () {},
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Pesquisar',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  // iconSize: 20.2,
                  icon: Icon(Icons.filter_list),
                  iconSize: 30,
                  onPressed: () {},
                ),
                Stack(
                  children: [
                    PopupMenuButton(
                      onSelected: (value) => eventSelect(value),
                      icon: Icon(
                        Icons.more_vert,
                        color:
                            selectedIds.length > 0 ? Colors.blue : Colors.black,
                      ),
                      itemBuilder: (BuildContext context) {
                        List<PopupMenuEntry> items = [];
                        // Delete
                        items.add(PopupMenuItem(
                          enabled: selectedIds.length > 0,
                          value: {'type': 'action', 'value': 'delete'},
                          child: ListTile(
                            title: Text('Excluir'),
                            leading: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                          ),
                        ));
                        // Desmarcar Selecionados
                        items.add(PopupMenuItem(
                          enabled: selectedIds.length > 0,
                          value: {'type': 'action', 'value': 'unmark'},
                          child: ListTile(
                            title: Text('Desmarcar Todos'),
                            leading: Icon(
                              Icons.close,
                              color: Colors.blue,
                            ),
                          ),
                        ));
                        if (conf['events'].length > 0) {
                          items.add(PopupMenuDivider(height: 10));
                        }
                        for (var i = 0; i < conf['events'].length; i++) {
                          items.add(PopupMenuItem(
                            value: {
                              'type': 'event',
                              'value': conf['events'][i]['id']
                            },
                            child: Text(conf['events'][i]['description']),
                            // child: ListTile(
                            //   title: Text(conf['events'][i]['description']),
                            //   leading: Icon(Icons.chevron_right),
                            // ),
                          ));
                        }
                        return items;
                      },
                    ),
                    selectedIds.length > 0
                        ? Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10.0),
                                ),
                                color: Colors.blue,
                              ),
                              child: Text(
                                selectedIds.length.toString(),
                                // 100.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: data.length,
              itemBuilder: (context, i) {
                List<TableRow> rows = [];
                for (int c = 0; c < conf['columns'].length; c++) {
                  rows.add(
                    TableRow(
                      children: [
                        Text(
                          '${conf['columns'][c]['title']}: ',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Text(
                            Utils.adjustData(
                                data[i][conf['columns'][c]['data']]),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Stack(
                  children: [
                    Card(
                      color: cardColor(data[i]['id']),
                      child: InkWell(
                        onLongPress: () => cardLongPress(data[i]['id']),
                        onTap: () => cardTap(data[i]['id']),
                        child: Padding(
                          padding: const EdgeInsets.all(9.0),
                          child: Table(
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                color: Colors.grey[200],
                                width: 0.5,
                              ),
                            ),
                            columnWidths: {0: IntrinsicColumnWidth()},
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: rows,
                          ),
                        ),
                      ),
                    ),
                    selectMode
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                selectedIds.indexOf(data[i]['id']) >= 0
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: selectedIds.indexOf(data[i]['id']) >= 0
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                            ),
                          )
                        : Container(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
