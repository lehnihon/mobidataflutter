import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobidata_dtc/classes/baixa.class.dart';
import 'package:mobidata_dtc/classes/configuracoes.class.dart';
import 'package:mobidata_dtc/classes/entrega.class.dart';
import 'dart:convert';

import 'package:mobidata_dtc/helpers/database_helper.dart';
import 'package:mobidata_dtc/helpers/database_helper_baixa.dart';
import 'package:mobidata_dtc/widgets/loading.widget.dart';

class EntregasPage extends StatefulWidget {
  @override
  _EntregasState createState() => _EntregasState();
}

class _EntregasState extends State {
  DatabaseHelper db = DatabaseHelper();
  DatabaseHelperBaixa dbb = DatabaseHelperBaixa();
  Configuracoes _config;
  Position _position;
  Baixa _baixa;
  List<Entrega> _entregas;
  String _listas;
  int _enviando;
  var _loading = true;
  final snackBar = SnackBar(content: Text('Cadastre seu ID em configurações!'));
  final snackBarB = SnackBar(
      content: Text(
          'Ligue seu GPS e reinicie o App, ele pode não estar funcionando'));

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future initData() async {
    getPosition();
    _enviando = 0;
    _config = await db.getConfig();
    if (_config == null || _config.id == null || _config.id == '') {
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
      _getEntregas();
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _getEntregas() async {
    try {
      final response = await http.get(
          'http://34.200.50.59/mobidataapi/base_novo_entregas_080321.php?id=' +
              _config.id);
      if (response.body == 'false') {
        setState(() {
          this._loading = false;
        });
      } else {
        var jsondecode = json.decode(response.body);
        Iterable list = jsondecode['notas'];
        _listas = jsondecode['listas'];
        setState(() {
          _entregas = list.map((model) => Entrega.fromJson(model)).toList();
        });
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

  Future getPosition() async {
    bool serviceEnabled = await Geolocator().isLocationServiceEnabled();
    if (serviceEnabled) {
      _position = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    } else {
      Scaffold.of(context).showSnackBar(snackBarB);
    }
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
    setState(() {
      _enviando--;
    });
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
      (_position == null) ? '' : _position.latitude.toString(),
      (_position == null) ? '' : _position.longitude.toString(),
      _config.id,
    );

    setState(() {
      _enviando++;
      _entregas.removeAt(index);
    });

    sendData(_baixa);
  }

  @override
  Widget build(BuildContext context) {
    return (_loading)
        ? Loading()
        : Container(
            child: Column(children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                width: double.infinity,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black12)),
                child: Wrap(children: <Widget>[
                  Text(
                    (_entregas == null)
                        ? "Nenhuma nota disponível"
                        : "${_entregas.length} Total - ${_enviando} Enviando \n${_listas}",
                    style: TextStyle(
                        fontSize: 18, color: Theme.of(context).primaryColor),
                  )
                ]),
              ),
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: (_entregas == null) ? 0 : _entregas.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(
                          '${_entregas[index].idexterno}',
                        ),
                        trailing: Icon(
                          Icons.send,
                          color: Theme.of(context).primaryColor,
                        ),
                        onTap: () {
                          enviaNota(_entregas[index].idexterno, index);
                        },
                      );
                    }),
              ),
            ]),
          );
  }
}
