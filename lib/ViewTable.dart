import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/ViewRegister.dart';
import 'package:flutter_app/Utils.dart';

class ViewTable extends StatefulWidget {
  final String url;
  final String parent;
  ViewTable({Key key, this.url, this.parent}) : super(key: key);
  @override
  ViewTableState createState() => ViewTableState();
}

class ViewTableState extends State<ViewTable> {
  ScrollController scrollController = ScrollController();
  TextEditingController fastsearchController = TextEditingController();
  Map<String, dynamic> conf = {};
  List data = [];
  int dsIndex = 0;
  int dsLength = 50;
  bool fullfetched = false;
  bool loading = false;
  bool deleting = false;
  bool selectMode = false;
  List<int> selectedIds = [];
  Timer timer;

  Future<Map> getData() async {
    Map body = {
      'view': widget.url,
      'start': dsIndex.toString(),
      'length': dsLength.toString(),
      '_filterfs': fastsearchController.text
    };
    if (widget.parent != null) {
      body['issubview'] = 'true';
      body['id'] = widget.parent;
    }
    return await Utils.requestPost('datasource', body);
  }

  Future<void> fetchData() async {
    if (!loading) {
      if (mounted)
        setState(() {
          loading = true;
        });
      final j = await getData();
      if (j['success']) {
        if (j['data'].length < dsLength) {
          fullfetched = true;
        }
        dsIndex += dsLength;
        if (mounted)
          setState(() {
            data.addAll(j['data']);
          });
      }
      if (mounted)
        setState(() {
          loading = false;
        });
    }
  }

  Future<void> resetUI(bool scrolltop, bool fromRefreshIndicator) async {
    if (mounted && !fromRefreshIndicator)
      setState(() {
        loading = true;
      });
    final lastIndex = dsIndex;
    final lastLength = dsLength;
    if (!scrolltop) dsLength = dsIndex + dsLength;
    dsIndex = 0;
    final j = await getData();
    if (j['success']) {
      if (mounted)
        setState(() {
          data = j['data'];
        });
      if (scrolltop) {
        scrollController.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
    }
    dsIndex = lastIndex;
    dsLength = lastLength;
    if (mounted && !fromRefreshIndicator)
      setState(() {
        loading = false;
      });
  }

  Future<void> initAsync() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }
    conf = await Utils.requestGet('v/${widget.url}/config');
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
    if (conf['success']) {
      fetchData();
    }
  }

  Color cardColor(int id) {
    return selectedIds.indexOf(id) >= 0 ? Colors.grey[300] : Colors.white;
  }

  void cardTap(int id) async {
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
      Utils.hideSnackBar(context);
      final Map lsr = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewRegister(
            key: ValueKey(widget.url),
            id: id.toString(),
            viewurl: widget.url,
          ),
        ),
      );
      if (lsr != null && lsr['success']) {
        if (lsr.containsKey('msg'))
          Utils.showSnackBar(context, lsr['msg'], Colors.green);
        resetUI(false, false);
      }
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
      } else if (option['value'] == 'delete') {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dcontext) {
            return AlertDialog(
              title: Text('Atenção'),
              content: Text(
                  'Os registros selecionados serão Excluídos. Prosseguir?'),
              actions: <Widget>[
                FlatButton(
                  child: Text('Cancelar'),
                  onPressed: () {
                    Navigator.of(dcontext).pop();
                  },
                ),
                FlatButton(
                  color: Colors.red,
                  child: Text('Excluir', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (mounted)
                      setState(() {
                        deleting = true;
                      });
                    final j =
                        await Utils.requestPost('v/${widget.url}/delete', {
                      'ids': selectedIds.join(','),
                    });
                    if (j['success']) {
                      selectMode = false;
                      selectedIds = [];
                      Utils.showSnackBar(context, j['msg'], Colors.green);
                      resetUI(false, false);
                    } else {
                      Utils.showSnackBar(
                          context,
                          j.containsKey('msg') ? j['msg'] : 'Algo deu errado',
                          Colors.red);
                    }
                    if (mounted)
                      setState(() {
                        deleting = false;
                      });
                  },
                )
              ],
            );
          },
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initAsync();
    scrollController.addListener(() {
      final dif = scrollController.position.pixels /
          scrollController.position.maxScrollExtent;
      if (dif >= 0.90 && !fullfetched) {
        fetchData();
      }
    });
  }

  @override
  void dispose() {
    conf = {};
    data = [];
    selectedIds = [];
    fastsearchController.dispose();
    scrollController.dispose();
    if (timer != null) timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(4.0),
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    // iconSize: 20.2,
                    icon: Icon(Icons.add_box),
                    color: Colors.green,
                    iconSize: 30,
                    onPressed: () => cardTap(0),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: TextField(
                        onChanged: (value) {
                          if (timer != null) timer.cancel();
                          timer = Timer(Duration(milliseconds: 750), () {
                            resetUI(true, false);
                          });
                        },
                        readOnly: conf.containsKey('fastsearch') &&
                            conf['fastsearch'].isEmpty,
                        controller: fastsearchController,
                        decoration: InputDecoration(
                          hintText: conf['fastsearch'],
                          border: InputBorder.none,
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
                          color: selectedIds.length > 0
                              ? Colors.blue
                              : Colors.black,
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
                              top: 1,
                              right: 1,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 0,
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
          ),
          fullfetched && data.length == 0
              ? Container(
                  child: Center(child: Text('Nenhum Registro Encontrado')),
                )
              : Expanded(
                  child: Stack(
                    children: <Widget>[
                      RefreshIndicator(
                        onRefresh: () async => resetUI(true, true),
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
                                      padding: EdgeInsets.only(left: 2),
                                      child: Text(
                                        Utils.adjustData(data[i]
                                            [conf['columns'][c]['data']]),
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
                                    onLongPress: () =>
                                        cardLongPress(data[i]['id']),
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
                                        columnWidths: {
                                          0: IntrinsicColumnWidth()
                                        },
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
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            selectedIds.indexOf(
                                                        data[i]['id']) >=
                                                    0
                                                ? Icons.check_box
                                                : Icons.check_box_outline_blank,
                                            color: selectedIds.indexOf(
                                                        data[i]['id']) >=
                                                    0
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
                      loading || deleting
                          ? Center(child: CircularProgressIndicator())
                          : Container()
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
