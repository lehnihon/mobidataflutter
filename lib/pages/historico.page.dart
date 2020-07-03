import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobidata_dtc/classes/historico.class.dart';
import 'package:mobidata_dtc/helpers/database_helper.dart';
import 'package:mobidata_dtc/widgets/loading.widget.dart';

class HistoricoPage extends StatefulWidget {
  @override
  _HistoricoState createState() => _HistoricoState();
}

class _HistoricoState extends State {
  List<Historico> historico;
  DatabaseHelper db = DatabaseHelper();
  String _id;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    db.getConfig().then((config) {
      _id = config.id;
      _getHistorico();
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _getHistorico() async {
    final response =
        await http.get('http://34.200.50.59/mobidataapi/baixa.php?id=$_id');
    if (response.body == 'false') {
      setState(() {
        this._loading = false;
      });
    } else {
      setState(() {
        Iterable list = json.decode(response.body);
        historico = list.map((model) => Historico.fromJson(model)).toList();
        this._loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_loading)
        ? Loading()
        : Container(
            child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: (historico == null) ? 0 : historico.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.home),
                      title: Text('${historico[index].nota}'),
                      subtitle: Text(
                          '${historico[index].enderecoentrega}\n${historico[index].motivo}'),
                      isThreeLine: true,
                    ),
                  );
                }),
          );
  }
}
