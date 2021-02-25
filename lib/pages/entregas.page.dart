import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobidata_dtc/helpers/database_helper.dart';
import 'package:mobidata_dtc/widgets/loading.widget.dart';

class EntregasPage extends StatefulWidget {
  @override
  _EntregasState createState() => _EntregasState();
}

class _EntregasState extends State {
  DatabaseHelper db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    db.getConfig().then((config) {});
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(8),
            child: Column(children: <Widget>[new Text("Selecione")]),
          )
        ],
      ),
    );
  }
}
