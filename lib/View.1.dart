import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:flutter_app/ViewRegister.dart';

class View extends StatefulWidget {
  @override
  ViewState createState() => ViewState();
}

class ViewState extends State<View> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();
  String title = 'Home';

  Map<String, dynamic> _currentConf = {};
  List _currentDatasource = [];
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

  bool isLoading = false;
  bool fullLoaded = false;

  int lastindex = 0;
  void getData(bool reset) async {
    isLoading = true;
    if (reset) {
      _currentDatasource = [];
      lastindex = 0;
      fullLoaded = false;
    } else {
      lastindex += 20;
    }
    final j = await Utils.requestPost(
      'datasource',
      {
        'view': _currentView['url'],
        'start': lastindex.toString(),
        'length': '20'
      },
    );
    if (j['success']) {
      if (j['data'].length < 20) {
        fullLoaded = true;
      }
      setState(() {
        _currentDatasource.addAll(j['data']);
      });
    }
    isLoading = false;
  }

  void viewSelect(view) async {
    _currentView = view;
    _currentConf = await Utils.requestGet('v/' + view['url'] + '/config');
    if (_currentConf['success']) {
      getData(true);
      setState(() {
        title = view['description'];
      });
    }
  }

  String adjustData(value) {
    if (value is bool) {
      return value ? 'Sim' : 'Não';
    } else if (value == null) {
      return '';
    } else {
      return value.toString();
    }
  }

  // void _buildDatasource() {
  //   cards = [];
  //   for (int i = 0; i < _currentDatasource['data'].length; i++) {
  //     List<Widget> rows = List<Widget>();
  //     for (int c = 0; c < _currentConf['columns'].length; c++) {
  //       rows.add(
  //         RichText(
  //           text: TextSpan(
  //             style: TextStyle(
  //               color: Colors.black,
  //             ),
  //             children: <TextSpan>[
  //               TextSpan(
  //                   text: _currentConf['columns'][c]['title'].toString() + ': ',
  //                   style: TextStyle(fontWeight: FontWeight.bold)),
  //               TextSpan(
  //                   text: adjustData(_currentDatasource['data'][i]
  //                       [_currentConf['columns'][c]['data']])),
  //             ],
  //           ),
  //         ),
  //       );
  //     }
  //     cards.add(
  //       Card(
  //         elevation: 3,
  //         margin: const EdgeInsets.only(bottom: 10),
  //         child: InkWell(
  //           onTap: () async {
  //             final lastSaveRequest = await Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => ViewRegister(
  //                     id: _currentDatasource['data'][i]['id'].toString(),
  //                     viewurl: _currentView['url']),
  //               ),
  //             );
  //             if (lastSaveRequest != null &&
  //                 lastSaveRequest.containsKey('msg')) {
  //               _scaffoldKey.currentState.removeCurrentSnackBar();
  //               _scaffoldKey.currentState.showSnackBar(
  //                 SnackBar(
  //                   content: Text(lastSaveRequest['msg']),
  //                   backgroundColor: Colors.green,
  //                 ),
  //               );
  //             }
  //             viewSelect(_currentView);
  //           },
  //           child: Padding(
  //             padding: const EdgeInsets.all(10.0),
  //             child: Row(
  //               children: <Widget>[
  //                 // ClipRRect(
  //                 //   borderRadius: new BorderRadius.circular(8.0),
  //                 //   child: Image.network(
  //                 //     'https://picsum.photos/200/300',
  //                 //     height: 150.0,
  //                 //     width: 100.0,
  //                 //   ),
  //                 // ),
  //                 Expanded(
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(8.0),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: rows,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  // }

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
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoading &&
          !fullLoaded) {
        getData(false);
      }
    });
    _loadMenu();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                // onChanged: (value) => filterSearchResults(),
                // controller: searchController,
                decoration: InputDecoration(
                  hintText: "Pesquisa",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _currentDatasource.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_currentDatasource[index]['id'].toString()),
                      onTap: () {
                        // Navigator.pop(context, items[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ViewRegister(id: '0', viewurl: _currentView['url']),
            ),
          );
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
