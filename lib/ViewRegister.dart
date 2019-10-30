import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/Utils.dart';
import 'package:flutter_app/ViewTable.dart';
import 'package:flutter_app/components/carousel_slider.dart';
import 'package:flutter_app/formatters/Decimal.dart';
import 'Autocomplete.dart';

class ViewRegister extends StatefulWidget {
  final String id;
  final String viewurl;
  final String parent;
  ViewRegister({Key key, this.viewurl, this.id, this.parent}) : super(key: key);

  @override
  ViewRegisterState createState() => ViewRegisterState();
}

class ViewRegisterState extends State<ViewRegister> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String title = '';
  Map<String, dynamic> conf = {};
  List<Widget> tabs = [];
  Map<String, List<Widget>> tabfields = {};
  List<Widget> tabscontainer = [];
  Map<String, dynamic> fieldcontroller = {};
  Map<String, dynamic> lastSaveRequest = {};
  bool saving = false;
  final EdgeInsets fieldPadding = EdgeInsets.only(top: 2, bottom: 5);

  String validator(fieldname) {
    if (lastSaveRequest.containsKey('invalidfields') &&
        lastSaveRequest['invalidfields'].indexOf(fieldname) >= 0) {
      return lastSaveRequest.containsKey('msg')
          ? lastSaveRequest['msg']
          : 'Campo Obrigatório';
    } else {
      return null;
    }
  }

  Future<void> initAsync() async {
    conf = await Utils.requestGet('v/${widget.viewurl}/${widget.id}/config');
    if (conf['success']) {
      if (mounted)
        setState(() {
          title = conf['view']['name'];
          buildUI();
        });
    }
  }

  void buildUI() async {
    for (int i = 0; i < conf['zone'].length; i++) {
      final zone = conf['zone'][i];
      tabfields[zone] = [];
      if (conf['zones'][zone]['subview'] != null) {
        final Map subview = conf['zones'][zone]['subview'];
        tabs.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(subview['description'] ??
                conf['zones'][zone]['description'] ??
                zone),
          ),
        );
        tabscontainer.add(
          ViewTable(
            key: ValueKey(subview['url']),
            url: subview['url'],
            parent: widget.id,
          ),
        );
      } else {
        tabs.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(conf['zones'][zone]['description'] ?? zone),
          ),
        );
        for (int z = 0; z < conf['zones'][zone]['fields'].length; z++) {
          Map field = conf['fields'][conf['zones'][zone]['fields'][z]];
          field['label'] += field['notnull'] ? '*' : '';
          if (field['type'] == 'autocomplete') {
            if (!fieldcontroller.containsKey(field['name'])) {
              // ID
              fieldcontroller[field['name']] = TextEditingController(
                text: field['value'] == null
                    ? ''
                    : field['value']['id'].toString(),
              );
              // TEXT
              fieldcontroller[field['name'] + '_text'] = TextEditingController(
                text: field['value'] == null
                    ? ''
                    : field['value']['text'].toString(),
              );
            }
            tabfields[zone].add(
              Stack(
                children: <Widget>[
                  Padding(
                    padding: fieldPadding,
                    child: TextFormField(
                      enabled: field['enabled'],
                      readOnly: true,
                      controller: fieldcontroller[field['name'] + '_text'],
                      validator: (value) => validator(field['name']),
                      decoration: InputDecoration(labelText: field['label']),
                      onTap: () async {
                        final ac = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Autocomplete(
                              title: field['label'],
                              model: field['add']['model'],
                              attribute: field['add']['attribute'] ?? '',
                              query: field['add']['query'] ?? '',
                              where: field['add']['where'] ?? '',
                            ),
                          ),
                        );
                        if (ac != null) {
                          fieldcontroller[field['name']].text =
                              ac['id'].toString();
                          fieldcontroller[field['name'] + '_text'].text =
                              ac['text'].toString();
                        }
                      },
                    ),
                  ),
                  field['enabled']
                      ? Positioned(
                          right: 0,
                          top: -2,
                          child: IconButton(
                            onPressed: () {
                              fieldcontroller[field['name']].clear();
                              fieldcontroller[field['name'] + '_text'].clear();
                            },
                            icon: Icon(Icons.clear),
                          ),
                        )
                      : Container(),
                ],
              ),
            );
          } else if (field['type'] == 'boolean') {
            if (!fieldcontroller.containsKey(field['name']))
              fieldcontroller[field['name']] = TextEditingController(
                  text: field['value'] == null
                      ? 'Não'
                      : field['value'] ? 'Sim' : 'Nâo');
            tabfields[zone].add(
              Stack(
                children: <Widget>[
                  Padding(
                    padding: fieldPadding,
                    child: TextFormField(
                      enabled: field['enabled'],
                      enableInteractiveSelection: false,
                      readOnly: true,
                      controller: fieldcontroller[field['name']],
                      validator: (value) => validator(field['name']),
                      decoration: InputDecoration(labelText: field['label']),
                      onTap: () {
                        if (fieldcontroller[field['name']].text == 'Sim') {
                          fieldcontroller[field['name']].text = 'Não';
                        } else {
                          fieldcontroller[field['name']].text = 'Sim';
                        }
                      },
                    ),
                  ),
                  field['enabled']
                      ? Positioned(
                          right: 0,
                          top: -2,
                          child: IconButton(
                            onPressed: () {
                              if (fieldcontroller[field['name']].text ==
                                  'Sim') {
                                fieldcontroller[field['name']].text = 'Não';
                              } else {
                                fieldcontroller[field['name']].text = 'Sim';
                              }
                            },
                            icon: Icon(Icons.cached),
                          ),
                        )
                      : Container()
                ],
              ),
            );
          } else if (field['type'] == 'decimal') {
            if (!fieldcontroller.containsKey(field['name']))
              fieldcontroller[field['name']] = TextEditingController(
                  text:
                      field['value'] == null ? '' : field['value'].toString());
            final int precision =
                field['add'] != null && field['add'].containsKey('precision')
                    ? field['add']['precision']
                    : 2;
            tabfields[zone].add(
              Padding(
                padding: fieldPadding,
                child: TextFormField(
                  enabled: field['enabled'],
                  keyboardType: TextInputType.numberWithOptions(signed: false),
                  inputFormatters: [DecimalFormatter(precision: precision)],
                  controller: fieldcontroller[field['name']],
                  validator: (value) => validator(field['name']),
                  decoration: InputDecoration(labelText: field['label']),
                ),
              ),
            );
          } else if (field['type'] == 'date') {
            if (!fieldcontroller.containsKey(field['name'])) {
              fieldcontroller[field['name']] = TextEditingController(
                  text:
                      field['value'] == null ? '' : field['value'].toString());
            }
            tabfields[zone].add(
              Stack(
                children: <Widget>[
                  Padding(
                    padding: fieldPadding,
                    child: TextFormField(
                      enabled: field['enabled'],
                      readOnly: true,
                      controller: fieldcontroller[field['name']],
                      validator: (value) => validator(field['name']),
                      decoration: InputDecoration(labelText: field['label']),
                      onTap: () async {
                        fieldcontroller[field['name']].text =
                            await Utils.selectDate(
                                context, fieldcontroller[field['name']].text);
                      },
                    ),
                  ),
                  field['enabled']
                      ? Positioned(
                          right: 0,
                          top: -2,
                          child: IconButton(
                            onPressed: () {
                              fieldcontroller[field['name']].clear();
                            },
                            icon: Icon(Icons.clear),
                          ),
                        )
                      : Container()
                ],
              ),
            );
          } else if (field['type'] == 'datetime') {
            if (!fieldcontroller.containsKey(field['name'])) {
              fieldcontroller[field['name']] = TextEditingController(
                  text:
                      field['value'] == null ? '' : field['value'].toString());
            }
            tabfields[zone].add(
              Stack(
                children: <Widget>[
                  Padding(
                    padding: fieldPadding,
                    child: TextFormField(
                      enabled: field['enabled'],
                      readOnly: true,
                      controller: fieldcontroller[field['name']],
                      validator: (value) => validator(field['name']),
                      decoration: InputDecoration(labelText: field['label']),
                      onTap: () async {
                        final date = await Utils.selectDate(
                            context, fieldcontroller[field['name']].text);
                        if (date == null) return;
                        final hour = await Utils.selectTime(
                            context, fieldcontroller[field['name']].text);
                        if (hour == null) return;
                        fieldcontroller[field['name']].text = '$date $hour';
                      },
                    ),
                  ),
                  field['enabled']
                      ? Positioned(
                          right: 0,
                          top: -2,
                          child: IconButton(
                            onPressed: () {
                              fieldcontroller[field['name']].clear();
                            },
                            icon: Icon(Icons.clear),
                          ),
                        )
                      : Container()
                ],
              ),
            );
          } else if (field['type'] == 'file') {
            fieldcontroller[field['name']] =
                field['value'] == null ? [] : jsonDecode(field['value']);
            tabfields[zone].add(
              Padding(
                padding: fieldPadding,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: CarouselSlider(
                          height: 150.0,
                          enlargeCenterPage: true,
                          enableInfiniteScroll: false,
                          onRemove: (index) {
                            fieldcontroller[field['name']].removeAt(index);
                          },
                          onAdd: (item) {
                            fieldcontroller[field['name']].add(item);
                          },
                          items: fieldcontroller[field['name']],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 25,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  field['label'],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else if (field['type'] == 'integer') {
            if (!fieldcontroller.containsKey(field['name']))
              fieldcontroller[field['name']] = TextEditingController(
                  text:
                      field['value'] == null ? '' : field['value'].toString());
            tabfields[zone].add(
              Padding(
                padding: fieldPadding,
                child: TextFormField(
                  enabled: field['enabled'],
                  keyboardType: TextInputType.number,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  controller: fieldcontroller[field['name']],
                  validator: (value) => validator(field['name']),
                  decoration: InputDecoration(labelText: field['label']),
                ),
              ),
            );
          } else if (field['type'] == 'text') {
            if (!fieldcontroller.containsKey(field['name']))
              fieldcontroller[field['name']] = TextEditingController(
                  text:
                      field['value'] == null ? '' : field['value'].toString());
            tabfields[zone].add(
              Padding(
                padding: fieldPadding,
                child: TextFormField(
                  enabled: field['enabled'],
                  controller: fieldcontroller[field['name']],
                  validator: (value) => validator(field['name']),
                  decoration: InputDecoration(labelText: field['label']),
                ),
              ),
            );
          } else if (field['type'] == 'textarea') {
            if (!fieldcontroller.containsKey(field['name']))
              fieldcontroller[field['name']] = TextEditingController(
                  text:
                      field['value'] == null ? '' : field['value'].toString());
            tabfields[zone].add(
              Padding(
                padding: fieldPadding,
                child: TextFormField(
                  enabled: field['enabled'],
                  controller: fieldcontroller[field['name']],
                  validator: (value) => validator(field['name']),
                  decoration: InputDecoration(labelText: field['label']),
                  maxLines: 5,
                ),
              ),
            );
          } else if (field['type'] == 'virtual') {
            tabfields[zone].add(
              Padding(
                padding: fieldPadding,
                child: TextFormField(
                  initialValue:
                      field['value'] == null ? '' : field['value'].toString(),
                  enabled: false,
                  decoration: InputDecoration(labelText: field['label']),
                ),
              ),
            );
          }
        }
        tabscontainer.add(
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey[400],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            margin: EdgeInsets.all(4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: tabfields[zone],
              ),
            ),
          ),
        );
      }
    }
  }

  void save() async {
    Map body = {};
    conf['fields'].forEach((String key, value) {
      if (value['enabled']) {
        if (value['type'] == 'boolean') {
          body[key] = fieldcontroller[key].text == 'Sim' ? 'true' : 'false';
        } else if (value['type'] == 'file') {
          body[key] = jsonEncode(fieldcontroller[key]);
        } else if ([
              'autocomplete',
              'date',
              'datetime',
              'decimal',
              'integer',
              'text',
              'textarea'
            ].indexOf(value['type']) >=
            0) {
          body[key] = fieldcontroller[key].text;
        }
      }
    });
    print(body);
    lastSaveRequest = await Utils.requestPost(
        'v/${widget.viewurl}/${widget.id}' +
            (widget.parent == null ? '' : '?parent=${widget.parent}'),
        body);
    if (lastSaveRequest['success']) {
      Navigator.pop(context, lastSaveRequest);
    } else {
      _formKey.currentState.validate();
      Utils.showSnackBarByKey(
          _scaffoldKey, lastSaveRequest['msg'] ?? 'Oops', Colors.red);
    }
  }

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  @override
  void dispose() {
    fieldcontroller.forEach((key, value) {
      if (fieldcontroller[key] is TextEditingController) {
        fieldcontroller[key].dispose();
      }
    });
    conf = {};
    tabs = [];
    tabfields = {};
    tabscontainer = [];
    fieldcontroller = {};
    lastSaveRequest = {};
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wTitle = RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: ' (${widget.id})',
            style: TextStyle(fontSize: 10),
          ),
        ],
      ),
    );

    if (tabs.length == 0) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: conf.containsKey('success') && conf['success']
              ? Container()
              : CircularProgressIndicator(),
        ),
      );
    } else if (tabs.length == 1) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: wTitle,
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () => save(),
              child: Text("Salvar"),
              shape: CircleBorder(
                side: BorderSide(color: Colors.transparent),
              ),
            )
          ],
        ),
        body: Form(
          key: _formKey,
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
            margin: EdgeInsets.all(4),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: tabfields[conf['zone'][0]],
              ),
            ),
          ),
        ),
      );
    } else {
      return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: wTitle,
            actions: <Widget>[
              FlatButton(
                textColor: Colors.white,
                onPressed: () => save(),
                child: Text("Salvar"),
                shape: CircleBorder(
                  side: BorderSide(color: Colors.transparent),
                ),
              ),
            ],
            bottom: TabBar(
              isScrollable: tabs.length > 3,
              tabs: tabs,
            ),
          ),
          body: Form(
            key: _formKey,
            child: TabBarView(children: tabscontainer),
          ),
        ),
      );
    }
  }
}
