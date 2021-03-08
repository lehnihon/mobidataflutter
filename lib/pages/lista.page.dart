import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobidata_dtc/classes/baixa.class.dart';
import 'package:mobidata_dtc/classes/configuracoes.class.dart';
import 'package:mobidata_dtc/classes/lista.class.dart';
import 'package:mobidata_dtc/classes/entrega.class.dart';
import 'dart:convert';

import 'package:mobidata_dtc/helpers/database_helper.dart';
import 'package:mobidata_dtc/widgets/loading.widget.dart';

class ListaPage extends StatefulWidget {
  @override
  _ListaState createState() => _ListaState();
}

class _ListaState extends State {
  DatabaseHelper db = DatabaseHelper();
  Configuracoes _config;
  Baixa _baixa;
  Position _position;
  var _loading = true;
  List<Lista> _listas;
  List<Entrega> _entregas;
  final snackBar = SnackBar(content: Text('Lista aceita!'));
  final snackBarB =
      SnackBar(content: Text('Cadastre seu ID em configurações!'));

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future initData() async {
    _config = await db.getConfig();
    if (_config == null || _config.id == null || _config.id == '') {
      Scaffold.of(context).showSnackBar(snackBarB);
    } else {
      _getLista();
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _getLista() async {
    try {
      final response = await http
          .get('http://34.200.50.59/mobidataapi/base_novo_listas.php');
      if (response.body == 'false') {
        setState(() {
          this._loading = false;
        });
      } else {
        Iterable list = json.decode(response.body);
        setState(() {
          _listas = list.map((model) => Lista.fromJson(model)).toList();
        });
        await Future.delayed(Duration(seconds: 1));
        setState(() {
          this._loading = false;
        });
      }
    } catch (e) {
      setState(() {
        this._loading = false;
      });
    }
  }

  Future<void> _showMyDialog(numlista) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aceita a lista: $numlista?'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Ao aceitar esta lista será enviada para aprovação.'),
                Text(
                    'Aguarde a aprovação, verifique se seu ID está cadastrado corretamente.')
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Aceitar'),
              onPressed: () {
                aceitarLista(numlista);
              },
            ),
          ],
        );
      },
    );
  }

  void aceitarLista(numlista) async {
    try {
      final response = await http.post(
        'http://34.200.50.59/mobidataapi/base_novo_listas.php',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'id': _config.id,
          'numlista': numlista,
        }),
      );
      Scaffold.of(context).showSnackBar(snackBar);
      Navigator.of(context).pop();
    } catch (e) {}
    _getLista();
  }

  @override
  Widget build(BuildContext context) {
    return (_loading)
        ? Loading()
        : Container(
            child: Container(
              child: (_listas != null && _listas.length > 0)
                  ? ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: (_listas == null) ? 0 : _listas.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                              'Lista: ${_listas[index].numlista} ',
                            ),
                            subtitle: Text('Setor: ${_listas[index].setor}'),
                            trailing: Icon(
                              Icons.add,
                              color: Theme.of(context).primaryColor,
                            ),
                            onTap: () {
                              _showMyDialog(_listas[index].numlista);
                            },
                          ),
                        );
                      })
                  : Column(children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12)),
                        child: Row(children: <Widget>[
                          Text(
                            "Nenhuma lista disponível",
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor),
                          )
                        ]),
                      ),
                    ]),
            ),
          );
  }
}
