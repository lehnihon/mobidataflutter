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
  bool bdinitial = false;

  @override
  void initState() {
    super.initState();
    db.getConfig().then((config) {
      setState(() {
        if (config == null) {
          bdinitial = true;
        } else {
          _idController.text = config.id;
        }
      });
    });
  }

  void saveConfig(id) {
    Configuracoes config = new Configuracoes(id);
    if (bdinitial) {
      db.insertConfig(config);
    } else {
      db.updateConfig(config);
    }
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Builder(
        builder: (BuildContext innerContext) => Center(
          child: (_loading)
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
                          Scaffold.of(innerContext).showSnackBar(
                              SnackBar(content: Text('ID Salvo')));
                        },
                        child: const Text('Gravar',
                            style: TextStyle(fontSize: 20)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.redAccent)),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    "- Confirme se o ID está correto.\n\n- Em caso de dúvida sobre uma baixa, pesquisar na aba 'histórico' por lista ou código de barras.\n\n- Ao realizar baixa de entrega na aba 'listas' aguardar o envio das entregas.\n- Não enviar as entregas novamente, aguardar o envio.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                )
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
