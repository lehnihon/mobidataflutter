import 'package:barcode_scan/barcode_scan.dart';
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
  var _loading = false;
  String dropdownValue = "Encomendas";
  final _notaController = TextEditingController();
  bool _buttonsEnabled = true;

  @override
  void initState() {
    super.initState();
    db.getConfig().then((config) {
      _id = config.id;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<void> barCodeScan() async {
    var result = await BarcodeScanner.scan();
    this._notaController.text = result.rawContent;
  }

  void buscarItens(nota) {
    setState(() {
      this._loading = true;
    });
    _getHistorico(nota);
  }

  _getHistorico(nota) async {
    print(this.dropdownValue);
    if (this.dropdownValue == 'Encomendas') {
      try {
        final response = await http.get(
            'http://34.200.50.59/mobidataapi/baixa_novo.php?id=$_id&nota=$nota');
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
      } catch (e) {
        setState(() {
          this._loading = false;
        });
      }
    } else {
      try {
        final response = await http.get(
            'http://34.200.50.59/mobidataapi/baixa_novo.php?id=$_id&nota=$nota&lista=1');
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
      } catch (e) {
        setState(() {
          this._loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_loading)
        ? Loading()
        : Container(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8),
                  child: Column(children: <Widget>[
                    DropdownButton<String>(
                      value: dropdownValue,
                      hint: new Text("Selecione"),
                      isExpanded: true,
                      elevation: 16,
                      style:
                          new TextStyle(color: Colors.grey[600], fontSize: 16),
                      underline: Container(
                        height: 1,
                        color: Colors.grey[500],
                      ),
                      onChanged: (String newValue) {
                        setState(() {
                          dropdownValue = newValue;
                        });
                      },
                      items: <String>['Encomendas', 'Listas']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    TextFormField(
                        controller: _notaController,
                        decoration: InputDecoration(
                          labelText: "Código",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.developer_mode),
                            onPressed: () {
                              barCodeScan();
                            },
                          ),
                        ),
                        keyboardType: TextInputType.number),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      color: Theme.of(context).primaryColor,
                      onPressed: _buttonsEnabled
                          ? () => buscarItens(_notaController.text)
                          : null,
                      child: const Text('Buscar',
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                    ),
                  ]),
                ),
                Expanded(
                  child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: (historico == null) ? 0 : historico.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.home),
                            title: Text('${historico[index].nota}'),
                            subtitle: Text(
                                '${historico[index].nomeentrega}\n${historico[index].enderecoentrega}'),
                            isThreeLine: true,
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
  }
}
