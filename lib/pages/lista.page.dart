import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobidata_dtc/classes/baixa.class.dart';
import 'package:mobidata_dtc/classes/configuracoes.class.dart';
import 'package:mobidata_dtc/classes/lista.class.dart';
import 'dart:convert';

import 'package:mobidata_dtc/helpers/database_helper.dart';
import 'package:mobidata_dtc/helpers/database_helper_baixa.dart';
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
  List<Lista> _lista;
  var _buttonsEnabled = true;
  DatabaseHelperBaixa dbb = DatabaseHelperBaixa();
  final snackBar = SnackBar(content: Text('Lista aceita!'));

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future initData() async {
    getPosition();
    _config = await db.getConfig();
    _getLista();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _getLista() async {
    try {
      final response = await http.get(
          'http://34.200.50.59/mobidataapi/base_novo.php?id=' + _config.id);
      if (response.body == 'false') {
        setState(() {
          this._loading = false;
        });
      } else {
        Iterable list = json.decode(response.body);
        setState(() {
          this._loading = false;
          _lista = list.map((model) => Lista.fromJson(model)).toList();
        });
      }
    } catch (e) {
      setState(() {
        this._loading = false;
      });
    }
  }

  Future getPosition() async {
    _position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future sendData(baixa) async {
    try {
      final response = await http.post(
        'http://34.200.50.59/mobidataapi/baixa_novo.php',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'image': baixa.foto,
          'nota': baixa.nota,
          'status': baixa.status,
          'data': baixa.data,
          'hora': baixa.hora,
          'latitude': baixa.latitude,
          'longitude': baixa.longitude,
          'userid': baixa.userid,
        }),
      );
    } catch (e) {
      dbb.insertBaixa(_baixa);
    }
  }

  void enviaNota(nota, index) async {
    var dt = DateTime.now();
    var formatData = DateFormat("yyyy-MM-dd");
    String data = formatData.format(dt);
    var formatHora = DateFormat("HH:mm:ss");
    String hora = formatHora.format(dt);

    _baixa = new Baixa(
      nota,
      '9',
      '',
      data,
      hora,
      _position.latitude.toString(),
      _position.longitude.toString(),
      _config.id,
    );

    setState(() {
      _lista.removeAt(index);
    });

    sendData(_baixa);
  }

  void aceitarLista(numlista) async {
    setState(() {
      _buttonsEnabled = false;
    });

    try {
      final response = await http.post(
        'http://34.200.50.59/mobidataapi/base_novo.php',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'id': _config.id,
          'numlista': numlista,
        }),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    } catch (e) {}
    setState(() {
      _buttonsEnabled = true;
    });
    _getLista();
  }

  @override
  Widget build(BuildContext context) {
    return (_loading)
        ? Loading()
        : Container(
            child: (_lista != null &&
                    _lista.length == 1 &&
                    _lista[0].idexterno == null)
                ? Column(children: <Widget>[
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Lista " + _lista[0].numlista + " disponível",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: _buttonsEnabled
                          ? () => aceitarLista(_lista[0].numlista)
                          : null,
                      child: const Text('Aceitar Lista',
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ])
                : Column(children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12)),
                      child: Row(children: <Widget>[
                        Text(
                          (_lista == null)
                              ? "Nenhuma nota disponível"
                              : "Quantidade: ${_lista.length}",
                          style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).primaryColor),
                        )
                      ]),
                    ),
                    Expanded(
                      child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: (_lista == null) ? 0 : _lista.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ListTile(
                              title: Text(
                                '${_lista[index].idexterno}',
                              ),
                              trailing: Icon(
                                Icons.send,
                                color: Theme.of(context).primaryColor,
                              ),
                              enabled: _buttonsEnabled,
                              onTap: () {
                                enviaNota(_lista[index].idexterno, index);
                              },
                            );
                          }),
                    )
                  ]),
          );
  }
}
