import 'package:flutter/material.dart';
import 'package:mobidata_dtc/classes/configuracoes.class.dart';
import 'package:mobidata_dtc/helpers/database_helper.dart';
import 'package:mobidata_dtc/widgets/loading.widget.dart';

class ConfiguracoesPage extends StatefulWidget {
  @override
  _ConfiguracoesState createState() => _ConfiguracoesState();
}

class _ConfiguracoesState extends State<ConfiguracoesPage> {
  var _loading = false;
  DatabaseHelper db = DatabaseHelper();

  final _idController = TextEditingController();
  bool editado = false;

  @override
  void initState() {
    super.initState();

    db.getConfig().then((config) {
      _idController.text = config.id;
    });
  }

  void saveConfig(id) {
    Configuracoes config = new Configuracoes(id);
    db.updateConfig(config);
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_loading)
        ? Loading()
        : Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: "ID",
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                  onPressed: () {
                    saveConfig(_idController.text);
                  },
                  child: const Text('Gravar', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          );
  }
}