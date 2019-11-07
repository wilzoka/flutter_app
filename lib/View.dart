import 'package:flutter/material.dart';
import 'package:flutter_app/Utils.dart';
import 'package:flutter_app/ViewRegister.dart';
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
              accountEmail: Text(profile['email'] ?? ''),
              currentAccountPicture: profile['image'] == null
                  ? Container(child: Icon(Icons.person))
                  : CircleAvatar(
                      backgroundColor: Colors.blue,
                      backgroundImage: NetworkImage(
                        '${Utils.mainurl}/file/${profile['image']['id']}',
                        headers: {
                          'x-access-token': Utils.jwt,
                        },
                      ),
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
                    onPressed: () async {
                      final lsr = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewRegister(
                            key: ValueKey('profile'),
                            id: profile['id'].toString(),
                            viewurl: 'profile',
                          ),
                        ),
                      );
                      if (lsr != null) {
                        profile = await Utils.loadProfile();
                        setState(() {});
                        print('loaded $profile');
                      }
                    },
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
                Utils.removeJwt();
                Navigator.pushReplacementNamed(context, 'login');
              },
            )
          ],
        ),
      ),
    );
  }
}
