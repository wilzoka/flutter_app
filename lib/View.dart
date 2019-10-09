import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class View extends StatefulWidget {
  final String url;
  final String title;

  View({Key key, this.url, this.title}) : super(key: key);

  @override
  ViewState createState() => ViewState();
}

class ViewState extends State<View> {
  @override
  void initState() {
    super.initState();
    getConf();
    print('initstate');
  }

  getConf() async {
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(
        'http://172.10.30.33:8080/v/' + widget.url + '/config?issubview=false',
        headers: {
          'x-access-token': prefs.getString('token')
        },
        body: {
          '_mobile': 'true',
        });
    print(response.body);
    if (response.statusCode == 200) {}
  }

  buildRow() {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            textDirection: TextDirection.ltr,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                          style: new TextStyle(
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Nome: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    ' asd aksdjklas jdkla jskdlj aklsdj alksjdas dhasdj asd  akljsd'),
                          ]),
                    ),
                  )
                  ,
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                          style: new TextStyle(
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Nome: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    ' asd aksdjklas jdkla jskdlj aklsdj alksjdas dhasdj asd  akljsd'),
                          ]),
                    ),
                  )
                  ,
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: ListView(
        children: <Widget>[
          Text(widget.url),
          buildRow(),
          buildRow(),
          buildRow(),
          buildRow(),
        ],
      ),
    );
  }
}
