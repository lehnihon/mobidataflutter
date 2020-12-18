import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:io' as Io;
import 'package:http/http.dart' as http;
import 'package:mobidata_dtc/classes/baixa.class.dart';
import 'package:mobidata_dtc/classes/configuracoes.class.dart';
import 'package:mobidata_dtc/classes/status.class.dart';
import 'package:mobidata_dtc/helpers/database_helper.dart';
import 'package:mobidata_dtc/helpers/database_helper_baixa.dart';
import 'package:mobidata_dtc/widgets/form_status.widget.dart';
import 'package:mobidata_dtc/widgets/take_picture.widget.dart';
import 'package:workmanager/workmanager.dart';

DatabaseHelperBaixa dbb = DatabaseHelperBaixa();
DatabaseHelper db = DatabaseHelper();

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    await sendWorkData();
    print("Native called background task teste");
    return Future.value(true);
  });
}

Future sendWorkData() async {
  List lista;
  int i = 0;

  lista = await dbb.getBaixaLista();
  for (var baixa in lista) {
    if (i < 15) {
      await sendData(baixa);
    }
    i++;
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
    await dbb.deleteBaixa(baixa.id);
    return true;
  } catch (e) {
    return false;
  }
}

class BaixaPage extends StatefulWidget {
  @override
  _BaixaPageState createState() => _BaixaPageState();
}

class _BaixaPageState extends State<BaixaPage> {
  Status _status;
  Position _position;
  Baixa _baixa;
  Configuracoes _config;
  List baixaLista;
  bool _buttonsEnabled = true;
  final _notaController = TextEditingController();
  final snackBar = SnackBar(content: Text('Nota salva!'));
  final snackBarB = SnackBar(content: Text('Nota enviada!'));
  final String imagePath = "";

  @override
  void initState() {
    super.initState();
    getListBaixa();
    initData();
    periodicWork();
  }

  void periodicWork() {
    Workmanager.initialize(callbackDispatcher, isInDebugMode: false);
    Workmanager.registerPeriodicTask(
      "2",
      "periodicTask",
      initialDelay: Duration(seconds: 10),
    );
  }

  void initWork() {
    Workmanager.registerOneOffTask(
      "1",
      "simpleTask",
      initialDelay: Duration(seconds: 10),
    );
  }

  void getListBaixa() {
    dbb.getBaixaLista().then((baixadb) {
      setState(() {
        baixaLista = baixadb;
      });
    });
  }

  Future initData() async {
    getPosition();
    _config = await db.getConfig();
  }

  Future takePicture() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    String img64;
    try {
      final path = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TakePictureScreen(
            camera: firstCamera,
          ),
        ),
      );
      final bytes = Io.File(path).readAsBytesSync();
      img64 = base64Encode(bytes);
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
    return img64;
  }

  void saveBaixa(nota, status) async {
    setState(() {
      _buttonsEnabled = false;
    });

    var dt = DateTime.now();
    var formatData = DateFormat("yyyy-MM-dd");
    String data = formatData.format(dt);
    var formatHora = DateFormat("HH:mm:ss");
    String hora = formatHora.format(dt);
    String foto = "";

    if (nota == '' || _status == null) {
      setState(() {
        _buttonsEnabled = true;
      });
      return;
    }

    if (status.tiraFoto == 'S') {
      foto = await takePicture();
    }

    _baixa = new Baixa(
      nota,
      status.id,
      foto,
      data,
      hora,
      _position.latitude.toString(),
      _position.longitude.toString(),
      _config.id,
    );

    _notaController.text = '';
    _status = null;

    setState(() {
      dbb.insertBaixa(_baixa);
      getListBaixa();
    });

    initWork();

    Scaffold.of(context).showSnackBar(snackBar);

    setState(() {
      _buttonsEnabled = true;
    });
  }

  Future getPosition() async {
    _position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
  }

  void alteraStatus(newValue) {
    setState(() {
      _status = newValue;
    });
  }

  void enviaNota(baixa) async {
    setState(() {
      _buttonsEnabled = false;
    });
    final send = await sendData(baixa);
    if (send) {
      Scaffold.of(context).showSnackBar(snackBarB);
      getListBaixa();
    }

    setState(() {
      _buttonsEnabled = true;
    });
  }

  Future<void> barCodeScan() async {
    var result = await BarcodeScanner.scan();
    this._notaController.text = result.rawContent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          TextFormField(
              controller: _notaController,
              decoration: InputDecoration(
                labelText: "Código da Nota",
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
          FormStatus(_status, alteraStatus),
          SizedBox(
            height: 10,
          ),
          RaisedButton(
            color: Theme.of(context).primaryColor,
            onPressed: _buttonsEnabled
                ? () => saveBaixa(_notaController.text, _status)
                : null,
            child: const Text('Gravar',
                style: TextStyle(fontSize: 20, color: Colors.white)),
          ),
          SizedBox(
            height: 10,
          ),
          const Divider(
            color: Colors.black26,
            height: 10,
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
          Container(
            padding: EdgeInsets.all(8),
            width: double.infinity,
            child: Row(children: <Widget>[
              Text(
                "Entregas em espera",
                style: TextStyle(fontSize: 14),
              ),
              Icon(Icons.arrow_downward),
              Text(
                "(envio automático)",
                style: TextStyle(fontSize: 14),
              ),
            ]),
          ),
          const Divider(
            color: Colors.black26,
            height: 10,
            thickness: 1,
            indent: 0,
            endIndent: 0,
          ),
          Expanded(
            child: Container(
              child: ListView.builder(
                  itemCount: (baixaLista == null) ? 0 : baixaLista.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text('${baixaLista[index].nota}'),
                      trailing: Icon(
                        Icons.send,
                        color: Theme.of(context).primaryColor,
                      ),
                      enabled: _buttonsEnabled,
                      onTap: () {
                        enviaNota(baixaLista[index]);
                      },
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
